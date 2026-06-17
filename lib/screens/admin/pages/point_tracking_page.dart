import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';

class PointTrackingPage extends StatelessWidget {
  const PointTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green[800],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total JunksPoin Beredar',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.totalJunksPoinInCirculation} Pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Riwayat Transaksi Poin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.transactions.isEmpty
                      ? const Center(child: Text('Belum ada transaksi poin.'))
                      : Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            itemCount: provider.transactions.length,
                            separatorBuilder: (c, i) => const Divider(),
                            itemBuilder: (c, i) {
                              final trx = provider.transactions[i];
                              final isEarn = trx['type'] == 'Earn';

                              // Mengubah warna teks berdasarkan tema aktif
                              final descColor = Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color;

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: isEarn
                                      ? Colors.green.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                                  child: Icon(
                                    isEarn
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isEarn ? Colors.green : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  trx['user_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Menampilkan Deskripsi dan Tanggal
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      trx['description'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: descColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      trx['date'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),

                                trailing: Text(
                                  '${isEarn ? '+' : '-'}${trx['points']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isEarn ? Colors.green : Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
