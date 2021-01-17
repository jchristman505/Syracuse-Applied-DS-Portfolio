/* 
	AUTHOR  :  John Christman
	Course  :  IST659 M402
	Term    :  July 2019
	Final Project - Mariner Match
*/

--Creating the location table.  This was not in the original design.  
CREATE TABLE location (
	--COLUMNS for the location table
	location_id int identity,
	address_1 varchar(30) not null,
	address_2 varchar(30),
	city varchar(30) not null,
	state_prov varchar(30) not null,
	postal_code varchar(30) not null,
	--Constraints on the location table
	CONSTRAINT PK_location PRIMARY KEY (location_id)
)
--End creating location table

--Creating the Mariner table
CREATE TABLE mariner (
	--Columns for the mariner table
	mariner_id int identity,
	first_name varchar(30) not null,
	last_name varchar(30) not null,
	location_id int not null,
	phone_number varchar(16),  --elected to make this optional
	email_address varchar(50) not null,
	--Constraints on the mariner table
	CONSTRAINT PK_mariner PRIMARY KEY (mariner_id),
	CONSTRAINT U1_mariner UNIQUE (email_address),
	CONSTRAINT FK1_mariner FOREIGN KEY (location_id) REFERENCES location(location_id)
)
--End creating Mariner table

--Creating the dock table.  Feedback suggested a dependency issue between Dock and boat.  Need to find
CREATE TABLE dock (
	--Columns for the dock table
	dock_id int identity,
	dock_name varchar(30) not null,
	location_id int not null,
	phone_number varchar(16) not null,
	--Constraints on the dock table
	CONSTRAINT PK_dock PRIMARY KEY (dock_id),
	CONSTRAINT FK1_dock FOREIGN KEY (location_id) REFERENCES location(location_id)
)
--End creating dock table

--Creating the boat table
CREATE TABLE boat (
	--Columns for the boat table
	boat_id int identity,
	boat_name varchar(30) not null,
	boat_power char(5) not null, --power is a reserve word, altered from design.  Values:  sail, motor, self
	boat_type varchar(30),  --type is a reserve word, altered from design.
	pier varchar(5) default '1',
	slip varchar(3) default '1',
	mariner_id int,
	dock_id int,
	--CONSTRAINTS on the Boat table
	CONSTRAINT PK_boat PRIMARY KEY (boat_id),
	CONSTRAINT U1_boat UNIQUE (pier, slip, dock_id),
	CONSTRAINT FK1_boat FOREIGN KEY (mariner_id) REFERENCES mariner(mariner_id),
	CONSTRAINT FK2_boat FOREIGN KEY (dock_id) REFERENCES dock(dock_id)
)
--End creating boat table	

--Creating the Skill table
CREATE TABLE skill (
	--Columns for the skill table
	skill_id int identity,
	skill_name varchar(30) not null,
	months_experience int,
	--Constraints on the table
	CONSTRAINT PK_skill PRIMARY KEY (skill_id),
	CONSTRAINT U1_skill UNIQUE (skill_name)
)
--End creating the Skill table

--Creating the job table
CREATE TABLE job (
	--Columns for the skill table
	job_id int identity,
	job_description varchar(50) not null,
	duration int,
	compensation varchar(50),
	--Constraints on the table
	CONSTRAINT PK_job PRIMARY KEY (job_id)
)
--End creating the job table

--Creating the Mariner Skill table
CREATE TABLE mariner_skill(
	--Columns for the skill table
	mariner_skill_id int identity,
	mariner_id int not null,
	skill_id int not null,
	--Constraints on the table
	CONSTRAINT PK_mariner_skill PRIMARY KEY (mariner_skill_id),
	CONSTRAINT FK1_mariner_skill FOREIGN KEY (mariner_id) REFERENCES mariner(mariner_id),
	CONSTRAINT FK2_mariner_skill FOREIGN KEY (skill_id) REFERENCES skill(skill_id)
)
--End creating the Mariner Skill table

--Creating the Job Skill table
CREATE TABLE job_skill(
	--Columns for the skill table
	job_skill_id int identity,
	job_id int not null,
	skill_id int not null,
	--Constraints on the table
	CONSTRAINT PK_job_skill PRIMARY KEY (job_skill_id),
	CONSTRAINT FK1_job_skill FOREIGN KEY (job_id) REFERENCES job(job_id),
	CONSTRAINT FK2_job_skill FOREIGN KEY (skill_id) REFERENCES skill(skill_id)
)
--End creating the Job Skill table

