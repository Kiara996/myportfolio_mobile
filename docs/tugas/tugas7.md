# Tugas 7

## Pertanyaan Reflektif

1. Jelaskan apa yang dimaksud dengan *widget tree* pada Flutter dan bagaimana hubungan induk-anak (*parent-child*) bekerja antar-*widget*!

Ans: *Widget tree* adalah susunan widget yang saling terhubung sehingga membentuk struktur tree dengan satu widget sebagai rootnya. Di Flutter hampir semua hal di layar adalah widget, mulai dari teks, tombol, sampai pengatur tata letak seperti `Column` dan `Padding`, dan widget-widget itu saling me-wrapping satu sama lain. Pada proyek ini rootnya adalah `MyApp` yang dijalankan lewat `runApp`, lalu method `build` milik setiap widget mengembalikan widget lain sebagai childnya. Alurnya mulai dari `MyApp` lalu turun ke `MaterialApp`, `MyHomePage`, lalu `Scaffold` yang punya dua child, yaitu `AppBar` dan `body` berisi `LayoutBuilder`. Di dalam `body` itu ada `SingleChildScrollView`, `Center`, `ConstrainedBox`, dan `Padding` yang mewrap sebuah `Column` berisi tiga `InfoCard` dalam satu `Row`, teks sambutan, dan `GridView` yang berisi enam `ItemCard`. Widget sendiri hanyalah deskripsi konfigurasi yang tidak bisa diubah, sedangkan pekerjaan menghitung layout dan menggambar dilakukan objek lain yang dibuat framework dari pohon itu, yaitu *Element tree* dan *RenderObject tree*.

Hubungan induk-anak terlihat dalam tiga hal. Pertama, dari sisi susunan, widget yang hanya punya satu child seperti `Padding`, `Center`, `Card`, dan `InkWell` memakai properti `child`, sedangkan widget yang punya banyak child seperti `Column`, `Row`, dan `GridView` memakai `children`. Kedua, dari sisi layout, parent memberi batas ukuran (*constraints*) kepada childnya, child memilih ukurannya sendiri di dalam batas itu, lalu parent yang menentukan posisinya. Contohnya di proyek saya, `GridView` memberi setiap `ItemCard` sebuah sel persegi, `Expanded` di dalam `Row` membagi lebar sama rata ke tiga `InfoCard`, dan `Flexible` di dalam `ItemCard` menyuruh `Text` menyusut ke sisa ruang kolom. `Flexible` itu baru saya tambahkan setelah tes menangkap bug overflow, yaitu ketika `Column` tidak punya ruang cadangan untuk teks dua baris. Ketiga, dari sisi data, informasi mengalir turun dari parent ke child lewat konstruktor, misalnya `InfoCard(title: 'NPM', content: npm)` dan `ItemCard(item)`, atau lewat `InheritedWidget` yang dibaca child memakai `context` seperti pada `Theme.of(context)`.

2. Sebutkan semua *widget* yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!

Ans: Widget yang saya pakai overall dapat di grouping ke dalam fungsinya:

