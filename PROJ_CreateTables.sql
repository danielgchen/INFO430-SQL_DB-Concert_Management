-- CREATE DATABASE
CREATE DATABASE INFO_430_Proj_07
-- BACKUP DATABASE
BACKUP DATABASE INFO_430_Proj_07 TO DISK = 'c:\SQL\INFO_430_Proj_07.BAK'
BACKUP DATABASE INFO_430_Proj_07 TO DISK = 'C:\SQL\INFO_430_Proj_07.BAK' WITH DIFFERENTIAL
-- USE DATABASE
USE INFO_430_Proj_07
-- CREATE TABLES
-- tblCOUNTRY
CREATE TABLE tblCOUNTRY
(CountryID INTEGER IDENTITY(1,1) PRIMARY KEY,
 CountryName VARCHAR(50) NOT NULL,
 CountryDescription VARCHAR(250) NULL)
-- tblCITY
CREATE TABLE tblCITY
(CityID INTEGER IDENTITY(1,1) PRIMARY KEY,
 CountryID INTEGER FOREIGN KEY REFERENCES tblCOUNTRY (CountryID) NOT NULL,
 CityName VARCHAR(50) NOT NULL,
 CityDescription VARCHAR(250) NULL
 )
-- tblVENUE
CREATE TABLE tblVENUE
(VenueID INTEGER IDENTITY(1,1) PRIMARY KEY,
 VenueName VARCHAR(50) NOT NULL,
 VenueDescription VARCHAR(250) NULL)
-- tblVENUE_TYPE
CREATE TABLE tblVENUE_TYPE
(VenueTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 VenueTypeName VARCHAR(50) NOT NULL,
 VenueTypeDescription VARCHAR(250) NULL)
-- add tblVENUE_TYPE FK into tblVENUE
ALTER TABLE tblVENUE
ADD VenueTypeID INT NOT NULL
CONSTRAINT FK_VenueTypeID
FOREIGN KEY (VenueTypeID)
REFERENCES tblVENUE_TYPE (VenueTypeID)
-- add tblCITY FK into tblVENUE
ALTER TABLE tblVENUE
ADD CityID INT NOT NULL
CONSTRAINT FK_CityID
FOREIGN KEY (CityID)
REFERENCES tblCITY (CityID)
-- tblCONCERT_TYPE
CREATE TABLE tblCONCERT_TYPE
(ConcertTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ConcertTypeName VARCHAR(50) NOT NULL,
 ConcertTypeDescription VARCHAR(250) NULL)
-- tblCONCERT
CREATE TABLE tblCONCERT
(ConcertID INTEGER IDENTITY(1,1) PRIMARY KEY,
 VenueID INTEGER FOREIGN KEY REFERENCES tblCITY (CityID) NOT NULL,
 ConcertTypeID INTEGER FOREIGN KEY REFERENCES tblCONCERT_TYPE (ConcertTypeID) NOT NULL,
 ConcertName VARCHAR(50) NOT NULL,
 ConcertDate DATE NOT NULL,
 ConcertDescription VARCHAR(250) NULL)
-- tblTICKET
CREATE TABLE tblTICKET
(TicketID INTEGER IDENTITY(1,1) PRIMARY KEY,
 TicketName VARCHAR(50) NOT NULL,
 ConcertID INTEGER FOREIGN KEY REFERENCES tblCONCERT (ConcertID) NOT NULL,
 Price NUMERIC(10,2) NOT NULL)
-- tblTICKET_TYPE
CREATE TABLE tblTICKET_TYPE
(TicketTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 TicketTypeName VARCHAR(50) NOT NULL,
 TicketTypeDescription VARCHAR(250) NULL)
-- add FK tblTICKET_TYPE into tblTICKET
ALTER TABLE tblTICKET
ADD TicketTypeID INT NOT NULL
CONSTRAINT FK_TicketTypeID
FOREIGN KEY (TicketTypeID)
REFERENCES tblTICKET_TYPE (TicketTypeID)
-- tblCUSTOMER
CREATE TABLE tblCUSTOMER
(CustomerID INTEGER IDENTITY(1,1) PRIMARY KEY,
 CustomerFname VARCHAR(50) NOT NULL,
 CustomerLname VARCHAR(50) NOT NULL,
 CustomerDOB DATE NOT NULL)
-- add FK tblCUSTOMER into tblTICKET
ALTER TABLE tblTICKET
ADD CustomerID INT NOT NULL
CONSTRAINT FK_CustomerID
FOREIGN KEY (CustomerID)
REFERENCES tblCUSTOMER (CustomerID)
-- tblCUSTOMER_TYPE
CREATE TABLE tblCUSTOMER_TYPE
(CustomerTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 CustomerTypeName VARCHAR(50) NOT NULL,
 CustomerTypeDescription VARCHAR(250) NULL)
