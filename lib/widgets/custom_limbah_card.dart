import 'package:flutter/material.dart';

class CustomLimbahCard extends StatelessWidget {
  final String namaPenyedia;
  final String jenisLimbah;
  final String berat;
  final String lokasi;
  final String status;
  final VoidCallback onAmbil;

  const CustomLimbahCard({
    Key? key,
    required this.namaPenyedia,
    required this.jenisLimbah,
    required this.berat,
    required this.lokasi,
    required this.status,
    required this.onAmbil,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                namaPenyedia,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'Tersedia' ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Tersedia' ? Colors.green.shade800 : Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$jenisLimbah • $berat', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lokasi,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onAmbil,
              child: const Text('Ambil Koleksi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}