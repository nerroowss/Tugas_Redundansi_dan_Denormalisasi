-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 01, 2026 at 06:03 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tepatsasar_denormalisasi`
--

-- --------------------------------------------------------

--
-- Table structure for table `pengajuan_bantuan`
--

CREATE TABLE `pengajuan_bantuan` (
  `id_pengajuan` int NOT NULL,
  `id_warga` int NOT NULL,
  `jenis_bantuan` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `tanggal_pengajuan` date NOT NULL,
  `status_pengajuan` varchar(30) COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'diajukan'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengajuan_bantuan`
--

INSERT INTO `pengajuan_bantuan` (`id_pengajuan`, `id_warga`, `jenis_bantuan`, `tanggal_pengajuan`, `status_pengajuan`) VALUES
(1, 1, 'PKH', '2026-10-05', 'diajukan'),
(2, 1, 'BPNT', '2026-10-06', 'diverifikasi'),
(3, 2, 'BLT', '2026-10-06', 'diajukan'),
(4, 3, 'PKH', '2026-10-07', 'disetujui'),
(5, 3, 'BPNT', '2026-10-07', 'diajukan'),
(6, 3, 'BLT', '2026-10-08', 'diverifikasi'),
(7, 1, 'BLT', '2026-10-20', 'diajukan'),
(8, 1, 'PKH', '2026-10-21', 'diajukan');

--
-- Triggers `pengajuan_bantuan`
--
DELIMITER $$
CREATE TRIGGER `trg_pengajuan_after_insert` AFTER INSERT ON `pengajuan_bantuan` FOR EACH ROW UPDATE warga SET jumlah_pengajuan = jumlah_pengajuan + 1
WHERE id_warga = NEW.id_warga
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `petugas`
--

CREATE TABLE `petugas` (
  `id_petugas` int NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `peran` enum('kader_rt','staf_kelurahan') COLLATE utf8mb4_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `petugas`
--

INSERT INTO `petugas` (`id_petugas`, `nama`, `username`, `password`, `peran`) VALUES
(1, 'Kader Contoh', 'kader1', 'hash_contoh', 'kader_rt');

-- --------------------------------------------------------

--
-- Table structure for table `warga`
--

CREATE TABLE `warga` (
  `id_warga` int NOT NULL,
  `id_petugas` int NOT NULL,
  `nik` char(16) COLLATE utf8mb4_general_ci NOT NULL,
  `nama` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `alamat` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `kategori_kerentanan` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `kondisi_ekonomi` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `tanggal_dicatat` date NOT NULL,
  `jumlah_pengajuan` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `warga`
--

INSERT INTO `warga` (`id_warga`, `id_petugas`, `nik`, `nama`, `alamat`, `kategori_kerentanan`, `kondisi_ekonomi`, `tanggal_dicatat`, `jumlah_pengajuan`) VALUES
(1, 1, '3577010101010001', 'Budi', 'RT 01 RW 01', 'lansia', 'tidak berpenghasilan tetap', '2026-10-01', 4),
(2, 1, '3577010101010002', 'Siti', 'RT 01 RW 02', 'disabilitas', 'buruh harian', '2026-10-01', 1),
(3, 1, '3577010101010003', 'Joko', 'RT 02 RW 01', 'keluarga miskin', 'pedagang kecil', '2026-10-02', 3),
(4, 1, '3577010101010004', 'Rina', 'RT 02 RW 02', 'keluarga miskin', 'tidak bekerja', '2026-10-02', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pengajuan_bantuan`
--
ALTER TABLE `pengajuan_bantuan`
  ADD PRIMARY KEY (`id_pengajuan`),
  ADD KEY `id_warga` (`id_warga`);

--
-- Indexes for table `petugas`
--
ALTER TABLE `petugas`
  ADD PRIMARY KEY (`id_petugas`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `warga`
--
ALTER TABLE `warga`
  ADD PRIMARY KEY (`id_warga`),
  ADD UNIQUE KEY `nik` (`nik`),
  ADD KEY `id_petugas` (`id_petugas`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pengajuan_bantuan`
--
ALTER TABLE `pengajuan_bantuan`
  MODIFY `id_pengajuan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `petugas`
--
ALTER TABLE `petugas`
  MODIFY `id_petugas` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `warga`
--
ALTER TABLE `warga`
  MODIFY `id_warga` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `pengajuan_bantuan`
--
ALTER TABLE `pengajuan_bantuan`
  ADD CONSTRAINT `pengajuan_bantuan_ibfk_1` FOREIGN KEY (`id_warga`) REFERENCES `warga` (`id_warga`);

--
-- Constraints for table `warga`
--
ALTER TABLE `warga`
  ADD CONSTRAINT `warga_ibfk_1` FOREIGN KEY (`id_petugas`) REFERENCES `petugas` (`id_petugas`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
