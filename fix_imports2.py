import os
import glob
import re

dst_base = "/Users/mac/Documents/adien/mixing_playlist/junkslab-mobile/junkslab/lib"

def replace_in_file(path, replacements):
    with open(path, 'r') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(path, 'w') as f:
        f.write(content)

dart_files = glob.glob(os.path.join(dst_base, 'screens', 'penyedia', '*.dart')) + \
             glob.glob(os.path.join(dst_base, 'screens', 'auth', '*.dart'))

for f in dart_files:
    # Read and modify
    with open(f, 'r') as file:
        content = file.read()
    
    # Fix database path
    content = content.replace("import 'package:junkslab/database/penyedia_database_helper.dart';", "import 'package:junkslab/helpers/penyedia_database_helper.dart';")
    content = content.replace("import 'package:tubes_junkslab/database/database_helper.dart';", "import 'package:junkslab/helpers/penyedia_database_helper.dart';")
    content = content.replace("import 'package:junkslab/database/database_helper.dart';", "import 'package:junkslab/helpers/penyedia_database_helper.dart';")
    content = content.replace("import '../../database/database_helper.dart';", "import '../../helpers/penyedia_database_helper.dart';")
    content = content.replace("import '../../database/penyedia_database_helper.dart';", "import '../../helpers/penyedia_database_helper.dart';")
    
    # Fix provider imports
    if "AdminProvider" in content and "import 'package:provider/provider.dart';" not in content:
        content = "import 'package:provider/provider.dart';\n" + content
    if "AdminProvider" in content and "admin_provider.dart" not in content:
        content = "import 'package:junkslab/screens/admin/admin_provider.dart';\n" + content
        
    with open(f, 'w') as file:
        file.write(content)

print("Imports fixed again.")