--Creating the Dock Job table
CREATE TABLE dock_job(
	--Columns for the skill table
	dock_job_id int identity,
	dock_id int not null,
	job_id int not null,
	--Constraints on the table
	CONSTRAINT PK_dock_job PRIMARY KEY (dock_job_id),
	CONSTRAINT FK1_dock_job FOREIGN KEY (dock_id) REFERENCES dock(dock_id),
	CONSTRAINT FK2_dock_job FOREIGN KEY (job_id) REFERENCES job(job_id)
)
--End creating the Dock Job table

--Creating the Boat Job table
CREATE TABLE boat_job(
	--Columns for the skill table
	boat_job_id int identity,
	boat_id int not null,
	job_id int not null,
	--Constraints on the table
	CONSTRAINT PK_boat_job PRIMARY KEY (boat_job_id),
	CONSTRAINT FK1_boat_job FOREIGN KEY (boat_id) REFERENCES boat(boat_id),
	CONSTRAINT FK2_boat_job FOREIGN KEY (job_id) REFERENCES job(job_id)
)
--End creating the Boat Job table

--Adding data from the boat show

--Add locations of the mariners, boats and docks
INSERT INTO location
	(address_1, city, state_prov, postal_code)
	VALUES
	('2210 Front St', 'Melbourne', 'FL', '32901'), 
	('1900 SE 15th St', 'Fort Lauderdale', 'FL', '33316'), 
	('205 S Hoover', 'Tampa', 'FL', '33609'), 
	('410 Severn Ave', 'Annapolis', 'MD', '21403'),  
	('333 Waterside Dr', 'Norfolk', 'VA', '23510'), 
	('120 E Washington St', 'Syracuse', 'NY', '13202'), 
	('26 Lee''s Wharf', 'Newport', 'RI', '02840'),
	('345 River st', 'Vero Beach', 'FL', '32933'),
	('257 San Diego rd', 'San Diego', 'CA', '40385'),
	('1 West rd', 'Key West', 'Fl', '59432'),
	('999 backwater Rd', 'Savannah', 'GA', '48632'),
	('123 Private lane', 'Ocracoke', 'NC', '34939')

--	add the mariners
INSERT INTO mariner
	(first_name, last_name, location_id, email_address)
	VALUES
	('Christoper','Columbus',  (SELECT location_id From location where city = 'Fort Lauderdale'),'ccolumbus@pinta.com'),  
	('Edward','Teach', (SELECT location_id From location where city = 'Norfolk'), 'bbeard@pillage.com'),  
	('John','Christman',  (SELECT location_id From location where city = 'Melbourne'),'oliscaptain@dreams.com'), 
	('Adm','Nimitz', (SELECT location_id From location where city = 'Norfolk'),'navyhero@usn.org'),  
	('Joe','Sailor',  (SELECT location_id From location where city = 'Norfolk'),'sevenseas@usn.org'),
	('John', 'Smith', (SELECT location_id From location where city = 'Norfolk'), 'john_smith@boats.com'), 
	('Silas', 'Mariner', (SELECT location_id From location where city = 'Newport'), 'silas_mariner@ships.com'),
	('Blackbeard', 'Pirate', (SELECT location_id From location where city = 'Norfolk'), 'queen_mary@pirates.com'),
	('Robin', 'Graham', (SELECT location_id From location where city = 'Tampa'),'Rgraham@aroundtheworld.com'), 
	('Will', 'Parker',	(SELECT location_id From location where city = 'Newport'),	'Will_parker@wind.com'),
	('William',	'Smee', (SELECT location_id From location where city = 'Syracuse'), 'piratebest@hook.com')

--add the docks
INSERT INTO dock
	(dock_name, location_id, phone_number)
	VALUES
	('Melbourne Yacht Club', (SELECT location_id From location where city = 'Melbourne'), '321-555-1234'), 
	('Dockside Marina', (SELECT location_id From location where city = 'Fort Lauderdale'), '301-555-2345'), 
	('Tampa Marina', (SELECT location_id From location where city = 'Tampa'), '311-555-3456'), 
	('Annapolis Basin', (SELECT location_id From location where city = 'Annapolis'), '474-555-4567'), 
	('Waterside Marina', (SELECT location_id From location where city = 'Norfolk'), '757-555-5678'),
	('Newport Marina', (SELECT location_id From location where city = 'Newport'), '401-555-2293'),
	('Harbor''s End', (SELECT location_id From location where city = 'Vero Beach'), '315-555-6470'),
	('Dock East', (SELECT location_id From location where city = 'Syracuse'), '567-890-1234'),
	('Dock West', (SELECT location_id From location where city = 'San Diego'),	'934-502-6984'),
	('Keys Dock', (SELECT location_id From location where city = 'Key West') ,'498-236-4912'),
	('Bubba''s', (SELECT location_id From location where city = 'Savannah')	,'759-754-0425'),
	('Private', (SELECT location_id From location where city = 'Ocracoke') ,'298-749-3247')

