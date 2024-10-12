import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/claim.dart';
import 'package:mafqodat/widgets/admin_portal_widgets/report.dart';

class ClaimsAndReports extends StatefulWidget {
  const ClaimsAndReports({super.key, required this.adminData});
  final DocumentSnapshot adminData;
  @override
  State<ClaimsAndReports> createState() => _ClaimsAndReportsState();
}

class _ClaimsAndReportsState extends State<ClaimsAndReports> {
  String _selectedTab = translate("Claims");
  int tabToggleSwitchIndex = 0;
  String? filter;
  final TextEditingController _searchController = TextEditingController();

  void _onDropdownValueChanged(String? value) {
    setState(() {
      filter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      ToggleSwitch(
                        minWidth: 90.0,
                        initialLabelIndex: tabToggleSwitchIndex,
                        cornerRadius: 17,
                        textDirectionRTL: LocalizedApp.of(context)
                                .delegate
                                .currentLocale
                                .toString() ==
                            'ar',
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        totalSwitches: 2,
                        labels: [translate('Claims'), translate('Reports')],
                        activeBgColors: [
                          [Theme.of(context).colorScheme.secondary],
                          [Theme.of(context).colorScheme.secondary],
                        ],
                        onToggle: (index) {
                          setState(() {
                            if (index == 0) {
                              _selectedTab = translate('Claims');
                              tabToggleSwitchIndex = 0;
                            } else {
                              _selectedTab = translate('Reports');
                              tabToggleSwitchIndex = 1;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      CustomDropdownButton(
                        isUser: false,
                        isFilter: true,
                        controller: _searchController,
                        selectedDropDownValue: filter,
                        onChanged: _onDropdownValueChanged,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            filter = null;
                          });
                        },
                        child: Text(
                          translate("ResetFilter"),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _selectedTab == translate('Claims')
                    ? filter == null
                        ? FirebaseFirestore.instance
                            .collection('claims')
                            .where('region',
                                isEqualTo: widget.adminData['region'])
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('claims')
                            .where('region',
                                isEqualTo: widget.adminData['region'])
                            .where('type', isEqualTo: filter)
                            .snapshots()
                    : filter == null
                        ? FirebaseFirestore.instance
                            .collection('reports')
                            .where('region',
                                isEqualTo: widget.adminData['region'])
                            .snapshots()
                        : FirebaseFirestore.instance
                            .collection('reports')
                            .where('region',
                                isEqualTo: widget.adminData['region'])
                            .where('type', isEqualTo: filter)
                            .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
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
                        const SizedBox(height: 270),
                        Center(
                          child: _selectedTab == translate('Claims')
                              ? Text(
                                  translate("NoClaims"),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                )
                              : Text(
                                  translate("NoReports"),
                                  style: const TextStyle(
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
