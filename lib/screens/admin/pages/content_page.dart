import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({Key? key}) : super(key: key);

  void _showArticleDialog(BuildContext context, {Map<String, dynamic>? article}) {
    final titleController = TextEditingController(text: article != null ? article['title'] : '');
    final tagController = TextEditingController(text: article != null ? article['tag'] : '');
    final contentController = TextEditingController(text: article != null ? article['content'] : '');
    String selectedCategory = article != null ? article['category'] : 'Eco-Tips';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isMobileDialog = MediaQuery.of(context).size.width < 600;

          // Widget Dropdown Kategori
          Widget categoryDropdown = DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFFFAFAFA),
            ),
            items: ['Eco-Tips', 'Promo', 'Berita'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => selectedCategory = v!),
          );

          // Widget TextField Tag
          Widget tagTextField = TextField(
            controller: tagController, 
            decoration: const InputDecoration(
              labelText: 'Tag (pisahkan dengan koma)', 
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Color(0xFFFAFAFA),
            )
          );

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(article == null ? 'Buat Artikel Baru' : 'Edit Artikel', style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Container(
              width: isMobileDialog ? double.maxFinite : 700, // Responsif lebar pop-up
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController, 
                      decoration: const InputDecoration(
                        labelText: 'Judul Artikel', 
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
                      )
                    ),
                    const SizedBox(height: 16),
                    
                    // Jika di mobile, tumpuk ke bawah. Jika desktop, sejajarkan ke samping.
                    if (isMobileDialog)
                      Column(
                        children: [
                          categoryDropdown,
                          const SizedBox(height: 16),
                          tagTextField,
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: categoryDropdown),
                          const SizedBox(width: 16),
                          Expanded(child: tagTextField),
                        ],
                      ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController, 
                      maxLines: 6, 
                      decoration: const InputDecoration(
                        labelText: 'Konten', 
                        alignLabelWithHint: true, 
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
                      )
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () async {
                  if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                    if (article == null) {
                      await context.read<AdminProvider>().addArticle(
                        titleController.text, selectedCategory, tagController.text, contentController.text
                      );
                    } else {
                      await context.read<AdminProvider>().updateArticle(
                        article['id'], titleController.text, selectedCategory, tagController.text, contentController.text
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal: Judul dan Konten artikel wajib diisi!'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Publish Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<AdminProvider>(builder: (context, provider, _) => 
        Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0), // Padding dinamis
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: provider.articles.isEmpty ? 
            const Center(child: Text('Belum ada konten dipublish. Klik tombol + untuk buat artikel baru.', textAlign: TextAlign.center)) : 
            ListView.separated(
              itemCount: provider.articles.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (c, i) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0, vertical: 8.0),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.article, color: Colors.green),
                ),
                title: Text(provider.articles[i]['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Kategori: ${provider.articles[i]['category']}'),
                    Text('Tag: ${provider.articles[i]['tag']}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showArticleDialog(context, article: provider.articles[i])),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => provider.deleteArticle(provider.articles[i]['id'])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        onPressed: () => _showArticleDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Buat Artikel", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}