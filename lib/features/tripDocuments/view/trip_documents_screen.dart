import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tranzoop_mobile_app/features/tripDocuments/view/view_documents_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/tripDocuments/viewmodel/trip_document_viewmodel.dart';

class TripDocumentsScreen extends StatefulWidget {
  final TripData trip;
  const TripDocumentsScreen({super.key, required this.trip});

  @override
  State<TripDocumentsScreen> createState() => _TripDocumentsScreenState();
}

class _TripDocumentsScreenState extends State<TripDocumentsScreen> {
  BasicWidgets basicWidgets = BasicWidgets();
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripDocumentViewModel>().fetchDocuments(widget.trip.id);
    });
  }

  Future<void> downloadBill(String docUrl) async {
    try {
      final dio = Dio();

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath =
          "${directory.path}/document_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await dio.download(
        docUrl,
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
    final vm = context.watch<TripDocumentViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: "Trip Documents",
      ),
      body: vm.isLoading
          ? Center(child: basicWidgets.loading())
          : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vm.documents.length,
          itemBuilder: (context, index) {
            final doc = vm.documents[index];
            return docCard(
                doc.documentType,
                DateFormat("dd MMM yyyy, hh:mm a").format(doc.createdAt),
                doc.fileUrl
            );
          }),
    );
  }

  Widget docCard(
      String title,
      String date,
      String docUrl
      ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize:
                          viewUtil.isTablet ? 22 : 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:
                          viewUtil.isTablet ? 17 : 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewDocumentsScreen(docUrl: docUrl,docType: title),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.remove_red_eye_outlined,
                      color: AppColors.btnColor,
                    ),
                    label: Text(
                      "View",
                      style: TextStyle(
                        color: AppColors.btnColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.btnColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => downloadBill(docUrl),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Download",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.btnColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
