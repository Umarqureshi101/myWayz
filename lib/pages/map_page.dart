import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Location controller to manage the user's current location
  final Location _locationController = Location();

  // Completer to manage the Google Map controller asynchronously
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  // Variables to store current and destination locations
  LatLng? _currentP;
  LatLng? _destinationP;

  // Sets to hold the markers and polylines for the map
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Initialize the current location when the map page is first loaded
    _initializeCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading spinner until current location is available
    return Scaffold(
      body: _currentP == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : GoogleMap(
        // When the map is created, the GoogleMapController is initialized
        onMapCreated: (GoogleMapController controller) => _mapController.complete(controller),

        // Set the initial camera position to the current location
        initialCameraPosition: CameraPosition(
          target: _currentP!,
          zoom: 15,
        ),

        // Display markers and polylines on the map
        markers: _markers,
        polylines: _polylines,

        // Handle tap on the map to set the destination location
        onTap: _onMapTapped,
      ),

      // Floating action button to navigate back
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
        backgroundColor: Colors.blue,
        tooltip: 'Back',
        mini: true, // Small size for the button
        heroTag: null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // Align FAB to the left
    );
  }

  // Initialize the current location using the location package
  Future<void> _initializeCurrentLocation() async {
    try {
      // Check if the location service is enabled
      bool serviceEnabled = await _locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationController.requestService();
        if (!serviceEnabled) {
          throw Exception("Location services are disabled.");
        }
      }

      // Check if the app has permission to access the location
      PermissionStatus permissionGranted = await _locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          throw Exception("Location permissions are denied.");
        }
      }

      // Set high accuracy for location
      _locationController.changeSettings(accuracy: LocationAccuracy.high);

      // Get the current location
      LocationData currentLocation = await _locationController.getLocation();

      // If latitude and longitude are available, set the current position
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        // Add a marker for the current location
        _markers.add(
          Marker(
            markerId: const MarkerId("current"),
            position: _currentP!,
            infoWindow: const InfoWindow(title: "Your Location"),
          ),
        );

        setState(() {});

        // Move the camera to the current location
        _cameraToPosition(_currentP!);
      } else {
        throw Exception("Failed to fetch the current location.");
      }
    } catch (e) {
      print("Error initializing location: $e");
    }
  }

  // Handle map tap to set destination location
  void _onMapTapped(LatLng position) async {
    setState(() {
      // Set the tapped position as the destination
      _destinationP = position;

      // Remove any existing destination marker
      _markers.removeWhere((marker) => marker.markerId.value == "destination");

      // Add a new marker for the destination
      _markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: _destinationP!,
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );
    });

    // Fetch the route if both start and destination locations are set
    if (_currentP != null && _destinationP != null) {
      await _getRoute(_currentP!, _destinationP!);
    }
  }

  // Fetch route directions from Google Maps API
  Future<void> _getRoute(LatLng origin, LatLng destination) async {
    const String apiKey = "YOUR_API_KEY"; // Replace with your Google Maps API key
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        // Decode the polyline points from the response
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        final List<LatLng> decodedPoints = _decodePolyline(polylinePoints);

        setState(() {
          // Clear any existing polylines and add the new route
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: decodedPoints,
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    } else {
      print("Failed to fetch directions: ${response.body}");
    }
  }

  // Move the camera to a new position (e.g., current location or destination)
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 15,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  // Decode polyline points from the Google Maps API response
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
