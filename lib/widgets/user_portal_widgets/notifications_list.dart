import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mafqodat/widgets/user_portal_widgets/claim_notification.dart';
import 'package:mafqodat/widgets/user_portal_widgets/report_notification.dart';

class NotificationsList extends StatefulWidget {
  const NotificationsList({super.key});

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('claims_notifications')
                .where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, claimsSnapshot) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('reports_notifications')
                    .where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, reportsSnapshot) {
                  if (claimsSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      reportsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (claimsSnapshot.hasError || reportsSnapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${claimsSnapshot.error ?? reportsSnapshot.error}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }

                  final hasNoClaims = !claimsSnapshot.hasData ||
                      claimsSnapshot.data!.docs.isEmpty;
                  final hasNoReports = !reportsSnapshot.hasData ||
                      reportsSnapshot.data!.docs.isEmpty;

                  if (hasNoClaims && hasNoReports) {
                    return const Center(
                      child: Column(
                        children: [
                          SizedBox(height: 320),
                          Text(
                            'No new notifications found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (!hasNoClaims)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: claimsSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot notification =
                                claimsSnapshot.data!.docs[index];
                            String notificationId = notification.id;
                            Map<String, dynamic> notificationData =
                                notification.data() as Map<String, dynamic>;
                            return ClaimNotification(
                              id: notificationId,
                              data: notificationData,
                            );
                          },
                        ),
                      if (!hasNoReports)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reportsSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot notification =
                                reportsSnapshot.data!.docs[index];
                            String notificationId = notification.id;
                            Map<String, dynamic> notificationData =
                                notification.data() as Map<String, dynamic>;
                            return ReportNotification(
                              id: notificationId,
                              data: notificationData,
                            );
                          },
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
