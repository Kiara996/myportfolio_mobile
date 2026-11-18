Nama: Kevin Fauzan Arjuna
NPM: 2506612266
Kelas: PBP F

# myportofolio_mobile

Aplikasi mobile portofolio pribadi berbasis Flutter, pendamping website [myportofolio](https://kevin-fauzan-myportofolio.pws.cs.ui.ac.id) untuk tugas PBP Semester 3, Fakultas Ilmu Komputer UI.

## Fitur

- **Identitas** - tiga kartu informasi (NPM, Name, Class) di bagian atas halaman.
- **Menu portofolio** - tombol berwarna untuk Lihat Proyek, Tambah Proyek, Lihat Pengalaman, Lihat Skills, Lihat Fotografi, dan Logout. Setiap tombol menampilkan SnackBar saat ditekan.
- **Konfirmasi Logout** - dialog Batal/Logout sebelum keluar.
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
│   │   └── project_form.dart  # ProjectFormPage (form tambah proyek)
│   └── widgets/
│       ├── left_drawer.dart   # drawer navigasi
│       └── project_card.dart  # ItemHomepage, ItemCard
├── test/
│   ├── widget_test.dart
│   └── project_form_test.dart
├── docs/
│   └── tugas/           # dokumentasi tugas mingguan
└── android/ ios/ web/ ...
```

## Dokumentasi Tugas Mingguan

Pertanyaan reflektif, catatan pengerjaan, dan AI disclosure setiap tugas disimpan di folder `docs/tugas/`, terpisah dari README ini agar lebih rapi.

- [Tugas 7 - Basic Flutter](docs/tugas/tugas7.md)