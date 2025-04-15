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

INSERT INTO `main`.`medici` (`nome`, `cognome`, `nascita`, `residenza`, `specializzazione`) VALUES
('Luca', 'Verdi', '1978-03-14', 'L\'Aquila, Abruzzo', 'Cardiologia'),
('Maria', 'Rossi', '1982-07-22', 'Pescara, Abruzzo', 'Neurologia'),
('Giuseppe', 'Bianchi', '1975-11-08', 'Chieti, Abruzzo', 'Ortopedia'),
('Chiara', 'Russo', '1986-01-18', 'Teramo, Abruzzo', 'Dermatologia'),
('Alessandro', 'Ferrari', '1980-05-30', 'Avezzano, Abruzzo', 'Pediatria'),
('Francesca', 'Romano', '1973-09-25', 'Lanciano, Abruzzo', 'Ginecologia'),
('Marco', 'Conti', '1985-02-12', 'Sulmona, Abruzzo', 'Psichiatria'),
('Sara', 'Galli', '1990-06-03', 'Vasto, Abruzzo', 'Oncologia'),
('Paolo', 'Fontana', '1976-12-15', 'Ortona, Abruzzo', 'Endocrinologia'),
('Elena', 'Marchetti', '1988-10-19', 'Montesilvano, Abruzzo', 'Nefrologia'),
('Andrea', 'De Luca', '1983-03-11', 'L\'Aquila, Abruzzo', 'Cardiologia'),
('Martina', 'Giordano', '1991-08-29', 'Pescara, Abruzzo', 'Neurologia'),
('Simone', 'Sartori', '1984-04-04', 'Chieti, Abruzzo', 'Ortopedia'),
('Federica', 'Colombo', '1979-09-09', 'Teramo, Abruzzo', 'Dermatologia'),
('Davide', 'Grassi', '1987-07-07', 'Avezzano, Abruzzo', 'Pediatria'),
('Laura', 'Moretti', '1972-02-22', 'Lanciano, Abruzzo', 'Ginecologia'),
('Matteo', 'Barbieri', '1981-11-30', 'Sulmona, Abruzzo', 'Psichiatria'),
('Giulia', 'Fabbri', '1989-05-15', 'Vasto, Abruzzo', 'Oncologia'),
('Emanuele', 'Costa', '1977-06-20', 'Ortona, Abruzzo', 'Endocrinologia'),
('Valentina', 'Testa', '1992-12-02', 'Montesilvano, Abruzzo', 'Nefrologia'),
('Stefano', 'De Angelis', '1980-01-10', 'L\'Aquila, Abruzzo', 'Cardiologia'),
('Ilaria', 'Parisi', '1985-08-21', 'Pescara, Abruzzo', 'Neurologia'),
('Tommaso', 'Negri', '1986-03-05', 'Chieti, Abruzzo', 'Ortopedia'),
('Beatrice', 'Pagano', '1978-09-28', 'Teramo, Abruzzo', 'Dermatologia'),
('Nicola', 'Martini', '1982-04-16', 'Avezzano, Abruzzo', 'Pediatria'),
('Camilla', 'Lombardi', '1990-11-01', 'Lanciano, Abruzzo', 'Ginecologia'),
('Fabio', 'Gentile', '1983-12-09', 'Sulmona, Abruzzo', 'Psichiatria'),
('Alessia', 'Farina', '1988-07-30', 'Vasto, Abruzzo', 'Oncologia'),
('Gabriele', 'Pellegrini', '1976-06-18', 'Ortona, Abruzzo', 'Endocrinologia'),
('Serena', 'Amato', '1991-02-26', 'Montesilvano, Abruzzo', 'Nefrologia'),
('Claudio', 'Fiore', '1984-03-03', 'L\'Aquila, Abruzzo', 'Cardiologia'),
('Cristina', 'Basile', '1979-09-14', 'Pescara, Abruzzo', 'Neurologia'),
('Daniele', 'Caputo', '1985-10-27', 'Chieti, Abruzzo', 'Ortopedia'),
('Angela', 'Silvestri', '1986-01-30', 'Teramo, Abruzzo', 'Dermatologia'),
('Roberto', 'Riva', '1977-05-08', 'Avezzano, Abruzzo', 'Pediatria'),
('Marta', 'Bellini', '1981-11-19', 'Lanciano, Abruzzo', 'Ginecologia'),
('Enrico', 'D\'Angelo', '1974-12-25', 'Sulmona, Abruzzo', 'Psichiatria'),
('Arianna', 'Piras', '1990-08-16', 'Vasto, Abruzzo', 'Oncologia'),
('Leonardo', 'Rizzo', '1983-07-01', 'Ortona, Abruzzo', 'Endocrinologia'),
('Giada', 'Monti', '1992-06-06', 'Montesilvano, Abruzzo', 'Nefrologia'),
('Riccardo', 'Serra', '1987-02-18', 'L\'Aquila, Abruzzo', 'Cardiologia'),
('Elisa', 'Longo', '1980-09-23', 'Pescara, Abruzzo', 'Neurologia'),
('Massimo', 'Coppola', '1982-10-10', 'Chieti, Abruzzo', 'Ortopedia'),
('Monica', 'Leone', '1975-04-12', 'Teramo, Abruzzo', 'Dermatologia'),
('Federico', 'Sanna', '1989-01-05', 'Avezzano, Abruzzo', 'Pediatria'),
('Silvia', 'Vitale', '1984-03-31', 'Lanciano, Abruzzo', 'Ginecologia'),
('Antonio', 'Palmieri', '1986-12-17', 'Sulmona, Abruzzo', 'Psichiatria'),
('Lucia', 'Ferraro', '1991-07-27', 'Vasto, Abruzzo', 'Oncologia'),
('Carlo', 'Mazza', '1978-10-02', 'Ortona, Abruzzo', 'Endocrinologia'),
('Noemi', 'Greco', '1993-05-20', 'Montesilvano, Abruzzo', 'Nefrologia');

