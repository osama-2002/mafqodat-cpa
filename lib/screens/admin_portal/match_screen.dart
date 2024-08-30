import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  void _fetchData() async {
  final itemDoc = await FirebaseFirestore.instance.collection('items').doc(widget.itemId).get();
  final claimDoc = await FirebaseFirestore.instance.collection('claims').doc(widget.claimId).get();

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
        title: const Text('Match Details'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComparisonSection(
              title: 'Category',
              claimValue: claimData['type'],
              itemValue: itemData['type'],
            ),
            _buildComparisonSection(
              title: 'Description',
              claimValue: claimData['description'],
              itemValue: itemData['description'],
            ),
            _buildComparisonSection(
              title: 'Date',
              claimValue: claimData['date'].toDate().toString(),
              itemValue: itemData['date'].toDate().toString(),
            ),
            _buildLocationComparison(),
            _buildImageComparisonSection(),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _handleDecision(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Accept', style: TextStyle(color: Colors.black),),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () => _handleDecision(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('Reject', style: TextStyle(color: Colors.black),),
                ),
              ],
            ),
          ],
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
            Expanded(child: Text('Claim: $claimValue')),
            const VerticalDivider(),
            Expanded(child: Text('Item: $itemValue')),
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
        _buildSectionTitle('Location'),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
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
              const VerticalDivider(),
              Expanded(
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
        _buildSectionTitle('Images'),
        Row(
          children: [
            Expanded(
                child: _buildImageSection(claimData['imageUrls'], 'Claim')),
            const VerticalDivider(),
            Expanded(
                child:
                    _buildImageSection([itemData['imageUrl']], 'Item')),
          ],
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
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _generateNotification() async {
    await FirebaseFirestore.instance.collection('matches_notifications').add({
      'title': 'Match Found!',
      'message': 'A match has been found for your claim.',
      'location': widget.adminData['location'],
      'contactInfo':
          '${widget.adminData['email']}\n${widget.adminData['phoneNumber']}',
      'userId': claimData['userId'],
      'timestamp': Timestamp.now(),
      'imageUrl': itemData['imageUrl'],
    });
  }

  void _handleDecision(BuildContext context, bool isAccepted) async {
    if (isAccepted) {
      await _generateNotification();
      await FirebaseFirestore.instance
          .collection('claims')
          .doc(widget.claimId)
          .update({
        'status': 'Match Found',
      });
    } else {
      FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .update(
        {
          'isRejected': true,
        },
      );
    }

    Navigator.of(context).pop();
  }
}
