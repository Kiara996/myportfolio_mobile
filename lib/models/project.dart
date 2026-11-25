import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Pilihan perangkat lunak editing, sama dengan EDITING_SOFTWARE_CHOICES
/// di model Django.
const Map<String, String> editingSoftwareChoices = {
  'lightroom': 'Adobe Lightroom',
  'photoshop': 'Adobe Photoshop',
  'capture-one': 'Capture One',
  'premiere-pro': 'Adobe Premiere Pro',
  'after-effects': 'Adobe After Effects',
  'fl-studio': 'FL Studio',
  'none': 'Tanpa Editing / Straight Out of Camera',
};

/// Proyek portofolio yang disinkronkan dengan ProjectSerializer di Django.
/// Field read-only dari server tidak ikut dikirim saat POST.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.story,
    required this.cameraGear,
    required this.captureSettings,
    this.editingSoftware = 'lightroom',
    this.locationTaken,
    this.takenAt,
    this.imageUrl,
    this.id,
    this.editingSoftwareDisplay = '',
    this.starCount = 0,
    this.isStarred = false,
    this.starredByNames = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String story;
  final String cameraGear;
  final String captureSettings;
  @JsonKey(defaultValue: 'lightroom')
  final String editingSoftware;

  @JsonKey(includeIfNull: false)
  final String? locationTaken;

  /// Tanggal dalam format yyyy-MM-dd, sesuai DateField di Django.
  @JsonKey(includeIfNull: false)
  final String? takenAt;

  @JsonKey(includeIfNull: false)
  final String? imageUrl;

  @JsonKey(includeToJson: false, defaultValue: '')
  final String editingSoftwareDisplay;
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;
  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;
  @JsonKey(includeToJson: false, defaultValue: '')
  final String starredByNames;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// Nama perangkat lunak editing yang siap ditampilkan.
  String get editingLabel {
    if (editingSoftwareDisplay.isNotEmpty) return editingSoftwareDisplay;
    return editingSoftwareChoices[editingSoftware] ?? editingSoftware;
  }

  bool get hasImage => (imageUrl ?? '').isNotEmpty;
}
