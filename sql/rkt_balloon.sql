
CREATE TABLE IF NOT EXISTS `rkt_ballon` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ownerID` varchar(50) DEFAULT NULL,
  `ballonID` varchar(50) DEFAULT NULL,
  `register` varchar(50) DEFAULT NULL,
  `outside` int(11) DEFAULT 0,
  `fuel` int(11) DEFAULT 100,
  `status` int(11) DEFAULT 100,
  `rentalTime` int(11) DEFAULT 0,
  `timeStamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
