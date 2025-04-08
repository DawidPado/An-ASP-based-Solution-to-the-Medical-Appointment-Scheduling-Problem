-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema main
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema main
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `main` DEFAULT CHARACTER SET utf8 ;
USE `main` ;

-- -----------------------------------------------------
-- Table `main`.`cliniche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`cliniche` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `latitudine` FLOAT NOT NULL,
  `longitudine` FLOAT NOT NULL,
  `budget` DECIMAL(9,2) NOT NULL,
  `accesibilita` TINYINT NULL DEFAULT 1,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`pazienti`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`pazienti` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `residenza` VARCHAR(45) NOT NULL,
  `latitudine` FLOAT NOT NULL,
  `longitudine` FLOAT NOT NULL,
  `password` VARCHAR(256) NOT NULL,
  `email` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`visite`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`visite` (
  `id` INT NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `nome` VARCHAR(45) NOT NULL,
  `cronico` TINYINT NULL,
  `in_sede` TINYINT NULL DEFAULT 1,
  `in_presenza` TINYINT NULL DEFAULT 1,
  `costo` FLOAT NULL,
  `sedute_richieste` INT NULL DEFAULT 1,
  `intervallo_sedute` INT NULL DEFAULT 0 COMMENT 'quanti giorni devono passare tra due sedute dello stesso tipo',
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`medici`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`medici` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(45) NOT NULL,
  `cognome` VARCHAR(45) NOT NULL,
  `nascita` DATE NOT NULL,
  `residenza` VARCHAR(45) NOT NULL,
  `specializzazione` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`appuntamenti`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`appuntamenti` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_paziente` INT NOT NULL,
  `id_clinica` INT NOT NULL,
  `id_visita` INT NOT NULL,
  `orario` INT NOT NULL COMMENT 'unix timestamp',
  `medici_id` INT NOT NULL,
  PRIMARY KEY (`id`, `id_paziente`, `id_clinica`, `id_visita`, `medici_id`),
  INDEX `fk_appuntamenti_cliniche_idx` (`id_clinica` ASC) VISIBLE,
  INDEX `fk_appuntamenti_pazienti1_idx` (`id_paziente` ASC) INVISIBLE,
  INDEX `fk_appuntamenti_visite` (`id_visita` ASC) VISIBLE,
  INDEX `fk_appuntamenti_medici1_idx` (`medici_id` ASC) VISIBLE,
  CONSTRAINT `fk_appuntamenti_cliniche`
    FOREIGN KEY (`id_clinica`)
    REFERENCES `main`.`cliniche` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_appuntamenti_pazienti1`
    FOREIGN KEY (`id_paziente`)
    REFERENCES `main`.`pazienti` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_appuntamenti_visite1`
    FOREIGN KEY (`id_visita`)
    REFERENCES `main`.`visite` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_appuntamenti_medici1`
    FOREIGN KEY (`medici_id`)
    REFERENCES `main`.`medici` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`condizioni_ambientali`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`condizioni_ambientali` (
  `id` INT NOT NULL,
  `tipo` VARCHAR(45) NOT NULL,
  `inizio` INT NULL,
  `fine` INT NULL,
  `cliniche_id` INT NOT NULL,
  PRIMARY KEY (`id`, `cliniche_id`),
  INDEX `fk_condizioni_ambientali_cliniche1_idx` (`cliniche_id` ASC) VISIBLE,
  CONSTRAINT `fk_condizioni_ambientali_cliniche1`
    FOREIGN KEY (`cliniche_id`)
    REFERENCES `main`.`cliniche` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`disponibilita`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`disponibilita` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `timestamp` INT NOT NULL,
  `disponibile` TINYINT NOT NULL DEFAULT 1,
  `medici_id` INT NOT NULL,
  `cliniche_id` INT NOT NULL,
  `visite_id` INT NOT NULL,
  PRIMARY KEY (`id`, `medici_id`, `cliniche_id`, `visite_id`),
  INDEX `fk_disponibilita_medici1_idx` (`medici_id` ASC) VISIBLE,
  INDEX `fk_disponibilita_cliniche1_idx` (`cliniche_id` ASC) VISIBLE,
  INDEX `fk_disponibilita_visite1_idx` (`visite_id` ASC) VISIBLE,
  CONSTRAINT `fk_disponibilita_medici1`
    FOREIGN KEY (`medici_id`)
    REFERENCES `main`.`medici` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_disponibilita_cliniche1`
    FOREIGN KEY (`cliniche_id`)
    REFERENCES `main`.`cliniche` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_disponibilita_visite1`
    FOREIGN KEY (`visite_id`)
    REFERENCES `main`.`visite` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `main`.`esperienze medici`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`esperienze medici` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `speciallizazione` VARCHAR(45) NULL,
  `inizio` DATE NULL,
  `medici_id` INT NOT NULL,
  PRIMARY KEY (`id`, `medici_id`),
  INDEX `fk_esperienze medici_medici1_idx` (`medici_id` ASC) VISIBLE,
  CONSTRAINT `fk_esperienze medici_medici1`
    FOREIGN KEY (`medici_id`)
    REFERENCES `main`.`medici` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `main` ;

-- -----------------------------------------------------
-- Placeholder table for view `main`.`view_pazienti_cliniche`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `main`.`view_pazienti_cliniche` (`id` INT);

-- -----------------------------------------------------
-- View `main`.`view_pazienti_cliniche`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `main`.`view_pazienti_cliniche`;
USE `main`;
CREATE  OR REPLACE VIEW view_pazienti_cliniche AS
SELECT
    rcte.paziente_id,
    rcte.paziente_nome,
    rcte.paziente_cognome,
    rcte.clinica_id,
    rcte.clinica_nome,
    rcte.distanza_km
FROM (
    SELECT
         dcte.*,
         ROW_NUMBER() OVER (PARTITION BY dcte.paziente_id ORDER BY dcte.distanza_km ASC) AS rn
    FROM (
        SELECT
            pazienti.id AS paziente_id,
            pazienti.nome AS paziente_nome,
            pazienti.cognome AS paziente_cognome,
            cliniche.id AS clinica_id,
            cliniche.nome AS clinica_nome,
            ROUND(
                6371 * 2 * ASIN(
                    SQRT(
                        POWER(SIN((RADIANS(cliniche.latitudine) - RADIANS(pazienti.latitudine)) / 2), 2) +
                        COS(RADIANS(pazienti.latitudine)) * COS(RADIANS(cliniche.latitudine)) *
                        POWER(SIN((RADIANS(cliniche.longitudine) - RADIANS(pazienti.longitudine)) / 2), 2)
                    )
                ),
                0
            ) AS distanza_km
         FROM
             main.pazienti
         CROSS JOIN
             cliniche
    ) dcte
) rcte
WHERE rcte.rn <= 10;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;



-- Inserimento cliniche in Abruzzo
INSERT INTO cliniche (nome, latitudine, longitudine, budget, accesibilita) VALUES
('Ospedale San Salvatore', 42.3574, 13.3514, 1000000.00, 1),
('Ospedale Mazzini', 42.6612, 13.6997, 1200000.00, 1),
('Ospedale Spirito Santo', 42.4643, 14.2148, 1100000.00, 1),
('Ospedale Renzetti', 42.2235, 14.3910, 900000.00, 1),
('Ospedale San Pio da Pietrelcina', 42.1111, 14.7067, 950000.00, 1),
('Ospedale Gaetano Bernabeo', 42.3500, 14.4033, 800000.00, 1),
('Ospedale San Camillo', 42.0781, 14.3875, 850000.00, 1),
('Ospedale Umberto I', 42.0681, 13.2567, 870000.00, 1);

-- Inserimento cliniche nel Lazio
INSERT INTO cliniche (nome, latitudine, longitudine, budget, accesibilita) VALUES
('Policlinico Universitario A. Gemelli', 41.9295, 12.4258, 2000000.00, 1),
('Ospedale San Giovanni Addolorata', 41.8853, 12.4989, 1800000.00, 1),
('Ospedale Sant''Andrea', 42.0017, 12.4828, 1750000.00, 1),
('Ospedale Sandro Pertini', 41.9103, 12.5450, 1600000.00, 1),
('Ospedale San Camillo-Forlanini', 41.8642, 12.4531, 1900000.00, 1),
('Ospedale San Filippo Neri', 41.9361, 12.4469, 1700000.00, 1),
('Ospedale Cristo Re', 41.9292, 12.4247, 1550000.00, 1),
('Ospedale Santissimo Gonfalone', 42.0514, 12.6175, 1400000.00, 1),
('Ospedale Santa Maria Goretti', 41.4675, 12.9042, 1300000.00, 1),
('Ospedale San Benedetto', 41.7308, 13.3425, 1250000.00, 1),
('Ospedale Santa Scolastica', 41.4906, 13.8222, 1200000.00, 1),
('Ospedale Belcolle', 42.4361, 12.0792, 1150000.00, 1);

-- Inserimento cliniche in Umbria
INSERT INTO cliniche (nome, latitudine, longitudine, budget, accesibilita) VALUES
('Azienda Ospedaliera di Perugia', 43.1107, 12.3908, 1500000.00, 1),
('Ospedale Santa Maria', 42.5667, 12.6500, 1400000.00, 1),
('Ospedale San Matteo degli Infermi', 42.7361, 12.7389, 1300000.00, 1),
('Ospedale di Gubbio-Gualdo Tadino', 43.3175, 12.5653, 1250000.00, 1),
('Ospedale di Città di Castello', 43.4561, 12.2389, 1200000.00, 1),
('Ospedale di Orvieto', 42.7167, 12.1000, 1150000.00, 1),
('Ospedale di Foligno', 42.9519, 12.7031, 1100000.00, 1),
('Ospedale di Terni', 42.5603, 12.6489, 1050000.00, 1);

-- Inserimento pazienti Abruzzo
INSERT INTO main.pazienti (nome, cognome, residenza, latitudine, longitudine, password, email) VALUES
('Luca', 'Bianchi', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'luca.bianchi@example.com'),
('Maria', 'Rossi', 'Chieti, Abruzzo', 42.3518, 14.1658, SHA2('password123', 256), 'maria.rossi@example.com'),
('Giuseppe', 'Verdi', 'L\'Aquila, Abruzzo', 42.3518, 13.3997, SHA2('password123', 256), 'giuseppe.verdi@example.com'),
('Anna', 'Neri', 'Teramo, Abruzzo', 42.6564, 13.6939, SHA2('password123', 256), 'anna.neri@example.com'),
('Carlo', 'Gialli', 'Vasto, Abruzzo', 42.1052, 14.7123, SHA2('password123', 256), 'carlo.gialli@example.com'),
('Roberta', 'Marrone', 'Sulmona, Abruzzo', 42.0899, 13.9150, SHA2('password123', 256), 'roberta.marrone@example.com'),
('Alessandro', 'Russo', 'Avezzano, Abruzzo', 42.0860, 13.4022, SHA2('password123', 256), 'alessandro.russo@example.com'),
('Giulia', 'Ferrari', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'giulia.ferrari@example.com'),
('Paolo', 'Marini', 'L\'Aquila, Abruzzo', 42.3518, 13.3997, SHA2('password123', 256), 'paolo.marini@example.com'),
('Claudia', 'Lombardi', 'Chieti, Abruzzo', 42.3518, 14.1658, SHA2('password123', 256), 'claudia.lombardi@example.com'),
('Marco', 'Martini', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'marco.martini@example.com'),
('Federica', 'Greco', 'Teramo, Abruzzo', 42.6564, 13.6939, SHA2('password123', 256), 'federica.greco@example.com'),
('Riccardo', 'De Angelis', 'Vasto, Abruzzo', 42.1052, 14.7123, SHA2('password123', 256), 'riccardo.deangelis@example.com'),
('Francesca', 'Costa', 'Sulmona, Abruzzo', 42.0899, 13.9150, SHA2('password123', 256), 'francesca.costa@example.com'),
('Giovanni', 'Schiavone', 'Chieti, Abruzzo', 42.3518, 14.1658, SHA2('password123', 256), 'giovanni.schiavone@example.com'),
('Federico', 'Mancini', 'Avezzano, Abruzzo', 42.0860, 13.4022, SHA2('password123', 256), 'federico.mancini@example.com'),
('Leonardo', 'Basile', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'leonardo.basile@example.com'),
('Francesca', 'Coppola', 'Teramo, Abruzzo', 42.6564, 13.6939, SHA2('password123', 256), 'francesca.coppola@example.com'),
('Alessandra', 'Buzzi', 'Sulmona, Abruzzo', 42.0899, 13.9150, SHA2('password123', 256), 'alessandra.buzzi@example.com'),
('Simone', 'Valenti', 'L\'Aquila, Abruzzo', 42.3518, 13.3997, SHA2('password123', 256), 'simone.valenti@example.com'),
('Lorenzo', 'Cattaneo', 'Teramo, Abruzzo', 42.6564, 13.6939, SHA2('password123', 256), 'lorenzo.cattaneo@example.com'),
('Paola', 'Sartori', 'Chieti, Abruzzo', 42.3518, 14.1658, SHA2('password123', 256), 'paola.sartori@example.com'),
('Vincenzo', 'Massa', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'vincenzo.massa@example.com'),
('Antonio', 'Marini', 'Avezzano, Abruzzo', 42.0860, 13.4022, SHA2('password123', 256), 'antonio.marini@example.com'),
('Sara', 'Neri', 'Vasto, Abruzzo', 42.1052, 14.7123, SHA2('password123', 256), 'sara.neri@example.com'),
('Marco', 'Rossi', 'Sulmona, Abruzzo', 42.0899, 13.9150, SHA2('password123', 256), 'marco.rossi@example.com'),
('Giulia', 'Giacalone', 'Pescara, Abruzzo', 42.4680, 14.2118, SHA2('password123', 256), 'giulia.giacalone@example.com'),
('Alessandro', 'Blasi', 'Avezzano, Abruzzo', 42.0860, 13.4022, SHA2('password123', 256), 'alessandro.blasi@example.com');
