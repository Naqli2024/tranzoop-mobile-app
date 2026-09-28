import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/view/home_screen.dart';
import 'package:bizoop_driver_app/features/profile/profile_screen.dart';
import 'package:bizoop_driver_app/features/tripDocuments/view/documents_screen.dart';
import 'package:bizoop_driver_app/features/trips/view/trips_screen.dart';

final ValueNotifier<int> dashboardIndex = ValueNotifier<int>(0);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Widget> screens = [
    const HomeScreen(),
    const TripsScreen(),
    const DocumentsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      extendBody: true,
      body: ValueListenableBuilder<int>(
        valueListenable: dashboardIndex,
        builder: (_, index, __) => screens[index],
      ),
      bottomNavigationBar: MediaQuery.removePadding(
        context: context,
        removeBottom: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          height: viewUtil.isTablet ? 90 : 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          // Rebuilds the nav items whenever the index changes
          child: ValueListenableBuilder<int>(
            valueListenable: dashboardIndex,
            builder: (_, current, __) => Row(
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  current: current,
                ),
                _navItem(
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  label: "Trips",
                  index: 1,
                  current: current,
                ),
                _navItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description,
                  label: "Documents",
                  index: 2,
                  current: current,
                ),
                _navItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: "Profile",
                  index: 3,
                  current: current,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int current,
  }) {
    final bool selected = current == index;
    ViewUtil viewUtil = ViewUtil(context);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => dashboardIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.btnColor.withOpacity(.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selected ? activeIcon : icon,
                  key: ValueKey(selected),
                  color: selected ? AppColors.btnColor : Colors.grey,
                  size: viewUtil.isTablet ? 30 : 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? AppColors.btnColor : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: viewUtil.isTablet ? 18 : 12,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}