INSERT INTO `main`.`esperienze medici` (`speciallizazione`, `inizio`, `medici_id`) VALUES
('Cardiologia', '2018-05-20', 1),
('Oncologia', '2023-08-13', 1),
('Neurologia', '2018-05-20', 2),
('Ortopedia', '2018-05-20', 3),
('Dermatologia', '2018-05-20', 4),
('Endocrinologia', '2019-03-28', 4),
('Pediatria', '2018-05-20', 5),
('Ginecologia', '2018-05-20', 6),
('Oncologia', '2019-04-05', 6),
('Psichiatria', '2018-05-20', 7),
('Pediatria', '2019-03-20', 7),
('Cardiologia', '2023-02-04', 7),
('Oncologia', '2018-05-20', 8),
('Ginecologia', '2023-07-12', 8),
('Nefrologia', '2020-07-01', 8),
('Endocrinologia', '2018-05-20', 9),
('Nefrologia', '2018-05-20', 10),
('Pediatria', '2023-08-16', 10),
('Cardiologia', '2018-05-20', 11),
('Dermatologia', '2019-06-18', 11),
('Ginecologia', '2019-10-13', 11),
('Neurologia', '2018-05-20', 12),
('Oncologia', '2022-12-11', 12),
('Ortopedia', '2018-05-20', 13),
('Dermatologia', '2018-05-20', 14),
('Pediatria', '2018-05-20', 15),
('Cardiologia', '2020-03-13', 15),
('Ortopedia', '2021-03-18', 15),
('Ginecologia', '2018-05-20', 16),
('Neurologia', '2021-08-05', 16),
('Dermatologia', '2019-11-25', 16),
('Psichiatria', '2018-05-20', 17),
('Cardiologia', '2024-06-27', 17),
('Oncologia', '2018-05-20', 18),
('Pediatria', '2019-03-05', 18),
('Nefrologia', '2021-03-26', 18),
('Endocrinologia', '2018-05-20', 19),
('Ginecologia', '2022-01-22', 19),
('Nefrologia', '2018-05-20', 20),
('Dermatologia', '2021-12-15', 20),
('Oncologia', '2023-06-29', 20),
('Cardiologia', '2018-05-20', 21),
('Psichiatria', '2022-07-31', 21),
('Ginecologia', '2019-02-11', 21),
('Neurologia', '2018-05-20', 22),
('Ginecologia', '2019-04-06', 22),
('Endocrinologia', '2020-11-02', 22),
('Ortopedia', '2018-05-20', 23),
('Dermatologia', '2018-05-20', 24),
('Nefrologia', '2021-07-21', 24),
('Pediatria', '2018-05-20', 25),
('Ginecologia', '2018-05-20', 26),
('Dermatologia', '2019-06-29', 26),
('Psichiatria', '2018-05-20', 27),
('Endocrinologia', '2020-04-17', 27),
('Oncologia', '2018-05-20', 28),
('Endocrinologia', '2018-05-20', 29),
('Nefrologia', '2018-05-20', 30),
('Ginecologia', '2023-01-24', 30),
('Cardiologia', '2018-05-20', 31),
('Nefrologia', '2022-02-03', 31),
('Psichiatria', '2023-09-25', 31),
('Neurologia', '2018-05-20', 32),
('Ortopedia', '2018-05-20', 33),
('Dermatologia', '2018-05-20', 34),
('Nefrologia', '2024-02-15', 34),
('Cardiologia', '2024-02-03', 34),
('Pediatria', '2018-05-20', 35),
('Neurologia', '2020-03-16', 35),
('Ginecologia', '2018-05-20', 36),
('Endocrinologia', '2020-02-20', 36),
('Psichiatria', '2018-05-20', 37),
('Endocrinologia', '2023-02-20', 37),
('Ortopedia', '2019-03-05', 37),
('Oncologia', '2018-05-20', 38),
('Endocrinologia', '2018-05-20', 39),
('Dermatologia', '2022-06-16', 39),
('Nefrologia', '2024-12-12', 39),
('Nefrologia', '2018-05-20', 40),
('Ortopedia', '2022-07-17', 40),
('Pediatria', '2024-08-11', 40),
('Cardiologia', '2018-05-20', 41),
('Neurologia', '2018-05-20', 42),
('Oncologia', '2021-07-02', 42),
('Ortopedia', '2018-05-20', 43),
('Cardiologia', '2022-05-22', 43),
('Psichiatria', '2019-01-24', 43),
('Dermatologia', '2018-05-20', 44),
('Neurologia', '2021-08-11', 44),
('Nefrologia', '2020-08-06', 44),
('Pediatria', '2018-05-20', 45),
('Cardiologia', '2024-10-05', 45),
('Oncologia', '2021-09-23', 45),
('Ginecologia', '2018-05-20', 46),
('Cardiologia', '2023-11-02', 46),
('Oncologia', '2023-01-31', 46),
('Psichiatria', '2018-05-20', 47),
('Oncologia', '2018-05-20', 48),
('Psichiatria', '2021-07-12', 48),
('Nefrologia', '2023-09-14', 48),
('Endocrinologia', '2018-05-20', 49),
('Oncologia', '2021-08-26', 49),
('Nefrologia', '2018-05-20', 50);