import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../components/app_button.dart';

class AdicionarMapaScreen extends StatefulWidget {
  const AdicionarMapaScreen({super.key});

  @override
  State<AdicionarMapaScreen> createState() => _AdicionarMapaScreenState();
}

class _AdicionarMapaScreenState extends State<AdicionarMapaScreen> {
  GoogleMapController? mapController;

  // Posição inicial do mapa (ex.: Brasil)
  static const LatLng initialPosition = LatLng(-15.793889, -47.882778);

  // Pontos do polígono
  final List<LatLng> polygonPoints = [];

  // Controle do modo de desenho
  bool isDrawing = false;

  void _toggleDrawingMode() {
    setState(() {
      // ao iniciar o desenho, limpamos os pontos anteriores
      isDrawing = !isDrawing;
      if (isDrawing) {
        polygonPoints.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Modo desenho ativado. Toque no mapa para marcar os pontos da área.",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modo desenho desativado.")),
        );
      }
    });
  }

  void _onMapTap(LatLng position) {
    if (!isDrawing) return;

    setState(() {
      polygonPoints.add(position);
    });
  }

  void _onSaveArea() {
    if (polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Defina pelo menos 3 pontos para formar uma área."),
        ),
      );
      return;
    }

    // Futuro: enviar polygonPoints para o cadastro de incêndio / Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Área de incêndio salva (demo).")),
    );

    // Exemplo: voltar com o resultado depois
    // Navigator.pop(context, polygonPoints);
  }

  @override
  Widget build(BuildContext context) {
    final polygons = <Polygon>{
      if (polygonPoints.isNotEmpty)
        Polygon(
          polygonId: const PolygonId('area'),
          points: polygonPoints,
          strokeColor: Colors.red,
          strokeWidth: 3,
          fillColor: Colors.red.withOpacity(0.25),
        ),
    };

    final markers = polygonPoints
        .asMap()
        .entries
        .map(
          (entry) => Marker(
            markerId: MarkerId('p${entry.key}'),
            position: entry.value,
            infoWindow: InfoWindow(title: 'Ponto ${entry.key + 1}'),
          ),
        )
        .toSet();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// BOTÃO VOLTAR
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// TÍTULO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Adicionar no mapa",
                style: AppTextStyles.titleMedium,
              ),
            ),

            const SizedBox(height: 8),

            /// STATUS DO DESENHO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                isDrawing
                    ? "Modo desenho ativo — toque no mapa para marcar pontos."
                    : "Toque em 'Desenhar área' para começar.",
                style: AppTextStyles.small,
              ),
            ),

            const SizedBox(height: 16),

            /// MAPA
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: initialPosition,
                      zoom: 4,
                    ),
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    onTap: _onMapTap,
                    polygons: polygons,
                    markers: markers,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BOTÃO: DESENHAR / PARAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: isDrawing ? "Parar desenho" : "Desenhar área",
                outlined: true,
                onPressed: _toggleDrawingMode,
              ),
            ),

            const SizedBox(height: 14),

            /// BOTÃO: SALVAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: "Salvar área no incêndio",
                onPressed: _onSaveArea,
                isDisabled: polygonPoints.length < 3,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
