import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mafqodat/screens/admin_portal/match_screen.dart';
import 'package:mafqodat/widgets/custom_dropdown_button.dart';
import 'package:material_symbols_icons/symbols.dart';

class Matches extends StatefulWidget {
  const Matches({super.key, required this.adminData});
  final DocumentSnapshot<Map<String, dynamic>> adminData;

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  String? filter;
  final TextEditingController _searchController = TextEditingController();

  void _onDropdownValueChanged(String? value) {
    setState(() {
      filter = value;
    });
  }

  void _findMatches() async {}

  @override
  void initState() {
    super.initState();
    _findMatches();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder(
            stream: filter == null
                ? FirebaseFirestore.instance
                    .collection('matches')
                    .where('isRejected', isEqualTo: false)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('matches')
                    .where('isRejected', isEqualTo: false)
                    .where('type', isEqualTo: filter)
                    .snapshots(),
            builder: (context, matchesSnapshot) {
              if (matchesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (matchesSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${matchesSnapshot.error}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              if (!matchesSnapshot.hasData ||
                  matchesSnapshot.data!.docs.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomDropdownButton(
                          isUser: false,
                          isFilter: true,
                          controller: _searchController,
                          selectedDropDownValue: filter,
                          onChanged: _onDropdownValueChanged,
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              filter = null;
                            });
                          },
                          child: Text(
                            'Reset Filter',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 280),
                    const Center(
                      child: Text(
                        'No matches found.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomDropdownButton(
                          isUser: false,
                          isFilter: true,
                          controller: _searchController,
                          selectedDropDownValue: filter,
                          onChanged: _onDropdownValueChanged),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            filter = null;
                          });
                        },
                        child: Text(
                          'Reset Filter',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: matchesSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final QueryDocumentSnapshot<Map<String, dynamic>> match =
                          matchesSnapshot.data!.docs[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MatchScreen(
                                adminData: widget.adminData,
                                matchId: match.id,
                                itemId: match['itemId'],
                                claimId: match['claimId'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 12, left: 6, right: 6),
                          child: Card(
                            elevation: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: ListTile(
                                leading: Icon(
                                  Symbols.quiz,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 30,
                                ),
                                title: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                          text: "Possible Match ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: "#${match.id.substring(0, 4)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal))
                                    ],
                                  ),
                                ),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                          text: "Claim: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              "#${match['claimId'].substring(0, 4)}\n",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal)),
                                      const TextSpan(
                                          text: "Item: ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                          text:
                                              "#${match['itemId'].substring(0, 4)}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
