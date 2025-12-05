import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../core/navigation/app_routes.dart';
import '../core/notifications/notification_service.dart';
import '../database/incendio_service.dart';
import '../model/incendio_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final MapController mapController = MapController();
  final Location _location = Location();
  final IncendioService _incendioService = IncendioService();
  final Distance _distance = const Distance();
  final Set<String> _notifiedIncendios = {};

  LatLng? _currentLocation;
  List<IncendioModel> _incendios = [];
  bool _isLoadingLocation = true;
  bool _hasCenteredOnUser = false;

  // 🔥 Posição inicial do mapa (Campus IF Goiano – Ceres)
  final LatLng initialPoint = LatLng(-15.3080, -49.6050);

  @override
  void initState() {
    super.initState();
    _initLocation();
    _listenIncendios();
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await _location.serviceEnabled() || await _location.requestService();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }
    if (permission != PermissionStatus.granted && permission != PermissionStatus.grantedLimited) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    // Última posição conhecida para centralizar rápido
    try {
      final lastLoc = await _location.getLocation();
      if (lastLoc.latitude != null && lastLoc.longitude != null) {
        _currentLocation = LatLng(lastLoc.latitude!, lastLoc.longitude!);
        _isLoadingLocation = false;
        mapController.move(_currentLocation!, 15);
        _hasCenteredOnUser = true;
      }
    } catch (_) {}

    _location.onLocationChanged.listen((loc) {
      if (loc.latitude != null && loc.longitude != null) {
        setState(() {
          _currentLocation = LatLng(loc.latitude!, loc.longitude!);
          _isLoadingLocation = false;
          if (!_hasCenteredOnUser) {
            mapController.move(_currentLocation!, 15);
            _hasCenteredOnUser = true;
          }
        });
      }
    }, onError: (e) {
      setState(() => _isLoadingLocation = false);
      debugPrint('❌ Erro de localização: $e');
    });
  }

  void _listenIncendios() {
    debugPrint('🗺️ [Home] Iniciando stream de incêndios...');
    _incendioService.streamIncendios().listen((incendios) {
      debugPrint('🔥 [Home] Recebido ${incendios.length} incêndios');
      if (_currentLocation != null) {
        _notifyNearbyIncendios(incendios);
      }
      setState(() {
        _incendios = incendios;
      });
    }, onError: (e) {
      debugPrint('❌ [Home] Erro no stream de incêndios: $e');
    });
  }

  void _notifyNearbyIncendios(List<IncendioModel> incendios) {
    if (_currentLocation == null) return;

    for (final inc in incendios) {
      if (inc.latitude == null || inc.longitude == null) continue;

      final distanciaKm = _distance.as(
        LengthUnit.Kilometer,
        _currentLocation!,
        LatLng(inc.latitude!, inc.longitude!),
      );

      final id = inc.id ?? '${inc.latitude}-${inc.longitude}-${inc.criadoEm}';

      if (distanciaKm <= 5 && !_notifiedIncendios.contains(id)) {
        _notifiedIncendios.add(id);
        NotificationService.showNearbyIncendio(
          id: id,
          titulo: 'Incêndio perto de você',
          corpo: '${inc.descricao} • ${distanciaKm.toStringAsFixed(1)} km de distância',
        );
      }
    }
  }

  void _recenterMap() {
    if (_currentLocation != null) {
      mapController.move(_currentLocation!, 15);
      _hasCenteredOnUser = true;
    }
  }

  void _mostrarDetalhesIncendio(IncendioModel inc, LatLng pontoToque) {
    debugPrint('📍 Dialog aberto para: ${inc.descricao}');
    debugPrint('🔍 [Dialog Debug] Descrição completa: "${inc.descricao}"');
    debugPrint('🔍 [Dialog Debug] Foto URL (primeiros 100 chars): "${inc.fotoUrl?.substring(0, math.min(100, inc.fotoUrl?.length ?? 0)) ?? "null"}"');
    debugPrint('🔍 [Dialog Debug] Tamanho Foto URL: ${inc.fotoUrl?.length ?? 0} bytes');
    debugPrint('🔍 [Dialog Debug] Direção: ${inc.direcao}°');
    debugPrint('🔍 [Dialog Debug] Distância: ${inc.distanciaMetros}m');

    DateTime dataHora = DateTime.parse(inc.criadoEm);
    String dataFormatada = '${dataHora.day} de ${_getNomeMes(dataHora.month)}, ${dataHora.hour.toString().padLeft(2, '0')}:${dataHora.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (inc.fotoUrl != null && inc.fotoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Builder(
                        builder: (context) {
                          try {
                            final decodedBytes = base64Decode(inc.fotoUrl!);
                            debugPrint('✅ Foto decodificada com sucesso: ${decodedBytes.length} bytes');
                            return Image.memory(
                              decodedBytes,
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('❌ Erro ao exibir Image.memory: $error');
                                return Container(
                                  height: 250,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  ),
                                );
                              },
                            );
                          } catch (e) {
                            debugPrint('❌ Erro ao decodificar Base64: $e');
                            return Container(
                              height: 250,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: _getCorPorRisco(inc.nivelRisco).withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_fire_department,
                          size: 80,
                          color: _getCorPorRisco(inc.nivelRisco),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inc.descricao,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getCorPorRisco(inc.nivelRisco).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Risco: ${inc.nivelRisco}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _getCorPorRisco(inc.nivelRisco),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade700),
                              const SizedBox(width: 10),
                              Text(
                                dataFormatada,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (inc.direcao != null || inc.distanciaMetros != null)
                          Row(
                            children: [
                              if (inc.direcao != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.blue.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.explore, size: 16, color: Colors.blue.shade700),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Direção',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${inc.direcao!.toStringAsFixed(0)}°',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (inc.direcao != null && inc.distanciaMetros != null)
                                const SizedBox(width: 10),
                              if (inc.distanciaMetros != null)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.orange.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.straighten, size: 16, color: Colors.orange.shade700),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Distância',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${inc.distanciaMetros!.toStringAsFixed(0)} m',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        const SizedBox(height: 20),

                        Text(
                          '📍 COORDENADAS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Centro do Incêndio:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Lat: ${inc.latitude?.toStringAsFixed(6) ?? "N/A"}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                              Text(
                                'Lng: ${inc.longitude?.toStringAsFixed(6) ?? "N/A"}',
                                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getCorPorRisco(inc.nivelRisco),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Fechar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getNomeMes(int mes) {
    const meses = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return meses[mes - 1];
  }

  void _handleMapaTap(LatLng tap) {
    for (final inc in _incendios) {
      if (inc.areaPoligono.isEmpty) continue;
      if (_pointInPolygon(tap, inc.areaPoligono)) {
        debugPrint('🔥 Tap dentro do polígono: ${inc.descricao}');
        _mostrarDetalhesIncendio(inc, tap);
        return;
      }
    }
  }

  bool _pointInPolygon(LatLng tap, List<LatLng> poly) {
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].latitude;
      final yi = poly[i].longitude;
      final xj = poly[j].latitude;
      final yj = poly[j].longitude;

      final intersect = ((yi > tap.longitude) != (yj > tap.longitude)) &&
          (tap.latitude < (xj - xi) * (tap.longitude - yi) / (yj - yi + 1e-12) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  Color _getCorPorRisco(String nivelRisco) {
    switch (nivelRisco.toLowerCase()) {
      case 'alto':
        return Colors.red;
      case 'medio':
      case 'médio':
        return Colors.orange;
      default:
        return Colors.yellow.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? initialPoint,
              initialZoom: 15,
              maxZoom: 19,
              minZoom: 3,
              onTap: (tapPosition, latLng) => _handleMapaTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.fireapp.app",
              ),
              CurrentLocationLayer(
                style: const LocationMarkerStyle(
                  marker: DefaultLocationMarker(),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              PolygonLayer(
                polygons: _incendios
                    .where((inc) => inc.areaPoligono.isNotEmpty)
                    .map((inc) {
                  final cor = _getCorPorRisco(inc.nivelRisco);
                  return Polygon(
                    points: inc.areaPoligono,
                    color: cor.withOpacity(0.3),
                    borderColor: cor,
                    borderStrokeWidth: 2,
                    isFilled: true,
                  );
                }).toList(),
              ),
              MarkerLayer(
                markers: _incendios
                    .where((inc) => inc.latitude != null && inc.longitude != null)
                    .map((inc) {
                  final cor = _getCorPorRisco(inc.nivelRisco);
                  final centerPoint = LatLng(inc.latitude ?? 0, inc.longitude ?? 0);
                  return Marker(
                    point: centerPoint,
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('🔥 Marcador tocado! Abrindo detalhes do incêndio: ${inc.descricao}');
                        _mostrarDetalhesIncendio(inc, centerPoint);
                      },
                      child: Icon(
                        Icons.local_fire_department,
                        color: cor,
                        size: 36,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          if (_isLoadingLocation)
            const Positioned(
              top: 12,
              right: 12,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: SafeArea(
              child: GestureDetector(
                onTap: _recenterMap,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 32,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.telaInicialAcao);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 32),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BottomButton(
                    icon: Icons.info_outline,
                    label: "Informações",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.informacoes),
                  ),
                  _BottomButton(
                    icon: Icons.notifications_none_outlined,
                    label: "Notificações",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.meusAlertas),
                  ),
                  _BottomButton(
                    icon: Icons.add_circle_outline,
                    label: "Adicionar",
                    onTap: () => Navigator.pushNamed(context, AppRoutes.cadastroIncendio),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.small.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
