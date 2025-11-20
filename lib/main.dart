// import yang dibutuhkan
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'catatan_model.dart';

void main() {
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<CatatanModel> _savedNotes = [];
  final MapController _mapController = MapController();

  // fungsi icon sesuai jenis (TAMBAHAN)
  Icon _getIconByJenis(String jenis) {
    if (jenis == "Rumah") {
      return const Icon(Icons.home, color: Colors.blue, size: 35);
    } else if (jenis == "Kantor") {
      return const Icon(Icons.business, color: Colors.green, size: 35);
    } else if (jenis == "Toko") {
      return const Icon(Icons.store, color: Colors.orange, size: 35);
    }
    return const Icon(Icons.location_on, color: Colors.red, size: 35);
  }

  //fungsi untuk mendapatkan lokasi saat ini
  Future<void> _findMyLocation() async {
    //Cek layanan dan izin GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();

    _mapController.move(
      latlong.LatLng(position.latitude, position.longitude),
      15.0,
    );
  }

  // Fungsi menangani Long Press pada peta
  void _handleLongPress(TapPosition _, latlong.LatLng point) async {
    List<Placemark> placemark = await placemarkFromCoordinates(
      point.latitude,
      point.longitude,
    );
    String address = placemark.first.street ?? "Alamat tidak dikenal";

    // Variabel dialog
    String? jenisDipilih;
    String catatan = "";

    // Tampilkan Dialog
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Buat Catatan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Jenis Lokasi"),
                items: const [
                  DropdownMenuItem(value: "Rumah", child: Text("Rumah")),
                  DropdownMenuItem(value: "Toko", child: Text("Toko")),
                  DropdownMenuItem(value: "Kantor", child: Text("Kantor")),
                ],
                onChanged: (value) => jenisDipilih = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Catatan"),
                onChanged: (v) => catatan = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () {
                if (jenisDipilih != null) {
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      },
    );

    if (jenisDipilih == null) return;

    // Simpan marker
    setState(() {
      _savedNotes.add(
        CatatanModel(
          Position: point,
          note: catatan,
          address: address,
          jenis: jenisDipilih!,
          id: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geo-Catatan")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const latlong.LatLng(-6.2, 106.8),
          initialZoom: 13.0,
          onLongPress: _handleLongPress,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),

          // Marker sesuai jenis (TAMBAHAN)
          MarkerLayer(
            markers: _savedNotes
                .map(
                  (n) => Marker(
                    point: n.Position,
                    child: _getIconByJenis(n.jenis), // Icon berubah sesuai jenis
                  ),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
