import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:fire_app/model/shared_location_model.dart';
import 'package:fire_app/database/firebase_location_service.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:intl/intl.dart';



class ShowLocationScreen extends StatefulWidget {
  const ShowLocationScreen({super.key});

  @override
  State<ShowLocationScreen> createState() => _ShowLocationScreenState();
}

class _ShowLocationScreenState extends State<ShowLocationScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseLocationService _firebaseLocationService = FirebaseLocationService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  bool _isCompressing = false;
  double _compressionProgress = 0.0;
  bool isLoading = true;
  bool isLoadingSharedLocations = false;


  LatLng? _currentLocation;
  LatLng? _destination;

  List<LatLng> _route = [];
  List<SharedLocation> _sharedLocations = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadSharedLocations();
    
  }

  void _loadSharedLocations() {
    setState(() {
      isLoadingSharedLocations = true;
    });

    _firebaseLocationService.getSharedLocations().listen((locations) {
      setState(() {
        _sharedLocations = locations;
        isLoadingSharedLocations = false;
      });
    }, onError: (error) {
      print("Erro ao carregar locais: $error");
      setState(() {
        isLoadingSharedLocations = false;
      });
    });
  }

  

  Future<void> _initializeLocation() async{
    if (!await _checktheRequestPermissions()) return;

    _location.onLocationChanged.listen(
      (LocationData locationData){
        if(locationData.latitude != null && locationData.longitude != null){
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!); 
            isLoading = false; 
          });
        }
      }
    );
  }

 Future<void> _fetchCoordinatesPoints(String location) async {
  try {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1');
     final headers = {
      'User-Agent': 'FireApp/1.0 (fireapp62@gmail.com)' 
    };
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data.isNotEmpty && data is List) {
        final lat = double.tryParse(data[0]['lat']?.toString() ?? '');
        final lon = double.tryParse(data[0]['lon']?.toString() ?? '');
        
        if (lat != null && lon != null) {
          setState(() {
            _destination = LatLng(lat, lon);
          });
          await fetchRoute();
        } else {
          errorMessage('Coordenadas inválidas na resposta');
        }
      } else {
        errorMessage('Localização não encontrada, por favor tente outra pesquisa');
      }
    } else {
      // Tratamento para outros status codes
      final errorMsg = _handleErrorResponse(response);
      errorMessage('Erro na requisição: $errorMsg');
    }
  } catch (e) {
    errorMessage('Erro inesperado: $e');
  }
}

String _handleErrorResponse(http.Response response) {
  switch (response.statusCode) {
    case 400:
      return 'Requisição inválida';
    case 404:
      return 'Serviço não encontrado';
    case 429:
      return 'Muitas requisições - tente novamente mais tarde';
    case 500:
      return 'Erro interno do servidor';
    default:
      return 'Erro HTTP ${response.statusCode}';
  }
}

  Future<void> fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;
    final url = Uri.parse("http://router.project-osrm.org/route/v1/driving/"
    '${_currentLocation!.longitude},${_currentLocation!.latitude};''${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline');
    final response = await http.get(url);

    if (response.statusCode == 200){
      final data = json.decode(response.body);
      final geometry = data['routes'][0]['geometry'];
      _decodePolyLine(
        geometry
      );
    }else {
      errorMessage('Falha em encontrar as rotas, tente novamente mais tarde');
    }
  }

  void _decodePolyLine(String encodedPolyLine){
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePoints = 
      polylinePoints.decodePolyline(encodedPolyLine);

      setState(() {
        _route = decodePoints
          .map((point)=> LatLng(point.latitude, point.longitude))
          .toList();
      });
  }

  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if(!serviceEnabled){
      serviceEnabled = await _location.requestService();
      if(!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if(permissionGranted == PermissionStatus.denied){
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    return true;
  }
  
  Future <void> _userCurrentLocation() async {
    if(_currentLocation != null){
      _mapController.move(_currentLocation!,15);
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Localização Atual não disponível."),
          ), 
      );
    }
  }

Marker _buildSharedLocationMarker(SharedLocation location) {
  Color markerColor;
  IconData markerIcon;
  
  switch (location.type) {
    case 'park':
      markerColor = Colors.green;
      markerIcon = Icons.park;
      break;
    case 'landmark':
      markerColor = Colors.orange;
      markerIcon = Icons.landscape;
      break;
    case 'restaurant':
      markerColor = Colors.red;
      markerIcon = Icons.restaurant;
      break;
    case 'fire':
      markerColor = Colors.red;
      markerIcon = Icons.fireplace;
      break;
    default:
      markerColor = Colors.blue;
      markerIcon = Icons.location_pin;
  }

  return Marker(
    point: location.toLatLng(),
    width: 50,
    height: 50,
    child: GestureDetector(
      onTap: () {
        _showLocationDetails(location);
      },
      child: Container(
        width: 50, 
        height: 50, 
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(
              markerIcon,
              color: markerColor,
              size: 25, 
            ),
            SizedBox(height: 2), 
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1), 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              child: Text(
                location.description, //O que mostra abaixo do ponto
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, 
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showLocationDetails(SharedLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(location.description),
            SizedBox(height: 8),
            Text(
              'Coordenadas: ${location.lat.toStringAsFixed(4)}, ${location.lng.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _setDestinationFromSharedLocation(location);
            },
            child: Text('Traçar Rota'),
          ),
        ],
      ),
    );
  }

  void _setDestinationFromSharedLocation(SharedLocation location) {
    setState(() {
      _destination = location.toLatLng();
    });
    fetchRoute();
  }

  //FIM MARCADORES

