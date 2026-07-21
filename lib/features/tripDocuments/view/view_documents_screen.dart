import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/features/tripDocuments/viewmodel/trip_document_viewmodel.dart';

class ViewDocumentsScreen extends StatefulWidget {
  final String docType;
  final String docUrl;

  const ViewDocumentsScreen({
    super.key,
    required this.docUrl, required this.docType,
  });

  @override
  State<ViewDocumentsScreen> createState() => _ViewDocumentsScreenState();
}

class _ViewDocumentsScreenState extends State<ViewDocumentsScreen> {
  final BasicWidgets basicWidgets = BasicWidgets();
  bool downloading = false;

  bool isImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp");
  }

  bool isPdf(String url) {
    return url.toLowerCase().contains(".pdf");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: widget.docType,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.red,
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
              child: buildDocument()
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDocument() {
    if (isImage(widget.docUrl)) {
      return Image.network(
        widget.docUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Center(child: basicWidgets.loading());
        },
        errorBuilder: (_, __, ___) {
          return const Center(
            child: Text("Unable to load image"),
          );
        },
      );
    }

    if (isPdf(widget.docUrl)) {
      return SfPdfViewer.network(widget.docUrl);
    }

    return const Center(
      child: Text("Unsupported file"),
    );
  }
}