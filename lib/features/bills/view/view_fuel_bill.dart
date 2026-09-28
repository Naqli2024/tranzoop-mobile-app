
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';

class ViewFuelBill extends StatefulWidget {
  final String fuelBill;

  const ViewFuelBill({
    super.key,
    required this.fuelBill,
  });

  @override
  State<ViewFuelBill> createState() => _ViewFuelBillState();
}

class _ViewFuelBillState extends State<ViewFuelBill> {
  final BasicWidgets basicWidgets = BasicWidgets();
  bool downloading = false;

  Future<void> downloadBill() async {
    try {
      final dio = Dio();

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath =
          "${directory.path}/fuel_bill_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await dio.download(
        widget.fuelBill,
        filePath,
      );

      basicWidgets.success(
        context,
        "Downloaded Successfully",
      );

    } catch (e) {
      basicWidgets.error(
        context,
        "Download failed",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: 'Bill',
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.btnColor,
        foregroundColor: Colors.white,
        onPressed: downloading ? null : downloadBill,
        icon: downloading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.download),
        label: Text(
          downloading ? "Downloading..." : "Download",
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Image.network(
                widget.fuelBill,
                fit: BoxFit.contain,
                loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                    ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: basicWidgets.loading(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text("Unable to load image"),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}