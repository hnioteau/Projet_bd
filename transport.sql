DROP TABLE IF EXISTS Ligne
DROP TABLE IF EXISTS Tramway;
DROP TABLE IF EXISTS Chauffeur;
DROP TABLE IF EXISTS chauf_tram;
DROP TABLE IF EXISTS Passage;
DROP TABLE IF EXISTS Station_ligne;
DROP TABLE IF EXISTS Station;
DROP TABLE IF EXISTS Carte;
DROP TABLE IF EXISTS Abonnement;
DROP TABLE IF EXISTS Client;



CREATE TABLE Client (
		`num_client` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
		`nom` VARCHAR(30) NOT NULL,
		`prenom` VARCHAR(30) NOT NULL,
		`dateN` DATE NOT NULL CHECK (dateN > 1900-1-1 AND dateN < NOW())
);

CREATE TABLE Abonnement (
		`id_abonnement` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
		`type_abo` CHAR(20) NOT NULL,
		`description` CHAR(40)
);

CREATE TABLE Carte (
		`num_carte` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
		`expiration` DATE NOT NULL,
		`deb_abo` DATE,
		`fin_abo` DATE,
		`num_client` INT NOT NULL,
		`id_abonnement` INT,
		FOREIGN KEY(num_client) REFERENCES Client(num_client),
		FOREIGN KEY(id_abonnement) REFERENCES Abonnement(id_abonnement)
);
CREATE TABLE Ligne(
	num_ligne INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	nom_ligne varchar(64) NOT NULL UNIQUE
);
CREATE TABLE Station(
       `id_station` INT NOT NULL AUTO_INCREMENT,
       `nom_station` VARCHAR(50) NOT NULL,
       PRIMARY KEY(id_station)
);

CREATE TABLE Station_ligne(
       `id_station` INT NOT NULL,
       `num_ligne` INT NOT NULL,
       `ordre` INT NOT NULL,
       CHECK (ordre>0),
       PRIMARY KEY(num_ligne,id_station),
       FOREIGN KEY(id_station) REFERENCES Station(id_station), 
       FOREIGN KEY(num_ligne) REFERENCES Ligne(num_ligne) 
);

CREATE TABLE Passage(
       `num_carte` INT NOT NULL,
       `id_station` INT NOT NULL, 
       `instant` DATE NOT NULL,
       PRIMARY KEY(num_carte, id_station),
       FOREIGN KEY(id_station) REFERENCES Station(id_station),
       FOREIGN KEY(num_carte) REFERENCES Carte(num_carte)
);


CREATE TABLE Chauffeur(
       `matricule` integer not null primary key auto_increment,
       `nom_chauf` varchar(64) not null
);

CREATE TABLE Tramway(
		`id_tram` INT NOT NULL,
		`num_ligne` INT NOT NULL,
		`heure_de_depart` TIME NOT NULL,
		PRIMARY KEY(id_tram, heure_de_depart),
		FOREIGN KEY(num_ligne) REFERENCES Ligne(num_ligne)
);
CREATE TABLE chauf_tram(
       matricule  int not null,
       id_tram int not null,
       _date date not null,
       Hdebut time not null,
       Hfin time not null,
       primary key(id_tram,_date,Hdebut),
       foreign key(matricule) references Chauffeur(matricule),
       foreign key(id_tram) references Tramway(id_tram)
);


INSERT INTO Abonnement(type_abo,description)
       values
		("Journee","1.4 euro pour 24h"),
       		("Semaine","7 euro pour une semaine"),
       		("Mois","20 euro pour le mois");

DROP VIEW IF EXISTS Horaire;

CREATE VIEW Horaire
AS SELECT Tramway.`id_tram`,Station_ligne.`num_ligne`, Station.`nom_station`, ADDTIME(Tramway.`heure_de_depart`,SEC_TO_TIME(Station_ligne.`ordre`*120)) AS Passages
FROM Station_ligne 
NATURAL JOIN Station
NATURAL JOIN Tramway
ORDER BY Tramway.`id_tram`,Passages;

DROP TRIGGER IF EXISTS Station_before_insert;
DROP TRIGGER IF EXISTS Station_before_update ;
DROP TRIGGER IF EXISTS before_update_Abo;
DROP TRIGGER IF EXISTS before_insert_expiration;
DROP TRIGGER IF EXISTS before_update_expiration;
DROP TRIGGER IF EXISTS before_update_carte;
DROP TRIGGER IF EXISTS after_delete_station;

DELIMITER |

CREATE TRIGGER Station_before_insert BEFORE INSERT
ON Station FOR EACH ROW
BEGIN
	SET NEW.nom_station = UPPER(NEW.nom_station);
END|

CREATE TRIGGER Station_before_update BEFORE UPDATE
ON Station FOR EACH ROW
BEGIN
	SET NEW.nom_station = UPPER(NEW.nom_station);
END|



CREATE TRIGGER before_update_Abo BEFORE UPDATE
ON Carte FOR EACH ROW
BEGIN
	IF NEW.id_abonnement <=> 1 THEN
                SET NEW.deb_abo = NOW();
                SET NEW.fin_abo = NOW() + INTERVAL 1 DAY;
	END IF;
    IF NEW.id_abonnement <=> 2 THEN
                SET NEW.deb_abo = NOW();
                SET NEW.fin_abo = NOW() + INTERVAL 7 DAY;
	END IF;
    IF NEW.id_abonnement <=> 3 THEN
		SET NEW.deb_abo = NOW();
        SET NEW.fin_abo = NOW() + INTERVAL 1 MONTH;
    END IF;
    
    SET NEW.expiration =  NOW() + INTERVAL 3 YEAR;
    
    IF (NEW.deb_abo <> OLD.deb_abo) THEN
		IF(NEW.deb_abo >= OLD.expiration) THEN
			SET NEW.deb_abo = OLD.deb_abo;
		END IF;
	END IF;
END|

CREATE TRIGGER before_insert_expiration BEFORE INSERT
ON Carte FOR EACH ROW
BEGIN
	SET NEW.expiration =  NOW() + INTERVAL 3 YEAR;
END|


CREATE TRIGGER before_after_update_st_ligne AFTER UPDATE 
ON Station_ligne FOR EACH ROW
BEGIN
	

END|


DELIMITER ;

