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

DELIMITER $$

CREATE PROCEDURE registrazione_paziente(
    IN  p_nome         VARCHAR(45),
    IN  p_cognome      VARCHAR(45),
    IN  p_residenza    VARCHAR(45),
    IN  p_nascita      DATE,
    IN  p_email        VARCHAR(45),
    IN  p_password     VARCHAR(128),
    IN  p_condizione   VARCHAR(225),
    IN  p_difficolta   VARCHAR(225),
    IN  p_obiettivi    VARCHAR(225),
    IN  p_tecnologie   VARCHAR(225),
    IN  p_ambiente     VARCHAR(225),
    IN  p_latitudine   FLOAT,
    IN  p_longitudine  FLOAT,
    OUT p_status       INT
)
BEGIN
    DECLARE v_count INT;

    -- 1) controllo esistenza email
    SELECT COUNT(*) INTO v_count
      FROM credenziali
     WHERE email = p_email;

    IF v_count > 0 THEN
        -- email già presente: fallimento
        SET p_status = 0;
    ELSE
        -- inserimento in pazienti / credenziali / personas_pazienti / posizione
        START TRANSACTION;

        INSERT INTO pazienti (nome, cognome, residenza, nascita)
        VALUES (p_nome, p_cognome, p_residenza, p_nascita);
        SET @last_id = LAST_INSERT_ID();

        INSERT INTO credenziali (id, pazienti_id, email, password)
        VALUES (@last_id, @last_id, p_email, p_password);

        INSERT INTO personas_pazienti (id, pazienti_id, condizione, difficolta, obiettivi, tecnologie, ambiente)
        VALUES (@last_id, @last_id, p_condizione, p_difficolta, p_obiettivi, p_tecnologie, p_ambiente);

        INSERT INTO posizione (id, pazienti_id, latitudine, longitudine)
        VALUES (@last_id, @last_id, p_latitudine, p_longitudine);

        COMMIT;
        SET p_status = 1;
    END IF;
END$$

DELIMITER ;



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

USE main;
SET @p_status = 0;

