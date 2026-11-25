import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Detail satu proyek. Gambar hanya ditampilkan kalau URL-nya terisi.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (project.hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        project.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 120,
                              child: Center(
                                child: Text('Gambar gagal dimuat.'),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(project.title, style: textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(project.story),
                  const SizedBox(height: 16),
                  _DetailRow('Kamera', project.cameraGear),
                  _DetailRow('Pengaturan', project.captureSettings),
                  _DetailRow('Editing', project.editingLabel),
                  if ((project.locationTaken ?? '').isNotEmpty)
                    _DetailRow('Lokasi', project.locationTaken!),
                  if ((project.takenAt ?? '').isNotEmpty)
                    _DetailRow('Tanggal', project.takenAt!),
                  _DetailRow('Bintang', '${project.starCount}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
