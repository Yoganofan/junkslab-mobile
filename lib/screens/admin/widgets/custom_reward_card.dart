import 'package:flutter/material.dart';

class CustomRewardCard extends StatefulWidget {
  final String title;
  final int points;
  final int stock;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CustomRewardCard({
    Key? key,
    required this.title,
    required this.points,
    required this.stock,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<CustomRewardCard> createState() => _CustomRewardCardState();
}

class _CustomRewardCardState extends State<CustomRewardCard> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _isHighlighted = !_isHighlighted;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isHighlighted ? '${widget.title} ditandai!' : 'Tanda dilepas.',
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: _isHighlighted
                ? Colors.orange[800]
                : Colors.grey[800],
          ),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Info Cepat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Reward "${widget.title}" membutuhkan ${widget.points} JunksPoin untuk ditukarkan. '
              'Saat ini tersisa ${widget.stock} stok di sistem.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Card(
          elevation: _isHighlighted ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isHighlighted
                  ? Colors.orange
                  : Theme.of(context).dividerColor,
              width: _isHighlighted ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.card_giftcard, color: Colors.orange),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.points} JunksPoin',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sisa Stok: ${widget.stock}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
