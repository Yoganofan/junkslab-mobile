import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final isMobile = MediaQuery.of(context).size.width < 800;

    // --- WIDGET PETA INTERAKTIF ---
    Widget mapWidget = Container(
      height: 350,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(-6.9825, 107.6288), // Area Bojongsoang
          initialZoom: 13.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.junkslab.admin',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(-6.9825, 107.6288),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              Marker(
                point: LatLng(-6.9936, 107.6225),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              Marker(
                point: LatLng(-7.0142, 107.6253),
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // --- WIDGET PROGRES PENJEMPUTAN ---
    Widget progressWidget = Column(
      children: [
        _buildProgressItem('Rute A - Dapur MBG Utara', 0.75, context),
        _buildProgressItem('Rute B - Pasar Sayur Pusat', 0.30, context),
        _buildProgressItem('Rute C - Peternakan Selatan', 0.15, context),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang kembali, Jupiter',
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            'Berikut adalah ringkasan operasional Anda hari ini.',
            style: TextStyle(color: secondaryTextColor, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // --- KARTU STATISTIK ---
          if (isMobile)
            Column(
              children: [
                _buildStatCard(
                  'Penjemputan Aktif',
                  '24',
                  '+12% dari kemarin',
                  Icons.local_shipping_outlined,
                  Colors.green,
                  context,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Limbah Terolah (kg)',
                  '1,450',
                  'Target 3 ton minggu ini',
                  Icons.eco_outlined,
                  Colors.green[800]!,
                  context,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  'Poin Terkumpul',
                  '8,200',
                  'Tingkat selanjutnya di 10rb',
                  Icons.stars_outlined,
                  Colors.orange,
                  context,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Penjemputan Aktif',
                    '24',
                    '+12% dari kemarin',
                    Icons.local_shipping_outlined,
                    Colors.green,
                    context,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    'Limbah Terolah (kg)',
                    '1,450',
                    'Target 3 ton minggu ini',
                    Icons.eco_outlined,
                    Colors.green[800]!,
                    context,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    'Poin Terkumpul',
                    '8,200',
                    'Tingkat selanjutnya di 10rb',
                    Icons.stars_outlined,
                    Colors.orange,
                    context,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // --- AREA BAWAH (CHART, PETA, & PROGRESS) ---
          if (isMobile)
            Column(
              children: [
                _buildDashboardSection(
                  title: 'Statistik Limbah Mingguan (Kg)',
                  child: _buildBarChart(context),
                  context: context,
                ),
                const SizedBox(height: 24),
                _buildDashboardSection(
                  title: 'Titik Penyedia Limbah',
                  child: mapWidget,
                  context: context,
                ),
                const SizedBox(height: 24),
                _buildDashboardSection(
                  title: 'Progres Penjemputan',
                  child: progressWidget,
                  context: context,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildDashboardSection(
                        title: 'Statistik Pengumpulan Limbah (Mingguan)',
                        child: _buildBarChart(context),
                        context: context,
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardSection(
                        title: 'Lokasi Titik Penyedia Limbah',
                        child: mapWidget,
                        context: context,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildDashboardSection(
                    title: 'Progres Penjemputan',
                    child: progressWidget,
                    context: context,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- WIDGET BAR CHART MENGGUNAKAN FL_CHART ---
  Widget _buildBarChart(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 400,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} Kg\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Sen',
                    'Sel',
                    'Rab',
                    'Kam',
                    'Jum',
                    'Sab',
                    'Min',
                  ];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _buildBarGroup(0, 150),
            _buildBarGroup(1, 280),
            _buildBarGroup(2, 180),
            _buildBarGroup(3, 350),
            _buildBarGroup(4, 250),
            _buildBarGroup(5, 300),
            _buildBarGroup(6, 120),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.green[600],
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 400,
            color: Colors.green.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Colors.green[700], fontSize: 12)),
        ],
      ),
    );
  }

  // ---> BAGIAN INI YANG DIPERBAIKI (Penambahan widget Expanded) <---
  Widget _buildDashboardSection({
    required String title,
    required Widget child,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                // <-- Mencegah error pita kuning/overflow
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // <-- Font diperkecil sedikit agar rapi
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View List',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String route,
    double progress,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                route,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).dividerColor,
            color: Colors.green[800],
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
