import os
import glob

dst_base = "/Users/mac/Documents/adien/mixing_playlist/junkslab-mobile/junkslab/lib"

def replace_in_file(path, replacements):
    with open(path, 'r') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(path, 'w') as f:
        f.write(content)

# Files to process
dart_files = glob.glob(os.path.join(dst_base, 'screens', 'penyedia', '*.dart')) + \
             glob.glob(os.path.join(dst_base, 'screens', 'auth', '*.dart')) + \
             glob.glob(os.path.join(dst_base, 'helpers', '*.dart'))

for f in dart_files:
    replace_in_file(f, [
        ('package:tubes_junkslab/', 'package:junkslab/'),
        ('database_helper.dart', 'penyedia_database_helper.dart'),
        ('import \'../../database/penyedia_database_helper.dart\';', 'import \'../../helpers/penyedia_database_helper.dart\';'),
        ('import \'../shared/main_navigation.dart\';', 'import \'main_navigation.dart\';'),
        ('import \'/screens/shared/main_navigation.dart\';', 'import \'../penyedia/main_navigation.dart\';'),
        ('themeState.toggleTheme()', 'context.read<AdminProvider>().toggleTheme()'),
        ('themeState.currentTheme == ThemeMode.dark', 'context.watch<AdminProvider>().isDarkMode'),
        ('import \'../../main.dart\';', 'import \'../admin/admin_provider.dart\';\nimport \'package:provider/provider.dart\';')
    ])
print("Imports replaced.")
