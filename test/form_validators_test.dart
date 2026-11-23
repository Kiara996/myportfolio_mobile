import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/utils/form_validators.dart';

void main() {
  group('requiredText', () {
    test('menolak null, kosong, dan hanya spasi', () {
      expect(requiredText(null, 'wajib'), 'wajib');
      expect(requiredText('', 'wajib'), 'wajib');
      expect(requiredText('   ', 'wajib'), 'wajib');
    });

    test('menerima teks biasa', () {
      expect(requiredText('Magang', 'wajib'), isNull);
    });
  });

  group('maxLength', () {
    test('menolak yang kelewat panjang, trim dulu sebelum dihitung', () {
      expect(maxLength('a' * 6, 5, 'kepanjangan'), 'kepanjangan');
      expect(maxLength('  ${'a' * 5}  ', 5, 'kepanjangan'), isNull);
    });
  });

  group('notOnlyHtml', () {
    test('menolak isian yang cuma tag HTML', () {
      expect(notOnlyHtml('<b></b>', 'html'), 'html');
      expect(notOnlyHtml('<script></script>', 'html'), 'html');
    });

    test(
      'menerima teks yang ada isinya, atau kosong (dicek validator lain)',
      () {
        expect(notOnlyHtml('<b>Halo</b>', 'html'), isNull);
        expect(notOnlyHtml('', 'html'), isNull);
      },
    );
  });

  group('optionalImageUrl', () {
    test('kosong dianggap valid', () {
      expect(optionalImageUrl(null), isNull);
      expect(optionalImageUrl('  '), isNull);
    });

    test('menolak yang bukan http(s)', () {
      expect(optionalImageUrl('bukan-url'), isNotNull);
      expect(optionalImageUrl('ftp://example.com/a.png'), isNotNull);
    });

    test('menerima http dan https', () {
      expect(optionalImageUrl('https://example.com/a.png'), isNull);
      expect(optionalImageUrl('http://example.com'), isNull);
    });

    test('link Google Drive wajib format thumbnail', () {
      expect(
        optionalImageUrl('https://drive.google.com/file/d/abc/view'),
        isNotNull,
      );
      expect(
        optionalImageUrl('https://drive.google.com/thumbnail?id=abc&sz=w1000'),
        isNull,
      );
    });
  });

  test('stripTags membuang tag dan merapikan spasi', () {
    expect(stripTags(' <p>Halo <b>dunia</b></p> '), 'Halo dunia');
  });
}
