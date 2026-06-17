import 'package:flutter/material.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<_NotifItem> notifications = [
      _NotifItem(
        icon: Icons.local_shipping_rounded,
        iconColor: const Color(0xFF0F7A44),
        bgColor: const Color(0xFFE8F5E9),
        title: 'Tugas Baru Tersedia',
        subtitle: 'Ada 3 limbah baru di Marketplace, segera ambil sebelum kehabisan!',
        time: '2 menit lalu',
        isUnread: true,
      ),
      _NotifItem(
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF22C55E),
        bgColor: const Color(0xFFE8F5E9),
        title: 'Penjemputan Selesai',
        subtitle: 'Penjemputan Minyak Jelantah dari Penyedia 3 berhasil diverifikasi.',
        time: '1 jam lalu',
        isUnread: true,
      ),
      _NotifItem(
        icon: Icons.emoji_events_rounded,
        iconColor: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
        title: 'Pencapaian Baru! 🎉',
        subtitle: 'Kamu sudah menyerap 300kg limbah. Terus berkontribusi untuk bumi!',
        time: '5 jam lalu',
        isUnread: false,
      ),
      _NotifItem(
        icon: Icons.monetization_on_rounded,
        iconColor: const Color(0xFF7B1FA2),
        bgColor: const Color(0xFFF3E5F5),
        title: 'Promo Tukar Poin',
        subtitle: 'Tukarkan JunksPoint-mu dengan voucher belanja. Berlaku s.d. akhir bulan!',
        time: 'Kemarin',
        isUnread: false,
      ),
      _NotifItem(
        icon: Icons.eco_rounded,
        iconColor: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        title: 'Tips Lingkungan',
        subtitle: 'Tahukah kamu? 1 liter minyak jelantah bisa mencemari 1.000 liter air bersih.',
        time: '2 hari lalu',
        isUnread: false,
      ),
      _NotifItem(
        icon: Icons.system_update_rounded,
        iconColor: const Color(0xFF455A64),
        bgColor: const Color(0xFFECEFF1),
        title: 'Update Aplikasi',
        subtitle: 'JunksLab versi terbaru sudah tersedia. Perbarui untuk pengalaman lebih baik.',
        time: '3 hari lalu',
        isUnread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Semua notifikasi ditandai sudah dibaca'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color(0xFF333333),
                ),
              );
            },
            child: const Text(
              'Tandai Semua',
              style: TextStyle(
                color: Color(0xFF0F7A44),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotifCard(notif);
        },
      ),
    );
  }

  Widget _buildNotifCard(_NotifItem notif) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notif.isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif.isUnread
              ? const Color(0xFF0F7A44).withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: notif.isUnread
            ? [
                BoxShadow(
                  color: const Color(0xFF0F7A44).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notif.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(notif.icon, color: notif.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontWeight: notif.isUnread ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (notif.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F7A44),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notif.time,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

class _NotifItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final String time;
  final bool isUnread;

  const _NotifItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isUnread,
  });
}
