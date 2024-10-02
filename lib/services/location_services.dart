import 'dart:math';

import 'package:fl_geocoder/fl_geocoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
final geocoder = FlGeocoder(googleMapsApiKey);

Future<String> getFormattedAddress(double latitude, double longitude) async {
  final coordinates = Location(latitude, longitude);
  final results = await geocoder.findAddressesFromLocationCoordinates(
    location: coordinates,
    useDefaultResultTypeFilter: true,
  );

  return results[0].formattedAddress!;
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295;
  double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
// get current address
// pick location