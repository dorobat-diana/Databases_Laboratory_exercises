
-- Use the created database
USE Test1;
GO
------------------------------I----------------------------------
-- Create a table R with the specified schema
CREATE TABLE R (
    FK1 INT,
    FK2 INT,
    C1 NVARCHAR(100),
    C2 INT,
    C3 INT,
    C4 NVARCHAR(100),
    C5 NVARCHAR(2),
    CONSTRAINT PK_R PRIMARY KEY (FK1, FK2)
);
GO
ALTER TABLE R
ALTER COLUMN C2 NVARCHAR(100)
ALTER TABLE R
ALTER COLUMN C4 INT
-- Insert sample data into the table R
INSERT INTO R (FK1, FK2, C1, C2, C3, C4,C5)
VALUES
    (1, 1, 'Pisica pe acoperisul fierbinte ','Tennessee Williams', 100, 20, 'AB'),
    (1, 2, 'Conul Leonida fata cu reactiunea ','Ion Luca Caragiale', 50, 50, 'CQ'),
    (1, 3, 'Concert din muzica de Bach ','Hortensia Papadat-Bengescu', 50, 10, 'QC'),
    (2, 1, 'Fata babei si fata mosneagului ','Ion Creanga', 100, 100, 'QM'),
    (2, 2, 'Frumosii nebuni ai marilor orase ','Fanus Neagu', 10, 10, 'BA'),
    (2, 3, 'Frumoasa calatorie a ursilor panda povestita de un saxofonist care avea o iubita la Frankfurt','Matei Visniec', 100, 20, 'MQ'),
    (3, 1, 'Mansarda la Paris cu vedere spre moarte ','Matei Visniec', 200, 10, 'PQ'),
    (3, 2, 'Richard al III-lea se interzice sau Scene din viata lui Meyerhold ','Matei Visniec', 100, 50, 'PQ'),
    (3, 3, 'Masinaria Cehov. Nina sau despre fragilitatea pescarusilor impaiati ','Matei Visniec', 100, 100, 'AZ'),
    (4, 1, 'Omul de zapada care voia sa intalneasca soarele ','Matei Visniec', 100, 100, 'CP'),
    (4, 2, 'Extraterestrul care isi dorea ca amintire o pijama ','Matei Visniec', 50, 10, 'CQ'),
    (4, 3, 'O femeie draguta cu o floare si ferestre spre nord ','Edvard Radzinski', 10, 100, 'CP'),
    (4, 4, 'Trenul din zori nu mai opreste aici ','Tennessee Williams', 200, 200, 'MA');
	
-----------1--------------------------------
SELECT C2, SUM(C3) TotalC3, AVG(C3) AvgC3
FROM R
WHERE C3 >= 100 OR C1 LIKE '%Pisica%'
GROUP BY C2
HAVING SUM(C3) > 100
---------------------2-----------------------------------------------
SELECT *
FROM
 (SELECT FK1, FK2, C3+C4 TotalC3C4
 FROM R
 WHERE FK1 = FK2) r1
INNER JOIN
 (SELECT FK1, FK2, C5
 FROM R
 WHERE C5 LIKE '%Q%') r2 ON r1.FK1 = r2.FK1 AND r1.FK2 = r2.FK2
 ----------------------3----------------------------------------------
 go
 CREATE OR ALTER TRIGGER TrOnUpdate
 ON R
 FOR UPDATE
AS
 DECLARE @total INT = 0
 SELECT @total = SUM(i.C3 - d.C3)
 FROM deleted d INNER JOIN inserted i ON d.FK1 = i.FK1 AND d.FK2 = i.FK2
 WHERE d.C3 < i.C3
 PRINT @total
 go
 UPDATE R
