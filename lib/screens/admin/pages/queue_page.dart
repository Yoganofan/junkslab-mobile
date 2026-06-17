import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';
import '../widgets/custom_queue_card.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({Key? key}) : super(key: key);

  void _showQueueDialog(BuildContext context, Map<String, dynamic> queue) {
    final nameCtrl = TextEditingController(text: queue['farmer_name']);
    final quotaCtrl = TextEditingController(text: queue['quota_kg'].toString());
    String type = queue['farm_type'];
    String status = queue['status'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Update Status Antrean',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Mitra',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quotaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kuota Limbah (Kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // --- UPDATE JENIS LIMBAH DISINI ---
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: 'Jenis Limbah',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'Limbah Sayuran',
                          'Limbah Dapur MBG',
                          'Hasil Panen Grade B',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => type = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status Penjadwalan',
                  border: OutlineInputBorder(),
                ),
                items: ['Menunggu', 'Aktif', 'Selesai']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
              onPressed: () {
                context.read<AdminProvider>().updateQueueStatus(
                  queue['id'],
                  nameCtrl.text,
                  type,
                  int.parse(quotaCtrl.text),
                  status,
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Antrean Penjemputan',
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
                          value: provider.queueFilter,
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.green,
                          ),
                          items: ['Semua', 'Aktif', 'Menunggu', 'Selesai']
                              .map(
                                (val) => DropdownMenuItem(
                                  value: val,
                                  child: Text(val),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => provider.updateQueueFilter(val!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.queues.isEmpty
                      ? const Center(child: Text('Tidak ada data antrean.'))
                      : ListView.builder(
                          itemCount: provider.queues.length,
                          itemBuilder: (context, index) {
                            return CustomQueueCard(
                              queue: provider.queues[index],
                              onEdit: () => _showQueueDialog(
                                context,
                                provider.queues[index],
                              ),
                              onDelete: () => provider.deleteQueue(
                                provider.queues[index]['id'],
                              ),
                            );
                          },
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
