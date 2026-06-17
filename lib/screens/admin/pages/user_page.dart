import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin_provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({Key? key}) : super(key: key);

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Penyedia';
    
    showDialog(
      context: context, 
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isMobileDialog = MediaQuery.of(context).size.width < 600;
          
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Add New User'),
            content: Container(
              width: isMobileDialog ? double.maxFinite : 500, // Responsif lebar pop-up
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView( // Tambahan scroll agar aman di HP kecil
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    TextField(
                      controller: usernameController, 
                      decoration: const InputDecoration(
                        labelText: 'Username', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline)
                      )
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController, 
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password', 
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline)
                      )
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole, 
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined)
                      ), 
                      items: ['Penyedia', 'Penyerap'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                      onChanged: (v) => setState(() => selectedRole = v!)
                    )
                  ]
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                onPressed: () async { 
                  if(usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) { 
                    await context.read<AdminProvider>().addUser(
                      usernameController.text, 
                      passwordController.text, 
                      selectedRole
                    ); 
                    if (context.mounted) Navigator.pop(context); 
                  } 
                }, 
                child: const Text('Save', style: TextStyle(color: Colors.white))
              )
            ],
          );
        }
      )
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
            child: provider.users.isEmpty ? 
            const Center(child: Text('Belum ada pengguna. Klik tombol + untuk menambahkan.', textAlign: TextAlign.center)) : 
            ListView.separated(
              itemCount: provider.users.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (c, i) => ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 16.0, vertical: 8.0),
                leading: CircleAvatar(
                  backgroundColor: provider.users[i]['role'] == 'Penyedia' ? Colors.blue[100] : Colors.green[100],
                  child: Text(provider.users[i]['username'][0].toUpperCase(), style: TextStyle(color: Colors.green[900]))
                ),
                title: Text(provider.users[i]['username'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Role: ${provider.users[i]['role']}   •   Status: ${provider.users[i]['status']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        provider.users[i]['status'] == 'Active' ? Icons.block : Icons.check_circle,
                        color: provider.users[i]['status'] == 'Active' ? Colors.orange : Colors.green,
                      ),
                      onPressed: () {
                        final newStatus = provider.users[i]['status'] == 'Active' ? 'Suspended' : 'Active';
                        provider.updateUserStatus(provider.users[i]['id'], newStatus);
                      },
                    ),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => provider.deleteUser(provider.users[i]['id'])),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        onPressed: () => _showAddUserDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}