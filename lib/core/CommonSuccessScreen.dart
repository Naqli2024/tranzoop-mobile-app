import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';

class CommonSuccessScreen extends StatelessWidget {
  final String title;
  final String message;
  final String nextStep;
  final String buttonText;
  final IconData nextStepIcon;
  final Widget nextScreen;
  final bool showSummaryCard;
  final bool showNextStep;
  final List<SummaryItem> summaryItems;

  const CommonSuccessScreen({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.nextScreen,
    this.nextStep = "",
    this.nextStepIcon = Icons.arrow_forward,
    this.showSummaryCard = false,
    this.showNextStep = true,
    this.summaryItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: viewUtil.isTablet ?180 :140,
                width: viewUtil.isTablet ?180 :140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(.08),
                ),
                child: Center(
                  child: Container(
                    height: viewUtil.isTablet ?130 :95,
                    width: viewUtil.isTablet ?130 :95,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(.35),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                      ],
                    ),

                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: viewUtil.isTablet ?60 :55,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: viewUtil.isTablet ?28 :22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: viewUtil.isTablet ?18 :14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              if (showSummaryCard) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: List.generate(
                      summaryItems.length,
                          (index) {
                        final item = summaryItems[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: index != summaryItems.length - 1
                                ? Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                    fontSize: viewUtil.isTablet ?18 :13,
                                  ),
                                ),
                              ),
                              Text(
                                item.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: viewUtil.isTablet ?18 :13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (showNextStep)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: viewUtil.isTablet ?EdgeInsets.all(18) : EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.btnColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          nextStepIcon,
                          color: AppColors.btnColor,
                          size: viewUtil.isTablet ?30 :24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Next Step",
                              style: TextStyle(
                                fontSize: viewUtil.isTablet ?18 :13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextStep,
                              style: TextStyle(
                                fontSize: viewUtil.isTablet ?20 :16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: viewUtil.isTablet ?80 :56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => nextScreen,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: viewUtil.isTablet ?28 :20,
                  ),
                  label: Text(
                    buttonText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: viewUtil.isTablet ?24 :16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryItem {
  final String label;
  final String value;

  SummaryItem({
    required this.label,
    required this.value,
  });
}