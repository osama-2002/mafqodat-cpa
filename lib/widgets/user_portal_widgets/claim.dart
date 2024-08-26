import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

class Claim extends StatefulWidget {
  const Claim(
      {super.key,
      required this.id,
      required this.claimData,
      required this.imageUrls});
  final String id;
  final Map<String, dynamic> claimData;
  final List<dynamic> imageUrls;

  @override
  State<Claim> createState() => _ClaimState();
}

class _ClaimState extends State<Claim> {
  final geocoder = FlGeocoder(googleMapsApiKey);
  String? formattedAddress = '';

  Future<void> _getFormattedAddress() async {
    final coordinates = Location(
      widget.claimData['location'].latitude,
      widget.claimData['location'].longitude,
    );
    final results = await geocoder.findAddressesFromLocationCoordinates(
      location: coordinates,
      useDefaultResultTypeFilter: true,
    );

    setState(() {
      formattedAddress = results[0].formattedAddress;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFormattedAddress();
  }

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
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Lost Item Claim',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      "Type: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Text(
                        widget.claimData['type'],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      "Description: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Text(
                        widget.claimData['description'],
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      widget.claimData['status'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Timestamp: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat('dd-MM-yyyy   hh a')
                          .format(widget.claimData['date'].toDate()),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: 150,
                    child: widget.imageUrls.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.imageUrls.length,
                            itemBuilder: (context, imageIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(4),
                                child: Image.network(
                                  widget.imageUrls[imageIndex],
                                  fit: BoxFit.cover,
                                  width: 150,
                                  height: 150,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                            'No images uploaded',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          )),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    height: 150,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.claimData['location'].latitude,
                            widget.claimData['location'].longitude),
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('marker_1'),
                          position: LatLng(
                              widget.claimData['location'].latitude,
                              widget.claimData['location'].longitude),
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
                Row(
                  children: [
                    const Text(
                      'Address: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Expanded(
                      child: Text(
                        "$formattedAddress",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: const Text(
                            "Are you sure you want to delete this claim?",
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
                                      .collection('claims')
                                      .doc(widget.id)
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
                    color: Color(widget.claimData['color']),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Icon(
                  Icons.color_lens_outlined,
                  color: Color(widget.claimData['color']),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
