Nama: Kevin Fauzan Arjuna
NPM: 2506612266
Kelas: PBP F

# myportofolio_mobile

Aplikasi mobile portofolio pribadi berbasis Flutter, pendamping website [myportofolio](https://kevin-fauzan-myportofolio.pws.cs.ui.ac.id) untuk tugas PBP Semester 3, Fakultas Ilmu Komputer UI.

## Fitur

- **Identitas** - tiga kartu informasi (NPM, Name, Class) di bagian atas halaman.
- **Menu portofolio** - tombol berwarna untuk Lihat Proyek, Tambah Proyek, Lihat Pengalaman, Lihat Skills, Lihat Fotografi, dan Logout.
- **Daftar dan detail proyek** - data diambil dari API Django lewat `FutureBuilder`, bisa ditarik untuk refresh, dan bisa dibuka tanpa login. Gambar di halaman detail hanya muncul kalau URL-nya terisi.
- **Login berbasis token** - login memakai endpoint `/api/v1/auth/token/`, token disimpan di memori lewat `AuthState`, dan logout mencabut token di server.
- **Route guard** - Tambah Proyek (kartu dan drawer) mengarahkan ke layar login kalau belum masuk. Drawer menampilkan Login atau Logout sesuai status.
- **Form Tambah Proyek** - field mengikuti `ProjectSerializer` di Django, dikirim ke API dengan header `Authorization: Token ...`. Kalau token ditolak (401) sesi diakhiri dan login diminta lagi.
- **Form Tambah Pengalaman** - validasi per field, date picker, dan dialog ringkasan. Belum terhubung ke API.
- **Tema dari Django** - palet warna diambil dari `style.css` di proyek website.
- **Responsif** - grid 3 kolom di layar sempit dan 6 kolom di layar lebar, tanpa overflow di landscape.

## Tech Stack

- Flutter 3.47 / Dart 3.13, Material 3
- `http` untuk pemanggilan API dan `provider` untuk menyisipkan `ApiClient` dan `AuthState`
- `json_serializable` dan `build_runner` untuk model data
- GitHub Actions (`very_good_workflows`) untuk CI dan build APK

## Setup

Prasyarat: [Flutter SDK](https://docs.flutter.dev/get-started/install), emulator, perangkat, atau Chrome, dan backend [myportofolio](https://github.com/Kiara996/myportofolio) yang berjalan.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # membuat project.g.dart
flutter analyze          # harus "No issues found!"
flutter test
```

### Menjalankan dengan backend Django

Jalankan `python manage.py runserver` di repositori Django, lalu jalankan aplikasi sesuai target. URL backend diatur lewat `--dart-define=API_BASE_URL`, dan bawaannya `http://10.0.2.2:8000` (emulator Android).

```bash
flutter run                                                     # emulator Android
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
flutter run --dart-define=API_BASE_URL=https://<domain-django>   # backend yang sudah di-deploy
```

Untuk perangkat fisik, jalankan `adb reverse tcp:8000 tcp:8000` lebih dulu, lalu pakai `--dart-define=API_BASE_URL=http://localhost:8000`.

Hanya superuser Django yang bisa menambah proyek. Akun lain tetap bisa login, tetapi POST-nya dibalas 403.

## CI/CD

Workflow di `.github/workflows/main.yaml` menjalankan `build_runner`, `dart format`, `flutter analyze`, dan `flutter test` pada setiap push ke `main` dan pull request. Kalau semuanya lolos, job `build_apk` membuat APK release dan mengunggahnya sebagai artefak `app-release-apk`. Isi variabel repositori `API_BASE_URL` di Settings agar APK mengarah ke backend yang sudah di-deploy.

## Struktur Proyek

```text
myportofolio_mobile/
├── lib/
│   ├── main.dart            # entry point, MultiProvider, tema
│   ├── config.dart          # apiBaseUrl dari --dart-define
│   ├── models/
│   │   └── project.dart     # Project (@JsonSerializable)
│   ├── services/
│   │   ├── api_client.dart  # ApiClient dan ApiException
│   │   └── auth_state.dart  # AuthState (token sesi)
│   ├── screens/
│   │   ├── menu.dart                  # MyHomePage, InfoCard
│   │   ├── login_screen.dart          # LoginScreen
│   │   ├── project_list_screen.dart   # daftar proyek dari API
│   │   ├── project_detail_screen.dart # detail satu proyek
│   │   ├── project_form.dart          # form tambah proyek (POST ke API)
│   │   └── experience_form.dart       # form tambah pengalaman
│   ├── theme/
│   │   └── app_theme.dart   # palet warna dan ThemeData
│   ├── utils/
│   │   └── form_validators.dart  # validator form yang dipakai bareng
│   └── widgets/
│       ├── auth_guard.dart    # ensureLoggedIn
│       ├── left_drawer.dart   # drawer navigasi
│       └── project_card.dart  # ItemHomepage, ItemCard
├── test/
│   ├── support/fake_backend.dart  # server Django tiruan untuk test
│   └── *_test.dart
├── docs/
│   └── tugas/           # dokumentasi tugas mingguan
├── .github/workflows/   # CI/CD
└── android/ ios/ web/ ...
```

## Dokumentasi Tugas Mingguan

Pertanyaan reflektif, catatan pengerjaan, dan AI disclosure setiap tugas disimpan di folder `docs/tugas/`, terpisah dari README ini agar lebih rapi.

- [Tugas 7 - Basic Flutter](docs/tugas/tugas7.md)
- [Tugas 8 - Navigation, Layouts, Forms, and Input Elements](docs/tugas/tugas8.md)