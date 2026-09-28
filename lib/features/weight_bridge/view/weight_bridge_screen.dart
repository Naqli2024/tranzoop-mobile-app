import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/CommonSuccessScreen.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/trips/view/in_transit_screen.dart';
import 'package:bizoop_driver_app/features/trips/view/start_trip_screen.dart';
import 'package:bizoop_driver_app/features/weight_bridge/model/weight_bridge_model.dart';
import 'package:bizoop_driver_app/features/weight_bridge/viewmodel/weight_bridge_viewmodel.dart';

class WeightBridgeScreen extends StatefulWidget {
  final CurrentTrip trip;
  const WeightBridgeScreen({super.key, required this.trip});

  @override
  State<WeightBridgeScreen> createState() => _WeightBridgeScreenState();
}

class _WeightBridgeScreenState extends State<WeightBridgeScreen> {
  final TextEditingController grossWeightController = TextEditingController();
  final TextEditingController weighbridgeFeeController = TextEditingController();
  final TextEditingController uomController = TextEditingController();
  File? receiptImage;
  final ImagePicker picker = ImagePicker();
  final BasicWidgets basicWidgets = BasicWidgets();
  bool isScanning = false;
  String? networkBill;

  @override
  void dispose() {
    grossWeightController.dispose();
    weighbridgeFeeController.dispose();
    uomController.dispose();
    super.dispose();
  }

