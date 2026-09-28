import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/features/bills/model/trip_expense_modal.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/trip_expenses_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';

class UpdateLoadingUnloadingBill extends StatefulWidget {
  final CurrentTrip trip;
  final TripExpense expenseBill;
  const UpdateLoadingUnloadingBill({super.key, required this.trip, required this.expenseBill});

  @override
  State<UpdateLoadingUnloadingBill> createState() => _UpdateLoadingUnloadingBillState();
}

class _UpdateLoadingUnloadingBillState extends State<UpdateLoadingUnloadingBill> {
  BasicWidgets basicWidgets = BasicWidgets();
  final TextEditingController amountController = TextEditingController();
  File? bill;
  final ImagePicker picker = ImagePicker();
  String? networkBill;

  @override
  void initState() {
    super.initState();
      final bill = widget.expenseBill;
      amountController.text = bill.amount.toString();
      if (bill.billUrl.isNotEmpty) {
        networkBill = bill.billUrl;
      }
    }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> updateBill() async {
    final request = LoadingUnloadingExpenseRequest(
      bill: bill,
      expenseType: widget.expenseBill.expenseType,
      amount: double.parse(amountController.text),
    );

    final vm = context.read<TripExpenseViewModel>();

    final success = await vm.updateExpense(
      expenseId: widget.expenseBill.id,
      request: request,
    );

    if (!mounted) return;

    if (success) {
      basicWidgets.success(context, vm.successMessage);
      context.read<TripExpenseViewModel>().fetchExpenses(widget.trip.id);
      Navigator.pop(context, true);
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripExpenseViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: '${widget.expenseBill.expenseType} Bill',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            uploadBillWidget(),
            SizedBox(height: 10),
            basicWidgets.buildTextField(
              'Amount',
              amountController,
              context: context,
            ),
            SizedBox(height: 30),
            basicWidgets.buildCommonButton(
              context,
              "Update Bill",
              updateBill,
              isLoading: vm.isLoading,
            ),
          ],
        ),
      ),
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
        bill = file;
      });
    }
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
            child: (bill == null && networkBill == null)
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
                        amountController.clear();
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