-- add FK tblCUSTOMER_TYPE ino tblCUSTOMER
ALTER TABLE tblCUSTOMER
ADD CustomerTypeID INT NOT NULL
CONSTRAINT FK_CustomerTypeID
FOREIGN KEY (CustomerTypeID)
REFERENCES tblCUSTOMER_TYPE (CustomerTypeID)
-- tblPRODUCT_TYPE
CREATE TABLE tblPRODUCT_TYPE
(ProductTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ProductTypeName VARCHAR(50) NOT NULL,
 ProductTypeDescription VARCHAR(250) NULL)
-- tblPRODUCT
CREATE TABLE tblPRODUCT
(ProductID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ProductTypeID INTEGER FOREIGN KEY REFERENCES tblPRODUCT_TYPE (ProductTypeID) NOT NULL,
 ProductName VARCHAR(50) NOT NULL,
 ProductCurrentPrice NUMERIC(4,2) NOT NULL,
 ProductDescription VARCHAR(250) NULL)
-- tblPRODUCT_PRICE_HISTORY
CREATE TABLE tblPRODUCT_PRICE_HISTORY
(ProductPriceHistoryID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ProductID INTEGER FOREIGN KEY REFERENCES tblPRODUCT (ProductID) NOT NULL,
 Price NUMERIC(4,2) NOT NULL,
 BeginDate DATE NOT NULL,
 EndDate DATE NOT NULL)
-- tblTICKET_PRODUCT
CREATE TABLE tblTICKET_PRODUCT
(TicketProductID INTEGER IDENTITY(1,1) PRIMARY KEY,
 TicketID INTEGER FOREIGN KEY REFERENCES tblTICKET (TicketID) NOT NULL,
 ProductID INTEGER FOREIGN KEY REFERENCES tblPRODUCT (ProductID) NOT NULL,
 Quantity INTEGER NOT NULL)
-- tblEMPLOYEE
CREATE TABLE tblEMPLOYEE
(EmployeeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 EmployeeFname VARCHAR(50) NOT NULL,
 EmployeeLname VARCHAR(50) NOT NULL,
 EmployeeDOB DATE NOT NULL)
-- tblSTATUS
CREATE TABLE tblSTATUS
(StatusID INTEGER IDENTITY(1,1) PRIMARY KEY,
 StatusName VARCHAR(50) NOT NULL,
 StatusDescription VARCHAR(250) NULL)
-- tblEMPLOYEE_STATUS
CREATE TABLE tblEMPLOYEE_STATUS
(EmployeeStatusID INTEGER IDENTITY(1,1) PRIMARY KEY,
 EmployeeID INTEGER FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) NOT NULL,
 StatusID INTEGER FOREIGN KEY REFERENCES tblSTATUS (StatusID) NOT NULL,
 BeginDate DATE NOT NULL,
 EndDate DATE NOT NULL)
-- tblCONCERT_EMPLOYEE
CREATE TABLE tblCONCERT_EMPLOYEE
(ConcertEmployeeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ConcertID INTEGER FOREIGN KEY REFERENCES tblCONCERT (ConcertID) NOT NULL,
 EmployeeID INTEGER FOREIGN KEY REFERENCES tblEMPLOYEE (EmployeeID) NOT NULL)
-- tblEMPLOYEE_TYPE
CREATE TABLE tblEMPLOYEE_TYPE
(EmployeeTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 EmployeeTypeName VARCHAR(50) NOT NULL,
 EmployeeTypeDescription VARCHAR(250) NULL)
-- tblEMPLOYEE_ROLE
CREATE TABLE tblEMPLOYEE_ROLE
(EmployeeRoleID INTEGER IDENTITY(1,1) PRIMARY KEY,
 EmployeeRoleName VARCHAR(50) NOT NULL,
 EmployeeRoleDescription VARCHAR(250) NULL)
-- add FK tblEMPLOYEE_TYPE and add FK tblEMPLOYEE_ROLE to tblCONCERT_EMPLOYEE
ALTER TABLE tblCONCERT_EMPLOYEE
ADD EmployeeTypeID INT NOT NULL
CONSTRAINT FK_EmployeeTypeID
FOREIGN KEY (EmployeeTypeID)
REFERENCES tblEMPLOYEE_TYPE (EmployeeTypeID)
ALTER TABLE tblCONCERT_EMPLOYEE
ADD EmployeeRoleID INT NOT NULL
CONSTRAINT FK_EmployeeRoleID
FOREIGN KEY (EmployeeRoleID)
REFERENCES tblEMPLOYEE_ROLE (EmployeeRoleID)
-- tblSONG_LINEUP_TYPE
CREATE TABLE tblSONG_LINEUP_TYPE
(SongLineupTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 SongLineupTypeName VARCHAR(50) NOT NULL,
 SongLineupTypeDescription VARCHAR(250) NULL)
