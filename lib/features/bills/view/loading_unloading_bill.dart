import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/features/bills/view/update_loading_unloading_bill.dart';
import 'package:bizoop_driver_app/features/bills/view/upload_fuel_entry.dart';
import 'package:bizoop_driver_app/features/bills/view/view_fuel_bill.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/fuel_viewmodel.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/trip_expenses_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';

class LoadingUnloadingBill extends StatefulWidget {
  final CurrentTrip trip;
  const LoadingUnloadingBill({super.key, required this.trip});

  @override
  State<LoadingUnloadingBill> createState() => _LoadingUnloadingBillState();
}

class _LoadingUnloadingBillState extends State<LoadingUnloadingBill> {
  BasicWidgets basicWidgets = BasicWidgets();
  final TextEditingController amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<TripExpenseViewModel>().fetchExpenses(widget.trip.id);
    });
  }

  Future<void> _showAddPettyCashSheet() async {
    amountController.clear();

    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final vm = context.watch<TripExpenseViewModel>();
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.currency_rupee_rounded,
                    color: Colors.purple,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Add Petty Cash",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  basicWidgets.buildTextField(
                    "Amount *",
                    amountController,
                    context: context,
                    isNumber: true,
                  ),
                  const SizedBox(height: 25),
                  basicWidgets.buildCommonButton(
                    context,
                    "Submit",
                        () async {
                      if (amountController.text.trim().isEmpty) {
                        basicWidgets.error(context, "Please enter amount");
                        return;
                      }
                      final expenseVm = context.read<TripExpenseViewModel>();
                      final success = await expenseVm.addExpense(
                        tripId: widget.trip.id,
                        request: LoadingUnloadingExpenseRequest(
                          expenseType: "PC",
                          amount: double.parse(amountController.text.trim()),
                        ),
                      );

                      if (!mounted) return;
                      Navigator.pop(sheetContext);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Petty cash entry added")),
                        );
                      } else {
                        basicWidgets.error(context, expenseVm.errorMessage);
                      }
                    },
                    isLoading: vm.isLoading,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripExpenseViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: 'Loading & Unloading Bills',
        onBackPressed: () {
          Navigator.pop(context);
        }
      ),
      body: vm.isLoading
          ? Center(child: basicWidgets.loading())
          : vm.expenses == null || vm.expenses!.data.isEmpty
          ? Center(
        child: Text("No Bills Found"),
      )
          : ListView.builder(
        itemCount: vm.expenses!.data.length,
        itemBuilder: (_, index) {
          final bill = vm.expenses!.data[index];
          return Container(
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
            margin: const EdgeInsets.all(10),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.swap_vert_circle,
                  color: Colors.orange,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.expenseType),
                  SizedBox(height: 5),
                  Text("₹${bill.amount.toStringAsFixed(2)}",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500),),
                  SizedBox(height: 5),
                  Text(DateFormat("dd MMM yyyy, hh:mm a").format(bill.createdAt)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orange,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      tooltip: "View",
                      icon: const Icon(Icons.visibility_outlined),
                      color: Colors.orange,
                      iconSize: 17,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewFuelBill(
                              fuelBill: bill.billUrl,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      tooltip: "Edit",
                      icon: const Icon(Icons.edit_outlined),
                      color: Colors.blue,
                      iconSize: 17,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateLoadingUnloadingBill(
                              trip: widget.trip,
                              expenseBill: bill,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.btnColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add PC",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: _showAddPettyCashSheet,
      ),
    );
  }
}