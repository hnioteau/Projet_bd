--DROP DATABASE IF EXISTS projet;
--CREATE DATABASE projet;

DROP TABLE IF EXISTS tramway;
DROP TABLE IF EXISTS passage;
DROP TABLE IF EXISTS station_ligne;
DROP TABLE IF EXISTS station;
DROP TABLE IF EXISTS carte;
DROP TABLE IF EXISTS abonnement;
DROP TABLE IF EXISTS client;



CREATE TABLE client (
		num_client SERIAL PRIMARY KEY,
		nom VARCHAR(30) NOT NULL,
		prenom VARCHAR(30) NOT NULL,
		dateN DATE NOT NULL CHECK (dateN >= '1900-1-1' AND dateN < current_date)
);

CREATE TABLE abonnement (
		id_abonnement  SERIAL PRIMARY KEY,
		type_abo CHAR(20) NOT NULL,
		description CHAR(40)
);

CREATE TABLE carte (
		num_carte SERIAL PRIMARY KEY,
		expiration DATE NOT NULL,
		deb_abo DATE,
		fin_abo DATE,
		num_client INT NOT NULL REFERENCES Client(num_client),
		id_abonnement INT REFERENCES Abonnement(id_abonnement)
);

CREATE TABLE station(
       id_station  SERIAL PRIMARY KEY,
       nom_station VARCHAR(50) NOT NULL
);

CREATE TABLE station_ligne(
       id_station INT NOT NULL REFERENCES Station(id_station),
       num_ligne INT NOT NULL UNIQUE,
       ordre INT NOT NULL,
       CHECK (ordre>0),
       PRIMARY KEY(num_ligne,ordre)
       
);

CREATE TABLE passage(
       num_carte INT NOT NULL REFERENCES Carte(num_carte),
       id_station INT NOT NULL REFERENCES Station(id_station), 
       instant DATE NOT NULL,
       PRIMARY KEY(num_carte, id_station)
);


CREATE TABLE tramway(
		id_tram SERIAL,
		num_ligne INT NOT NULL,
		heure_de_depart TIME NOT NULL,
		FOREIGN KEY (num_ligne) REFERENCES Station_ligne(num_ligne),
		PRIMARY KEY(id_tram, heure_de_depart)
);


INSERT INTO abonnement(type_abo,description) VALUES 
			('Journee','1.4 euro pour 24h'),
			('Semaine','7 euro pour une semaine'),
       		('Mois','20 euro pour le mois');
/*
DROP VIEW IF EXISTS Horaire;

CREATE VIEW Horaire
AS SELECT station_ligne.num_ligne, station.nom_station, tramway.heure_de_depart + INTERVAL station_ligne.ordre * 2 MINUTE AS heure_passage
FROM (station_ligne NATURAL JOIN station NATURAL JOIN tramway);
*/
DROP TRIGGER IF EXISTS Station_before_insert;
DROP TRIGGER IF EXISTS Station_before_update ;
DROP TRIGGER IF EXISTS before_update_Abo;
DROP TRIGGER IF EXISTS before_insert_expiration;
DROP TRIGGER IF EXISTS before_update_expiration;
DROP TRIGGER IF EXISTS before_update_carte;

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
                SET NEW.deb_abo = current_date;
                SET NEW.fin_abo = current_date + INTERVAL 1 DAY;
	END IF;
    IF NEW.id_abonnement <=> 2 THEN
                SET NEW.deb_abo = current_date;
                SET NEW.fin_abo = current_date + INTERVAL 7 DAY;
	END IF;
    IF NEW.id_abonnement <=> 3 THEN
		SET NEW.deb_abo = current_date;
        SET NEW.fin_abo = current_date + INTERVAL 1 MONTH;
    END IF;
    
    SET NEW.expiration =  current_date + INTERVAL 3 YEAR;
    
    IF (NEW.deb_abo <> OLD.deb_abo) THEN
		IF(NEW.deb_abo >= OLD.expiration) THEN
			SET NEW.deb_abo = OLD.deb_abo;
		END IF;
	END IF;
END|

CREATE TRIGGER before_insert_expiration BEFORE INSERT
ON Carte FOR EACH ROW
BEGIN
	SET NEW.expiration =  current_date + INTERVAL 3 YEAR;
END|


DELIMITER ;