SET C3 = 300
WHERE FK1 < FK2
-------------------------------II-------------------------------------
-------------------------------1--------------------------------------
CREATE TABLE Train_types(
	train_type_id INT,
	name varchar(200) ,
	description varchar(Max),
	CONSTRAINT PK_types PRIMARY KEY(train_type_id)
);
CREATE TABLE Trains(
	train_id INT,
	name varchar(200),
	type INT,
	CONSTRAINT FK_train_types FOREIGN KEY(type) REFERENCES Train_types(train_type_id),
	CONSTRAINT PK_train PRIMARY KEY (train_id)
);
CREATE TABLE Stations(
	station_id int,
	name varchar(100),
	CONSTRAINT UQ_name UNIQUE(name),
	CONSTRAINT PK_stations PRIMARY KEY(station_id)
);
CREATE TABLE Routes_train(
	route_train_id int,
	CONSTRAINT PK_route PRIMARY KEY(route_train_id),
	name varchar(200),
	train int,
	CONSTRAINT FK_train FOREIGN KEY(train) REFERENCES Trains(train_id),
	CONSTRAINT UQ_name_route UNIQUE(name)
);
CREATE TABLE Route_list(
	route_train_id int,
	CONSTRAINT FK_route FOREIGN KEY(route_train_id) REFERENCES Routes_train(route_train_id),
	station_id int,
	CONSTRAINT FK_station FOREIGn KEY(station_id) references Stations(station_id),
	CONSTRAINT PK_route_list PRIMARY KEY (route_train_id,station_id),
	departure_time TIME,
	arrival_time TIME
);
INSERT INTO Train_types VALUES(1,'CFR1','DESC1');
INSERT INTO Train_types VALUES(2,'CFR2','DESC2');
INSERT INTO Train_types VALUES(3,'CFR3','DESC3');

INSERT INTO Trains VALUES(1,'Name1', 1), 
(2,'Name2', 1), (3,'Name2', 3);

INSERT INTO Stations VALUES(1,'S1'), (2,'S2'),
(3,'S3');

INSERT INTO Routes_train VALUES(1,'R1', 1), 
(2,'R2', 1), (3,'R3', 3);

INSERT INTO Route_list VALUES(1,2,'9:00am', '10:00am'), 
(2,3,'10:00am', '12:00am'), (3,1,'8:00am', '11:00am'), 
(2,1,'4:00am', '9:00am'), (3,2,'6:00am', '12:00am');
-----------------------------------2--------------------------------------
go
CREATE PROCEDURE USP_Add_or_Update_RouteStation(@route VARCHAR(200),@station VARCHAR(200),@arrival_time time,@departure_time time)
AS
begin
	DECLARE @route_id int
	IF @route IN (SELECT name
					FROM Routes_train)
		SELECT @route_id=route_train_id
		FROM Routes_train
		WHERE name=@route
	else 
	begin
		RAISERROR('the route doesn t exist',10,1)
		return
	end
	DECLARE @station_id int
	IF @station IN (SELECT name
					FROM Stations)
		SELECT @station_id=station_id
		FROM Stations
		WHERE name=@station
	else
	begin
		RAISERROR('the station doesn t exist',10,1)
		return
	end
	if exists(SELECT *
				FROM Route_list
				WHERE station_id=@station_id and route_train_id=@route_id)
		begin
			UPDATE Route_list SET arrival_time=@arrival_time, departure_time=@departure_time
			WHERE station_id=@station_id and route_train_id=@route_id
		end
	else
		insert into Route_list VALUES(@route_id,@station_id,@departure_time,@arrival_time)
end
GO
exec USP_Add_or_Update_RouteStation 'R1', 'S1', '10:00am', '11:00am'
exec USP_Add_or_Update_RouteStation 'R1', 'S2', '10:21am', '11:12am'
exec USP_Add_or_Update_RouteStation 'R3', 'S3', '10:00am', '11:00am'
select * from Route_list
------------------------------3--------------------------------------------------------------------
GO
CREATE VIEW view_routes
AS
select r.name as route_train
from Route_list l inner join Stations s on s.station_id=l.station_id 
inner join Routes_train r on r.route_train_id=l.route_train_id
GROUP BY r.name
HAVING count(*)=(select count(*) from Stations)
GO
----------------------------4--------------------------------------------------
CREATE FUNCTION function_4 (@R int)
RETURNS @Stations_R table(sname varchar(200))
AS
BEGIN
	INSERT INTO @Stations_R
	SELECT s.name
	FROM Stations s inner join Route_list l on s.station_id=l.station_id
	inner join Routes_train r on r.route_train_id=l.route_train_id
	GROUP BY s.name
	HAVING COUNT(*)>@R
	RETURN
END
GO
SELECT *
FROM function_4(3)