- Widget Kerangka aplikasi dan halaman: `MyApp` adalah `StatelessWidget` root yang membangun `MaterialApp`, yaitu widget yang menyediakan tema, judul, navigator, dan menentukan halaman awal lewat properti `home`. `MyHomePage` adalah halaman utama yang juga `StatelessWidget`. Di dalamnya `Scaffold` menjadi kerangka halaman dengan `appBar` dan `body` sekaligus tempat SnackBar ditampilkan, sedangkan `AppBar` menampilkan bar judul MyPortfolio di bagian atas.
- Widget Tata letak: saya memakai `Column` dan `Row` untuk menyusun child secara vertikal dan horizontal, `Padding` untuk memberi jarak, dan `SizedBox` sebagai spasi kosong antar elemen. `Expanded` membagi lebar `Row` sama rata ke tiga `InfoCard`, dan `IntrinsicHeight` menyamakan tinggi ketiga kartu itu walaupun jumlah baris teksnya berbeda. `GridView.count` menata `ItemCard` dalam kisi dengan jumlah kolom tetap. Agar tampilannya responsif, `LayoutBuilder` membaca lebar yang tersedia untuk memilih 3 atau 6 kolom, `Center` dan `ConstrainedBox` memusatkan konten sekaligus membatasi lebarnya 720 dp di layar lebar, dan `SingleChildScrollView` membuat halaman bisa discroll supaya tidak overflow di layar pendek atau landscape. `Flexible` dipakai di dalam `ItemCard` agar teks bisa menyusut ke ruang yang tersisa.
- Widget Isi tampilan: `Text` menampilkan semua tulisan, mulai dari judul kartu, isi kartu, kalimat sambutan, sampai nama tombol, dan `Icon` menampilkan ikon tiap tombol. `InfoCard` adalah widget buatan sendiri yang dibangun dari `Card`, yaitu wadah bergaya Material dengan bayangan, untuk menampilkan pasangan judul dan isi seperti NPM, Name, dan Class. `ItemCard` juga widget buatan sendiri. Widget tersebut dibangun dari `Material` yang memberi warna latar dan sudut membulat, serta `InkWell` yang membuatnya bisa ditekan lewat `onTap` dengan ripple effect.
- Widget Interaksi: `SnackBar` menampilkan pesan singkat di bawah layar ketika tombol ditekan. Khusus tombol Logout dipakai `AlertDialog` dengan `TextButton` dan `FilledButton` sebagai tombol Batal dan Logout, yang dibuka dengan `showDialog`.

3. Apa fungsi dari *widget* `MaterialApp`? Jelaskan mengapa *widget* ini umumnya digunakan sebagai *root widget* pada aplikasi Flutter!

Ans: `MaterialApp` adalah widget wrapper yang menyiapkan semua kebutuhan dasar aplikasi bergaya Material Design. `MaterialApp` menyediakan tema lewat `Theme` dan `ThemeData` yang dibaca widget Material memakai `Theme.of(context)`. Di proyek ini `ColorScheme.fromSeed` dengan `seedColor` indigo membuat warna `AppBar` dan komponen lain tampil konsisten. `MaterialApp` juga menyediakan `Navigator` untuk berpindah halaman, menampilkan dialog, dan menentukan halaman awal lewat `home` atau `routes`, serta `ScaffoldMessenger` yang mengatur antrean SnackBar sehingga `ScaffoldMessenger.of(context).showSnackBar` di `ItemCard` bisa bekerja. Di bawahnya masih ada layanan dasar seperti `MediaQuery` untuk ukuran layar, `Directionality` untuk arah teks, `Localizations`, dan `Overlay` tempat dialog digambar, ditambah pengaturan seperti `title` aplikasi.

`MaterialApp` umumnya dijadikan *root widget* karena widget Material seperti `Scaffold`, `AppBar`, `SnackBar`, dan `showDialog` mencari ancestornya lewat `context`, yaitu `Theme`, `Navigator`, `ScaffoldMessenger`, `MaterialLocalizations`, dan `Directionality`. Kalau tidak ada `MaterialApp` di atasnya, widget-widget itu tidak menemukan yang dicarinya dan menghasilkan error karena `MediaQuery` atau `MaterialLocalizations` tidak ditemukan. Dengan menaruhnya di root, semua widget di bawahnya otomatis mendapat tema, navigasi, dan layanan yang sama dari satu tempat saja. Meski begitu ini bukan keharusan mutlak, karena aplikasi bergaya iOS bisa memakai `CupertinoApp` dan kebutuhan yang paling minimal bisa dipenuhi `WidgetsApp`.

4. Jelaskan perbedaan antara `StatelessWidget` dan `StatefulWidget`! Kapan kita sebaiknya memilih `StatelessWidget` dan kapan harus menggunakan `StatefulWidget`?

