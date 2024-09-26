import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:mafqodat/widgets/user_portal_widgets/claim_notification.dart';
import 'package:mafqodat/widgets/user_portal_widgets/match_notification.dart';
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
                .collection('matches_notifications')
                .where('userId',
                    isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, matchesSnapshot) {
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('claims_notifications')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, claimsSnapshot) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('reports_notifications')
                        .where('userId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, reportsSnapshot) {
                      if (matchesSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          claimsSnapshot.connectionState ==
                              ConnectionState.waiting ||
                          reportsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (matchesSnapshot.hasError ||
                          claimsSnapshot.hasError ||
                          reportsSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${matchesSnapshot.error ?? ' '}\n${reportsSnapshot.error ?? ' '}\n${claimsSnapshot.error ?? ' '}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }

                      final hasNoMatches = !matchesSnapshot.hasData ||
                          matchesSnapshot.data!.docs.isEmpty;
                      final hasNoClaims = !claimsSnapshot.hasData ||
                          claimsSnapshot.data!.docs.isEmpty;
                      final hasNoReports = !reportsSnapshot.hasData ||
                          reportsSnapshot.data!.docs.isEmpty;

                      if (hasNoMatches && hasNoClaims && hasNoReports) {
                        return  Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 320),
                              Text(
                                translate("NoNotification"),
                                style:const TextStyle(
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
                          if (!hasNoMatches)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: matchesSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                QueryDocumentSnapshot notification =
                                    matchesSnapshot.data!.docs[index];
                                String notificationId = notification.id;
                                Map<String, dynamic> notificationData =
                                    notification.data() as Map<String, dynamic>;
                                return MatchNotification(
                                  id: notificationId,
                                  data: notificationData,
                                );
                              },
                            ),
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
              );
            },
          ),
        ],
      ),
    );
  }
}