Future<void> _addCurrentLocationWithPhoto() async {
  if (_currentLocation == null) {
    errorMessage('Localização atual não disponível');
    return;
  }

  // Verifica permissões
final permission_handler.PermissionStatus cameraStatus = await permission_handler.Permission.camera.request();
final permission_handler.PermissionStatus storageStatus = await permission_handler.Permission.storage.request();
  
  if (!cameraStatus.isGranted || !storageStatus.isGranted) {
    errorMessage('Permissões da câmera e armazenamento são necessárias');
    return;
  }

  final result = await _showAddLocationDialog();
  if (result != null) {
    final String name = result['name'];
    final String description = result['description'];
    final Uint8List? imageBytes = result['image'];
    
    setState(() {
      _isUploading = true;
      _isCompressing = true;
      _compressionProgress = 0.0;
    });

    try {
      _simulateCompressionProgress(); // Opcional - para UX
      
      final newLocation = SharedLocation(
        id: '',
        lat: _currentLocation!.latitude,
        lng: _currentLocation!.longitude,
        name: name,
        description: description,
        createdBy: 'current_user',
        type: 'fire',
        createdAt: DateTime.now(),
      );

      await _firebaseLocationService.addSharedLocation(
        newLocation, 
        imageBytes: imageBytes
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Ponto de incêndio adicionado com sucesso!')),
      );
    } catch (e) {
      errorMessage('Erro ao adicionar ponto: $e');
    } finally {
      setState(() {
        _isUploading = false;
        _isCompressing = false;
        _compressionProgress = 0.0;
      });
    }
  }
}

Future<Map<String, dynamic>?> _showAddLocationDialog() async {
  String name = 'Incêndio ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';
  String description = '';
  Uint8List? imageBytes;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text('Registrar Ponto de Incêndio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => name = value,
                  controller: TextEditingController(text: name),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                    hintText: 'Descreva a situação do incêndio...',
                  ),
                  maxLines: 3,
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 16),
                
                // Preview da imagem
                if (imageBytes != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: MemoryImage(imageBytes!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                
                if (imageBytes != null) 
                  Text(
                    'Imagem pronta para upload',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                
                SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.photo_camera),
                        label: Text('Tirar Foto'),
                        onPressed: () async {
                          final XFile? image = await _imagePicker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                            maxWidth: 800,
                          );
                          
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() {
                              imageBytes = bytes;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                
                if (imageBytes == null)
                  Text(
                    'Tire uma foto do incêndio para documentação',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: imageBytes != null && description.isNotEmpty
                  ? () => Navigator.pop(context, {
                        'name': name,
                        'description': description,
                        'image': imageBytes,
                      })
                  : null,
              child: Text('Salvar'),
            ),
          ],
        );
      },
    ),
  );
}

// ADICIONAR ESTAS FUNÇÕES:

void _simulateCompressionProgress() {
  for (int i = 0; i <= 100; i += 10) {
    Future.delayed(Duration(milliseconds: i * 10), () {
      if (mounted) {
        setState(() {
          _compressionProgress = i / 100.0;
        });
      }
    });
  }
}

Widget _buildCompressionOverlay() {
  if (!_isCompressing) return SizedBox.shrink();
  
  return Container(
    color: Colors.black54,
    child: Center(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comprimindo imagem...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CircularProgressIndicator(value: _compressionProgress, strokeWidth: 4),
            SizedBox(height: 8),
            Text('${(_compressionProgress * 100).toInt()}%', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}


  void errorMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message)
      ),
    );
  }

   Widget _title(){
    return const Text('Marque pontos de Incêndio!');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          title: _title(),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red,Colors.red, Colors.yellow],
                stops: [0.0, 0.5, 9.0],
              ),
            ),
          ),
          elevation: 0,
        ),
      body: Stack(
        children: [
          isLoading
            ? const Center(child: CircularProgressIndicator(),
            ) 
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(0,0), //LatLng(-15.351792,-49.595488),
              initialZoom: 12,
              minZoom: 0,
              maxZoom: 100 
            ),
            children: [
              TileLayer(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png"),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),

              MarkerLayer(
                      markers: _sharedLocations
                          .map(_buildSharedLocationMarker)
                          .toList(),
                    ),

              if (_destination != null)
                MarkerLayer(
                  markers:[
                    Marker(
                      point: _destination!,
                      width: 50,
                      height: 50,
                      child: Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                if(_currentLocation != null && _destination != null && _route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(points: _route,strokeWidth: 5, color: Colors.red)
                ]),
                
                _buildCompressionOverlay(),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Digite a localização',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: 
                          const EdgeInsets.symmetric(horizontal: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: (){
                      final location = _locationController.text.trim();
                      if (location.isNotEmpty){
                        _fetchCoordinatesPoints(
                          location
                        );
                      }
                    },
                    icon: const Icon(Icons.search),
                  )
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Text(
                '${_sharedLocations.length} pontos encontrados',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isUploading)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(strokeWidth: 2),
                    SizedBox(width: 8),
                    Text('Enviando...'),
                  ],
                ),
              ),
            
            FloatingActionButton.small(
              heroTag: "add_location_button",
              onPressed: _isUploading ? null : _addCurrentLocationWithPhoto,
              backgroundColor: _isUploading ? Colors.grey : Colors.red,
              child: _isUploading 
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    )
                  : Icon(Icons.add_location, color: Colors.white),
            ),
            SizedBox(height: 8),
            
            FloatingActionButton(
              heroTag: "my_location_button",
              onPressed: _userCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, size: 30, color: Colors.white),
            ),
          ],
        ),
    );
  }
}