Ans: Perbedaan utamanya ada pada apakah widget itu menyimpan state yang bisa berubah selama ia hidup. `StatelessWidget` tidak menyimpan state sendiri, jadi tampilannya hanya bergantung pada konfigurasi yang diberikan lewat field `final` dan pada `InheritedWidget` yang dibaca lewat `context`. Method `build`-nya hanya dipanggil ulang kalau parentnya membangun ulang atau dependensinya berubah. `StatefulWidget` terdiri dari dua class, yaitu widget yang tetap *immutable* dan objek `State` yang berumur panjang dan bertahan di antara *rebuild*. Perubahan tampilan dilakukan lewat `setState` yang memicu `build` dipanggil lagi, dan `State` juga punya siklus hidup seperti `initState`, `didUpdateWidget`, dan `dispose` untuk menyiapkan dan membersihkan sumber daya.

Saya memilih `StatelessWidget` selama tampilan hanya bergantung pada data yang diberikan dari luar. `StatefulWidget` baru diperlukan ketika widget itu sendiri harus mengingat sesuatu yang berubah, misalnya isi `TextField` lewat `TextEditingController`, status centang, tab yang sedang dipilih, animasi dengan `AnimationController`, atau counter pada template bawaan Flutter. Kalau state itu dibutuhkan banyak widget sekaligus, biasanya lebih baik diangkat ke parent atau memakai *state management* daripada menambah `StatefulWidget` di banyak tempat.

5. Apa itu `BuildContext` dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode `build`?

Ans: `BuildContext` adalah penunjuk ke posisi sebuah widget di dalam widget tree, yang di balik layar berupa objek `Element` milik widget itu. Setiap widget punya context-nya sendiri, dan lewat context itulah sebuah widget bisa melihat ke atas tree untuk mencari ancestor terdekat dengan tipe tertentu. Karena itu method seperti `Theme.of(context)` bergantung pada posisi, karena hasilnya adalah tema terdekat di atas widget tersebut. Hal ini penting karena Flutter tidak memakai variabel global untuk tema atau navigasi, jadi context adalah jalan bagi widget untuk mendapatkannya.

Di dalam method `build(BuildContext context)`, saya memakainya untuk membaca konfigurasi dari ancestor, misalnya `Theme.of(context).colorScheme.primary` untuk warna `AppBar` di `MyHomePage`. Context juga dipakai untuk mengambil layanan seperti `ScaffoldMessenger.of(context)` yang menampilkan SnackBar di `ItemCard`, dan untuk membuka dialog lewat `showDialog(context: context, ...)`.

Context adalah milik widget yang sedang di-*build*, jadi memanggil `Scaffold.of(context)` di dalam `build` milik `Scaffold` sendiri tidak akan menemukan apa-apa karena target widget ada di atas context tersebut. Solusinya memakai `Builder` atau memecahnya menjadi widget terpisah. Hal lain, context sebaiknya tidak dipakai setelah `await` karena widget bisa saja sudah dilepas dari tree saat future selesai. Karena itu di `ItemCard._onTap` saya mengambil `ScaffoldMessenger.of(context)` ke variabel `messenger` sebelum `showDialog` di-`await`, sehingga setelah dialog ditutup yang dipakai adalah `messenger`, bukan `context`. Hal ini juga diminta oleh lint `use_build_context_synchronously`, dan alternatif lainnya adalah mengecek `context.mounted` sebelum memakai context lagi. Terakhir, di dalam `builder` milik dialog saya memakai `dialogContext` untuk `Navigator.pop` supaya yang ditutup adalah rute dialog itu sendiri.

6. Jelaskan konsep *hot reload* di Flutter dan apa perbedaannya dengan *hot restart*! Kapan kita tidak bisa hanya mengandalkan *hot reload* dan harus melakukan *hot restart* atau *full restart*?

