import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:mafqodat/widgets/user_portal_widgets/claim.dart';
import 'package:mafqodat/widgets/user_portal_widgets/report.dart';

class ClaimsAndReports extends StatefulWidget {
  const ClaimsAndReports({super.key});

  @override
  State<ClaimsAndReports> createState() => _ClaimsAndReportsState();
}

class _ClaimsAndReportsState extends State<ClaimsAndReports> {
  String _selectedTab = translate("Claims");
  int genderToggleSwitchIndex = 0;
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(translate("ClaimsReport")),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleSwitch(
                    minWidth: 90.0,
                    initialLabelIndex: genderToggleSwitchIndex,
                    cornerRadius: 20.0, //!
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.white,
                    totalSwitches: 2,
                    labels: [translate('Claims'), translate('Reports')],
                    activeBgColors: [
                      [Theme.of(context).colorScheme.primary],
                      [Theme.of(context).colorScheme.primary],
                    ],
                    onToggle: (index) {
                      setState(() {
                        if (index == 0) {
                          _selectedTab = translate('Claims');
                          genderToggleSwitchIndex = 0;
                        } else {
                          _selectedTab = translate('Reports');
                          genderToggleSwitchIndex = 1;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _selectedTab == translate('Claims')
                    ? FirebaseFirestore.instance
                        .collection('claims')
                        .where('userId', isEqualTo: userId)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('reports')
                        .where('userId', isEqualTo: userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54),
                    ));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 320),
                        Center(
                          child: _selectedTab == translate('Claims')
                              ? Text(
                                  translate("NoClaims"),
                                  style:const  TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                )
                              :  Text(
                                  translate("NoReports"),
                                  style:const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                        ),
                      ],
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: _selectedTab == translate("Claims")
                        ? (context, index) {
                            QueryDocumentSnapshot claim =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> claimData =
                                claim.data() as Map<String, dynamic>;
                            List<dynamic> imageUrls =
                                claimData['imageUrls'] as List<dynamic>? ?? [];
                            return Claim(
                                id: claim.id,
                                claimData: claimData,
                                imageUrls: imageUrls);
                          }
                        : (context, index) {
                            QueryDocumentSnapshot report =
                                snapshot.data!.docs[index];
                            Map<String, dynamic> reportData =
                                report.data() as Map<String, dynamic>;
                            String imageUrl = reportData['imageUrl'];
                            return Report(
                                id: report.id,
                                reportData: reportData,
                                imageUrl: imageUrl);
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
