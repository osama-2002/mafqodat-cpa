import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Report extends StatelessWidget {
  const Report(
      {super.key,
      required this.id,
      required this.reportData,
      required this.imageUrl});
  final String id;
  final Map<String, dynamic> reportData;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  reportData['description'],
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Status: ${reportData['status']}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Date: ${reportData['date'].toDate().toString()}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    height: 150,
                    child: imageUrl.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No images uploaded',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    height: 150,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(reportData['location'].latitude,
                            reportData['location'].longitude),
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('marker_1'),
                          position: LatLng(reportData['location'].latitude,
                              reportData['location'].longitude),
                        ),
                      },
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text(
                            "Are you sure you want to delete this report?",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                try {
                                  FirebaseFirestore.instance
                                      .collection('reports')
                                      .doc(id)
                                      .delete();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("$e")));
                                }
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(reportData['color']),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Icon(
                  Icons.color_lens_outlined,
                  color: Color(reportData['color']),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
