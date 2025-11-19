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

  // Posição inicial do mapa (Brasil)
  static const LatLng initialPosition = LatLng(-15.793889, -47.882778);

  // FUTURO: pontos para desenhar polígono
  final List<LatLng> polygonPoints = [];

  @override
  Widget build(BuildContext context) {
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

            const SizedBox(height: 20),

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

                    /// FUTURO: detectar pontos clicados
                    onTap: (LatLng position) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Modo desenho ainda não implementado"),
                        ),
                      );
                    },

                    polygons: {
                      Polygon(
                        polygonId: const PolygonId('area'),
                        points: polygonPoints,
                        strokeColor: Colors.red,
                        strokeWidth: 3,
                        fillColor: Colors.red.withOpacity(0.2),
                      ),
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// BOTÃO: DESENHAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: "Desenhar área",
                outlined: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Modo de desenho será implementado"),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            /// BOTÃO: SALVAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: AppButton(
                text: "Salvar área no incêndio",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Polígono salvo (demo)")),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