-- tblSONG_LINEUP
CREATE TABLE tblSONG_LINEUP
(SongLineupID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ConcertID INTEGER FOREIGN KEY REFERENCES tblCONCERT (ConcertID) NOT NULL,
 SongLineupTypeID INTEGER FOREIGN KEY REFERENCES tblSONG_LINEUP_TYPE (SongLineupTypeID) NOT NULL,
 Duration NUMERIC(8,4) NOT NULL)
-- tblSONG
CREATE TABLE tblSONG
(SongID INTEGER IDENTITY(1,1) PRIMARY KEY,
 SongName VARCHAR(50) NOT NULL,
 SongDescription VARCHAR(250) NULL)
-- add FK tblSONG into tblSONG_LINEUP
ALTER TABLE tblSONG_LINEUP
ADD SongID INT NOT NULL
CONSTRAINT FK_SongID
FOREIGN KEY (SongID)
REFERENCES tblSONG (SongID)
-- tblALBUM
CREATE TABLE tblALBUM
(AlbumID INTEGER IDENTITY(1,1) PRIMARY KEY,
 AlbumName VARCHAR(50) NOT NULL,
 AlbumDescription VARCHAR(250) NULL,
 AlbumReleaseDate DATE NOT NULL)
-- tblSONG_ALBUM
CREATE TABLE tblSONG_ALBUM
(SongAlbumID INTEGER IDENTITY(1,1) PRIMARY KEY,
 SongID INTEGER FOREIGN KEY REFERENCES tblSONG (SongID) NOT NULL,
 AlbumID INTEGER FOREIGN KEY REFERENCES tblALBUM (AlbumID) NOT NULL)
-- tblALBUM_TYPE
CREATE TABLE tblALBUM_TYPE
(AlbumTypeID INTEGER IDENTITY(1,1) PRIMARY KEY,
 AlbumTypeName VARCHAR(50) NOT NULL,
 AlbumTypeDescription VARCHAR(250) NULL)
-- add FK tblALBUM_TYPE into tblALBUM
ALTER TABLE tblALBUM
ADD AlbumTypeID INT NOT NULL
CONSTRAINT FK_AlbumTypeID
FOREIGN KEY (AlbumTypeID)
REFERENCES tblALBUM_TYPE (AlbumTypeID)
-- tblGENERE
CREATE TABLE tblGENRE
(GenreID INTEGER IDENTITY(1,1) PRIMARY KEY,
 GenreName VARCHAR(50) NOT NULL,
 GenreDescription VARCHAR(250) NULL)
-- tblSONG_GENRE
CREATE TABLE tblSONG_GENRE
(SongGenreID INTEGER IDENTITY(1,1) PRIMARY KEY,
 SongID INTEGER FOREIGN KEY REFERENCES tblSONG (SongID) NOT NULL,
 GenreID INTEGER FOREIGN KEY REFERENCES tblGENRE (GenreID) NOT NULL)
-- tblARTIST
CREATE TABLE tblARTIST
(ArtistID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ArtistFname VARCHAR(50) NOT NULL,
 ArtistLname VARCHAR(50) NOT NULL,
 ArtistDOB DATE NOT NULL)
-- tblLABEL
CREATE TABLE tblLABEL
(LabelID INTEGER IDENTITY(1,1) PRIMARY KEY,
 LabelName VARCHAR(50) NOT NULL,
 LabelDescription VARCHAR(250) NULL)
-- tblARTIST_LABEL
CREATE TABLE tblARTIST_LABEL
(ArtistLabelID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ArtistID INTEGER FOREIGN KEY REFERENCES tblARTIST (ArtistID) NOT NULL,
 LabelID INTEGER FOREIGN KEY REFERENCES tblLABEL (LabelID) NOT NULL,
 BeginDate DATE NOT NULL,
 EndDate DATE NOT NULL)
-- tblPRODUCER
CREATE TABLE tblPRODUCER
(ProducerID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ProducerFname VARCHAR(50) NOT NULL,
 ProducerLname VARCHAR(50) NOT NULL,
 ProducerDOB DATE NOT NULL)
-- tblPRODUCER_ALBUM
CREATE TABLE tblPRODUCER_ALBUM
(ProducerAlbumID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ProducerID INTEGER FOREIGN KEY REFERENCES tblPRODUCER (ProducerID) NOT NULL,
 AlbumID INTEGER FOREIGN KEY REFERENCES tblALBUM (AlbumID) NOT NULL)
-- tblARTIST_SONG
CREATE TABLE tblARTIST_SONG
(ArtistSongID INTEGER IDENTITY(1,1) PRIMARY KEY,
 ArtistID INTEGER FOREIGN KEY REFERENCES tblARTIST (ArtistID) NOT NULL,
 SongID INTEGER FOREIGN KEY REFERENCES tblSONG (SongID) NOT NULL)