import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';
import '../widgets/custom_reward_card.dart';

class RewardPage extends StatelessWidget {
  const RewardPage({Key? key}) : super(key: key);

  void _showRewardDialog(BuildContext context, {Map<String, dynamic>? reward}) {
    final nameCtrl = TextEditingController(text: reward?['name'] ?? '');
    final pointsCtrl = TextEditingController(
      text: reward != null ? reward['points_required'].toString() : '',
    );
    final stockCtrl = TextEditingController(
      text: reward != null ? reward['stock'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(reward == null ? 'Tambah Reward Baru' : 'Edit Reward'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Reward',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pointsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga (JunksPoin)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stok Tersedia',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  pointsCtrl.text.isNotEmpty &&
                  stockCtrl.text.isNotEmpty) {
                if (reward == null) {
                  context.read<AdminProvider>().addReward(
                    nameCtrl.text,
                    int.parse(pointsCtrl.text),
                    int.parse(stockCtrl.text),
                  );
                } else {
                  context.read<AdminProvider>().updateReward(
                    reward['id'],
                    nameCtrl.text,
                    int.parse(pointsCtrl.text),
                    int.parse(stockCtrl.text),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
                // HEADER & DROPDOWN SORTING
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Manajemen Katalog',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.sortOrder,
                          icon: const Icon(Icons.sort, color: Colors.green),
                          items: ['Poin Terendah', 'Poin Tertinggi']
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => provider.updateSortOrder(val!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // GRIDVIEW KATALOG ASLI
                Expanded(
                  child: provider.rewards.isEmpty
                      ? const Center(
                          child: Text(
                            'Katalog reward masih kosong. Klik + untuk tambah.',
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 2 : 4,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: isMobile ? 0.75 : 0.85,
                              ),
                          itemCount: provider.rewards.length,
                          itemBuilder: (context, i) {
                            final item = provider.rewards[i];
                            return CustomRewardCard(
                              title: item['name'],
                              points: item['points_required'],
                              stock: item['stock'],
                              onEdit: () =>
                                  _showRewardDialog(context, reward: item),
                              onDelete: () => provider.deleteReward(item['id']),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        onPressed: () => _showRewardDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Reward',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
