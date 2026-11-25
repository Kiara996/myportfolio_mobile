import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Drawer navigasi utama. Memakai pushReplacement agar tumpukan halaman
/// tidak menumpuk setiap kali pengguna berpindah lewat drawer.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  Future<void> _login(BuildContext context) async {
    final navigator = Navigator.of(context);
    // Menutup drawer setelah login berhasil.
    if (await ensureLoggedIn(context)) navigator.pop();
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final auth = context.read<AuthState>();

    navigator.pop();
    await auth.logout();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kamu sudah logout.')));
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
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
            icon: Icons.folder_outlined,
            label: 'Projects',
            builder: (context) => const ProjectListScreen(),
          ),
          _DrawerItem(
            icon: Icons.add_circle_outline,
            label: 'Add Project',
            requiresLogin: true,
            builder: (context) => const ProjectFormPage(),
          ),
          _DrawerItem(
            icon: Icons.work_outline,
            label: 'Add Experience',
            builder: (context) => const ExperienceFormPage(),
          ),
          const Divider(),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _login(context),
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
  final bool requiresLogin;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.builder,
    this.requiresLogin = false,
  });

  Future<void> _open(BuildContext context) async {
    // Navigator diambil sebelum await karena drawer bisa sudah ditutup setelahnya.
    final navigator = Navigator.of(context);
    if (requiresLogin && !await ensureLoggedIn(context)) return;
    navigator.pushReplacement(MaterialPageRoute(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => _open(context),
    );
  }
}
