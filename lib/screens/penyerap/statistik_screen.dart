import 'package:flutter/material.dart';
import '../../helpers/shared_pref_helper.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({Key? key}) : super(key: key);

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  int _limbahTerserap = 300;
  int _totalTransaksi = 12;
  double _co2Dicegah = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final limbah = await SharedPrefHelper.getLimbahTerserap();
    final transaksi = await SharedPrefHelper.getTotalTransaksi();
    final co2Cents = await SharedPrefHelper.getCo2DicegahCents();
    setState(() {
      _limbahTerserap = limbah;
      _totalTransaksi = transaksi;
      _co2Dicegah = co2Cents / 100.0;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Statistik Dampak',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F7A44)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HERO IMPACT SUMMARY ---
                  _buildImpactHero(),
                  const SizedBox(height: 24),

                  // --- MONTHLY CHART ---
                  _buildSectionLabel('Penjemputan per Minggu', Icons.bar_chart_rounded),
                  const SizedBox(height: 14),
                  _buildWeeklyChart(),
                  const SizedBox(height: 28),

                  // --- ECO GOALS ---
                  _buildSectionLabel('Target Bulan Ini', Icons.flag_rounded),
                  const SizedBox(height: 14),
                  _buildEcoGoal('Limbah Terserap', _limbahTerserap, 500, 'kg', const Color(0xFF0F7A44)),
                  const SizedBox(height: 12),
                  _buildEcoGoal('Penjemputan', _totalTransaksi, 20, 'kali', const Color(0xFF1565C0)),
                  const SizedBox(height: 12),
                  _buildEcoGoal('CO2 Dicegah', (_co2Dicegah * 10).round(), 15, 'ton', const Color(0xFF7B1FA2)),
                  const SizedBox(height: 28),

                  // --- TIPS SECTION ---
                  _buildSectionLabel('Tips Ekonomi Sirkular', Icons.lightbulb_rounded),
                  const SizedBox(height: 14),
                  _buildTipsCard(
                    'Minyak jelantah bisa diolah menjadi biodiesel, sabun, dan lilin. '
                    'Dengan mendaur ulang 1 liter minyak jelantah, kamu mencegah '
                    'pencemaran 1.000 liter air bersih.',
                    Icons.water_drop_rounded,
                    const Color(0xFF1565C0),
                    const Color(0xFFE3F2FD),
                  ),
                  const SizedBox(height: 12),
                  _buildTipsCard(
                    'Plastik bekas dapat didaur ulang menjadi bahan baku industri, '
                    'seperti paving block, pot tanaman, dan serat tekstil. Setiap '
                    '1kg plastik yang didaur ulang mengurangi emisi 1.5kg CO2.',
                    Icons.recycling_rounded,
                    const Color(0xFF0F7A44),
                    const Color(0xFFE8F5E9),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0F7A44)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color ?? const Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactHero() {
    final co2Display = _co2Dicegah.toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A5C32), Color(0xFF0F7A44), Color(0xFF14A05A)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F7A44).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Dampak Positifmu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kontribusi nyata untuk lingkungan',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildHeroStat('$_limbahTerserap', 'kg', 'Limbah\nTerserap'),
              _buildHeroDivider(),
              _buildHeroStat(co2Display, 'ton', 'CO2\nDicegah'),
              _buildHeroDivider(),
              _buildHeroStat('$_totalTransaksi', 'kali', 'Total\nTransaksi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String unit, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildWeeklyChart() {
    final data = [
      _BarData('Min 1', 45),
      _BarData('Min 2', 72),
      _BarData('Min 3', 30),
      _BarData('Min 4', 88),
    ];
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Juni 2026',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total: $_limbahTerserap kg',
                  style: const TextStyle(
                    color: Color(0xFF0F7A44),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final ratio = d.value / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${d.value}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: ratio),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Container(
                              height: 100 * value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    const Color(0xFF0F7A44),
                                    const Color(0xFF22C55E).withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoGoal(String label, int current, int target, String unit, Color color) {
    final ratio = (current / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '$current / $target $unit',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${(ratio * 100).toInt()}% tercapai',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(String text, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color.withValues(alpha: 0.9),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final int value;
  const _BarData(this.label, this.value);
}
