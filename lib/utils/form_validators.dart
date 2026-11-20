/// Validator form yang dipakai bareng oleh semua halaman form.
/// Aturannya diport dari form Django (ExperienceForm / ProjectForm).
library;

final RegExp _htmlTag = RegExp(r'<[^>]*>');

/// Buang tag HTML, mirip strip_tags di Django, lalu trim.
String stripTags(String value) => value.replaceAll(_htmlTag, '').trim();

/// Tolak nilai kosong atau cuma spasi.
String? requiredText(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

/// Tolak teks yang melebihi [max] karakter (setelah di-trim).
String? maxLength(String? value, int max, String message) {
  if ((value?.trim().length ?? 0) > max) return message;
  return null;
}

/// Tolak isian yang setelah tag HTML dibuang jadi kosong, misalnya `<b></b>`.
String? notOnlyHtml(String? value, String message) {
  final raw = value?.trim() ?? '';
  if (raw.isNotEmpty && stripTags(raw).isEmpty) return message;
  return null;
}

/// URL opsional. Kalau diisi harus http(s) dan kalau dari Google Drive
/// harus format thumbnail supaya gambarnya bisa tampil.
String? optionalImageUrl(String? value) {
  final link = value?.trim() ?? '';
  if (link.isEmpty) return null;

  final uri = Uri.tryParse(link);
  final valid =
      uri != null && uri.hasAuthority && uri.scheme.startsWith('http');
  if (!valid) return 'Tautan harus diawali http:// atau https://';

  if (link.contains('drive.google.com') && !link.contains('thumbnail?id=')) {
    return 'Link Google Drive harus format thumbnail, contoh: '
        'https://drive.google.com/thumbnail?id=FILE_ID&sz=w1000';
  }
  return null;
}

/// Tanggal selesai boleh kosong (masih berlangsung), tapi tidak boleh sebelum
/// tanggal mulai. Hari yang sama masih diterima.
String? endNotBeforeStart(DateTime? start, DateTime? end) {
  if (start == null || end == null) return null;
  return end.isBefore(start)
      ? 'Tanggal selesai tidak boleh sebelum tanggal mulai!'
      : null;
}
