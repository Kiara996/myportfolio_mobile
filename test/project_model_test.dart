import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

import 'support/fake_backend.dart';

void main() {
  group('Project.fromJson', () {
    test('memetakan kunci snake_case dari DRF', () {
      final project = Project.fromJson(
        projectJson(imageUrl: 'https://example.com/a.jpg'),
      );

      expect(project.id, '11111111-1111-1111-1111-111111111111');
      expect(project.cameraGear, 'Fujifilm X-T30 II');
      expect(project.captureSettings, 'f/2.0, 1/500s, ISO 200');
      expect(project.editingSoftware, 'lightroom');
      expect(project.editingLabel, 'Adobe Lightroom');
      expect(project.locationTaken, 'Jakarta');
      expect(project.takenAt, '2026-03-14');
      expect(project.starCount, 2);
      expect(project.hasImage, isTrue);
    });

    test('field null atau hilang memakai nilai bawaan', () {
      final json = projectJson()
        ..remove('star_count')
        ..remove('editing_software_display')
        ..['location_taken'] = null
        ..['image_url'] = null;
      final project = Project.fromJson(json);

      expect(project.locationTaken, isNull);
      expect(project.hasImage, isFalse);
      expect(project.starCount, 0);
      expect(project.editingLabel, 'Adobe Lightroom');
    });

    test('label editing jatuh ke kode kalau pilihannya tidak dikenal', () {
      final project = Project.fromJson(
        projectJson()
          ..['editing_software'] = 'gimp'
          ..remove('editing_software_display'),
      );

      expect(project.editingLabel, 'gimp');
    });
  });

  group('Project.toJson', () {
    test('tidak mengirim field read-only dan membuang nilai null', () {
      const project = Project(
        id: 'abc',
        title: 'Judul',
        story: 'Cerita',
        cameraGear: 'Kamera',
        captureSettings: 'f/8',
        starCount: 5,
        isStarred: true,
      );

      expect(project.toJson(), {
        'title': 'Judul',
        'story': 'Cerita',
        'camera_gear': 'Kamera',
        'capture_settings': 'f/8',
        'editing_software': 'lightroom',
      });
    });

    test('field opsional yang terisi ikut terkirim', () {
      const project = Project(
        title: 'Judul',
        story: 'Cerita',
        cameraGear: 'Kamera',
        captureSettings: 'f/8',
        editingSoftware: 'none',
        locationTaken: 'Bali',
        takenAt: '2026-01-02',
        imageUrl: 'https://example.com/a.jpg',
      );

      final json = project.toJson();
      expect(json['location_taken'], 'Bali');
      expect(json['taken_at'], '2026-01-02');
      expect(json['image_url'], 'https://example.com/a.jpg');
    });
  });
}
