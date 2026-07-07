## Fitur Umum (General Features Baseline)

Sebelum masuk ke fitur *overpower*, aplikasi ini wajib memiliki pondasi dasar yang biasa ada di aplikasi finansial:

* **Registrasi & Autentikasi:** Login via Email, Google, Apple ID, dan Biometrik (Fingerprint/FaceID).
* **Manajemen Multi-Akun/Dompet:** Pengelompokan dana (Cash, Bank A, Bank B, E-Wallet).
* **Pencatatan Manual:** Input transaksi manual jika pengguna bertransaksi tunai (Nominal, Kategori, Catatan, Tanggal).
* **Riwayat Transaksi & Filter:** Pencarian dan filter transaksi berdasarkan tanggal, kategori, atau nominal.
* **Dashboard & Grafik Analitik:** Grafik lingkaran (*pie chart*) atau batang untuk melihat persentase pengeluaran bulanan.

---

## Functional Requirements (FR) Matrix

Berikut adalah spesifikasi fitur *overpower* gabungan dengan fitur general, dikategorikan berdasarkan prioritasnya:

### 1. Must Have (Wajib Ada di MVP)

> Tanpa fitur ini, aplikasi tidak bisa berfungsi dengan baik atau kehilangan esensi utamanya sebagai *smart finance app*.

| ID | Nama Fitur | Deskripsi Fungsional | Kategori |
| --- | --- | --- | --- |
| **FR-M01** | *Core Authentication* | Pengguna dapat mendaftar, masuk, dan mengamankan akun menggunakan PIN/Biometrik. | General |
| **FR-M02** | *Multi-Wallet Setup* | Pengguna dapat membuat lebih dari satu kantong/dompet digital (Cash, Bank, E-Wallet). | General |
| **FR-M03** | *Manual Logging* | Pengguna dapat mencatat pemasukan dan pengeluaran secara manual lengkap dengan kategori standar. | General |
| **FR-M04** | **AI Auto-Categorization & Receipt Scanner** | Pengguna dapat memfoto struk fisik atau menyalin riwayat e-wallet; AI otomatis membaca teks (OCR) dan memasukkannya ke kategori yang tepat tanpa input manual. | **Overpower** |
| **FR-M05** | *Basic Budgeting* | Pengguna dapat menetapkan batas anggaran bulanan per kategori (misal: Makanan Rp1.000.000/bulan). | General |
| **FR-M06** | *Analytical Dashboard* | Sistem menyediakan visualisasi grafik pengeluaran dan pemasukan secara real-time di halaman utama. | General |

### 2. Should Have (Sangat Penting, Harap Ada Setelah MVP)

> Fitur yang memberikan nilai kompetitif tinggi. Aplikasi tetap bisa jalan tanpa ini, tapi fitur inilah yang mulai membedakanmu dari kompetitor.

| ID | Nama Fitur | Deskripsi Fungsional | Kategori |
| --- | --- | --- | --- |
| **FR-S01** | **Predictive Burn-Rate Alert** | AI menganalisis kecepatan belanja pengguna dan memprediksi tanggal uang habis. Sistem otomatis mengirimkan notifikasi peringatan dini. | **Overpower** |
| **FR-S02** | **Split-Bill & Auto-Tagging** | Pengguna bisa membuat grup patungan, membagi tagihan secara otomatis, dan sistem mengirimkan pengingat tagihan ke anggota grup via ekosistem aplikasi/WA. | **Overpower** |
| **FR-S03** | **Guilt-Free Spending Calculator** | Kalkulator instan untuk mengecek apakah pengguna "aman" membeli barang tersier saat itu juga berdasarkan sisa *budget* aman bulanan. | **Overpower** |
| **FR-S04** | **Anti-Impulsive Buying Barrier** | Fitur "Cooling Off". Mengunci saldo tertentu selama beberapa jam jika mendeteksi adanya indikasi *panic buying* atau belanja di jam rawan (tengah malam). | **Overpower** |

### 3. Could Have (Good to Have / Inovasi Masa Depan)

> Fitur pelengkap yang membuat aplikasi terasa sangat futuristik dan menyenangkan (*delighters*), bisa dimasukkan di fase *update* besar.

| ID | Nama Fitur | Deskripsi Fungsional | Kategori |
| --- | --- | --- | --- |
| **FR-C01** | **Financial Avatar & Persona** | Karakter gamifikasi visual yang kondisinya (senang/sedih/sakit) berubah secara real-time mengikuti kesehatan finansial riil pengguna. | **Overpower** |
| **FR-C02** | **Auto-Investment Sweep** | Sistem otomatis memindahkan sisa *budget* bulanan yang tidak terpakai ke reksa dana/emas mitra berizin resmi di akhir bulan. | **Overpower** |
| **FR-C03** | **Financial Compatibility Score** | Mode berbagi finansial aman dengan pasangan untuk melihat kecocokan gaya hidup dan tujuan keuangan bersama tanpa membuka detail saldo privasi. | **Overpower** |
| **FR-C04** | **What-If Simulator & Macro Impact** | Kalkulator simulasi dampak jangka panjang jika pengguna menaikkan gaya hidup (*lifestyle upgrade*) atau jika terjadi inflasi terhadap target tabungan mereka. | **Overpower** |

---

## Non-Functional Requirements (NFR)

NFR mendefinisikan *bagaimana* sistem harus bekerja (kualitas, keamanan, dan performa). Untuk aplikasi keuangan, bagian ini sangat krusial.

* **NFR-SEC-01 (Security):** Semua data keuangan dan data pribadi pengguna wajib dienkripsi saat dikirim (*in-transit*) menggunakan TLS 1.3 dan saat disimpan (*at-rest*) menggunakan algoritma AES-256.
* **NFR-SEC-02 (Compliance):** Sistem harus patuh pada regulasi perlindungan data pribadi lokal (seperti UU PDP di Indonesia) dan tidak menyimpan kredensial bank pengguna secara mentah (*plain text*).
* **NFR-PERF-01 (Performance):** Proses pemindaian struk (OCR AI) hingga berhasil mengategorikan pengeluaran tidak boleh memakan waktu lebih dari 3 detik.
* **NFR-PERF-02 (Availability):** Sistem harus memiliki *uptime* minimal 99.9% agar pengguna bisa mencatat atau mengecek keuangan kapan saja.
* **NFR-UX-01 (Usability):** Alur pencatatan manual atau pemindaian struk harus bisa diakses maksimal dalam 2 kali ketukan (*clicks*) dari halaman utama aplikasi.

---

Dokumen ini bisa langsung kamu salin ke Notion, Jira, atau diberikan ke tim *Product Manager* dan *Developer* sebagai panduan awal pengembangan taktis aplikasi finansialmu.

Mengingat fitur **AI Auto-Categorization & Receipt Scanner (FR-M04)** adalah jangkar utama dari fitur *overpower* di fase awal, apakah kamu sudah ada bayangan ingin menggunakan *third-party API* untuk OCR-nya atau berniat membangun model AI sendiri?



