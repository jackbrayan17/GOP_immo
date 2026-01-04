import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Service de localisation desactive.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permission de localisation refusee.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission de localisation bloquee.');
    }

    return Geolocator.getCurrentPosition();
  }
}
