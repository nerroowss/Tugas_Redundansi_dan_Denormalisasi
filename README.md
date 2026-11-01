# Praktikum Redundansi dan Denormalisasi - TepatSasar

Modul 9 - Basis Data
Program Studi Teknologi Rekayasa Perangkat Lunak (TRPL)

-- IKHZANIERO ARDYANA JUNIAR
-- TEKNOLOGI REKAYASA PERANGKAT LUNAK
-- 1C

## Kasus yang Dipakai
Tabel dari SKPL kelompok (sistem TepatSasar): `petugas`, `warga`, dan
`pengajuan_bantuan`. Data yang dipakai adalah data fiktif.

## Lingkungan
- DBMS: MySQL/MariaDB lewat phpMyAdmin (versi: <hasil SELECT VERSION();>)

## Isi Repositori
| File / Folder | Keterangan |
|---|---|
| `tepatsasar_denormalisasi.sql` | Seluruh script: tabel, data, Tahap 1-3, bukti tidak sinkron, dan trigger |
| `bukti/` | Screenshot hasil praktikum (01 sampai 14) |

## Cara Menjalankan
1. Buka phpMyAdmin, pilih tab **Impor**.
2. Pilih file `tepatsasar_denormalisasi.sql`, lalu klik **Kirim**.
3. Atau tempel isinya per bagian di tab **SQL** sesuai urutan tahap.

Catatan: script diawali `DROP DATABASE IF EXISTS`, sehingga database
`tepatsasar_denormalisasi` yang sudah ada akan dihapus dan dibuat ulang.

## Relasi Tabel
![Designer](bukti/03_designer.png)

Gambar diambil setelah Tahap 2, sehingga kolom `jumlah_pengajuan` sudah ada di tabel `warga`.

## Tahap 1 - Eksplorasi JOIN (Kondisi Normalisasi)
Query `LEFT JOIN` + `COUNT` + `GROUP BY` untuk menghitung jumlah pengajuan per warga.

![Tahap 1](bukti/04_tahap1_join.png)

Hasil: Budi 2, Siti 1, Joko 3, Rina 0.

### Catatan Kompleksitas Query
| Aspek | Tahap 1 (Normalisasi) | Tahap 3 (Denormalisasi) |
|---|---|---|
| Tabel yang diakses | 2 (`warga`, `pengajuan_bantuan`) | 1 (`warga`) |
| Jumlah JOIN | 1 (LEFT JOIN) | 0 |
| Kunci penghubung | `warga.id_warga = pengajuan_bantuan.id_warga` | - |
| Fungsi agregat | `COUNT` + `GROUP BY` | Tidak ada |
| Pekerjaan database | Mencocokkan dan menghitung ulang setiap dijalankan | Hanya membaca nilai tersimpan |
| Hasil | Budi 2, Siti 1, Joko 3, Rina 0 | Sama dengan Tahap 1 |

## Tahap 2 - Penerapan Denormalisasi
Menambah atribut turunan `jumlah_pengajuan` pada tabel `warga`, lalu mengisinya
dari hasil perhitungan Tahap 1.

DDL `ALTER TABLE`:

![ALTER TABLE](bukti/05_tahap2_alter_table.png)

Mengisi kolom dengan `UPDATE` (3 baris berubah, Rina tetap 0):

![UPDATE](bukti/06_tahap2_update_isi_kolom.png)

## Tahap 3 - Pembuktian
`SELECT` sederhana dari satu tabel, tanpa JOIN dan tanpa agregasi.

![Tahap 3](bukti/07_tahap3_select_sederhana.png)

Isi kolom pada tabel `warga`:

![Isi kolom](bukti/08_tahap3_cek_isi_kolom.png)

Hasilnya sama dengan Tahap 1, tetapi query lebih sederhana dan lebih ringan.

## Kaitan dengan SKPL
Daftar penerima dan laporan rekapitulasi membutuhkan data gabungan warga dan
pengajuan, dan SKPL mensyaratkan laporan tampil cepat. Karena itu jumlah
pengajuan per warga disimpan sebagai kolom turunan di tabel `warga`.
<sesuaikan dengan nomor KF/KNF di SKPL kelompok>

## Redundansi dan Risikonya
Kolom `jumlah_pengajuan` bisa dihitung dari `pengajuan_bantuan`, tetapi sengaja
disimpan lagi supaya pembacaan lebih ringan. Akibatnya informasi yang sama ada
di dua tempat dan bisa tidak sinkron.

**1. Pengajuan baru untuk Budi dimasukkan**

![Insert pengajuan baru](bukti/09_insert_pengajuan_baru.png)

**2. Data tidak sinkron** (hasil JOIN 3, kolom tersimpan masih 2)

![Tidak sinkron](bukti/10_bukti_tidak_sinkron.png)

**3. Sinkronisasi ulang dengan `UPDATE`** (1 baris berubah)

![Sinkron ulang](bukti/11_update_sinkron_ulang.png)

**4. Trigger dibuat** (`trg_pengajuan_after_insert`, hanya untuk INSERT)

![Buat trigger](bukti/12_buat_trigger.png)

**5. Tes trigger: pengajuan baru dimasukkan**

![Tes trigger](bukti/13_insert_tes_trigger.png)

**6. Hasil: kolom ikut naik otomatis** (Budi 4 dan 4)

![Trigger sinkron](bukti/14_bukti_trigger_sinkron.png)

## Persiapan Database
Pembuatan tabel dan data contoh:

![Buat tabel](bukti/01_buat_tabel.png)

![Isi data](bukti/02_isi_data.png)

## Kesimpulan
Denormalisasi membuat pembacaan lebih sederhana karena tidak perlu JOIN dan
agregasi, tetapi menambah redundansi sehingga data harus dijaga tetap sinkron.
Trigger yang dipakai baru menangani INSERT. Untuk penghapusan pengajuan
diperlukan trigger DELETE tersendiri.
