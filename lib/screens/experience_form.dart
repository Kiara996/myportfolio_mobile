import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Pilihan kategori, sama dengan EXPERIENCE_CHOICES di model Django.
const Map<String, String> experienceCategories = {
  'internship': 'Internship',
  'research': 'Research',
  'volunteer': 'Volunteer',
  'part-time': 'Part-Time',
  'full-time': 'Full-Time',
  'freelance': 'Freelance',
};

/// Format tanggal dd/MM/yyyy tanpa perlu package intl.
String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

/// Form tambah pengalaman. Data belum disimpan ke database; setelah valid,
/// isinya hanya ditampilkan di dialog.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  String _category = 'full-time';
  DateTime? _startedAt;
  DateTime? _endedAt;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  String? _validateTitle(String? value) =>
      requiredText(value, 'Nama pengalaman tidak boleh kosong!') ??
      maxLength(value, 255, 'Nama pengalaman maksimal 255 karakter!') ??
      notOnlyHtml(value, 'Nama pengalaman tidak boleh hanya berisi tag HTML!');

  String? _validateDescription(String? value) =>
      requiredText(value, 'Deskripsi pengalaman tidak boleh kosong!') ??
      notOnlyHtml(value, 'Deskripsi tidak boleh hanya berisi tag HTML!');

  String? _validateStart(String? value) =>
      _startedAt == null ? 'Tanggal mulai wajib dipilih!' : null;

  String? _validateEnd(String? value) =>
      endNotBeforeStart(_startedAt, _endedAt);

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _startedAt = picked;
      _startController.text = formatDate(picked);
    });
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? _startedAt ?? now,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _endedAt = picked;
      _endController.text = formatDate(picked);
    });
  }

  void _clearEnd() {
    setState(() {
      _endedAt = null;
      _endController.clear();
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _category = 'full-time';
      _startedAt = null;
      _endedAt = null;
      _startController.clear();
      _endController.clear();
    });
  }

  void _showSummary() {
    final thumbnail = _thumbnailController.text.trim();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${stripTags(_titleController.text)}'),
                Text('Deskripsi: ${stripTags(_descriptionController.text)}'),
                Text('Kategori: ${experienceCategories[_category]}'),
                Text('Thumbnail: ${thumbnail.isEmpty ? '-' : thumbnail}'),
                Text('Mulai: ${formatDate(_startedAt!)}'),
                Text(
                  'Selesai: ${_endedAt == null ? 'Sedang berlangsung' : formatDate(_endedAt!)}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _showSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Experience Form'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // SingleChildScrollView menjaga semua field tetap terjangkau saat keyboard muncul.
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _gap(
                      TextFormField(
                        controller: _titleController,
                        decoration: _decoration(
                          'Nama Pengalaman',
                          hint: 'Contoh: Freelance Photographer di Bali',
                        ),
                        validator: _validateTitle,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: _decoration(
                          'Deskripsi Pengalaman',
                          hint: 'Ceritakan pengalamanmu...',
                        ),
                        validator: _validateDescription,
                      ),
                    ),
                    _gap(
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: _decoration('Kategori Pengalaman'),
                        items: [
                          for (final entry in experienceCategories.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _category = value!),
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _thumbnailController,
                        keyboardType: TextInputType.url,
                        decoration: _decoration(
                          'URL Thumbnail',
                          hint: 'URL gambar (opsional)',
                        ),
                        validator: optionalImageUrl,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _startController,
                        readOnly: true,
                        onTap: _pickStart,
                        decoration: _decoration(
                          'Tanggal Mulai',
                          hint: 'Pilih tanggal',
                          suffix: const Icon(Icons.calendar_today),
                        ),
                        validator: _validateStart,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _endController,
                        readOnly: true,
                        onTap: _pickEnd,
                        decoration: _decoration(
                          'Tanggal Selesai',
                          hint: 'Kosongkan jika masih berlangsung',
                          suffix: _endedAt == null
                              ? const Icon(Icons.calendar_today)
                              : IconButton(
                                  tooltip: 'Hapus tanggal selesai',
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearEnd,
                                ),
                        ),
                        validator: _validateEnd,
                      ),
                    ),
                    _gap(
                      FilledButton(
                        onPressed: _submit,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap(Widget child) =>
      Padding(padding: const EdgeInsets.all(8), child: child);
}
