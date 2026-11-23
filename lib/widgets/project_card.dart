import 'package:material_ui/material_ui.dart';

/// Data satu tombol menu. [destination] diisi bila tombol membuka halaman lain,
/// [confirmMessage] diisi bila aksi perlu dikonfirmasi.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;
  final String? confirmMessage;
  final WidgetBuilder? destination;

  ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.confirmMessage,
    this.destination,
  });
}

/// Tombol menu berbentuk kartu. Membuka [ItemHomepage.destination] lewat
/// Navigator.push bila ada, kalau tidak menampilkan SnackBar, plus dialog
/// konfirmasi tambahan jika item memiliki [ItemHomepage.confirmMessage].
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  Future<void> _onTap(BuildContext context) async {
    // Pindah halaman tanpa SnackBar, karena SnackBar bakal ikut tampil di
    // halaman tujuan dan menutupi tombol di bagian bawah form.
    final destination = item.destination;
    if (destination != null) {
      Navigator.push(context, MaterialPageRoute(builder: destination));
      return;
    }

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
