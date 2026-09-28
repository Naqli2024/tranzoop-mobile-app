import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/features/bills/model/fuel_bill_model.dart';
import 'package:bizoop_driver_app/features/bills/model/fuel_model.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/fuel_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';

class UploadFuelEntry extends StatefulWidget {
  final CurrentTrip trip;
  final FuelBill? fuelBill;
  const UploadFuelEntry({super.key, required this.trip, this.fuelBill});

  bool get isEdit => fuelBill != null;

  @override
  State<UploadFuelEntry> createState() => _UploadFuelEntryState();
}

class _UploadFuelEntryState extends State<UploadFuelEntry> {
  BasicWidgets basicWidgets = BasicWidgets();
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  File? bill;
  final ImagePicker picker = ImagePicker();
  final List<String> fuelTypes = ["Petrol", "Diesel", "CNG", "LPG", "Electric"];
  String? selectedFuelType;
  bool isScanning = false;
  String? networkBill;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      final bill = widget.fuelBill!;

      odometerController.text = bill.odometer.toString();
      quantityController.text = bill.quantity.toString();
      rateController.text = bill.rate.toString();

      selectedFuelType = bill.fuelType;

      if (bill.billUrl.isNotEmpty) {
        networkBill = bill.billUrl;
      }
    }
  }

  @override
  void dispose() {
    odometerController.dispose();
    quantityController.dispose();
    rateController.dispose();
    super.dispose();
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

  Future<void> updateFuelBill() async {
    final request = FuelRequest(
      odometer: double.parse(odometerController.text),
      fuelType: selectedFuelType!,
      quantity: double.parse(quantityController.text),
      rate: double.parse(rateController.text),
      bill: bill,
    );

    final vm = context.read<FuelViewModel>();

    final success = await vm.updateFuel(
      context,
      widget.fuelBill!.id,
      request,
    );

    if (!mounted) return;

    if (success) {
      basicWidgets.success(context, vm.successMessage);
      Navigator.pop(context, true);
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  Future<void> uploadFuelBill() async {
    if (odometerController.text.trim().isEmpty) {
      basicWidgets.error(context, "Enter Odometer");
      return;
    }

    if (quantityController.text.trim().isEmpty) {
      basicWidgets.error(context, "Enter Quantity");
      return;
    }

    if (rateController.text.trim().isEmpty) {
      basicWidgets.error(context, "Enter Rate");
      return;
    }
    if (bill == null) {
      basicWidgets.error(context, "Upload Fuel Bill");
      return;
    }

    final request = FuelRequest(
      odometer: double.parse(odometerController.text.trim()),
      fuelType: selectedFuelType!,
      quantity: double.parse(quantityController.text.trim()),
      rate: double.parse(rateController.text.trim()),
      bill: bill,
    );

    final vm = context.read<FuelViewModel>();

    final success = await vm.uploadFuel(context, widget.trip.id, request);

    if (!mounted) return;

    if (success) {
      basicWidgets.success(context, vm.successMessage);
      Navigator.pop(context);
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  Future<void> _pickBill(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      final file = File(image.path);

      setState(() {
        bill = file;
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

  bool _looksLikeDateOrTime(String line) {
    return RegExp(r'\d{1,2}\s*/\s*\d{1,2}\s*/\s*\d{2,4}').hasMatch(line) ||
        RegExp(r'\d{1,2}\s*:\s*\d{2}\s*:\s*\d{2}').hasMatch(line);
  }

  String? _findNearKeyword(
      List<String> lines,
      RegExp keyword, {
        bool requireDecimal = false,
      }) {
    const loose = r'\d[\dOoIl]*(?:\.+[\dOoIl]+)?';
    for (int i = 0; i < lines.length; i++) {
      final kw = keyword.firstMatch(lines[i]);
      if (kw == null) continue;

      final rest = lines[i].substring(kw.end);
      final same = RegExp(loose).firstMatch(rest);
      if (same != null && (!requireDecimal || same.group(0)!.contains('.'))) {
        return _fixDigits(same.group(0)!);
      }

      for (int j = i + 1; j <= i + 6 && j < lines.length; j++) {
        if (_looksLikeDateOrTime(lines[j])) continue;
        final m = RegExp(loose).firstMatch(lines[j]);
        if (m != null && (!requireDecimal || m.group(0)!.contains('.'))) {
          return _fixDigits(m.group(0)!);
        }
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

    const unit =
        r'(?:[Ll][Tt][Rr][Ss]?|[Ll][Ii][Tt][Rr][Ee][Ss]?|[Ll][Ii][Tt][Ee][Rr][Ss]?|[Ll][Tt]\.?|[Ii][Tt]\.?|[Ll])';
    const rsPrefix = r'(?:[Rr][Ss]\.?|₹)';

    if (RegExp(r'\bdiesel\b|\bhsd\b', caseSensitive: false).hasMatch(text)) {
      selectedFuelType = "Diesel";
    } else if (RegExp(r'\bpetrol\b|\bxg\b', caseSensitive: false)
        .hasMatch(text)) {
      selectedFuelType = "Petrol";
    } else if (RegExp(r'\bcng\b', caseSensitive: false).hasMatch(text)) {
      selectedFuelType = "CNG";
    } else if (RegExp(r'\blpg\b', caseSensitive: false).hasMatch(text)) {
      selectedFuelType = "LPG";
    } else if (RegExp(r'\belectric\b|\bev\b', caseSensitive: false)
        .hasMatch(text)) {
      selectedFuelType = "Electric";
    }

    String? qty;

    for (final line in lines) {
      final m = RegExp('($loose)\\s*$unit\\b').firstMatch(line);
      if (m != null) {
        qty = _fixDigits(m.group(1)!);
        break;
      }
    }

    // 2) Fallback: a number sitting a few lines below a Volume/Qty label.
    qty ??= _findNearKeyword(lines, RegExp(r'vol|qty|quantity', caseSensitive: false));

    if (qty != null) quantityController.text = _normalizeDots(qty);

    String? amount;

    for (final line in lines) {
      final kw = RegExp(r'(sale|amount|total)', caseSensitive: false)
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
          if (context.contains("sale") ||
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

    amount ??=
        _findNearKeyword(lines, RegExp(r'sale|amount|total', caseSensitive: false));

    String? rate = _findNearKeyword(lines, RegExp(r'rate', caseSensitive: false),
        requireDecimal: true);
    if (rate == null) {
      final rsNums = RegExp('$rsPrefix\\s*($loose)')
          .allMatches(text)
          .map((m) => _fixDigits(m.group(1)!))
          .toList();
      if (rsNums.isNotEmpty) rate = rsNums.first;
    }
    if (rate == null) {
      final decimals = RegExp(loose)
          .allMatches(text)
          .map((m) => m.group(0)!)
          .where((s) => s.contains('.'))
          .toList();
      if (decimals.isNotEmpty) rate = _fixDigits(decimals.first);
    }
    if (rate != null && amount != null && qty != null) {
      final amtVal = double.tryParse(_normalizeDots(amount));
      final qtyVal = double.tryParse(_normalizeDots(qty));
      final rateVal = double.tryParse(_normalizeDots(rate));
      if (amtVal != null && qtyVal != null && rateVal != null && qtyVal > 0) {
        final expected = amtVal / qtyVal;
        if (expected > 0 && (rateVal - expected).abs() > expected * 0.3) {
          if (rate.length > 1) {
            final trimmed = rate.substring(1);
            final trimmedVal = double.tryParse(_normalizeDots(trimmed));
            if (trimmedVal != null &&
                (trimmedVal - expected).abs() < expected * 0.15) {
              rate = trimmed;
            }
          }
        }
      }
    }

    if (rate != null) rateController.text = _normalizeDots(rate);
    debugPrint("FuelType : $selectedFuelType");
    debugPrint("Amount   : $amount (internal, not shown)");
    debugPrint("Qty      : ${quantityController.text}");
    debugPrint("Rate     : ${rateController.text}");

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FuelViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: 'Upload Fuel Bill',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            uploadBillWidget(),
            SizedBox(height: 10),
            basicWidgets.buildTextField(
              'Odometer',
              odometerController,
              context: context,
            ),
            SizedBox(height: 10),
            basicWidgets.buildCommonDropdown<String>(
              context: context,
              label: "Fuel Type",
              items: fuelTypes,
              value: selectedFuelType,
              itemLabel: (item) => item,
              onChanged: (value) {
                setState(() {
                  selectedFuelType = value;
                });
              },
            ),
            SizedBox(height: 10),
            basicWidgets.buildTextField(
              'Quantity (Litres)',
              quantityController,
              context: context,
            ),
            SizedBox(height: 10),
            basicWidgets.buildTextField(
              'Rate',
              rateController,
              context: context,
            ),
            SizedBox(height: 30),
            basicWidgets.buildCommonButton(
              context,
              widget.isEdit ? "Update Bill" : "Submit Bill",
              widget.isEdit ? updateFuelBill : uploadFuelBill,
              isLoading: vm.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget uploadBillWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text("Upload Fuel Bill", style: TextStyle(fontWeight: FontWeight.w500)),
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
                : (bill == null && networkBill == null)
                ? Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: const [
                  Icon(Icons.cloud_upload_outlined, size: 45),
                  SizedBox(height: 10),
                  Text("Tap to Capture Fuel Bill"),
                ],
              ),
            )
                : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: bill != null
                      ? Image.file(
                    bill!,
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
                        bill = null;
                        networkBill = null;

                        odometerController.clear();
                        quantityController.clear();
                        rateController.clear();
                        selectedFuelType = null;
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