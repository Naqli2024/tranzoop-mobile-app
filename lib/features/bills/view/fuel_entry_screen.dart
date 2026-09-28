import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/features/bills/view/upload_fuel_entry.dart';
import 'package:bizoop_driver_app/features/bills/view/view_fuel_bill.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/fuel_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';

class FuelEntryScreen extends StatefulWidget {
  final CurrentTrip trip;
  const FuelEntryScreen({super.key, required this.trip});

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  BasicWidgets basicWidgets = BasicWidgets();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<FuelViewModel>().getFuelBills(widget.trip.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FuelViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: 'Fuel Bill Entries',
      ),
      body: vm.isLoading
          ? Center(child: basicWidgets.loading())
          : vm.bills == null || vm.bills!.data.isEmpty
          ? const Center(
        child: Text("No Fuel Bills Found"),
      )
          : ListView.builder(
        itemCount: vm.bills!.data.length,
        itemBuilder: (_, index) {
          final bill = vm.bills!.data[index];
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
                child: const Icon(
                  Icons.local_gas_station,
                  color: Colors.orange,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${bill.quantity} L"),
                  SizedBox(height: 5),
                  Text("₹${bill.amount.toStringAsFixed(2)}",style: TextStyle(color: Colors.green,fontWeight: FontWeight.w500),),
                  SizedBox(height: 5),
                  Text(
                    DateFormat("dd MMM yyyy, hh:mm a")
                        .format(bill.createdAt),
                  ),
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
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UploadFuelEntry(
                              trip: widget.trip,
                              fuelBill: bill,
                            ),
                          ),
                        );

                        if (updated == true) {
                          context
                              .read<FuelViewModel>()
                              .getFuelBills(widget.trip.id);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UploadFuelEntry(trip: widget.trip),
            ),
          );
        },
        backgroundColor: AppColors.btnColor,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.file_upload_outlined),
        label: const Text(
          "Upload Bill",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


