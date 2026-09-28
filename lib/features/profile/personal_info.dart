import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    BasicWidgets basicWidgets = BasicWidgets();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: basicWidgets.buildAppBarWithRadius(context: context, title: 'Profile',
          onBackPressed: () {
            Navigator.pop(context);
          }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderColor)
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    child: Icon(Icons.person, size: 45),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    vm.driver?.data?.name ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vm.driver?.data?.driverId ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.green)
                    ),
                    child: Text(
                      vm.driver?.data?.availableStatus ?? "",
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 18),

            _buildCard(
              title: "Personal Information",
              icon: Icons.person_outline,
              children: [
                _tile(Icons.person, "Full Name", vm.driver?.data?.name ?? "",),
                _tile(Icons.phone, "Mobile", vm.driver?.data?.mobile.toString() ?? "",),
                _tile(Icons.badge, "Aadhaar", vm.driver?.data?.aadhaarNo.toString() ?? "",)
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: "Driving License",
              icon: Icons.credit_card,
              children: [
                _tile(Icons.confirmation_number,
                    "License Number", vm.driver?.data?.dlNo ?? "",),
                _tile(Icons.category,
                    "License Class", vm.driver?.data?.dlClass ?? "",),
                _tile(Icons.work_history,
                    "Experience", "${vm.driver?.data?.experience ?? ""} Years"),
                _tile(Icons.calendar_month,
                    "License Expiry Date", vm.driver?.data?.licenseExpiryDate ?? "",),
              ],
            ),

            const SizedBox(height: 16),

            _buildCard(
              title: "Performance",
              icon: Icons.analytics_outlined,
              children: [
                _tile(Icons.local_shipping,
                    "Total Trips", vm.driver?.data?.totalTrips.toString() ?? ""),
                _tile(Icons.info_outline,
                    "Vehicle Status", vm.driver?.data?.vehicle.status ?? ""),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor)
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}