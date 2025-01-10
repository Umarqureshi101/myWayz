import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class GoogleMapScreen extends StatefulWidget {
  final Map<String, dynamic> startCoordinates;
  final Map<String, dynamic> endCoordinates;
  final List<dynamic> directions; // Fixed to accept List<dynamic>

  GoogleMapScreen({
    required this.startCoordinates,
    required this.endCoordinates,
    required this.directions,
  });

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  String apiKey = '9068c95b8fff4784a859b59cdc429e56'; // Replace with your Geoapify API Key
  double distanceThreshold = 1000.0; // Threshold distance in meters (for proximity)

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _fetchPolyline();
  }

  void _initializeMarkers() {
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: LatLng(
          widget.startCoordinates['latitude'],
          widget.startCoordinates['longitude'],
        ),
        infoWindow: const InfoWindow(title: 'Start Location'),
      ),
    );
    markers.add(
      Marker(
        markerId: const MarkerId('end'),
        position: LatLng(
          widget.endCoordinates['latitude'],
          widget.endCoordinates['longitude'],
        ),
        infoWindow: const InfoWindow(title: 'End Location'),
      ),
    );
    _processDirections();
  }

  Future<void> _fetchPolyline() async {
    String url =
        "https://api.geoapify.com/v1/routing?waypoints=${widget.startCoordinates['latitude']},${widget.startCoordinates['longitude']}|${widget.endCoordinates['latitude']},${widget.endCoordinates['longitude']}&mode=drive&apiKey=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['features'][0]['geometry']['coordinates'];
        setState(() {
          polylineCoordinates = coordinates
              .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
              .toList();
        });
      } else {
        debugPrint("Failed to fetch polyline: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching polyline: $e");
    }
  }

  void _processDirections() {
    final directions = widget.directions.cast<Map<String, dynamic>>(); // Explicitly cast

    for (var step in directions) {
      String instruction = step['instruction']['text'] ?? '';
      if (instruction.isEmpty) continue;

      var subLocation = instruction.split("onto").last.trim();
      _geocodeSubLocation(subLocation).then((location) {
        if (location != null) {
          for (var point in polylineCoordinates) {
            double distance = _calculateDistance(
              point.latitude,
              point.longitude,
              location['latitude'],
              location['longitude'],
            );

            if (distance <= distanceThreshold) {
              markers.add(
                Marker(
                  markerId: MarkerId('subLocation-${markers.length}'),
                  position: LatLng(location['latitude'], location['longitude']),
                  infoWindow: InfoWindow(title: 'Sub-location: $subLocation'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              );
              setState(() {});
              break; // Avoid multiple markers for the same sub-location
            }
          }
        }
      });
    }
  }

  Future<Map<String, dynamic>?> _geocodeSubLocation(String location) async {
    String url =
        "https://api.geoapify.com/v1/geocode/search?text=$location&apiKey=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          return {
            'latitude': data['features'][0]['geometry']['coordinates'][1],
            'longitude': data['features'][0]['geometry']['coordinates'][0],
          };
        }
      }
    } catch (e) {
      debugPrint("Error geocoding sub-location: $e");
    }
    return null;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of the Earth in km
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = R * c * 1000; // Distance in meters
    return distance;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route on Google Maps'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
          _adjustCameraToFitMarkers();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.startCoordinates['latitude'],
            widget.startCoordinates['longitude'],
          ),
          zoom: 12,
        ),
        markers: markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        },
      ),
    );
  }

  void _adjustCameraToFitMarkers() {
    if (markers.isEmpty) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        markers.map((m) => m.position.latitude).reduce(min),
        markers.map((m) => m.position.longitude).reduce(min),
      ),
      northeast: LatLng(
        markers.map((m) => m.position.latitude).reduce(max),
        markers.map((m) => m.position.longitude).reduce(max),
      ),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }
}
