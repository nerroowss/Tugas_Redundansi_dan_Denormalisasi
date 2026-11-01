-- =====================================================
-- IKHZANIERO ARDYANA JUNIAR - 264311070 - TRPL - 1C
-- Modul 9: Redundansi dan Denormalisasi
-- Kasus: TepatSasar (tabel dari SKPL kelompok)
-- Catatan: DROP DATABASE menghapus database lama bernama sama.
-- =====================================================

DROP DATABASE IF EXISTS tepatsasar_denormalisasi;
CREATE DATABASE tepatsasar_denormalisasi;
USE tepatsasar_denormalisasi;

-- ===== 0. SCHEMA =====
CREATE TABLE petugas (
    id_petugas INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    peran ENUM('kader_rt','staf_kelurahan') NOT NULL
);

CREATE TABLE warga (
    id_warga INT AUTO_INCREMENT PRIMARY KEY,
    id_petugas INT NOT NULL,
    nik CHAR(16) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    kategori_kerentanan VARCHAR(50),
    kondisi_ekonomi VARCHAR(100),
    tanggal_dicatat DATE NOT NULL,
    FOREIGN KEY (id_petugas) REFERENCES petugas(id_petugas)
);

CREATE TABLE pengajuan_bantuan (
    id_pengajuan INT AUTO_INCREMENT PRIMARY KEY,
    id_warga INT NOT NULL,
    jenis_bantuan VARCHAR(50) NOT NULL,
    tanggal_pengajuan DATE NOT NULL,
    status_pengajuan VARCHAR(30) NOT NULL DEFAULT 'diajukan',
    FOREIGN KEY (id_warga) REFERENCES warga(id_warga)
);

-- ===== 0. DATA CONTOH (fiktif) =====
INSERT INTO petugas (id_petugas, nama, username, password, peran)
VALUES (1, 'Kader Contoh', 'kader1', 'hash_contoh', 'kader_rt');

INSERT INTO warga (id_warga, id_petugas, nik, nama, alamat, kategori_kerentanan, kondisi_ekonomi, tanggal_dicatat) VALUES
(1, 1, '3577010101010001', 'Budi', 'RT 01 RW 01', 'lansia', 'tidak berpenghasilan tetap', '2026-10-01'),
(2, 1, '3577010101010002', 'Siti', 'RT 01 RW 02', 'disabilitas', 'buruh harian', '2026-10-01'),
(3, 1, '3577010101010003', 'Joko', 'RT 02 RW 01', 'keluarga miskin', 'pedagang kecil', '2026-10-02'),
(4, 1, '3577010101010004', 'Rina', 'RT 02 RW 02', 'keluarga miskin', 'tidak bekerja', '2026-10-02');

INSERT INTO pengajuan_bantuan (id_pengajuan, id_warga, jenis_bantuan, tanggal_pengajuan, status_pengajuan) VALUES
(1, 1, 'PKH',  '2026-10-05', 'diajukan'),
(2, 1, 'BPNT', '2026-10-06', 'diverifikasi'),
(3, 2, 'BLT',  '2026-10-06', 'diajukan'),
(4, 3, 'PKH',  '2026-10-07', 'disetujui'),
(5, 3, 'BPNT', '2026-10-07', 'diajukan'),
(6, 3, 'BLT',  '2026-10-08', 'diverifikasi');

-- ===== TAHAP 1: EKSPLORASI JOIN (kondisi normalisasi) =====
SELECT w.id_warga, w.nik, w.nama,
       COUNT(pb.id_pengajuan) AS kalkulasi_jumlah_pengajuan
FROM warga w
LEFT JOIN pengajuan_bantuan pb ON pb.id_warga = w.id_warga
GROUP BY w.id_warga, w.nik, w.nama;

-- ===== TAHAP 2: PENERAPAN DENORMALISASI =====
ALTER TABLE warga
ADD COLUMN jumlah_pengajuan INT NOT NULL DEFAULT 0;

UPDATE warga
SET jumlah_pengajuan = (
    SELECT COUNT(*) FROM pengajuan_bantuan pb
    WHERE pb.id_warga = warga.id_warga
);

-- ===== TAHAP 3: PEMBUKTIAN (tanpa JOIN dan agregasi) =====
SELECT id_warga, nik, nama, jumlah_pengajuan
FROM warga;

-- ===== BUKTI REDUNDANSI: DATA TIDAK SINKRON =====
INSERT INTO pengajuan_bantuan (id_warga, jenis_bantuan, tanggal_pengajuan, status_pengajuan)
VALUES (1, 'BLT', '2026-10-20', 'diajukan');

-- Budi: hitung_join = 3, tersimpan = 2 (tidak sinkron)
SELECT w.id_warga, w.nama,
       COUNT(pb.id_pengajuan) AS hitung_join,
       w.jumlah_pengajuan AS tersimpan
FROM warga w
LEFT JOIN pengajuan_bantuan pb ON pb.id_warga = w.id_warga
GROUP BY w.id_warga, w.nama, w.jumlah_pengajuan;

-- Sinkronkan ulang
UPDATE warga
SET jumlah_pengajuan = (
    SELECT COUNT(*) FROM pengajuan_bantuan pb
    WHERE pb.id_warga = warga.id_warga
);

-- ===== TRIGGER: JAGA SINKRON SAAT ADA PENGAJUAN BARU (hanya INSERT) =====
CREATE TRIGGER trg_pengajuan_after_insert
AFTER INSERT ON pengajuan_bantuan
FOR EACH ROW
UPDATE warga SET jumlah_pengajuan = jumlah_pengajuan + 1
WHERE id_warga = NEW.id_warga;

-- Tes trigger
INSERT INTO pengajuan_bantuan (id_warga, jenis_bantuan, tanggal_pengajuan, status_pengajuan)
VALUES (1, 'PKH', '2026-10-21', 'diajukan');

-- Budi: hitung_join = 4, tersimpan = 4 (sinkron)
SELECT w.id_warga, w.nama,
       COUNT(pb.id_pengajuan) AS hitung_join,
       w.jumlah_pengajuan AS tersimpan
FROM warga w
LEFT JOIN pengajuan_bantuan pb ON pb.id_warga = w.id_warga
GROUP BY w.id_warga, w.nama, w.jumlah_pengajuan;
