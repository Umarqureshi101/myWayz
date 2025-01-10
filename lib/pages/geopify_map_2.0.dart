import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For Google Maps LatLng
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'more_screen.dart';
import 'logout_screen.dart';
class TruckRoutingApp extends StatefulWidget {
  @override
  _TruckRoutingAppState createState() => _TruckRoutingAppState();
}

class _TruckRoutingAppState extends State<TruckRoutingApp> {
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  String selectedVehicleType = 'car'; // Default vehicle type
  List<String> vehicleTypes = ['car', 'truck'];
  String userName = "User"; // Default name, should be updated after login
  String userEmail = "user@example.com";
  String userDob = "dob";
  String userGen = "Male";

  String apiKey =
      "9068c95b8fff4784a859b59cdc429e56"; // Avoid hardcoding API keys in production
  bool isLoading = false;
  Map<String, dynamic>? responseOutput;
  Map<String, dynamic>? startCoordinates;
  Map<String, dynamic>? endCoordinates;
  //late gmf.GoogleMapController mapController;
  @override
  void initState() {
    super.initState();
    _loadUserProfile();// Load user profile on app startup

  }
  Future<Map<String, dynamic>?> fetchCoordinates(String location) async {
    String url =
        "https://api.geoapify.com/v1/geocode/search?text=$location&apiKey=$apiKey";

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
    return null;
  }

  String mapVehicleTypeToApiMode(String vehicleType) {
    switch (vehicleType) {
      case 'car':
        return 'drive';
      case 'bike':
        return 'drive';
      case 'walk':
        return 'walk';
      case 'light_truck':
        return 'drive';
      case 'medium_truck':
        return 'drive';
      case 'heavy_truck':
        return 'drive';
      case 'bus':
        return 'bus';
      case 'truck':
        return 'long_truck';
      default:
        return 'drive'; // Default to car if no match
    }
  }

  List<List<double>> coordinatesList = [];

  String startLng = '';
  String startLat = '';

  String endLat = '';
  String endLng = '';
  final Set<gmf.Polyline> _polylines = {};

  List<String> instructionList = [];
  Set<gmf.Marker> _markers = {}; // Initialize a Set to store markers

  void moveCameraToPosition(gmf.LatLng position) {
    // mapController.animateCamera(
    //   gmf.CameraUpdate.newLatLngZoom(
    //       position, 14), // Zoom level 14 for better visibility
    // );
  }

