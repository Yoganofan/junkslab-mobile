import sys

def add_imports(filepath, imports):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    # Find the last import line
    last_import_idx = 0
    for i, line in enumerate(lines):
        if line.startswith('import '):
            last_import_idx = i

    lines.insert(last_import_idx + 1, imports + '\n')
    
    with open(filepath, 'w') as f:
        f.writelines(lines)

add_imports('lib/screens/penyedia/riwayat_screen.dart', "import 'package:url_launcher/url_launcher.dart';\nimport 'package:qr_flutter/qr_flutter.dart';")
add_imports('lib/screens/penyedia/input_waste_screen.dart', "import 'package:image_picker/image_picker.dart';\nimport '../../helpers/penyedia_database_helper.dart';")

print("Imports fixed.")
