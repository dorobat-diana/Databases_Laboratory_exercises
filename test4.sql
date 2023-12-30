CREATE DATABASE Test4
GO
USE Test4
GO
------------------------------------1------------------------------------------
CREATE TABLE Company(
	company_id INT,
	company_name VARCHAR(200),
	CONSTRAINT PK_company PRIMARY KEY (company_id)
);
CREATE TABLE Director(
	director_name VARCHAR(200),
	awards INT,
	CONSTRAINT PK_director PRIMARY KEY (director_name)
);

CREATE TABLE Movie(
	movie_name VARCHAR(200),
	release DATE,
	company_id INT,
	director_name VARCHAR(200),
	CONSTRAINT FK_company FOREIGN KEY(company_id) REFERENCES Company(company_id),
	CONSTRAINT PK_movie PRIMARY KEY(movie_name),
	CONSTRAINT FK_director FOREIGN KEY (director_name) REFERENCES Director(director_name)
);
CREATE TABLE Actor(
	actor_name VARCHAR(200),
	CONSTRAINt PK_actor PRIMARY KEY(actor_name),
	ranking INT,
	CONSTRAINT CK_rankning CHECK(ranking>=0 and ranking<=100)
);
CREATE TABLE Cinema_Production(
	title VARCHAR(200),
	movie_name VARCHAR(200),
	CONSTRAINt PK_cinema PRIMARY KEY(title),
	CONSTRAINT FK_movie FOREIGN KEY(movie_name) REFERENCES Movie(movie_name)
);
CREATE TABLE Actor_Production(
	actor_name VARCHAR(200),
	production_title VARCHAR(200),
	CONSTRAINT FK_actor FOREIGN KEY(actor_name) REFERENCES Actor(actor_name),
	CONSTRAINT FK_production FOREIGN KEY(production_title) REFERENCES Cinema_Production(title),
	CONSTRAINT PK_actor_production PRIMARY KEY(actor_name,production_title),
	entry_moment TIME
);
INSERT INTO Company (company_id, company_name)
VALUES (1, 'Company A'),
       (2, 'Company B');
INSERT INTO Director (director_name, awards)
VALUES ('Director X', 3),
       ('Director Y', 5);
INSERT INTO Movie (movie_name, release, company_id, director_name)
VALUES ('Movie 1', '2023-01-15', 1, 'Director X'),
       ('Movie 2', '2023-05-20', 2, 'Director Y');
INSERT INTO Actor (actor_name, ranking)
VALUES ('Actor A', 90),
       ('Actor B', 75),
       ('Actor C', 85);
INSERT INTO Cinema_Production (title, movie_name)
VALUES ('Production 1', 'Movie 1'),
       ('Production 2', 'Movie 2');
INSERT INTO Actor_Production (actor_name, production_title, entry_moment)
VALUES ('Actor A', 'Production 1', '00:30:00'),
       ('Actor B', 'Production 1', '00:40:00'),
       ('Actor C', 'Production 2', '01:00:00');
---------------------------------2--------------------------------------------------
GO
CREATE PROCEDURE procedure_4(@actor_name VARCHAR(200),@entry TIME,@title VARCHAR(200))
AS
BEGIN
	IF @title NOT IN (select title
						FROM Cinema_Production)
		BEGIN
			RAISERROR ('Production doesn t exist',10,1)
			RETURN
		END
	IF @actor_name NOT IN (SELECT actor_name
							FROM Actor)
		BEGIN
		 RAISERROR('ACTOR DOESN T EXIST',10,1)
		 RETURN
		END
	IF @actor_name NOT IN (SELECT a.actor_name
							FROM Actor_Production a
							WHERE a.production_title=@title)
		BEGIN
			INSERT INTO Actor_Production VALUES(@actor_name,@title,@entry)
			return
		END
	ELSE 
	BEGIN 
		RAISERROR('Actor already in the production',10,1)
		return 
	END
END
GO
SELECT* FROM Actor
SELECT* FROM Actor_Production
SELECT* FROM Cinema_Production
EXEC procedure_4 @actor_name='Actor C',@entry='00:00:00',@title='Production 1'
DROP PROCEDURE procedure_4
------------------------------------3----------------------------------------------------
GO
CREATE VIEW view_4 
AS 
SELECT a.actor_name
FROM Actor_Production ap INNER JOIN Actor a ON a.actor_name=ap.actor_name
INNER JOIN Cinema_Production p ON p.title=ap.production_title
GROUP BY a.actor_name
HAVING COUNT(*)=(SELECT COUNT(*)
				FROM Cinema_Production)
GO
SELECT * FROM view_4
SELECT * FROM Cinema_Production
SELECT * FROM Actor_Production
-----------------------------------4-------------------------------------------------------
GO
CREATE FUNCTION function_4(@p INT)
RETURNS @movies TABLE(movie_title VARCHAR(200))
AS
BEGIN 
		INSERT INTO @movies
		SELECT m.movie_name
		FROM Movie m
		WHERE m.release>'2018-01-01' AND @p<=(SELECT COUNT(*)
												FROM Cinema_Production p
												WHERE p.movie_name=m.movie_name)
RETURN
END 
GO
SELECT* FROM function_4(1)
SELECT* FROM Movie
SELECT* FROM Cinema_Production
INSERT INTO Movie VALUES('Movie 3','2017-02-25',1,'Director X')
INSERT INTO Cinema_Production VALUES ('Production 3','Movie 2'),('Production 4','Movie 3');