CALL registrazione_paziente('Mario', 'Rossi', 'Milano, Lombardia', '1985-06-15', 'mario.rossi1@example.com', 'ef92b778ba5c9c1d5ad54c0a1e8e52b17843be233d7b0d4f43f6d6f9d3a3f0f2', 'Condizione A', 'Difficoltà A', 'Obiettivo A', 'Tecnologia A', 'Ambiente A', 45.4642, 9.19, @p_status);
CALL registrazione_paziente('Luca', 'Bianchi', 'Roma, Lazio', '1990-03-22', 'luca.bianchi2@example.com', '2c1743a391305fbf367df8e4f069f9f9beba3e8b8b6f8ebf8e6cc1f30b7316db', 'Condizione B', 'Difficoltà B', 'Obiettivo B', 'Tecnologia B', 'Ambiente B', 41.9028, 12.4964, @p_status);
CALL registrazione_paziente('Giulia', 'Verdi', 'Napoli, Campania', '1992-07-08', 'giulia.verdi3@example.com', '9d5ed678fe57bcca610140957afab57122a5c623cf3dbfb8359d1a55c2b5e9f7', 'Condizione C', 'Difficoltà C', 'Obiettivo C', 'Tecnologia C', 'Ambiente C', 40.8518, 14.2681, @p_status);
CALL registrazione_paziente('Francesca', 'Russo', 'Torino, Piemonte', '1988-11-30', 'francesca.russo4@example.com', '12dea96fec20593566ab75692c9949596833adc9d6603c7d2b6b62b7e6f6b796', 'Condizione D', 'Difficoltà D', 'Obiettivo D', 'Tecnologia D', 'Ambiente D', 45.0703, 7.6869, @p_status);
CALL registrazione_paziente('Matteo', 'Ferrari', 'Palermo, Sicilia', '1987-04-17', 'matteo.ferrari5@example.com', '7c4a8d09ca3762af61e59520943dc26494f8941b', 'Condizione E', 'Difficoltà E', 'Obiettivo E', 'Tecnologia E', 'Ambiente E', 38.1157, 13.3615, @p_status);
CALL registrazione_paziente('Sara', 'Esposito', 'Genova, Liguria', '1995-09-12', 'sara.esposito6@example.com', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'Condizione F', 'Difficoltà F', 'Obiettivo F', 'Tecnologia F', 'Ambiente F', 44.4056, 8.9463, @p_status);
CALL registrazione_paziente('Andrea', 'Conti', 'Bologna, Emilia-Romagna', '1993-02-27', 'andrea.conti7@example.com', '4e07408562bedb8b60ce05c1decfe3ad16b7223096b2e1a9ef8c010b63ecdbdd', 'Condizione G', 'Difficoltà G', 'Obiettivo G', 'Tecnologia G', 'Ambiente G', 44.4949, 11.3426, @p_status);
CALL registrazione_paziente('Chiara', 'Gallo', 'Firenze, Toscana', '1989-08-05', 'chiara.gallo8@example.com', '8d969eef6ecad3c29a3a629280e686cff8fab55d0f8a798edc2cc74f0d8f70c0', 'Condizione H', 'Difficoltà H', 'Obiettivo H', 'Tecnologia H', 'Ambiente H', 43.7696, 11.2558, @p_status);
CALL registrazione_paziente('Davide', 'Fontana', 'Bari, Puglia', '1991-01-19', 'davide.fontana9@example.com', '45c48cce2e2d7fbdea1afc51c7c6ad26e1b8e6f7e5f7b5c9e1e62c61ef4b4ef7', 'Condizione I', 'Difficoltà I', 'Obiettivo I', 'Tecnologia I', 'Ambiente I', 41.1171, 16.8719, @p_status);
CALL registrazione_paziente('Laura', 'Marino', 'Venezia, Veneto', '1986-10-03', 'laura.marino10@example.com', '6c569aabbf7775ef8fc570e228c16b9815de4a35d511a1b5b3e26b2d1c8fa0c6', 'Condizione J', 'Difficoltà J', 'Obiettivo J', 'Tecnologia J', 'Ambiente J', 45.4408, 12.3155, @p_status);
-- Visits
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (1, 'odontoiatria', 'Odontoiatria 1', 1, 1, 0, 278.85, 4, 1);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (2, 'psichiatria', 'Psichiatria 2', 0, 1, 1, 247.84, 1, 20);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (3, 'pediatria', 'Pediatria 3', 1, 1, 1, 196.1, 4, 25);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (4, 'psichiatria', 'Psichiatria 4', 1, 1, 1, 87.54, 1, 12);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (5, 'cardiologia', 'Cardiologia 5', 1, 1, 1, 85.94, 3, 0);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (6, 'neurologia', 'Neurologia 6', 1, 1, 0, 190.96, 1, 14);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (7, 'cardiologia', 'Cardiologia 7', 0, 1, 1, 278.93, 1, 10);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (8, 'gastroenterologia', 'Gastroenterologia 8', 1, 1, 1, 109.87, 1, 0);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (9, 'oculistica', 'Oculistica 9', 1, 1, 0, 104.2, 5, 15);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (10, 'oculistica', 'Oculistica 10', 0, 1, 1, 277.7, 1, 25);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (11, 'cardiologia', 'Cardiologia 11', 0, 1, 1, 62.71, 4, 19);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (12, 'urologia', 'Urologia 12', 1, 1, 1, 134.06, 1, 19);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (13, 'psichiatria', 'Psichiatria 13', 1, 1, 0, 92.8, 4, 23);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (14, 'oculistica', 'Oculistica 14', 0, 1, 0, 57.99, 2, 13);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (15, 'dermatologia', 'Dermatologia 15', 1, 1, 1, 290.62, 1, 15);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (16, 'urologia', 'Urologia 16', 0, 1, 0, 78.54, 1, 15);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (17, 'ortopedia', 'Ortopedia 17', 0, 1, 0, 177.8, 2, 15);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (18, 'pediatria', 'Pediatria 18', 0, 1, 1, 136.13, 2, 17);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (19, 'oculistica', 'Oculistica 19', 0, 1, 0, 190.22, 2, 13);
INSERT INTO visite (id, tipo, nome, cronico, in_sede, in_presenza, costo, sedute_richieste, intervallo_sedute) VALUES (20, 'ortopedia', 'Ortopedia 20', 0, 1, 0, 294.18, 4, 25);

