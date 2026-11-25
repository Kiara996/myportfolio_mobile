import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart'
    show formatDate;
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/utils/form_validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Format yyyy-MM-dd yang diterima DateField di Django.
String formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Form tambah proyek. Isinya dikirim ke API dengan token login, jadi
/// hanya pemilik portofolio (superuser) yang berhasil menyimpan.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _cameraGearController = TextEditingController();
  final _captureSettingsController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _takenAtController = TextEditingController();

  String _editingSoftware = 'lightroom';
  DateTime? _takenAt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _cameraGearController.dispose();
    _captureSettingsController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    _takenAtController.dispose();
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
      requiredText(value, 'Nama proyek tidak boleh kosong!') ??
      maxLength(value, 255, 'Nama proyek maksimal 255 karakter!') ??
      notOnlyHtml(value, 'Nama proyek tidak boleh hanya berisi tag HTML!');

  String? _validateStory(String? value) =>
      requiredText(value, 'Cerita proyek tidak boleh kosong!') ??
      notOnlyHtml(value, 'Cerita tidak boleh hanya berisi tag HTML!');

  String? _validateShortField(String? value, String label) =>
      requiredText(value, '$label tidak boleh kosong!') ??
      maxLength(value, 255, '$label maksimal 255 karakter!');

  String? _validateLocation(String? value) =>
      maxLength(value, 255, 'Lokasi maksimal 255 karakter!');

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _takenAt ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _takenAt = picked;
      _takenAtController.text = formatDate(picked);
    });
  }

  void _clearDate() {
    setState(() {
      _takenAt = null;
      _takenAtController.clear();
    });
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _editingSoftware = 'lightroom';
      _takenAt = null;
      _takenAtController.clear();
    });
  }

  Project _buildProject() {
    String? optional(String value) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return Project(
      title: _titleController.text.trim(),
      story: _storyController.text.trim(),
      cameraGear: _cameraGearController.text.trim(),
      captureSettings: _captureSettingsController.text.trim(),
      editingSoftware: _editingSoftware,
      locationTaken: optional(_locationController.text),
      takenAt: _takenAt == null ? null : formatIsoDate(_takenAt!),
      imageUrl: optional(_imageUrlController.text),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);

    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    setState(() => _isSubmitting = true);
    try {
      final created = await api.createProject(
        _buildProject(),
        token: auth.token!,
      );
      if (!mounted) return;
      _showCreated(created);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        // Token sudah tidak berlaku, jadi sesi diakhiri dan login diminta lagi.
        await auth.logout();
        messenger.showSnackBar(SnackBar(content: Text(e.userMessage)));
        if (!mounted) return;
        await ensureLoggedIn(context);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(e.userMessage)));
      }
    } on Exception catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCreated(Project project) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama: ${project.title}'),
                Text('Kamera: ${project.cameraGear}'),
                Text('Pengaturan: ${project.captureSettings}'),
                Text('Editing: ${project.editingLabel}'),
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        decoration: _decoration('Nama Proyek'),
                        validator: _validateTitle,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _storyController,
                        maxLines: 5,
                        decoration: _decoration(
                          'Cerita Proyek',
                          hint: 'Ceritakan proyek ini...',
                        ),
                        validator: _validateStory,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _cameraGearController,
                        decoration: _decoration(
                          'Kamera dan Lensa',
                          hint: 'Contoh: Fujifilm X-T30 II, 35mm f/2',
                        ),
                        validator: (value) =>
                            _validateShortField(value, 'Kamera dan lensa'),
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _captureSettingsController,
                        decoration: _decoration(
                          'Pengaturan Pemotretan',
                          hint: 'Contoh: f/2.0, 1/500s, ISO 200',
                        ),
                        validator: (value) =>
                            _validateShortField(value, 'Pengaturan pemotretan'),
                      ),
                    ),
                    _gap(
                      DropdownButtonFormField<String>(
                        initialValue: _editingSoftware,
                        isExpanded: true,
                        decoration: _decoration('Perangkat Lunak Editing'),
                        items: [
                          for (final entry in editingSoftwareChoices.entries)
                            DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _editingSoftware = value!),
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _locationController,
                        decoration: _decoration(
                          'Lokasi',
                          hint: 'Lokasi pengambilan (opsional)',
                        ),
                        validator: _validateLocation,
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _takenAtController,
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: _decoration(
                          'Tanggal Pengambilan',
                          hint: 'Pilih tanggal (opsional)',
                          suffix: _takenAt == null
                              ? const Icon(Icons.calendar_today)
                              : IconButton(
                                  tooltip: 'Hapus tanggal',
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearDate,
                                ),
                        ),
                      ),
                    ),
                    _gap(
                      TextFormField(
                        controller: _imageUrlController,
                        keyboardType: TextInputType.url,
                        decoration: _decoration(
                          'URL Gambar',
                          hint: 'URL gambar (opsional)',
                        ),
                        validator: optionalImageUrl,
                      ),
                    ),
                    _gap(
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Simpan'),
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
