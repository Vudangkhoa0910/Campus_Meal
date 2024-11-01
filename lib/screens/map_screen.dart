import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _initialPosition = LatLng(20.962791517851002, 105.74866493969844);
  late MapController _mapController;

  List<Marker> _markers = [];
  LatLng _currentCenter = LatLng(20.962791517851002, 105.74866493969844); // Vị trí hiện tại của bản đồ
  double _currentZoom = 12.0; // Zoom hiện tại

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange, // Màu cam chủ đạo
        title: Text('CAMPUS MEAL MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Thêm chức năng tìm kiếm ở đây
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition, // Sử dụng initialCenter thay cho center
              initialZoom: _currentZoom, // Sử dụng initialZoom thay cho zoom
              onPositionChanged: (mapPosition, _) {
                setState(() {
                  _currentCenter = mapPosition.center!;
                  _currentZoom = mapPosition.zoom!;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          Positioned(
            bottom: 115,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _mapController.move(_currentCenter, _currentZoom + 1); // Phóng to
                  },
                  backgroundColor: Colors.orange, // Màu cam
                  child: Icon(Icons.zoom_in, color: Colors.white),
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    _mapController.move(_currentCenter, _currentZoom - 1); // Thu nhỏ
                  },
                  backgroundColor: Colors.orange, // Màu cam
                  child: Icon(Icons.zoom_out, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.orange, // Màu cam chủ đạo
        tooltip: 'Get Current Location',
        child: Icon(Icons.location_searching, color: Colors.white),
      ),
    );
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _mapController.move(currentLatLng, 15.0); // Di chuyển camera đến vị trí hiện tại
      _markers = [
        Marker(
          point: currentLatLng,
          width: 40.0,
          height: 40.0,
          child: Icon( // Thêm đối số child vào đây
            Icons.location_pin,
            color: Colors.orange, // Marker có màu cam
            size: 40.0,
          ),
        ),
      ];
    });
  }

  void _showSearchDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // Màu nền của dialog
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Bo góc cho dialog
        ),
        title: Text(
          'Search Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.orange, // Màu chữ
          ),
        ),
        content: Container(
          width: 300, // Chiều rộng của dialog
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Enter location',
              hintStyle: TextStyle(color: Colors.grey), // Màu chữ gợi ý
              prefixIcon: Icon(Icons.search, color: Colors.orange), // Biểu tượng tìm kiếm
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0), // Bo góc cho trường nhập
                borderSide: BorderSide(color: Colors.orange), // Màu viền
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.orange, width: 2), // Màu viền khi chọn
              ),
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop();
              _searchLocation(value);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      );
    },
  );
}

  void _searchLocation(String location) {
    print('Searching for: $location');
    LatLng searchedLocation = LatLng(20.962791517851002, 105.74866493969844);
    setState(() {
      _mapController.move(searchedLocation, 15.0);
      _markers = [
        Marker(
          point: searchedLocation,
          width: 40.0,
          height: 40.0,
          child: Icon(
            Icons.location_pin,
            color: Colors.orange,
            size: 40.0,
          ),
        ),
      ];
    });
  }
}