Ans: *Hot reload* adalah fitur yang memasukkan perubahan kode ke Dart VM yang sedang berjalan lalu membangun ulang widget tree dengan state aplikasi tetap terjaga. Menurut dokumentasi resmi Flutter, hot reload tidak menjalankan ulang `main()` maupun `initState()`, dan hasilnya muncul dalam hitungan detik sehingga cocok untuk mengubah tampilan seperti warna, teks, atau susunan widget. *Hot restart* memuat kode baru lalu menjalankan aplikasi dari awal sehingga `main()` dijalankan lagi dan semua state hilang. Ia lebih lambat dari hot reload tetapi lebih cepat dari *full restart*, yang mana ia akan menghentikan progra, lalu menjalankan ulang aplikasi di perangkat, termasuk mengompilasi ulang bagian native seperti Kotlin, Java, Swift, atau Objective-C. Jadi perbedaan hot reload dan hot restart ada pada nasib state, hot reload mempertahankannya sedangkan hot restart membuangnya.

Hot reload tidak cukup dalam beberapa kondisi berikut.

- Perubahan di `main()` atau `initState()`, karena keduanya tidak dijalankan ulang, dan secara umum kode yang tidak dieksekusi lagi ketika widget tree dibangun ulang tidak akan terlihat efeknya.
- Perubahan initializer variabel global atau field `static`, karena nilainya tidak dihitung ulang. Contohnya di proyek ini, kalau daftar `items` saya pindahkan dari field `MyHomePage` menjadi variabel global `final` lalu saya ganti warnanya, hot reload tidak akan memperlihatkan perubahan itu. Karena sekarang `items` adalah field instance dan `MyHomePage()` dibuat ulang setiap `MyApp.build` dipanggil, perubahan warna terbaca lewat hot reload.
- Perubahan `enum` menjadi kelas biasa atau sebaliknya, atau perubahan deklarasi tipe generik, misalnya `class A<T>` menjadi `class A<T, V>`.
- State yang sudah terlanjur berubah. Karena state dipertahankan, perilaku setelah beberapa kali hot reload bisa berbeda dari setelah hot restart, jadi kalau tampilan terlihat janggal, hot restart adalah cara cepat memastikan kodenya benar dari kondisi awal.

Full restart diperlukan kalau yang berubah adalah kode native, dan praktis juga ketika ada perubahan sisi native lain seperti konfigurasi Android atau iOS atau penambahan plugin baru di `pubspec.yaml`, karena bagian itu harus dikompilasi dan dipasang ulang. Terakhir, hot reload akan ditolak kalau ada error kompilasi, jadi errornya harus diperbaiki dulu baru reload lagi.

## AI Disclosure Tugas 7

**Tools:** Gemini Plus Student

**Bagian yang dibantu AI:**

- Unit Tes `test/widget_test.dart` (12 tes) (Saya sesuaikan ulang pasca generate).
- Penyusunan teori dan dasar argumen reflektif

**Keterbatasan AI yang ditemukan dan perbaikannya:**

- AI tidak dapat menjalankan emulator atau perangkat Android/iOS. Tes widget memakai font uji (Ahem) yang ukurannya berbeda dari font asli, dan verifikasi visual hanya lewat build web. Hasil pada font asli diperiksa lewat screenshot web. Pengecekan di emulator/perangkat perlu saya lakukan sendiri.
- Setelah AI menulis dan memformat file dari luar editor, VS Code menampilkan false red lines padahal `flutter analyze` bersih. Saya melihat red lines di IDE, lalu AI membandingkan diagnostik IDE dengan `flutter analyze`. Error menunjuk baris dari versi lama file. Penyelesaiannya language server Dart di-restart sehingga diagnostik kembali bersih, dan `dart format` dijalankan untuk merapikan kode.

**Log prompting:**

https://share.gemini.google/EFlESdOvN23e 