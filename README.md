# Honda Dealer (Flutter Web + Firebase)

Web dealer mobil Honda yang dirancang untuk penjualan **online dan offline**, dibangun dengan **Flutter Web** dan **Firebase**.

> **Project pembelajaran, bukan dealer resmi Honda.**
> Project ini dibuat untuk belajar Flutter dan backend. Nama dan gambar produk Honda adalah milik pemegang mereknya masing-masing. Logo "H" di aplikasi adalah logo buatan sendiri, bukan logo resmi. Pembayaran di Checkout hanya **simulasi** dan tidak terhubung ke bank sungguhan. Gunakan **data dummy** saat mengisi NIK dan Kartu Keluarga.

**Demo langsung:** https://web-dealer-mobil.web.app

---

## Gambaran Singkat

Pengunjung membuka situs dan langsung melihat katalog mobil. Untuk melihat detail unit mereka perlu membuat akun, dan untuk membeli mereka perlu melengkapi data diri. Setelah pembayaran lunas, pembeli dihubungkan dengan admin yang mengurus dokumen (BPKB/STNK) dan pengiriman unit.

### Alur Pengguna

```
Home (guest, eksplorasi terbatas)
  -> Daftar akun (email + password)
  -> Detail mobil
  -> Lengkapi data diri (NIK, KK, nomor HP, alamat)
  -> Checkout (Virtual Account simulasi: BRI, Mandiri, BCA, Jatim)
  -> Admin Chat (direncanakan)
```

### Tiga Level Akses

| Level | Syarat | Bisa melakukan |
|---|---|---|
| `guest` | Belum login | Melihat katalog di Home |
| `registered` | Sudah punya akun | Melihat detail mobil |
| `complete` | Data diri sudah diisi | Membeli (Checkout) |

---

## Fitur

**Sudah jadi**

- Katalog 11 unit Honda dengan spesifikasi lengkap (transmisi, bahan bakar, kapasitas, fitur unggulan, deskripsi)
- Registrasi, login, dan reset password via email memakai Firebase Authentication
- Sesi login bertahan setelah halaman di-refresh
- Penyimpanan profil dan level akses di Cloud Firestore
- Gerbang akses tiga level (guest, registered, complete)
- Checkout dengan simulasi Virtual Account per transaksi dan status pembayaran (belum bayar, pending, lunas)
- Tampilan responsif untuk layar lebar dan sempit, dengan halaman login, daftar, dan reset password bergaya animasi
- Sistem desain terpusat (warna merah Honda, font Barlow)

**Direncanakan**

- Admin Chat real-time (Admin Pusat sebelum dan saat membeli, Admin Cabang setelah lunas)
- Penyimpanan pesanan ke Firestore
- Sisi admin: verifikasi data diri dan pengelolaan stok per cabang
- Peta dealer dengan ketersediaan unit per cabang
- Login dengan Google
- Redesain halaman Registrasi Data Diri dan Checkout

---

## Teknologi

- **Flutter Web** (Flutter 3.47.2, Dart 3.13.2)
- **GetX** untuk state management dan navigasi
- **Firebase Authentication** (Email/Password)
- **Cloud Firestore** sebagai database
- **Firebase Hosting** untuk deploy
- **Google Fonts** (Barlow)

---

## Struktur Folder

```
lib/
  Controller/   # AuthController (login, daftar, level akses)
  Views/        # Halaman: Home, Detail, Login, Sign Up, Reset Password,
                #          Registrasi Data Diri, Checkout, About Me
  models/       # Model Mobil dan daftar unit
  style/        # Token desain dan tampilan halaman autentikasi
  firebase_options.dart   # Dibuat oleh FlutterFire CLI
  main.dart
```

---

## Cara Menjalankan

Kebutuhan: Flutter SDK, Node.js, dan akun Firebase.

1. **Clone repositori dan pasang dependensi**

   ```bash
   git clone <url-repositori-ini>
   cd <nama-folder>
   flutter pub get
   ```

2. **Siapkan project Firebase milikmu sendiri.** Buat project di [Firebase Console](https://console.firebase.google.com/), lalu aktifkan:
   - Authentication, metode **Email/Password**
   - Cloud Firestore (production mode)

3. **Hubungkan aplikasi ke project Firebase-mu**

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Perintah ini akan membuat ulang `lib/firebase_options.dart` untuk project-mu.

4. **Pasang aturan keamanan Firestore.** Buka tab **Rules** di Firestore lalu publish:

   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{uid} {
         allow read: if request.auth != null && request.auth.uid == uid;
         allow create: if request.auth != null && request.auth.uid == uid
                       && request.resource.data.role == 'user';
         allow update: if request.auth != null && request.auth.uid == uid
                       && request.resource.data.role == resource.data.role;
       }
     }
   }
   ```

   User hanya bisa membaca dan mengubah dokumennya sendiri, dan tidak bisa mengubah `role` miliknya. Koleksi lain terkunci.

5. **Jalankan di Chrome**

   ```bash
   flutter run -d chrome
   ```

### Build dan Deploy

```bash
flutter build web
firebase deploy --only hosting
```

---

## Catatan Keamanan

- Nilai di `firebase_options.dart` untuk web adalah pengenal project yang memang tampil di sisi klien. Perlindungan datanya ada pada **Firestore Rules** dan Authentication, bukan pada kerahasiaan nilai tersebut.
- Jangan memasukkan data pribadi asli (NIK, KK, nomor HP) saat mencoba demo.
- Akun admin dibuat manual lewat Firebase Console (mengubah field `role` pada dokumen user).

---

## Status

Project dalam pengembangan aktif (sekitar 45%). Fokus saat ini: fitur Admin Chat berbasis Firestore real-time.