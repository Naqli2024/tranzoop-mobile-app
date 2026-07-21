import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/CommonSuccessScreen.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/home_screen.dart';
import 'package:tranzoop_mobile_app/features/inspection/model/inspection_model.dart';
import 'package:tranzoop_mobile_app/features/inspection/viewmodel/inspection_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/trips/view/pickup_screen.dart';

class PreTripInspectionScreen extends StatefulWidget {
  final CurrentTrip trip;
  const PreTripInspectionScreen({super.key, required this.trip});

  @override
  State<PreTripInspectionScreen> createState() =>
      _PreTripInspectionScreenState();
}

class _PreTripInspectionScreenState extends State<PreTripInspectionScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final SharedPrefService _pref = SharedPrefService();
  final TextEditingController notesController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();

  bool engineOil = false;
  bool coolant = false;
  bool brakes = false;
  bool lights = false;
  bool horn = false;
  bool fuel = false;
  bool documents = false;
  bool fireExtinguisher = false;
  bool firstAidKit = false;

  static const List<String> _tyrePositions = [
    "FL",
    "FR",
    "RL1",
    "RL2",
    "RR1",
    "RR2",
  ];

  late List<TyreInspection> tyres;
  int? _expandedTyreIndex = 0;

  List<Map<String, dynamic>> get inspectionItems => [
    {
      "title": "Engine Oil",
      "icon": Icons.oil_barrel_outlined,
      "value": engineOil,
      "onChanged": (bool value) => setState(() => engineOil = value),
    },
    {
      "title": "Coolant",
      "icon": Icons.water_drop_outlined,
      "value": coolant,
      "onChanged": (bool value) => setState(() => coolant = value),
    },
    {
      "title": "Brakes",
      "icon": Icons.disc_full_outlined,
      "value": brakes,
      "onChanged": (bool value) => setState(() => brakes = value),
    },
    {
      "title": "Lights",
      "icon": Icons.lightbulb_outline,
      "value": lights,
      "onChanged": (bool value) => setState(() => lights = value),
    },
    {
      "title": "Horn",
      "icon": Icons.volume_up_outlined,
      "value": horn,
      "onChanged": (bool value) => setState(() => horn = value),
    },
    {
      "title": "Fuel",
      "icon": Icons.local_gas_station_outlined,
      "value": fuel,
      "onChanged": (bool value) => setState(() => fuel = value),
    },
    {
      "title": "Documents",
      "icon": Icons.description_outlined,
      "value": documents,
      "onChanged": (bool value) => setState(() => documents = value),
    },
    {
      "title": "Fire Extinguisher",
      "icon": Icons.local_fire_department_outlined,
      "value": fireExtinguisher,
      "onChanged": (bool value) =>
          setState(() => fireExtinguisher = value),
    },
    {
      "title": "First Aid Kit",
      "icon": Icons.medical_services_outlined,
      "value": firstAidKit,
      "onChanged": (bool value) => setState(() => firstAidKit = value),
    },
  ];

  @override
  void initState() {
    super.initState();

    tyres = _tyrePositions
        .map((p) => TyreInspection(position: p))
        .toList(growable: false);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<InspectionViewModel>();

      await vm.fetchAllPreTripInspection(widget.trip.id);

      final inspection = vm.inspectionDetails?.data;

      if (!mounted || inspection == null) return;

      setState(() {
        engineOil = inspection.engineOil;
        coolant = inspection.coolant;
        brakes = inspection.brakes;
        lights = inspection.lights;
        horn = inspection.horn;
        fuel = inspection.fuel;
        documents = inspection.documents;
        fireExtinguisher = inspection.fireExtinguisher;
        firstAidKit = inspection.firstAidKit;
        if (inspection.tyres.isNotEmpty) {
          for (var i = 0; i < tyres.length; i++) {
            final match = inspection.tyres.firstWhere(
                  (t) => t.position == tyres[i].position,
              orElse: () => tyres[i],
            );
            tyres[i] = match;
          }
        }

        notesController.text = inspection.remarks;
      });
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitPreInspection(InspectionViewModel vm) async {
    final id = await _pref.getDriverId();

    final request = PreTripInspection(
      tripId: widget.trip.id,
      vehicleId: widget.trip.vehicleId,
      inspectedBy: id.toString(),
      engineOil: engineOil,
      coolant: coolant,
      brakes: brakes,
      lights: lights,
      horn: horn,
      fuel: fuel,
      documents: documents,
      fireExtinguisher: fireExtinguisher,
      firstAidKit: firstAidKit,
      tyres: tyres,
      remarks: notesController.text,
    );

    bool success;

    if (vm.failedInspectionId != null) {
      success = await vm.updatePreInspection(
        request,
        vm.failedInspectionId!,
      );
    } else {
      success = await vm.submitPreInspection(request);
    }

    if (!mounted) return;

    if (!success) {
      basicWidgets.error(context, vm.errorMessage);
      return;
    }

    await vm.fetchAllPreTripInspection(widget.trip.id);

    if (vm.inspectionStatus == "Failed") {
      basicWidgets.error(
        context,
        "Inspection Failed. Please fix the issues before proceeding.",
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CommonSuccessScreen(
              title: "Inspection Completed!",
              message: vm.successMessage,
              nextStep: "Proceed to Pickup Location",
              buttonText: "Navigate to Pickup",
              nextStepIcon: Icons.location_on,
              nextScreen: PickupScreen(trip: widget.trip),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final vm = Provider.of<InspectionViewModel>(context);

    final checkedGeneral =
        inspectionItems.where((e) => e["value"] == true).length;
    final okTyres = tyres.where((t) => t.isOk).length;

    final totalCount = inspectionItems.length + tyres.length;
    final completedCount = checkedGeneral + okTyres;
    final progress = completedCount / totalCount;

    final allGeneralChecked = checkedGeneral == inspectionItems.length;
    final allTyresOk = okTyres == tyres.length;
    final allChecked = allGeneralChecked && allTyresOk;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: basicWidgets.buildCommonAppBar(
        context: context,
        title: "Pre-Trip Inspection",
      ),
      body: vm.isLoading
          ? basicWidgets.loading()
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.btnColor, Colors.white],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$completedCount/$totalCount Completed",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: viewUtil.isTablet ? 22 : 18,
                        ),
                      ),
                      Text(
                        "${(progress * 100).round()}%",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: viewUtil.isTablet ? 18 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _sectionHeader(
                    "General Checklist",
                    "$checkedGeneral/${inspectionItems.length}",
                    viewUtil,
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(inspectionItems.length, (index) {
                    final item = inspectionItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: viewUtil.isTablet ? 14 : 10,
                      ),
                      child: _checklistTile(item, viewUtil),
                    );
                  }),
                  const SizedBox(height: 8),
                  _sectionHeader(
                    "Tyre Inspection",
                    "$okTyres/${tyres.length} OK",
                    viewUtil,
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(tyres.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: viewUtil.isTablet ? 14 : 10,
                      ),
                      child: _tyreCard(index, viewUtil),
                    );
                  }),
                  if (!allChecked) ...[
                    const SizedBox(height: 8),
                    _remarksBanner(viewUtil),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: basicWidgets.buildSlideActionButton(
                context: context,
                animation: _animation,
                text: vm.failedInspectionId != null
                    ? "Update Inspection"
                    : "Complete Inspection",
                isTablet: viewUtil.isTablet,
                outerColor: AppColors.btnColor,
                innerColor: const Color(0xff6889da),
                onSubmit: () => _submitPreInspection(vm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String status, ViewUtil viewUtil) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: viewUtil.isTablet ? 18 : 15,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: viewUtil.isTablet ? 15 : 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _checklistTile(Map<String, dynamic> item, ViewUtil viewUtil) {
    final bool value = item["value"] as bool;
    return GestureDetector(
      onTap: () => item["onChanged"](!value),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? Colors.green.shade200 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(
              item["icon"] as IconData,
              color: value ? Colors.green : Colors.grey.shade500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item["title"],
                style: TextStyle(
                  fontSize: viewUtil.isTablet ? 20 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Checkbox(
              activeColor: Colors.green,
              value: value,
              onChanged: (v) => item["onChanged"](v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tyreCard(int index, ViewUtil viewUtil) {
    final tyre = tyres[index];
    final expanded = _expandedTyreIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tyre.isOk ? Colors.green.shade200 : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(
                  () => _expandedTyreIndex = expanded ? null : index,
            ),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: viewUtil.isTablet ? 20 : 16,
                    backgroundColor: tyre.isOk
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Text(
                      tyre.position,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: viewUtil.isTablet ? 13 : 11,
                        color: tyre.isOk ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tyre ${tyre.position}  •  ${tyre.treadDepthMM.toStringAsFixed(1)} mm",
                      style: TextStyle(
                        fontSize: viewUtil.isTablet ? 18 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    tyre.isOk ? Icons.check_circle : Icons.warning_amber,
                    color: tyre.isOk ? Colors.green : Colors.red,
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _decimalStepperRow(
                    label: "Tread Depth",
                    value: tyre.treadDepthMM,
                    suffix: "mm",
                    onChanged: (v) => setState(
                          () => tyres[index] = tyre.copyWith(treadDepthMM: v),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _tyreToggleRow(
                    label: "Air Pressure OK",
                    value: tyre.airPressureOK,
                    positiveIsGood: true,
                    onChanged: (v) => setState(
                          () => tyres[index] = tyre.copyWith(airPressureOK: v),
                    ),
                  ),
                  _tyreToggleRow(
                    label: "Sidewall Damage",
                    value: tyre.sideWallDamage,
                    positiveIsGood: false,
                    onChanged: (v) => setState(
                          () => tyres[index] = tyre.copyWith(sideWallDamage: v),
                    ),
                  ),
                  _tyreToggleRow(
                    label: "Puncture",
                    value: tyre.puncture,
                    positiveIsGood: false,
                    onChanged: (v) => setState(
                          () => tyres[index] = tyre.copyWith(puncture: v),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _decimalStepperRow({
    required String label,
    required double value,
    required String suffix,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Row(
          children: [
            _stepperButton(
              icon: Icons.remove,
              onTap: () {
                final next = (value - 0.1).clamp(0, 100);
                onChanged(double.parse(next.toStringAsFixed(1)));
              },
            ),
            Container(
              width: 58,
              alignment: Alignment.center,
              child: Text(
                "${value.toStringAsFixed(1)} $suffix",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            _stepperButton(
              icon: Icons.add,
              onTap: () {
                final next = (value + 0.1).clamp(0, 100);
                onChanged(double.parse(next.toStringAsFixed(1)));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _tyreToggleRow({
    required String label,
    required bool value,
    required bool positiveIsGood,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isGood = positiveIsGood ? value : !value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isGood ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: isGood ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
              ),
            ],
          ),
          Switch(
            value: value,
            activeColor: positiveIsGood ? Colors.green : Colors.red,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _remarksBanner(ViewUtil viewUtil) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                "Inspection Remarks Required",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: viewUtil.isTablet ? 18 : 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter remarks for unchecked/flagged items...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}