/*
Since the boat table has FKs inputs from both the mariner and dock tables, creating this procedure to simplify the insert statement.  This procedure was revised to include the pier and slip #
*/	

GO
CREATE PROCEDURE insert_boat(@boatname varchar(30), @boatpower char(5), @boattype varchar(30), @marinername varchar(30), @pier varchar(5), @slip varchar(3)) 
AS

BEGIN
  --Want the location id
  --First, declare variables to hold the IDs
  DECLARE @marinerID int
  DECLARE @dockID int
  DECLARE @locationID int

  SELECT @marinerID = mariner_id FROM mariner
  WHERE last_name = @marinername
  SELECT @locationID = location_id FROM mariner
  WHERE mariner_id = @marinerID
  SELECT @dockID = dock_id FROM dock
  WHERE location_id = @locationID

  --Now we can add the row using an INSERT statement
  INSERT INTO boat (boat_name, boat_power, boat_type, mariner_id, dock_id, pier, slip) 
  VALUES (@boatname, @boatpower, @boattype, @marinerID, @dockID, @pier, @slip)
END
GO

--The original insert_boat procedure calls without the pier and slip
EXEC insert_boat 'Olis', 'motor', 'trawler', 'Christman'
EXEC insert_boat 'Stars & Stripes 87', 'sail', 'sloop', 'Graham'
EXEC insert_boat 'The Dove', 'sail', 'ketch', 'Parker'
EXEC insert_boat 'Queen Mary', 'self', 'kayak', 'Pirate'
EXEC insert_boat 'The Constitution', 'sail', 'Man of War', 'Nimitz'

--added the pier and slip data
UPDATE boat SET pier = '1', slip = '1' WHERE boat_id = 2
UPDATE boat SET pier = '2', slip = '1' WHERE boat_id = 3
UPDATE boat SET pier = '3', slip = '1' WHERE boat_id = 7
UPDATE boat SET pier = '4', slip = '1' WHERE boat_id = 10

--insert jobs
INSERT INTO job (job_description, duration, compensation)
VALUES	('paint boat hull', 2, '$20 / hour'), 
		('rebuild engine',	14, '$1,000'), 
		('line handling', NULL, '$15 / hour'),
		('1st mate', 60, 'room and board'),
		('cleaning', 1, Null)	

--insert skills
INSERT INTO skill (skill_name, months_experience)
VALUES	('laborer',	0),
	('1st mate', 72),
	('engineer', 120),
	('electrician',	60),
	('Captain',	120)

--matching mariners and their skills.  Users would normally complete this task through the app/web interface
INSERT INTO mariner_skill (mariner_id, skill_id)
VALUES 
	(1,5),
	(2, 5),
	(3, 5),
	(3, 3),
	(4, 5),
	(4, 4),
	(5, 1),
	(6, 2),
	(7, 3),
	(8, 2),
	(9, 4),
	(10, 3),
	(11, 1),
	(11, 2)

--matching jobs and the required skills.  Users would normally complete this task through the app/web interface
INSERT INTO job_skill (job_id, skill_id)
VALUES 
	(1,1),
	(2, 3),
	(2, 4),
	(3, 1),
	(4, 2),
	(4, 5),
	(5, 1)

--adding jobs associated with boats. Users would normally complete this task through the app/web interface
INSERT INTO boat_job (boat_id, job_id)
VALUES 
	(2,5),
	(3, 5),
	(3, 4),
	(5, 4),
	(7, 2),
	(10, 3)
		
--adding jobs associated with docks. Users would normally complete this task through the app/web interface
INSERT INTO dock_job (dock_id, job_id)
VALUES 
	(23,3),
	(24, 5),
	(25, 3),
	(26, 2),
	(27, 1),
	(28, 2)

