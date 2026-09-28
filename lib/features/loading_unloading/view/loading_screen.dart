import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/CommonSuccessScreen.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';
import 'package:bizoop_driver_app/features/loading_unloading/viewmodal/loading_unloading_viewmodel.dart';
import 'package:bizoop_driver_app/features/trips/view/in_transit_screen.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:bizoop_driver_app/features/weight_bridge/view/weight_bridge_screen.dart';


class LoadingScreen extends StatefulWidget {
  final CurrentTrip trip;
  const LoadingScreen({super.key, required this.trip, });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  late DateTime loadingStartTime;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();
  final ImagePicker picker = ImagePicker();
  bool visibleCargo = false;
  Timer? _timer;
  int _seconds = 0;
  File? billImage;

  @override
  void initState() {
    super.initState();
    loadingStartTime = DateTime.now();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        setState(() {
          _seconds++;
        });
      },
    );
  }

  String get formattedTime {
    final hours = (_seconds ~/ 3600)
        .toString()
        .padLeft(2, '0');

    final minutes = ((_seconds % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_seconds % 60)
        .toString()
        .padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Future<void> _completeLoading(LoadingUnloadingViewmodel vm) async {
    if (weightController.text.trim().isEmpty) {
      basicWidgets.error(context, "Please enter loaded weight");
      return;
    }
    if (amountController.text.trim().isEmpty) {
      basicWidgets.error(context, "Please enter amount");
      return;
    }

    final request = LoadingRequest(
      loadingStartTime: loadingStartTime.toUtc(),
      loadingEndTime: DateTime.now().toUtc(),
      loadedWeight: double.parse(weightController.text.trim()),
      loadedBy: widget.trip.currentJourneyLeg?.from ?? '',
    );

    final success = await vm.loadingTrip(
      widget.trip.id,
      request,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "Loading Completed!",
            message: vm.successMessage,
            nextStep: "Proceed to Destination",
            buttonText: "Start Trip",
            showNextStep: false,
            showSummaryCard: true,
            summaryItems: [
              SummaryItem(
                label: "Pickup Location",
                value: widget.trip.currentJourneyLeg?.from ?? '',
              ),
              SummaryItem(
                label: "Delivery Location",
                value: widget.trip.currentJourneyLeg?.to ?? '',
              ),
              SummaryItem(
                label: "Loaded Weight",
                value: "${weightController.text} ${widget.trip.currentJourneyLeg?.uom ?? ''}",
              ),
              SummaryItem(
                label: "Loading Time",
                value: formattedTime,
              ),
            ],
            nextScreen: WeightBridgeScreen(trip: widget.trip),
          ),
        ),
      );
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  Future<void> upload() async {
    final vm = context.read<LoadingUnloadingViewmodel>();
    if (amountController.text.trim().isEmpty) {
      basicWidgets.error(context, "Please enter amount");
      return;
    }

    final request = LoadingUnloadingExpenseRequest(
      expenseType: "Loading",
      amount: double.parse(amountController.text),
      bill: billImage!,
    );

    final success = await vm.loadingUnloadingExpense(
      widget.trip.id,
      request,
    );

    if (!mounted) return;

    if (success) {
      basicWidgets.error(
        context,
        vm.successMessage,
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
    ViewUtil viewUtil = ViewUtil(context);
    final vm = context.watch<LoadingUnloadingViewmodel>();
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: basicWidgets.buildAppBarWithRadius(
      context: context,
      title: "Loading",
    ),
      body: vm.isLoading
        ? basicWidgets.loading()
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 25,
                    color: AppColors.btnColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Loading Duration",
                      style: TextStyle(color: Colors.grey,fontSize: viewUtil.isTablet ?20 :16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: AppColors.btnColor,
                      fontWeight: FontWeight.bold,
                      fontSize: viewUtil.isTablet ?34 :18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  uploadBillWidget(),
                  const SizedBox(height: 20),
                  basicWidgets.buildTextField(
                    "Loading Amount",
                    amountController,
                    context: context,
                    isNumber: true
                  ),
                  basicWidgets.buildTextField("Loaded Weight", weightController, context: context, isNumber: true),
                  const SizedBox(height: 30),
                  basicWidgets.buildCommonButton(
                    context,
                    "Upload",
                    upload,
                    isLoading: context.watch<LoadingUnloadingViewmodel>().isLoading,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        visibleCargo = !visibleCargo;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,color: AppColors.btnColor,size: viewUtil.isTablet ?30 :20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Cargo Details",
                            style: basicWidgets.coloredText(context, AppColors.btnColor, viewUtil.isTablet ?22 :16, FontWeight.w500)
                          ),
                        ),
                        Icon(visibleCargo ?Icons.arrow_drop_up :Icons.arrow_drop_down_outlined)
                      ],
                    ),
                  ),
                  Visibility(
                    visible: visibleCargo,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _detailRow("Trip ID", widget.trip.tripNo),
                        const Divider(),
                        _detailRow("Items", widget.trip.currentJourneyLeg?.commodity ?? ''),
                        const Divider(),
                        _detailRow("Consignment Weight", "${widget.trip.currentJourneyLeg?.weight}${widget.trip.currentJourneyLeg?.uom}"),
                        const Divider(),
                        _detailRow("Status", "In Progress"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
        bottomNavigationBar: BottomAppBar(
          height: viewUtil.isTablet ?90 :125,
          color: Colors.transparent,
          child: basicWidgets.buildSlideActionButton(
            context: context,
            animation: _animation,
            text: "Done Loading",
            isTablet: viewUtil.isTablet,
            outerColor: AppColors.btnColor,
            innerColor: const Color(0xff6889da),
            onSubmit: () =>  _completeLoading(vm),
          ),
        )
    );
  }

  Widget _detailRow(String title, String value) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: Colors.grey,fontSize: viewUtil.isTablet ?20 :16)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600,color: title == "Status"?Colors.orange :Colors.black,
              fontSize: viewUtil.isTablet ?20 :16
          )),
        ],
      ),
    );
  }

  Future<void> _pickBill(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        billImage = File(image.path);
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
      builder: (_) {
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
        const Text(
          "Upload Loading Bill",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _showImagePicker,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            child: (billImage == null)
                ? const Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 45,
                  ),
                  SizedBox(height: 10),
                  Text("Tap to Upload Bill"),
                ],
              ),
            )
                : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    billImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        billImage = null;
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
