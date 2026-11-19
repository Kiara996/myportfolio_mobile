import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Drawer navigasi utama. Memakai pushReplacement agar tumpukan halaman
/// tidak menumpuk setiap kali pengguna berpindah lewat drawer.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Home',
            builder: (context) => MyHomePage(),
          ),
          _DrawerItem(
            icon: Icons.add_circle_outline,
            label: 'Add Project',
            builder: (context) => const ProjectFormPage(),
          ),
          _DrawerItem(
            icon: Icons.work_outline,
            label: 'Add Experience',
            builder: (context) => const ExperienceFormPage(),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final WidgetBuilder builder;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: builder),
      ),
    );
  }
}
