import os
import shutil

src_base = "/Users/mac/Documents/adien/folder tanpa judul/tubes_junkslab/lib"
dst_base = "/Users/mac/Documents/adien/mixing_playlist/junkslab-mobile/junkslab/lib"

def read_file(path):
    with open(path, 'r') as f: return f.read()

def write_file(path, content):
    with open(path, 'w') as f: f.write(content)

os.makedirs(os.path.join(dst_base, "models"), exist_ok=True)
shutil.copy(os.path.join(src_base, "models", "waste_item.dart"), os.path.join(dst_base, "models", "waste_item.dart"))

os.makedirs(os.path.join(dst_base, "helpers"), exist_ok=True)
write_file(os.path.join(dst_base, "helpers", "penyedia_database_helper.dart"), read_file(os.path.join(src_base, "database", "database_helper.dart")))
write_file(os.path.join(dst_base, "helpers", "preferences_helper.dart"), read_file(os.path.join(src_base, "helpers", "preferences_helper.dart")))

os.makedirs(os.path.join(dst_base, "screens", "auth"), exist_ok=True)
write_file(os.path.join(dst_base, "screens", "auth", "login_screen.dart"), read_file(os.path.join(src_base, "screens", "auth", "login_screen.dart")))

os.makedirs(os.path.join(dst_base, "screens", "penyedia"), exist_ok=True)
for f in ["dashboard_screen.dart", "input_waste_screen.dart", "riwayat_screen.dart", "wallet_screen.dart", "profil_screen.dart"]:
    write_file(os.path.join(dst_base, "screens", "penyedia", f), read_file(os.path.join(src_base, "screens", "penyedia", f)))

write_file(os.path.join(dst_base, "screens", "penyedia", "main_navigation.dart"), read_file(os.path.join(src_base, "screens", "shared", "main_navigation.dart")))

print("Copied files.")
