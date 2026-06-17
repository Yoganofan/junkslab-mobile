import os
import re

src_dir = "/Users/mac/Documents/adien/folder tanpa judul/assesment_2/lib"
dst_dir = "/Users/mac/Documents/adien/mixing_playlist/junkslab-mobile/junkslab/lib/screens/admin"
helpers_dst = "/Users/mac/Documents/adien/mixing_playlist/junkslab-mobile/junkslab/lib/helpers"

def read_file(path):
    with open(path, 'r') as f: return f.read()

def write_file(path, content):
    with open(path, 'w') as f: f.write(content)

# Helpers
dh = read_file(os.path.join(src_dir, "database_helper.dart"))
write_file(os.path.join(helpers_dst, "admin_database_helper.dart"), dh)

ph = read_file(os.path.join(src_dir, "prefs_helper.dart"))
write_file(os.path.join(helpers_dst, "admin_prefs_helper.dart"), ph)

# Provider
ap = read_file(os.path.join(src_dir, "admin_provider.dart"))
ap = ap.replace("import 'database_helper.dart';", "import '../../helpers/admin_database_helper.dart';")
ap = ap.replace("import 'prefs_helper.dart';", "import '../../helpers/admin_prefs_helper.dart';")
write_file(os.path.join(dst_dir, "admin_provider.dart"), ap)

# Widgets
os.makedirs(os.path.join(dst_dir, "widgets"), exist_ok=True)
ir = read_file(os.path.join(src_dir, "custom_impact_ring.dart"))
write_file(os.path.join(dst_dir, "widgets", "custom_impact_ring.dart"), ir)

qc = read_file(os.path.join(src_dir, "custom_queue_card.dart"))
write_file(os.path.join(dst_dir, "widgets", "custom_queue_card.dart"), qc)

rc = read_file(os.path.join(src_dir, "custom_reward_card.dart"))
write_file(os.path.join(dst_dir, "widgets", "custom_reward_card.dart"), rc)

# Pages
os.makedirs(os.path.join(dst_dir, "pages"), exist_ok=True)
ml = read_file(os.path.join(src_dir, "pages", "main_layout.dart"))
ml = ml.replace("import '../custom_impact_ring.dart';", "import '../widgets/custom_impact_ring.dart';")
ml = ml.replace("import '../prefs_helper.dart';", "import '../../../helpers/admin_prefs_helper.dart';")
ml = ml.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
write_file(os.path.join(dst_dir, "pages", "main_layout.dart"), ml)

dp = read_file(os.path.join(src_dir, "pages", "dashboard_page.dart"))
write_file(os.path.join(dst_dir, "pages", "dashboard_page.dart"), dp)

up = read_file(os.path.join(src_dir, "pages", "user_page.dart"))
up = up.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
write_file(os.path.join(dst_dir, "pages", "user_page.dart"), up)

cp = read_file(os.path.join(src_dir, "pages", "content_page.dart"))
cp = cp.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
write_file(os.path.join(dst_dir, "pages", "content_page.dart"), cp)

rp = read_file(os.path.join(src_dir, "pages", "reward_page.dart"))
rp = rp.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
rp = rp.replace("import '../custom_reward_card.dart';", "import '../widgets/custom_reward_card.dart';")
write_file(os.path.join(dst_dir, "pages", "reward_page.dart"), rp)

ptp = read_file(os.path.join(src_dir, "pages", "point_tracking_page.dart"))
ptp = ptp.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
write_file(os.path.join(dst_dir, "pages", "point_tracking_page.dart"), ptp)

qp = read_file(os.path.join(src_dir, "pages", "queue_page.dart"))
qp = qp.replace("import '../admin_provider.dart';", "import '../admin_provider.dart';")
qp = qp.replace("import '../custom_queue_card.dart';", "import '../widgets/custom_queue_card.dart';")
write_file(os.path.join(dst_dir, "pages", "queue_page.dart"), qp)

print("Files copied and updated successfully!")
