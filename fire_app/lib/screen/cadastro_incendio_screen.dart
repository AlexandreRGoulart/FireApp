import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_button.dart';
import '../components/app_input.dart';
import '../database/incendio_service.dart';
import '../model/incendio_model.dart';
import 'adicionar_mapa_screen.dart';

class CadastroIncendioScreen extends StatefulWidget {
  const CadastroIncendioScreen({super.key});

  @override
  State<CadastroIncendioScreen> createState() => _CadastroIncendioScreenState();
}

class _CadastroIncendioScreenState extends State<CadastroIncendioScreen> {
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController nivelRiscoController = TextEditingController();

  final MapController _mapController = MapController();
  final Location _location = Location();
  final IncendioService _incendioService = IncendioService();

  LatLng? _currentLocation;

  bool isLoading = true;
  bool isSaving = false;

  // Polígono desenhado no mapa de seleção
  List<LatLng> areaPoligono = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((loc) {
      if (loc.latitude != null && loc.longitude != null) {
        setState(() {
          _currentLocation = LatLng(loc.latitude!, loc.longitude!);
          isLoading = false;
        });
      }
    });
  }

  // Abre a tela para desenhar área
  Future<void> _abrirMapaDesenho() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdicionarMapaScreen()),
    );

    if (resultado != null && resultado is List<LatLng>) {
      setState(() {
        areaPoligono = resultado;
      });
    }
  }

  // Salvar incêndio no banco
  void _salvarIncendio() async {
    if (descricaoController.text.isEmpty ||
        nivelRiscoController.text.isEmpty ||
        areaPoligono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha todos os campos e desenhe a área no mapa."),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final incendio = IncendioModel(
        descricao: descricaoController.text,
        nivelRisco: nivelRiscoController.text,
        areaPoligono: areaPoligono,
        criadoEm: DateTime.now().toIso8601String(),
        latitude: _currentLocation?.latitude,
        longitude: _currentLocation?.longitude,
      );

      await _incendioService.salvarIncendio(incendio);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("✓ Incêndio registrado com sucesso!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔙 topo
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// 🔥 título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Registrar incêndio",
                style: AppTextStyles.titleMedium,
              ),
            ),

            const SizedBox(height: 20),

            /// 📝 campos de texto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                children: [
                  AppInput(
                    label: "Descrição do incêndio",
                    hint: "Ex: Fumaça densa próxima à mata",
                    controller: descricaoController,
                  ),
                  const SizedBox(height: 16),

                  AppInput(
                    label: "Nível de risco",
                    hint: "Ex: Alto / Médio / Baixo",
                    controller: nivelRiscoController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🗺️ MINI MAPA + POLÍGONO
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isLoading || _currentLocation == null
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation!,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            ),

                            // Polígono desenhado
                            PolygonLayer(
                              polygons: [
                                if (areaPoligono.isNotEmpty)
                                  Polygon(
                                    points: areaPoligono,
                                    color: Colors.red.withOpacity(0.3),
                                    borderColor: Colors.red,
                                    borderStrokeWidth: 3,
                                  ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// ✏️ botão abrir tela de desenho
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: "Adicionar área no mapa",
                outlined: true,
                onPressed: _abrirMapaDesenho,
              ),
            ),

            const SizedBox(height: 12),

            /// 🔴 salvar incêndio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: isSaving ? "Salvando..." : "Salvar incêndio",
                onPressed: (descricaoController.text.isNotEmpty &&
                        nivelRiscoController.text.isNotEmpty &&
                        areaPoligono.isNotEmpty &&
                        !isSaving)
                    ? _salvarIncendio
                    : () {},
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
