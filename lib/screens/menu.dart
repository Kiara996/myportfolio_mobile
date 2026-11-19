import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Lebar layar (dp) mulai dari mana menu ditampilkan dalam satu baris penuh.
const double _wideBreakpoint = 600;

/// Halaman utama: identitas pemilik portofolio dan menu aksi.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506612266";
  final String nama = "Kevin Fauzan Arjuna";
  final String kelas = "PBP F";

  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue.shade700),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle,
      Colors.green.shade700,
      destination: (context) => const ProjectFormPage(),
    ),
    ItemHomepage("Lihat Pengalaman", Icons.work, Colors.deepPurple.shade400),
    ItemHomepage(
      "Tambah Pengalaman",
      Icons.post_add,
      Colors.teal.shade700,
      destination: (context) => const ExperienceFormPage(),
    ),
    ItemHomepage("Lihat Skills", Icons.psychology, Colors.orange.shade900),
    ItemHomepage("Lihat Fotografi", Icons.photo_camera, Colors.cyan.shade800),
    ItemHomepage(
      "Logout",
      Icons.logout,
      Colors.red.shade700,
      confirmMessage: "Yakin ingin keluar dari MyPortfolio?",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= _wideBreakpoint ? 6 : 3;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // IntrinsicHeight menyamakan tinggi ketiga kartu walau isinya beda baris.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: InfoCard(title: 'NPM', content: npm),
                            ),
                            Expanded(
                              child: InfoCard(title: 'Name', content: nama),
                            ),
                            Expanded(
                              child: InfoCard(title: 'Class', content: kelas),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Selamat datang di MyPortfolio Mobile!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Scroll ditangani SingleChildScrollView di atas, bukan oleh grid.
                      GridView.count(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [for (final item in items) ItemCard(item)],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Kartu informasi singkat berisi judul dan isi.
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
