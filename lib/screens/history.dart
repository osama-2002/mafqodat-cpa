import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mafqodat/widgets/location_input.dart';

class ClaimsListScreen extends StatelessWidget {
  const ClaimsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Claims'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('claims')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No claims found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var claim = snapshot.data!.docs[index];
              var claimData = claim.data() as Map<String, dynamic>;
              var imageUrls = claimData['imageUrls'] as List<dynamic>? ?? [];

              return Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      claimData['description'],
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Status: ${claimData['status']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Date: ${claimData['date'].toDate().toString()}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      height: 150.0,
                      child: imageUrls.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageUrls.length,
                              itemBuilder: (context, imageIndex) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(
                                    imageUrls[imageIndex],
                                    fit: BoxFit.cover,
                                    width: 150.0,
                                    height: 150.0,
                                  ),
                                );
                              },
                            )
                          : Text('No images uploaded'),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      height: 200,
                      // child: Image.network(
                      //   'https://maps.googleapis.com/maps/api/staticmap?center=${claimData['location'].latitude},${claimData['location'].longitude}&zoom=16&size=600x400&maptype=roadmap&markers=color:red%7Clabel:A%7C${claimData['location'].latitude},${claimData['location'].longitude}&key=$googleMapsApiKey',
                      //   fit: BoxFit.cover,
                      //   width: 200,
                      //   height: 200,
                      // ),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(claimData['location'].latitude, claimData['location'].longitude),
                          zoom: 12,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('marker_1'),
                            position: LatLng(claimData['location'].latitude, claimData['location'].longitude),
                          ),
                        },
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: 50,
                      height: 50,
                      color: Color(claimData['color']),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
