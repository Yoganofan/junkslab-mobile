import 'package:flutter/material.dart';

class CustomQueueCard extends StatelessWidget {
  final Map<String, dynamic> queue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomQueueCard({Key? key, required this.queue, required this.onEdit, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = queue['status'];
    Color statusColor;
    IconData statusIcon;

    if (status == 'Aktif') {
      statusColor = Colors.green;
      statusIcon = Icons.autorenew;
    } else if (status == 'Selesai') {
      statusColor = Colors.grey;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    return Card(
      elevation: status == 'Aktif' ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: status == 'Aktif' ? Colors.green : Colors.transparent, width: 2)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.15),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(queue['farmer_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Jenis: ${queue['farm_type']} | Kuota: ${queue['quota_kg']} Kg'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}