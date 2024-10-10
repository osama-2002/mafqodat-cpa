import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:mafqodat/services/entity_management_services.dart' as entity_services;

class MatchScreen extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> adminData;
  final String matchId;
  final String itemId;
  final String claimId;

  const MatchScreen({
    super.key,
    required this.adminData,
    required this.matchId,
    required this.itemId,
    required this.claimId,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  Map<String, dynamic> itemData = {};
  Map<String, dynamic> claimData = {};
  bool _isLoading = true;
  bool _userNotified = false;
  bool _isClosingCase = false;

  void _fetchData() async {
    final itemDoc = await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .get();
    final claimDoc = await FirebaseFirestore.instance
        .collection('claims')
        .doc(widget.claimId)
        .get();

    setState(() {
      itemData = itemDoc.data()!;
      claimData = claimDoc.data()!;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("MatchDetails")),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildComparisonSection(
                      title: translate("Category"),
                      claimValue: claimData['type'],
                      itemValue: itemData['type'],
                    ),
                    _buildComparisonSection(
                      title: translate("Description"),
                      claimValue: claimData['description'],
                      itemValue: itemData['description'],
                    ),
                    _buildComparisonSection(
                      title: translate("Date"),
                      claimValue: DateFormat('dd-MM-yyyy   hh:mm a')
                          .format(claimData['date'].toDate()),
                      itemValue: DateFormat('dd-MM-yyyy   hh:mm a')
                          .format(itemData['date'].toDate()),
                    ),
                    _buildLocationComparison(),
                    _buildImageComparisonSection(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => _handleDecision(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          child: _isClosingCase
                              ? CircularProgressIndicator()
                              : Text(
                                  translate("CloseCase"),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                        ElevatedButton(
                          onPressed: !_userNotified
                              ? () async {
                                  try {
                                    await entity_services
                                        .generateMatchNotification(
                                      widget.adminData['location'],
                                      '${widget.adminData['email']}\n${widget.adminData['phoneNumber']}',
                                      claimData['userId'],
                                      itemData['imageUrl'],
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text(translate('UserNotified')),
                                      ),
                                    );
                                    await FirebaseFirestore.instance
                                        .collection('claims')
                                        .doc(widget.claimId)
                                        .update({
                                      'status': 'possibleMatch',
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content:
                                                Text(translate('ErrorOc'))));
                                  }
                                  setState(() {
                                    _userNotified = true;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            translate("NotifyUserButton"),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _handleDecision(context, false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                          child: Text(
                            translate("Reject"),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildComparisonSection({
    required String title,
    required String claimValue,
    required String itemValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text("${translate("Claim")}$claimValue")),
            const VerticalDivider(),
            Expanded(child: Text("${translate("Item")}$itemValue")),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildLocationComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(translate('Location')),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        claimData['location'].latitude,
                        claimData['location'].longitude,
                      ),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('claimLocation'),
                        position: LatLng(
                          claimData['location'].latitude,
                          claimData['location'].longitude,
                        ),
                      ),
                    },
                  ),
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        itemData['location'].latitude,
                        itemData['location'].longitude,
                      ),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('itemLocation'),
                        position: LatLng(
                          itemData['location'].latitude,
                          itemData['location'].longitude,
                        ),
                      ),
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(translate('Images')),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                  child: _buildImageSection(
                      claimData['imageUrls'], translate('Claim'))),
              const VerticalDivider(),
              Expanded(
                  child: _buildImageSection(
                      [itemData['imageUrl']], translate('Item'))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImageSection(List<dynamic> imageUrls, String label) {
    return Column(
      children: [
        Text(label),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: 170,
                  height: 300,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleDecision(BuildContext context, bool isAccepted) async {
    if (isAccepted) {
      await entity_services.closeCase(widget.matchId, context, () {
        setState(() {
          _isClosingCase = true;
        });
      }, () {
        Navigator.of(context).pop();
      });
    } else {
      await entity_services.rejectMatch(widget.matchId);
      Navigator.of(context).pop();
    }
  }
}
