import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;

const String googleApiKey =
    "AIzaSyB1aKJp3HqKWfbnuRfKLV8k1ZX2F-O80us"; // ضع مفتاح Google API هنا

class MapSelectionScreen extends StatefulWidget {
  final Function(double lat, double lng, String address, String placeId,
      String placeName) onLocationSelected;

  const MapSelectionScreen({
    Key? key,
    required this.onLocationSelected,
  }) : super(key: key);
  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  TextEditingController searchController = TextEditingController();
  List<dynamic> suggestions = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getPlaceNameFromLatLng(LatLng location) async {
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$googleApiKey&language=ar";
    try {
      dio.Response response = await dio.Dio().get(url);
      if (response.statusCode == 200) {
        var results = response.data['results'];
        if (results.isNotEmpty) {
          String address = results[0]['formatted_address'];
          setState(() {
            searchController.text = address; // تحديث حقل البحث تلقائيًا
          });
        }
      }
    } catch (e) {
      print("❌ خطأ في جلب اسم المكان: $e");
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Get.dialog(
        AlertDialog(
          title: Text('Activate the site'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: Colors.blue, size: 50),
              SizedBox(height: 16),
              Text(
                  "Location services must be enabled on your device to use this feature."
                    ..tr),
              SizedBox(height: 8),
              Text(
                "Click OK and you will be directed to enable location services and then return to the app."
                    .tr,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel".tr),
            ),
            TextButton(
              onPressed: () async {
                Get.back(); // إغلاق البوب أب
                await Geolocator.openLocationSettings(); // فتح الإعدادات

                Future.delayed(Duration(seconds: 2), () async {
                  if (await Geolocator.isLocationServiceEnabled()) {
                    Navigator.pop(context); // إغلاق الصفحة والعودة تلقائيًا
                  }
                });
              },
              child: Text('OK'.tr),
            ),
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    // الحصول على الموقع بعد منح الإذن
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng userLocation = LatLng(position.latitude, position.longitude);

      mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: userLocation, zoom: 15),
      ));

      setState(() {
        selectedLocation = userLocation;
        _updateMarker(userLocation);
      });

      _getPlaceNameFromLatLng(userLocation);
    } catch (e) {}
  }

  Future<List<dynamic>> fetchPlaceSuggestions(String input) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey&language=ar";
    try {
      dio.Response response = await dio.Dio().get(url);
      if (response.statusCode == 200) {
        return response.data['predictions'];
      }
    } catch (e) {
      print("❌ خطأ في جلب الاقتراحات: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('selected location'.tr,
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue),
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBar(),
          if (selectedLocation != null) _buildConfirmButton(),
          Positioned(
            bottom: 80, // لتحديد المسافة من الأسفل

            left: 16, // لتحديد المسافة من اليمين
            child: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: _getUserLocation,
              child: Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition:
          const CameraPosition(target: LatLng(26.0, 45.0), zoom: 2.0),
      onMapCreated: (controller) {
        mapController = controller;
        _getUserLocation();
      },
      markers: markers,
      onTap: _onMapTap,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 10,
      right: 15,
      left: 15,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Find a place...".tr,
              prefixIcon: Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (query) async {
              if (query.isEmpty) {
                setState(() {
                  suggestions = [];
                });
              } else if (query.length > 2) {
                List<dynamic> results = await fetchPlaceSuggestions(query);
                setState(() {
                  suggestions = results;
                });
              }
            },
          ),
          if (suggestions.isNotEmpty)
            if (suggestions.isNotEmpty)
              Material(
                elevation: 5, // تأثير الظل
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    separatorBuilder: (context, index) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () async {
                          await _handlePlaceSelection(
                              suggestions[index]['place_id']);
                          setState(() {
                            suggestions = [];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.blueAccent),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  suggestions[index]['description'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                  overflow:
                                      TextOverflow.ellipsis, // تجنب النص الطويل
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceSelection(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey&language=ar";
    try {
      dio.Response response = await dio.Dio().get(url);
      if (response.statusCode == 200) {
        var detail = response.data['result'];
        double lat = detail['geometry']['location']['lat'];
        double lng = detail['geometry']['location']['lng'];
        LatLng newPosition = LatLng(lat, lng);

        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 15)));
        setState(() {
          selectedLocation = newPosition;
          searchController.text = detail['name'];
          _updateMarker(newPosition);
        });
      }
    } catch (e) {
      print("❌ خطأ في جلب تفاصيل المكان: $e");
    }
  }

  Widget _buildConfirmButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 50)),
          onPressed: _confirmLocation,
          child: Text('Confirm location'.tr,
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ),
    );
  }

  void _confirmLocation() {
    if (selectedLocation == null) return;

    widget.onLocationSelected(
      selectedLocation!.latitude,
      selectedLocation!.longitude,
      searchController.text, // يرسل اسم الموقع الفعلي
      "placeId", // يمكن جلبه لاحقًا من Google Places API
      searchController.text,
    );
    Get.back();
  }

  void _onMapTap(LatLng location) async {
    setState(() {
      selectedLocation = location;
      _updateMarker(location);
    });
    await _getPlaceNameFromLatLng(location); // تحديث اسم المكان
  }

  void _updateMarker(LatLng location) {
    markers = {
      Marker(
          markerId: MarkerId('selecte location'.tr),
          position: location,
          infoWindow: InfoWindow(title: 'specified location'.tr)),
    };
    setState(() {});
  }
}
