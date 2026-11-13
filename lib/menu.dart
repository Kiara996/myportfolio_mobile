import 'package:flutter/material.dart';

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
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green.shade700),
    ItemHomepage("Lihat Pengalaman", Icons.work, Colors.deepPurple.shade400),
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
      ),
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

/// Data satu tombol menu. [confirmMessage] diisi bila aksi perlu dikonfirmasi.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final String? confirmMessage;

  ItemHomepage(this.name, this.icon, this.color, {this.confirmMessage});
}

/// Tombol menu berbentuk kartu. Menampilkan SnackBar saat ditekan, dan
/// dialog konfirmasi tambahan jika item memiliki [ItemHomepage.confirmMessage].
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  Future<void> _onTap(BuildContext context) async {
    // Messenger diambil sebelum await agar context tidak dipakai setelah jeda async.
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
      );

    final confirmMessage = item.confirmMessage;
    if (confirmMessage == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.name),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Batal"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(item.name),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text("${item.name} berhasil.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Material(
      color: item.color,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: Colors.white, size: 30),
              const SizedBox(height: 6),
              // Flexible + maxLines menjaga sel tetap muat di layar sempit atau font besar.
              Flexible(
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