-- Disponibilita
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746814678, 1, 8, 21, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749399608, 1, 8, 5, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746384441, 1, 29, 23, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746208145, 1, 38, 23, 18);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746003065, 1, 21, 8, 18);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746129240, 1, 2, 23, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750238956, 1, 2, 13, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750583367, 1, 12, 3, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1745847111, 1, 3, 13, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746166112, 0, 16, 21, 20);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750050133, 0, 36, 19, 16);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749116957, 1, 26, 20, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750216365, 0, 30, 1, 19);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747912965, 0, 7, 27, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1745942926, 0, 49, 15, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747607170, 0, 17, 16, 15);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749969447, 1, 48, 25, 10);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750384005, 1, 26, 21, 5);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746288385, 1, 44, 20, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749959925, 1, 42, 3, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749488600, 1, 41, 23, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747580279, 1, 25, 6, 2);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746892728, 1, 32, 24, 8);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749624742, 1, 19, 17, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750101625, 1, 6, 17, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750461262, 1, 38, 1, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746122771, 0, 17, 25, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750186752, 0, 8, 15, 5);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748558838, 1, 13, 13, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749380657, 1, 22, 15, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749953984, 1, 11, 14, 10);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748432232, 1, 6, 25, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750223969, 1, 37, 7, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750103885, 1, 42, 12, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746227280, 1, 12, 8, 7);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748563814, 1, 30, 19, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749238691, 1, 37, 22, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749566036, 1, 19, 28, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750421733, 1, 3, 3, 19);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746776634, 1, 9, 7, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746078054, 1, 41, 24, 20);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1745843717, 1, 31, 16, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1745776147, 0, 34, 18, 15);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746656129, 1, 24, 28, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746347437, 1, 14, 16, 16);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747542751, 1, 31, 6, 11);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749025436, 1, 28, 17, 15);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746714957, 1, 17, 14, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748294786, 0, 43, 9, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750277132, 1, 29, 12, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746336035, 1, 1, 4, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750514872, 1, 31, 9, 8);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746787873, 1, 26, 14, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746717154, 1, 43, 10, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750505145, 1, 9, 23, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747534751, 1, 31, 10, 15);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746415817, 1, 31, 1, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748441605, 1, 45, 28, 18);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748504118, 1, 30, 22, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746320924, 1, 50, 1, 18);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748468380, 1, 2, 10, 14);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750437195, 0, 13, 19, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750427373, 1, 47, 2, 2);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750876074, 0, 14, 2, 5);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749277561, 1, 31, 22, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746972392, 1, 5, 9, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747269308, 1, 27, 5, 6);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748046494, 1, 2, 7, 7);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750343393, 0, 13, 20, 11);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750688213, 1, 47, 24, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748724607, 1, 13, 7, 10);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750237463, 1, 30, 20, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749437694, 1, 29, 9, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750516535, 1, 28, 6, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747766735, 0, 34, 6, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747880969, 1, 10, 26, 2);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748734336, 1, 6, 17, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749273283, 1, 21, 7, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747905281, 1, 41, 2, 11);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750466889, 1, 19, 27, 16);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747860700, 1, 38, 25, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748358376, 1, 13, 2, 20);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749043062, 1, 3, 27, 3);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749215600, 1, 9, 24, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750477857, 1, 34, 15, 1);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747876019, 1, 5, 19, 17);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748726029, 1, 37, 27, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748213803, 1, 46, 15, 5);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747104928, 1, 24, 3, 20);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748502350, 1, 27, 5, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748364828, 1, 23, 7, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749295679, 1, 2, 15, 11);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750013587, 1, 17, 10, 15);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1750448863, 1, 32, 9, 8);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747325634, 1, 11, 8, 12);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1746952357, 1, 33, 16, 13);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749802876, 1, 10, 22, 19);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1748038005, 1, 45, 4, 9);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1747236428, 1, 42, 19, 4);
INSERT INTO disponibilita (timestamp, disponibile, medici_id, cliniche_id, visite_id) VALUES (1749524074, 1, 25, 15, 9);

