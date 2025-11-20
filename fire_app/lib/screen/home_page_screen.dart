import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../core/navigation/app_routes.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final MapController mapController = MapController();

  // 🔥 Posição inicial do mapa (Campus IF Goiano – Ceres)
  final LatLng initialPoint = LatLng(-15.3080, -49.6050);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          /// ===========================================================
          /// 🗺 MAPA EM TELA CHEIA
          /// ===========================================================
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: initialPoint,
              initialZoom: 15,
              maxZoom: 19,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.fireapp.app",
              ),

              // 📌 Aqui futuramente adicionamos marcadores de incêndio
            ],
          ),

          /// ===========================================================
          /// ☰ BOTÃO SANDUÍCHE — abre Menu Rápido
          /// ===========================================================
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

          /// ===========================================================
          /// 🔻 BARRA INFERIOR FIXA — Informações / Notificações / Adicionar
          /// ===========================================================
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
                  /// 📘 INFORMAÇÕES
                  _BottomButton(
                    icon: Icons.info_outline,
                    label: "Informações",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.informacoes),
                  ),

                  /// 🔔 NOTIFICAÇÕES
                  _BottomButton(
                    icon: Icons.notifications_none_outlined,
                    label: "Notificações",
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.meusAlertas),
                  ),

                  /// ➕ ADICIONAR INCÊNDIO
                  _BottomButton(
                    icon: Icons.add_circle_outline,
                    label: "Adicionar",
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.cadastroIncendio,
                    ),
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

/// =====================================================================
/// 🔘 COMPONENTE DO BOTÃO INFERIOR
/// =====================================================================
class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
