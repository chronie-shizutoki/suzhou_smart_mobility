import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/station.dart';
import '../utils/zh_converter.dart';
import '../widgets/glass_container.dart';
import '../widgets/station_detail_view.dart';

class StationDetailPage extends StatelessWidget {
  final String stationId;
  final String stationName;
  final String? stationRoad;
  final double latitude;
  final double longitude;

  const StationDetailPage({
    super.key,
    required this.stationId,
    required this.stationName,
    this.stationRoad,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final station = Station(
      stationId: stationId,
      stationName: stationName,
      latitude: latitude,
      longitude: longitude,
      stationRoad: stationRoad,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F0F1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF0F4F8),
                    const Color(0xFFE8EEF5),
                    const Color(0xFFD9E2EC),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, localizations),
              Expanded(
                child: StationDetailView(station: station),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            iconColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConvertedText(
                  stationName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (stationRoad != null)
                  ConvertedText(
                    stationRoad!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
