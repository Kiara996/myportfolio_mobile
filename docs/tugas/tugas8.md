# Tugas 8

## Pertanyaan Reflektif

1. Jelaskan perbedaan antara `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`. Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Jelaskan juga bagaimana opsi Home di drawer membawa pengguna kembali ke halaman utama.

Ans: Navigator menyimpan halaman-halaman yang sedang terbuka dalam bentuk *stack*. `push()` menambahkan halaman baru di paling atas, jadi halaman sebelumnya masih ada di bawahnya dan pengguna bisa kembali lewat tombol back. `pushReplacement()` menukar halaman paling atas dengan halaman baru, jadi halaman lamanya hilang dan tidak bisa dikembalikan lewat tombol back. Sedangkan `pop()` hanya membuang halaman paling atas sehingga pengguna kembali ke halaman di bawahnya.

Untuk kartu aksi saya memakai `push()`, karena form adalah halaman tambahan yang cukup ditutup untuk kembali ke home. Opsi Home di drawer memakai `pushReplacement()` ke `MyHomePage`, sehingga form yang sedang terbuka digantikan oleh halaman utama. Efek sampingnya, kalau form dibuka dari kartu lalu pengguna menekan Home di drawer, di *stack* ada dua `MyHomePage`. Tampilannya tetap benar, hanya saja tombol back dari home yang baru akan menuju home yang lama.

2. Bagaimana susunan `Scaffold`, `AppBar`, dan `Drawer` membantu menjaga struktur halaman tetap konsisten? Berikan satu contoh penggunaan warna tema portofolio di lebih dari satu halaman.

Ans: `Scaffold` sudah menyediakan slot `appBar`, `drawer`, dan `body`, jadi semua halaman otomatis punya susunan yang sama. Judul dan tombol menu selalu di atas, dan isi halaman ada di bawahnya. `LeftDrawer` juga hanya satu widget yang dipakai di home, form proyek, dan form pengalaman, sehingga untuk menambah menu baru cukup mengedit satu file.

Contoh warnanya, `primary` di tema saya set ke warna `--ink` dari website Django lewat `buildAppTheme()`. Warna itu dibaca dengan `Theme.of(context).colorScheme.primary` di `AppBar` home, `AppBar` kedua form, dan `DrawerHeader`. Jadi kalau warnanya ingin diganti, cukup mengubahnya di tema dan semua halaman ikut berubah.

3. Mengapa tata letak tersebut dipilih untuk formulir? Jelaskan peran widget pengatur jarak dan widget penggulir ketika ruang layar terbatas.

Ans: Form saya susun satu kolom, yaitu `Column` di dalam `SingleChildScrollView`. Fieldnya cukup banyak dan ada yang panjang seperti deskripsi, jadi diisi dari atas ke bawah adalah yang paling nyaman di layar HP. Agar di layar lebar fieldnya tidak melebar berlebihan, saya membungkusnya dengan `Center` dan `ConstrainedBox` dengan lebar maksimal 600.

`Padding` memberi jarak 8 dp di sekitar tiap field supaya tidak berdempetan dan pesan error tidak menabrak field di bawahnya. Scroll sangat penting saat ruang sempit, misalnya layar pendek atau keyboard sedang muncul dan menutupi setengah layar. Tanpa scroll, field paling bawah dan tombol Simpan akan terpotong dan terkena overflow. Dengan scroll, semuanya tetap bisa dijangkau. Saat menguji di lebar 320 dp saya sempat menemukan overflow 75 px dari dropdown kategori, dan masalahnya selesai setelah diberi `isExpanded: true` supaya isinya mengikuti lebar kolom.

4. Apa peran `GlobalKey<FormState>`, validator, dan `validate()` saat tombol Simpan ditekan? Berikan satu contoh nilai yang ditolak oleh validasi dan jelaskan mengapa memilih jenis input atau papan ketik saja belum cukup.

Ans: `GlobalKey<FormState>` adalah pegangan ke `FormState` milik widget `Form`, sehingga tombol Simpan yang berada di luar field tetap bisa mengakses semua field di dalam form. Validator adalah fungsi di tiap field yang mengembalikan `null` kalau isinya valid atau teks error kalau tidak. Saat Simpan ditekan, `validate()` menjalankan semua validator sekaligus dan menampilkan pesan error di field yang salah. Hasilnya `true` hanya kalau semuanya lolos, dan baru pada saat itu `showDialog()` dipanggil.

Contoh yang ditolak, misalnya nama pengalaman `<b></b>` atau hanya spasi, link thumbnail `https://drive.google.com/file/d/abc/view`, atau tanggal selesai yang lebih awal dari tanggal mulai. Jenis keyboard saja tidak cukup karena itu hanya mengatur tampilan keyboard. `TextInputType.url` tidak mencegah orang menempelkan teks apa pun, dan date picker hanya menjamin formatnya tanggal, bukan urutan mulai dan selesai. Aturan seperti itu bergantung pada isi field lain atau aturan model, jadi harus dicek lewat validator.

## AI Disclosure Tugas 8

**Tools:** Gemini student plus Hydrogen

**Bagian yang dibantu AI:**

- Penyusunan `lib/utils/form_validators.dart` dan halaman `lib/screens/experience_form.dart`.
- Refactor `ItemHomepage.destination` dan `_DrawerItem`.
- Test di `test/experience_form_test.dart`, `test/form_validators_test.dart`, dan `test/app_theme_test.dart`.
- Port palet warna dari proyek Django ke tema Flutter.
- Diskusi teori dan materi untuk pertanyaan reflektif

**Keterbatasan AI yang ditemukan dan perbaikannya:**

- Di awal `flutter analyze` melaporkan 268 error dan test gagal dimuat, padahal kodenya tidak salah. Penyebabnya pub cache kosong sehingga `material_ui` tidak ditemukan. Setelah `flutter pub get`, hasilnya kembali bersih.
- Language server di VS Code menampilkan red lines palsu setiap ada file baru yang dibuat dari luar editor. Truthnya dicek dengan `flutter analyze`.
- Test di lebar 320 dp menangkap overflow dropdown kategori dan SnackBar dari halaman utama yang ikut tampil dan menutupi tombol Simpan di halaman form. Keduanya diperbaiki dan sekarang ada test pencegahnya.
- AI tidak bisa menjalankan emulator atau perangkat asli, jadi verifikasi hanya lewat widget test. Pengecekan di emulator atau Chrome saya lakukan sendiri.

**Log prompting:**
https://share.gemini.google/ZAYwPA5RbRL5 
