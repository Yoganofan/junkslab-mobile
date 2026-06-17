import 'package:flutter/material.dart';
import 'package:junkslab/helpers/penyedia_database_helper.dart';
import 'package:junkslab/helpers/preferences_helper.dart';
import 'package:junkslab/models/waste_item.dart';
import 'dart:io'; 
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../helpers/penyedia_database_helper.dart';



class InputWasteScreen extends StatefulWidget {
  final WasteItem? wasteItem;
  const InputWasteScreen({super.key, this.wasteItem});
  @override
  State<InputWasteScreen> createState() => _InputWasteScreenState();
}

class _InputWasteScreenState extends State<InputWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedCategory = 'Sisa Makanan Matang';
  final List<String> _categories = [
    'Sisa Makanan Matang',
    'Potongan Sayur Mentah',
    'Buah Busuk',
    'Limbah Dapur Lainnya',
  ];

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;
  String? _imagePath; 
  final ImagePicker _picker = ImagePicker();
  String? _locationString;

  // Cek apakah screen ini sedang dalam mode "Edit Data"
  bool get _isEditMode => widget.wasteItem != null;

  @override
  void initState() {
    super.initState();
    // Jika ada data yang dikirim, set controller dengan data lama tersebut (Mode Edit)
    if (_isEditMode) {
      _selectedCategory = widget.wasteItem!.category;
      _weightController.text = widget.wasteItem!.weightKg.toString();
      _descriptionController.text = widget.wasteItem!.description;
      _imagePath = widget.wasteItem!.imagePath;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefsHelper = PreferencesHelper();
      await prefsHelper.init();
      String activeEmail = prefsHelper.getUserEmail() ?? 'guest';

      if (_isEditMode) {
        // LOGIKA EDIT DATA
        final updatedItem = WasteItem(
          id: widget.wasteItem!.id, 
          userEmail: widget.wasteItem!.userEmail.isEmpty ? activeEmail : widget.wasteItem!.userEmail,
          category: _selectedCategory,
          weightKg: double.parse(_weightController.text),
          description: _descriptionController.text,
          createdAt: widget.wasteItem!.createdAt, 
          isListed: widget.wasteItem!.isListed,
          imagePath: _imagePath,
        );

        await _databaseHelper.updateWasteItem(updatedItem); 

      } else {
        // --- LOGIKA DATA BARU (INSERT) ---
        String finalDescription = _descriptionController.text.trim();
        if (_locationString != null) {
          finalDescription += '\nLokasi: $_locationString';
        }
        final wasteItem = WasteItem(
          userEmail: activeEmail, 
          category: _selectedCategory,
          weightKg: double.parse(_weightController.text),
          description: finalDescription,
          createdAt: DateTime.now(),
          isListed: false,
          imagePath: _imagePath,
        );

        await _databaseHelper.insertWasteItem(wasteItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Data limbah berhasil diperbarui!' : 'Data limbah berhasil disimpan!'),
            backgroundColor: const Color(0xFF006B23),
          ),
        );
        
        if (_isEditMode) {
          Navigator.pop(context, true); 
        } else {
          _formKey.currentState!.reset();
          _weightController.clear();
          _descriptionController.clear();
          setState(() => _selectedCategory = 'Sisa Makanan Matang');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi untuk memanggil kamera
  Future<void> _takePicture() async {
    // Membuka kamera HP
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Kompres sedikit agar database SQLite tidak berat
    );

    if (photo != null) {
      setState(() {
        _imagePath = photo.path; // Simpan path gambar ke variabel state
      });
    }
  }

  // Fungsi untuk mengambil titik koordinat GPS
Future<void> _getCurrentLocation() async {
     setState(() => _isLoading = true);
     try {
       LocationPermission permission = await Geolocator.checkPermission();
       if (permission == LocationPermission.denied) {
         permission = await Geolocator.requestPermission();
         if (permission == LocationPermission.denied) {
           throw 'Izin lokasi ditolak oleh pengguna.';
         }
       }
       if (permission == LocationPermission.deniedForever) {
         throw 'Izin lokasi ditolak permanen. Buka pengaturan HP.';
       }

       Position position = await Geolocator.getCurrentPosition(
           desiredAccuracy: LocationAccuracy.high);
       
       setState(() {
         // HANYA SIMPAN DI VARIABEL INI, JANGAN TAMPILKAN DI FORM DESKRIPSI
         _locationString = '${position.latitude}, ${position.longitude}';
       });

       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Lokasi berhasil didapatkan!'), backgroundColor: Color(0xFF006B23)),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
         );
       }
     } finally {
       if (mounted) {
         setState(() => _isLoading = false);
       }
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006B23)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Ubah Data Limbah' : 'Input Data Limbah', // Judul dinamis
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF191C1A)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FFF1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBECABA)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF006B23)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Masukkan data limbah organik yang siap disalurkan hari ini',
                        style: TextStyle(fontSize: 12, color: Color(0xFF3F4A3D)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kategori Limbah
              const Text(
                'Kategori Limbah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFBECABA)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4EF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBECABA)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Color(0xFF006B23)),
                  title: Text(
                    _locationString != null ? 'Lokasi Tersimpan' : 'Titik Jemput (Opsional)',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF3F4A3D)),
                  ),
                  subtitle: Text(
                    _locationString ?? 'Ketuk untuk melampirkan koordinat',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: TextButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Ambil GPS'),
                  ),
                ),
              ),

              const Text(
                'Foto Kondisi Limbah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _takePicture, // Memanggil fungsi kamera saat diklik
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBECABA)), // Warna border disamakan
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover, // Gambar akan memenuhi kotak
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 48, color: Color(0xFF006B23)),
                            SizedBox(height: 12),
                            Text(
                              'Ketuk untuk Ambil Foto Bukti',
                              style: TextStyle(color: Color(0xFF70796D), fontSize: 13),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),


              // Estimasi Berat
              const Text(
                'Estimasi Berat (kg)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.scale, color: Color(0xFF3F4A3D)),
                  hintText: '0.0 kg',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBECABA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF006B23), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat harus diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Berat harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Deskripsi
              const Text(
                'Deskripsi Limbah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3F4A3D)),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Jelaskan kondisi limbah (misal: sisa nasi, sayuran layu, dll)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFBECABA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF006B23), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  if (value.length < 10) {
                    return 'Deskripsi minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B23),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isEditMode ? Icons.save : Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            Text(
                              _isEditMode ? 'Perbarui Data Limbah' : 'Simpan Data Limbah', 
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF6F7A6C))),
                ),
              ),
              
            ],
            
          ),
        ),
      ),
    );
  }
}