--Display the boats, owner names,  locations, and count of jobs by city 
SELECT
	boat.boat_name,
	CONCAT (mariner.first_name,' ',mariner.last_name) AS Mariner_Name,
	location.city,
	COUNT(job_id)  AS Number_of_jobs 
FROM location, boat
JOIN mariner ON mariner.mariner_id = boat.mariner_id
JOIN boat_job ON boat_job.boat_id = boat.boat_id
WHERE mariner.location_id = location.location_id
GROUP BY
	location.city,
	boat.boat_name,
	mariner.first_name,
	mariner.last_name
ORDER BY location.city

--mariners in location by skill by years of experience then location
SELECT
CONCAT (mariner.first_name,' ',mariner.last_name) AS Mariner_Name,
location.city,
SUM(skill.months_experience)  AS Months_of_Experience
FROM location, mariner_skill
JOIN mariner ON mariner.mariner_id = mariner_skill.mariner_id
JOIN skill ON skill.skill_id = mariner_skill.skill_id
WHERE mariner.location_id = location.location_id 
GROUP BY
	location.city,
	mariner.first_name,
	mariner.last_name
ORDER BY Months_of_Experience DESC, location.city 

GO
--Function to count the number of jobs per boat
CREATE FUNCTION dbo.boatJobCount(@boatID int)
RETURNS int AS
BEGIN  
	DECLARE @returnValue int

		/*
		Get the count of the Jobs for the provided BoatID and
		assign the value to @returnValue.  Note that we use the 
		@BoatID parameter in the WHERE clause to limit our count
		to that of the boat's jobs.
	*/
		SELECT @returnValue = COUNT(boat_job.job_id) FROM boat_job
	WHERE boat_job.boat_id = @boatID

	--Return @returnValue to the calling code.
	RETURN @returnValue
END
GO

CREATE FUNCTION dbo.dockJobCount(@dockID int)
RETURNS int AS
BEGIN  
	DECLARE @returnValue int

		/*
		Get the count of the Jobs for the provided dockID and
		assign the value to @returnValue.  Note that we use the 
		@dockID parameter in the WHERE clause to limit our count
		to that of the docks's jobs.
	*/
		SELECT @returnValue = COUNT(dock_job.job_id) FROM dock_job
	WHERE dock_job.dock_id = @dockID

	--Return @returnValue to the calling code.
	RETURN @returnValue
END
GO

--test code
--SELECT dbo.boatJobCount(10)

GO
--Create a view to retrieve all jobs in a dock
CREATE VIEW all_dock_jobs AS
	SELECT 
		dock.dock_name,
		job.job_description,
		dbo.dockJobCount (dock_job.dock_id) AS Job_Count
	FROM dock_job
	JOIN dock ON dock.dock_id = dock_job.dock_id
	JOIN job ON job.job_id = dock_job.job_id
	GROUP BY
	dock.dock_name,
	job.job_description,
	dock_job.dock_id
	--ORDER BY Job_Count DESC
GO
--Test code
--SELECT * FROM all_dock_jobs 

GO
--Create a view to retrieve all boats in a dock with the location

CREATE VIEW boat_locations AS
	SELECT
		boat.boat_name,
		dock.dock_name,
		location.city,
		location.state_prov
	FROM boat, location, dock
	WHERE boat.dock_id = dock.dock_id AND dock.location_id = location.location_id
	GROUP BY 
		boat.boat_name,
		dock.dock_name,
		location.city,
		location.state_prov
GO

--Test code
--SELECT * FROM boat_locations 

--Procedure to insert jobs with a transaction roll back check
CREATE PROCEDURE insert_job(@jobdescription varchar(50), @duration int, @compensation varchar(50))
AS 
BEGIN
--Transaction to add a job
	BEGIN TRANSACTION
		DECLARE @rwcnt int
		SET @rwcnt = @@ROWCOUNT

		--adding the job
		INSERT INTO job
			(job_description, duration, compensation)
		VALUES
			(@jobdescription,  @duration, @compensation)
	
	--insert failed
	IF(@rwcnt = @@ROWCOUNT)
	BEGIN
		SELECT 'Job Submission Failed.  Please contact Customer Support'
		ROLLBACK
	END
	ELSE  --insert success
	BEGIN
		SELECT 'Your Job has been successfully submited.  You will be notified with interested mariners'
		COMMIT
	END 
END

GO

--test code
--EXEC insert_job 'bottom cleaning', 1, '$10/ft'

--END Project


