import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  BasicWidgets basicWidgets = BasicWidgets();
  List<Map<String, dynamic>> notifications = [
    {
      "title": "New Trip Assigned",
      "message":
      "Trip TR-2026-1025 has been assigned to you.",
      "time": "5 min ago",
      "read": false,
      "icon": Icons.assignment_rounded,
      "color": Colors.blue,
    },
    {
      "title": "Loading Completed",
      "message":
      "Loading has been completed at Chennai Port.",
      "time": "30 min ago",
      "read": false,
      "icon": Icons.inventory_2_rounded,
      "color": Colors.orange,
    },
    {
      "title": "Trip Started",
      "message":
      "Your trip to Tambaram Market is now active.",
      "time": "1 hr ago",
      "read": true,
      "icon": Icons.local_shipping_rounded,
      "color": Colors.green,
    },
    {
      "title": "OTP Verified",
      "message":
      "Delivery OTP has been verified successfully.",
      "time": "Yesterday",
      "read": true,
      "icon": Icons.verified_rounded,
      "color": Colors.purple,
    },
    {
      "title": "Trip Completed",
      "message":
      "Trip TR-2026-1020 completed successfully.",
      "time": "Yesterday",
      "read": true,
      "icon": Icons.check_circle_rounded,
      "color": Colors.teal,
    },
  ];

  void markAllRead() {
    setState(() {
      for (var item in notifications) {
        item["read"] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((e) => !e["read"]).length;
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: basicWidgets.buildAppBarWithRadius(
          context: context,
          title: "Notifications",
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(index.toString()),
            background: Container(
              margin:
              const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.centerRight,
              padding:
              const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              setState(() {
                notifications.removeAt(index);
              });
            },
            child: Container(
              margin:
              const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    height: viewUtil.isTablet ? 62 :52,
                    width: viewUtil.isTablet ? 62 :52,
                    decoration: BoxDecoration(
                      color: notification["color"]
                          .withOpacity(.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification["icon"],
                      color: notification["color"],
                      size: viewUtil.isTablet ? 30 :20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification["title"],
                                style:
                                TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: viewUtil.isTablet ? 22 :15,
                                ),
                              ),
                            ),
                            if (!notification["read"])
                              Container(
                                height: 10,
                                width: 10,
                                decoration:
                                const BoxDecoration(
                                  color: Colors.red,
                                  shape:
                                  BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification["message"],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.4,
                            fontSize: viewUtil.isTablet ? 18 :14
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notification["time"],
                          style: TextStyle(
                            color:
                            Colors.grey.shade500,
                            fontSize: viewUtil.isTablet ? 18 :12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: unreadCount > 0
        ? BottomAppBar(
        height: viewUtil.isTablet ?90 :80,
        color: Colors.transparent,
        child: TextButton(
        style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green)),
      onPressed: markAllRead,
      child: Text(
        "Mark All Read",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: viewUtil.isTablet ? 20 :16
        ),
      ),
          ),
      )
        : null
    );
  }

  Widget _buildEmptyState() {
    ViewUtil viewUtil = ViewUtil(context);
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "No Notifications",
            style: TextStyle(
              fontSize: viewUtil.isTablet ? 22 :18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up.",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: viewUtil.isTablet ? 18 :14
            ),
          ),
        ],
      ),
    );
  }
}