  Future<void> upload() async {
    final vm = context.read<WeighbridgeViewModel>();
    final request = WeighbridgeRequest(
      grossWeight: double.parse(grossWeightController.text.trim()),
      weighbridgeFee: double.parse(
        weighbridgeFeeController.text.trim(),
      ),
      uom: uomController.text.trim(),
      receipt: receiptImage,
    );

    final success = await vm.uploadWeighbridge(
      widget.trip.id,
      request,
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "Uploaded Successfully",
            message: vm.successMessage,
            buttonText: "Continue",
            nextStep: "Start your Trip",
            showNextStep: true,
            nextScreen: StartTripScreen(trip: widget.trip),
          ),
        ),
      );
    } else {
      basicWidgets.error(
        context,
        vm.errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<WeighbridgeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(context: context, title: 'Weight Bridge'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: Column(
          children: [
            uploadReceiptWidget(),
            basicWidgets.buildTextField('Gross Weight', grossWeightController, context: context,isNumber: true),
            SizedBox(height:10),
            basicWidgets.buildTextField('UOM', uomController, context: context),
            SizedBox(height:10),
            basicWidgets.buildTextField('Weight Bridge Amount', weighbridgeFeeController, context: context,isNumber: true),
            SizedBox(height:30),
            basicWidgets.buildCommonButton(context, 'Submit', () => upload(),isLoading: vm.isLoading)
          ],
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickBill(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickBill(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickBill(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      final file = File(image.path);

      setState(() {
        receiptImage = file;
        isScanning = true;
      });

      await _scanFuelBill(file);

      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> _scanFuelBill(File imageFile) async {
    try {
      debugPrint("Starting OCR...");

      final inputImage = InputImage.fromFile(imageFile);

      final recognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final result = await recognizer.processImage(inputImage);

      debugPrint("OCR Completed");
      debugPrint(result.text);

      _extractBillData(result.text);

      recognizer.close();
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrint(s.toString());
    }
  }


  String _fixDigits(String token) {
    return token
        .replaceAll(RegExp(r'[oO]'), '0')
        .replaceAll(RegExp(r'[iIl]'), '1');
  }

  String _normalizeDots(String token) => token.replaceAll(RegExp(r'\.+'), '.');

  String _normalizeUom(String raw) {
    final r = raw.toLowerCase();
    if (r.startsWith('kg') || r.startsWith('kilo')) return 'Kg';
    if (r == 'mt') return 'MT';
    if (r.startsWith('ton')) return 'Ton';
    return raw;
  }

  bool _looksLikeDateOrTime(String line) {
    return RegExp(r'\d{1,2}\s*/\s*\d{1,2}\s*/\s*\d{2,4}').hasMatch(line) ||
        RegExp(r'\d{1,2}\s*:\s*\d{2}\s*:\s*\d{2}').hasMatch(line);
  }
  bool _looksLikeFieldLabelNoise(String line) {
    return RegExp(r'field', caseSensitive: false).hasMatch(line);
  }

  String? _findNearKeyword(List<String> lines, RegExp keyword) {
    const loose = r'\d[\dOoIl]*(?:\.+[\dOoIl]+)?';
    for (int i = 0; i < lines.length; i++) {
      final kw = keyword.firstMatch(lines[i]);
      if (kw == null) continue;

      final same = RegExp(loose).firstMatch(lines[i].substring(kw.end));
      if (same != null) return _fixDigits(same.group(0)!);

      for (int j = i + 1; j <= i + 25 && j < lines.length; j++) {
        if (_looksLikeDateOrTime(lines[j]) || _looksLikeFieldLabelNoise(lines[j])) {
          continue;
        }
        final m = RegExp(loose).firstMatch(lines[j]);
        if (m != null) return _fixDigits(m.group(0)!);
      }
    }
    return null;
  }

  void _extractBillData(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    const loose = r'\d[\dOoIl]*(?:\.+[\dOoIl]+)?';
    const weightUnit =
        r'(?:[Kk][Gg][Ss]?|[Kk][Ii][Ll][Oo][Gg][Rr][Aa][Mm][Ss]?|[Tt][Oo][Nn][Nn]?[Ee]?[Ss]?|[Mm][Tt])';
    const rsPrefix = r'(?:[Rr][Ss]\.?|₹)';

    String? weight;
    String? weightUom;

    for (final line in lines) {
      if (!RegExp(r'gross', caseSensitive: false).hasMatch(line)) continue;
      final m = RegExp('($loose)\\s*($weightUnit)\\b').firstMatch(line);
      if (m != null) {
        weight = _fixDigits(m.group(1)!);
        weightUom = _normalizeUom(m.group(2)!);
        break;
      }
    }

    if (weight == null) {
      final weightLike = <MapEntry<String, String>>[];
      for (final line in lines) {
        final m = RegExp('($loose)\\s*($weightUnit)\\b').firstMatch(line);
        if (m != null) {
          weightLike.add(
              MapEntry(_fixDigits(m.group(1)!), _normalizeUom(m.group(2)!)));
        }
      }
      if (weightLike.length == 1) {
        weight = weightLike.first.key;
        weightUom = weightLike.first.value;
      } else if (weightLike.length > 1) {
        final winner = weightLike.reduce((a, b) {
          final av = double.tryParse(_normalizeDots(a.key)) ?? 0;
          final bv = double.tryParse(_normalizeDots(b.key)) ?? 0;
          return av >= bv ? a : b;
        });
        weight = winner.key;
        weightUom = winner.value;
      }
    }

    weight ??= _findNearKeyword(lines, RegExp(r'gross', caseSensitive: false));

    weight ??= _findNearKeyword(lines, RegExp(r'\bwt\b|weight', caseSensitive: false));

    if (weight != null) grossWeightController.text = _normalizeDots(weight);

    uomController.text = weightUom ?? (weight != null ? "Kg" : "");

    String? amount;

    for (final line in lines) {
      final kw = RegExp(r'(charge|fee|amount|total)', caseSensitive: false)
          .firstMatch(line);
      if (kw == null) continue;
      final m = RegExp(loose).firstMatch(line.substring(kw.end));
      if (m != null) {
        amount = _fixDigits(m.group(0)!);
        break;
      }
    }

    if (amount == null) {
      final rsMatches =
      RegExp('$rsPrefix\\s*($loose)').allMatches(text).toList();
      if (rsMatches.isNotEmpty) {
        double? best;
        double? fallbackMax;
        for (final m in rsMatches) {
          final value =
          double.tryParse(_normalizeDots(_fixDigits(m.group(1)!)));
          if (value == null) continue;
          if (fallbackMax == null || value > fallbackMax) fallbackMax = value;
          final start = (m.start - 20).clamp(0, text.length);
          final context = text.substring(start, m.start).toLowerCase();
          if (context.contains("charge") ||
              context.contains("fee") ||
              context.contains("amount") ||
              context.contains("total")) {
            best = value;
          }
        }
        final chosen = best ?? fallbackMax;
        if (chosen != null) amount = chosen.toString();
      }
    }

    if (amount == null) {
      final moneyLike = RegExp(loose)
          .allMatches(text)
          .map((m) => m.group(0)!)
          .where((s) => s.contains('.'))
          .toList();
      if (moneyLike.isNotEmpty) amount = _fixDigits(moneyLike.last);
    }

    amount ??= _findNearKeyword(
        lines, RegExp(r'charge|fee|amount|total', caseSensitive: false));

    if (amount != null) weighbridgeFeeController.text = _normalizeDots(amount);

    debugPrint("Weight   : ${grossWeightController.text}");
    debugPrint("UOM      : ${uomController.text}");
    debugPrint("Amount   : ${weighbridgeFeeController.text}");

    setState(() {});
  }

  Widget uploadReceiptWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text("Upload Receipt", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(),
            ),
            child: isScanning
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Reading receipt...",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
                : (receiptImage == null && networkBill == null)
                ? Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: const [
                  Icon(Icons.cloud_upload_outlined, size: 45),
                  SizedBox(height: 10),
                  Text("Tap to Upload Receipt"),
                ],
              ),
            )
                : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: receiptImage != null
                      ? Image.file(
                    receiptImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    networkBill!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;

                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        receiptImage = null;
                        networkBill = null;
                        grossWeightController.clear();
                        weighbridgeFeeController.clear();
                        uomController.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}