  Future<void> fetchRoute() async {
    setState(() {
      isLoading = true;
      responseOutput = null;
      startCoordinates = null;
      endCoordinates = null;
    });

    // Map selected vehicle type to Geoapify API mode
    String apiMode = mapVehicleTypeToApiMode(selectedVehicleType);

    String? url;

    if (apiMode == 'long_truck') {
      url =
      "https://api.geoapify.com/v1/routing?waypoints=$startLat,$startLng|$endLat,$endLng&mode=$apiMode&details=instruction_details&type=less_maneuvers&apiKey=$apiKey";
    } else {
      url =
      "https://api.geoapify.com/v1/routing?waypoints=$startLat,$startLng|$endLat,$endLng&mode=$apiMode&details=instruction_details&type=balanced&apiKey=$apiKey";
    }
    print('API Mode is $apiMode');

    log('url is $url');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['features'].isEmpty) {
        setState(() {
          // Fallback to car or bus route if no truck route is available
          responseOutput = {
            'message':
            'Custom route not available, showing route for car or bus.'
          };
          String fallbackApiMode =
          mapVehicleTypeToApiMode('car'); // Fallback to car route
          fetchFallbackRoute(fallbackApiMode);
        });
      } else {
        setState(() {
          isLoading = false;
          responseOutput = data;
          _polylines.clear();
          _markers.clear();
          final features = data['features'] as List<dynamic>;
          for (var feature in features) {
            final coordinates =
            feature['geometry']['coordinates'] as List<dynamic>;
            for (var line in coordinates) {
              final List<LatLng> polylineCoordinates = [];
              for (var point in line) {
                polylineCoordinates.add(LatLng(
                  (point[1] as num).toDouble(), // Ensure latitude is a double
                  (point[0] as num).toDouble(), // Ensure longitude is a double
                ));
              }

              final polyline = gmf.Polyline(
                polylineId: gmf.PolylineId(
                  'route_${DateTime.now().millisecondsSinceEpoch}',
                ), // Unique ID for each polyline
                points: polylineCoordinates,
                color: Colors.blue,
              );

              _polylines.add(polyline);

              // Add marker at the start of the polyline
              if (polylineCoordinates.isNotEmpty) {
                final startMarker = gmf.Marker(
                  markerId: gmf.MarkerId(
                    'marker_start_${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  position:
                  polylineCoordinates.first, // Start point of the polyline
                  infoWindow: const gmf.InfoWindow(
                    title: 'Start Point',
                    snippet: 'This is the starting location',
                  ),
                  icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
                    gmf.BitmapDescriptor.hueGreen,
                  ),
                );
                _markers.add(startMarker);

                // Add marker at the end of the polyline
                final endMarker = gmf.Marker(
                  markerId: gmf.MarkerId(
                    'marker_end_${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  position:
                  polylineCoordinates.last, // End point of the polyline
                  infoWindow: const gmf.InfoWindow(
                    title: 'End Point',
                    snippet: 'This is the ending location',
                  ),
                  icon: gmf.BitmapDescriptor.defaultMarkerWithHue(
                    gmf.BitmapDescriptor.hueRed,
                  ),
                );
                _markers.add(endMarker);
                moveCameraToPosition(polylineCoordinates.first);
              }

              print('Polylines list is ${_polylines.length}');
            }
          }

        });
      }
    } else {
      setState(() {
        isLoading = false;
        responseOutput = {
          'error': 'Failed to fetch route: ${response.reasonPhrase}'
        };
      });
    }
  }

  Future<void> fetchFallbackRoute(String fallbackApiMode) async {
    String url =
        "https://api.geoapify.com/v1/routing?waypoints=${startCoordinates!['latitude']},${startCoordinates!['longitude']}|${endCoordinates!['latitude']},${endCoordinates!['longitude']}&mode=$fallbackApiMode&details=instruction_details&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        responseOutput = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        responseOutput = {
          'error': 'Failed to fetch fallback route: ${response.reasonPhrase}'
        };
      });
    }
  }
  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('userName');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        userName = savedName;
      });
      _showWelcomeMessage();

    }
  }

  Future<void> _saveUserProfile(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name); // Save the username
  }

  void updateUserProfile(String name, String email, String dob, String gen) {
    setState(() {
      userName = name;
      userEmail = email;
      userDob = dob;
      userGen = gen;
    });
    _saveUserProfile(name); // Save the updated name
  }
  void _showWelcomeMessage() {
    if (userName.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Text(
                  userName[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Welcome, $userName!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.blue[700],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Routing App"),
        ),
        drawer: Drawer(
          child: Container(
            color: Colors.blue[50], // Drawer background color
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue[700], // Background color of the account header
                  ),
                  accountName: Text(userName, style: TextStyle(color: Colors.white)),
                  accountEmail: Text(userEmail, style: TextStyle(color: Colors.white)),
                  currentAccountPicture: CircleAvatar(
                    child: Text(userName.isNotEmpty ? userName[0] : "U", style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue[900],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Profile"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        initialName: userName,
                        initialEmail: userEmail,
                        initialDob: userDob,
                        initialGender: userGen,
                        onSave: updateUserProfile,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Settings"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.more),
                  title: Text("More"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MoreScreen()),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogoutScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField(
                        value: selectedVehicleType,
                        items: vehicleTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedVehicleType = value.toString();
                            print(
                                'Selected vehicle type is $selectedVehicleType');
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Vehicle Type",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      GooglePlaceAutoCompleteTextField(
                        containerHorizontalPadding: 10,
                        textEditingController: startLocationController,
                        googleAPIKey: "AIzaSyAQxt5fBB3z51rDf6mkePd3qCJnjtiwM2A",
                        inputDecoration:
                        InputDecoration(border: InputBorder.none),
                        debounceTime: 800,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          setState(() {
                            startLat = prediction.lat.toString();
                            startLng = prediction.lng.toString();
                          });
                        },
                        itemClick: (Prediction prediction) {
                          startLocationController.text =
                          prediction.description!;
                          startLocationController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                        },
                      ),
                      SizedBox(height: 8),
                      GooglePlaceAutoCompleteTextField(
                        containerHorizontalPadding: 10,
                        seperatedBuilder: SizedBox(),
                        textEditingController: endLocationController,
                        googleAPIKey: "AIzaSyAQxt5fBB3z51rDf6mkePd3qCJnjtiwM2A",
                        inputDecoration:
                        InputDecoration(border: InputBorder.none),
                        debounceTime: 800,
                        isLatLngRequired: true,
                        getPlaceDetailWithLatLng: (Prediction prediction) {
                          setState(() {
                            endLat = prediction.lat.toString();
                            endLng = prediction.lng.toString();
                          });
                        },
                        itemClick: (Prediction prediction) {
                          endLocationController.text = prediction.description!;
                          endLocationController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: prediction.description!.length));
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchRoute,
                  child: Text("Find Route"),
                ),
                SizedBox(height: 16),
                if (isLoading) CircularProgressIndicator() else _buildOutput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutput() {
    if (responseOutput == null) return SizedBox.shrink();

    if (responseOutput!.containsKey('error')) {
      return Text(
        responseOutput!['error'],
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    if (responseOutput!.containsKey('message')) {
      return Text(
        responseOutput!['message'],
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    }
    List<dynamic> legs = responseOutput!['features'][0]['properties']['legs'];
    List<String> directions = [];
    for (var leg in legs) {
      for (var step in leg['steps']) {
        directions.add(step['instruction']['text']);
      }
    }

    return Column(
      children: [
        Container(
          height: 280,
          child: ListView(
            children: [
              ListTile(
                title: Text("Route Directions step-by-step",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: directions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.all(10),
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 10)
                            ]),
                        child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${index + 1}:"),
                                Text(directions[index]),
                              ],
                            )),
                      );
                    }),
              )

              // for (var direction in directions)
              //   ListTile(
              //     title: Text(direction),
              //   ),
            ],
          ),
        ),

        Column(
          children: [
            Container(
                height: 500,
                child: GoogleMap(
                  onMapCreated: (gmf.GoogleMapController controller) {
                    // mapController = controller;
                  },
                  initialCameraPosition: gmf.CameraPosition(
                    target: gmf.LatLng(
                        double.parse(startLat), double.parse(startLng)),
                    zoom: 14.0,
                  ),
                  polylines: _polylines,
                  markers: _markers,
                )),
            ListTile(
              leading: Icon(Icons.my_location, color: Colors.green),
              title: Text("Start Coordinates"),
              subtitle: Text("Lat: $startLat, Lon: $startLng"),
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.red),
              title: Text("End Coordinates"),
              subtitle: Text("Lat: $endLat, Lon: $endLat"),
            ),
          ],
        ),
      ],
    );


  }
}
