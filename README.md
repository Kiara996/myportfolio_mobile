Nama: Kevin Fauzan Arjuna
NPM: 2506612266
Kelas: PBP F

# myportofolio_mobile

Aplikasi mobile portofolio pribadi berbasis Flutter, pendamping website [myportofolio](https://kevin-fauzan-myportofolio.pws.cs.ui.ac.id) untuk tugas PBP Semester 3, Fakultas Ilmu Komputer UI.

## Fitur

- **Identitas** - tiga kartu informasi (NPM, Name, Class) di bagian atas halaman.
- **Menu portofolio** - tombol berwarna untuk Lihat Proyek, Tambah Proyek, Lihat Pengalaman, Lihat Skills, Lihat Fotografi, dan Logout. Tombol biasa menampilkan SnackBar saat ditekan, sedangkan Tambah Proyek dan Tambah Pengalaman langsung membuka form.
- **Konfirmasi Logout** - dialog Batal/Logout sebelum keluar.
- **Form Tambah Proyek dan Tambah Pengalaman** - validasi per field, date picker, dan dialog ringkasan setelah lolos validasi. Dibuka dari kartu di halaman utama atau dari drawer.
- **Tema dari Django** - palet warna diambil dari `style.css` di proyek website.
- **Responsif** - grid 3 kolom di layar sempit dan 6 kolom di layar lebar, tanpa overflow di landscape.

## Tech Stack

- Flutter 3.47 / Dart 3.13
- Material 3

## Setup

Prasyarat: [Flutter SDK](https://docs.flutter.dev/get-started/install) dan emulator, perangkat, atau Chrome.

```bash
flutter pub get
flutter run              # atau: flutter run -d chrome
flutter analyze          # harus "No issues found!"
flutter test
```

## Struktur Proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart            # entry point, MaterialApp, tema
│   ├── screens/
│   │   ├── menu.dart        # MyHomePage, InfoCard
│   │   ├── project_form.dart     # ProjectFormPage (form tambah proyek)
│   │   └── experience_form.dart  # ExperienceFormPage (form tambah pengalaman)
│   ├── theme/
│   │   └── app_theme.dart   # palet warna dan ThemeData
│   ├── utils/
│   │   └── form_validators.dart  # validator form yang dipakai bareng
│   └── widgets/
│       ├── left_drawer.dart   # drawer navigasi
│       └── project_card.dart  # ItemHomepage, ItemCard
├── test/
│   ├── widget_test.dart
│   ├── project_form_test.dart
│   ├── experience_form_test.dart
│   ├── form_validators_test.dart
│   └── app_theme_test.dart
├── docs/
│   └── tugas/           # dokumentasi tugas mingguan
└── android/ ios/ web/ ...
```

## Dokumentasi Tugas Mingguan

Pertanyaan reflektif, catatan pengerjaan, dan AI disclosure setiap tugas disimpan di folder `docs/tugas/`, terpisah dari README ini agar lebih rapi.

- [Tugas 7 - Basic Flutter](docs/tugas/tugas7.md)
- [Tugas 8 - Navigation, Layouts, Forms, and Input Elements](docs/tugas/tugas8.md)