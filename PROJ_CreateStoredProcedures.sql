-- use the correct database
USE INFO_430_Proj_07
-- insert into tblCITY
GO
CREATE PROCEDURE GET_CountryID
@GetCountryName VARCHAR(50),
@GetCountryID INT OUTPUT
AS
SET @GetCountryID = (SELECT CountryID FROM tblCOUNTRY WHERE CountryName = @GetCountryName)
GO
CREATE PROCEDURE INSERT_tblCITY
@CountryName VARCHAR(50),
@CityName VARCHAR(50),
@CityDescription VARCHAR(250) NULL
AS
DECLARE @COUNTRY_ID INT
-- querying for CountryID from tblCOUNTRY
EXEC GET_CountryID
@GetCountryName = @CountryName,
@GetCountryID = @COUNTRY_ID OUTPUT
IF @COUNTRY_ID IS NULL
BEGIN
    PRINT 'ERROR @COUNTRY_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblCITY (CountryID, CityName, CityDescription)
VALUES (@COUNTRY_ID, @CityName, @CityDescription)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblVENUE
GO
CREATE PROCEDURE GET_CityID
@GetCityName VARCHAR(50),
@GetCityID INT OUTPUT
AS
SET @GetCityID = (SELECT CityID FROM tblCITY WHERE CityName = @GetCityName)
GO
CREATE PROCEDURE GET_VenueTypeID
@GetVenueTypeName VARCHAR(50),
@GetVenueTypeID INT OUTPUT
AS
SET @GetVenueTypeID = (SELECT VenueTypeID FROM tblVENUE_TYPE WHERE VenueTypeName = @GetVenueTypeName)
GO
CREATE PROCEDURE INSERT_tblVENUE
@CityName VARCHAR(50),
@VenueTypeName VARCHAR(50),
@VenueName VARCHAR(50),
@VenueDescription VARCHAR(250) NULL
AS
DECLARE @CITY_ID INT, @VENUE_TYPE_ID INT
-- querying for CityID from tblCITY
EXEC GET_CityID
@GetCityName = @CityName,
@GetCityID = @CITY_ID OUTPUT
IF @CITY_ID IS NULL
BEGIN
    PRINT 'ERROR @CITY_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for VenueTypeID from tblVENUE_TYPE
EXEC GET_VenueTypeID
@GetVenueTypeName = @VenueTypeName,
@GetVenueTypeID = @VENUE_TYPE_ID OUTPUT
IF @VENUE_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @VENUE_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblVENUE (CityID, VenueTypeID, VenueName, VenueDescription)
VALUES (@CITY_ID, @VENUE_TYPE_ID, @VenueName, @VenueDescription)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblCONCERT
GO
CREATE PROCEDURE GET_ConcertTypeID
@GetConcertTypeName VARCHAR(50),
@GetConcertTypeID INT OUTPUT
AS
SET @GetConcertTypeID = (SELECT ConcertTypeID FROM tblCONCERT_TYPE WHERE ConcertTypeName = @GetConcertTypeName)
GO
CREATE PROCEDURE INSERT_tblCONCERT
@ConcertTypeName VARCHAR(50),
@VenueName VARCHAR(50),
@ConcertName VARCHAR(50),
@ConcertDate DATE,
@ConcertDescription VARCHAR(250) NULL
AS
DECLARE @CONCERT_TYPE_ID INT, @VENUE_ID INT
-- querying for ConcertTypeID from tblCONCERT_TYPE
EXEC GET_ConcertTypeID
@GetConcertTypeName = @ConcertTypeName,
@GetConcertTypeID = @CONCERT_TYPE_ID OUTPUT
IF @CONCERT_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @CONCERT_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for VenueID from tblVENUE
SET @VENUE_ID = (SELECT VenueID FROM tblVENUE WHERE VenueName = @VenueName)
IF @VENUE_ID IS NULL
BEGIN
    PRINT 'ERROR @VENUE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblCONCERT (ConcertTypeID, VenueID, ConcertName, ConcertDescription, ConcertDate)
VALUES (@CONCERT_TYPE_ID, @VENUE_ID, @ConcertName, @ConcertDescription, @ConcertDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblCUSTOMER
GO
CREATE PROCEDURE GET_CustomerTypeID
@GetCustomerTypeName VARCHAR(50),
@GetCustomerTypeID INT OUTPUT
AS
SET @GetCustomerTypeID = (SELECT CustomerTypeID FROM tblCUSTOMER_TYPE WHERE CustomerTypeName = @GetCustomerTypeName)
GO
CREATE PROCEDURE INSERT_tblCUSTOMER
@CustomerTypeName VARCHAR(50),
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB DATE
AS
DECLARE @CUSTOMER_TYPE_ID INT
-- querying for CustomerTypeID from tblCUSTOMER_TYPE
EXEC GET_CustomerTypeID
@GetCustomerTypeName = @CustomerTypeName,
@GetCustomerTypeID = @CUSTOMER_TYPE_ID OUTPUT
IF @CUSTOMER_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @CUSTOMER_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblCUSTOMER (CustomerTypeID, CustomerFname, CustomerLname, CustomerDOB)
VALUES (@CUSTOMER_TYPE_ID, @CustomerFname, @CustomerLname, @CustomerDOB)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblTICKET
GO
CREATE PROCEDURE GET_ConcertID
@GetConcertName VARCHAR(50),
@GetConcertID INT OUTPUT
AS
SET @GetConcertID = (SELECT ConcertID FROM tblCONCERT WHERE ConcertName = @GetConcertName)
GO
CREATE PROCEDURE GET_TicketTypeID
@GetTicketTypeName VARCHAR(50),
@GetTicketTypeID INT OUTPUT
AS
SET @GetTicketTypeID = (SELECT TicketTypeID FROM tblTICKET_TYPE WHERE TicketTypeName = @GetTicketTypeName)
GO
CREATE PROCEDURE GET_CustomerID
@GetCustomerFname VARCHAR(50),
@GetCustomerLname VARCHAR(50),
@GetCustomerDOB DATE,
@GetCustomerID INT OUTPUT
AS
SET @GetCustomerID = (SELECT CustomerID FROM tblCUSTOMER WHERE CustomerFname = @GetCustomerFname AND CustomerLname = @GetCustomerLname AND CustomerDOB = @GetCustomerDOB)
GO
CREATE PROCEDURE INSERT_tblTICKET
@CustomerFname VARCHAR(50),
@CustomerLname VARCHAR(50),
@CustomerDOB DATE,
@TicketTypeName VARCHAR(50),
@ConcertName VARCHAR(50),
@TicketName VARCHAR(50),
@Price NUMERIC(10,2)
AS
-- correct for business rule 1. no customers younger than 20 may buy a ticket of type VIP for stadium concerts
-- we don't know how often ticket type will be VIP so that is last, few if any customers < 20, so we check customer, concert then vip
IF DATEADD(YEAR, -20, GETDATE()) < @CustomerDOB
BEGIN
    PRINT 'WARNING: customer younger than 20...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblCONCERT C JOIN tblVENUE V ON V.VenueID = C.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE C.ConcertName = @ConcertName AND VT.VenueTypeName = 'Stadium')
    BEGIN
        PRINT '...venue also of type stadium...checking other exclusion criteria...'
        IF @TicketTypeName = 'VIP'
        BEGIN
            PRINT '...ticket also of type ' + @TicketTypeName + '...ERROR';
            THROW 50002, 'BREAKS BUSINESS RULE', 1;
        END
    END
END
-- correct for 2. the same customer cannot purchase more than 10 special tickets for an international concert unless they are a stakeholder
-- we dont know how often will buy a special ticket we know, 1/3 of customers are stakeholders, 1/8 of concerts are international
IF EXISTS (SELECT * FROM tblCONCERT C JOIN tblCONCERT_TYPE CT ON CT.ConcertTypeID = C.ConcertTypeID WHERE C.ConcertName = @ConcertName AND CT.ConcertTypeName = 'International')
BEGIN
    PRINT 'WARNING: concert is of type international..checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblCUSTOMER C JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE C.CustomerFname = @CustomerFname AND C.CustomerLname = @CustomerLname AND C.CustomerDOB = @CustomerDOB AND CT.CustomerTypeName <> 'Stakeholder')
    BEGIN
        PRINT '...customer also not a stakeholder...checking other exclusion criteria...'
        IF @TicketTypeName = 'Special'
        BEGIN
            PRINT '...ticket also of type ' + @TicketTypeName + '...checking to see if customer bought ten other special tickets...'
            IF EXISTS (SELECT * FROM tblCUSTOMER C JOIN tblTICKET T ON T.CustomerID = C.CustomerID JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID WHERE TT.TicketTypeName = 'Special' GROUP BY C.CustomerID HAVING COUNT(*) >= 10)
            BEGIN
                PRINT '...this will push customer past the ten special ticket limit for non-stakeholders...ERROR';
                THROW 50002, 'BREAKS BUSINESS RULE', 1;
            END
        END
    END
END
-- begin actual procedure post business rule processing
DECLARE @CUSTOMER_ID INT, @TICKET_TYPE_ID INT, @CONCERT_ID INT
-- querying for CustomerID from tblCUSTOMER
EXEC GET_CustomerID
@GetCustomerFname = @CustomerFname,
@GetCustomerLname = @CustomerLname,
@GetCustomerDOB = @CustomerDOB,
@GetCustomerID = @CUSTOMER_ID OUTPUT
IF @CUSTOMER_ID IS NULL
BEGIN
    PRINT 'ERROR @CUSTOMER_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for TicketTypeID from tblTICKET_TYPE
EXEC GET_TicketTypeID
@GetTicketTypeName = @TicketTypeName,
@GetTicketTypeID = @TICKET_TYPE_ID OUTPUT
IF @TICKET_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @TICKET_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for ConcertID from tblCONCERT
EXEC GET_ConcertID
@GetConcertName = @ConcertName,
@GetConcertID = @CONCERT_ID OUTPUT
IF @CONCERT_ID IS NULL
BEGIN
    PRINT 'ERROR @CONCERT_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblTICKET (CustomerID, TicketTypeID, ConcertID, TicketName, Price)
VALUES (@CUSTOMER_ID, @TICKET_TYPE_ID, @CONCERT_ID, @TicketName, @Price)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblPRODUCT_PRICE_HISTORY
GO
CREATE PROCEDURE GET_ProductID
@GetProductName VARCHAR(50),
@GetProductID INT OUTPUT
AS
SET @GetProductID = (SELECT ProductID FROM tblPRODUCT WHERE ProductName = @GetProductName)
GO
CREATE PROCEDURE INSERT_tblPRODUCT_PRICE_HISTORY
@ProductName VARCHAR(50),
@Price NUMERIC(4,2),
@BeginDate DATE,
@EndDate DATE
AS
DECLARE @PRODUCT_ID INT
-- querying for ProductID from tblPRODUCT
EXEC GET_ProductID
@GetProductName = @ProductName,
@GetProductID = @PRODUCT_ID OUTPUT
IF @PRODUCT_ID IS NULL
BEGIN
    PRINT 'ERROR @PRODUCT_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblPRODUCT_PRICE_HISTORY (ProductID, Price, BeginDate, EndDate)
VALUES (@PRODUCT_ID, @Price, @BeginDate, @EndDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblTICKET_PRODUCT
GO
CREATE PROCEDURE GET_TicketID
@GetTicketName VARCHAR(50),
@GetTicketID INT OUTPUT
AS
SET @GetTicketID = (SELECT TicketID FROM tblTICKET WHERE TicketName = @GetTicketName)
GO
CREATE PROCEDURE INSERT_tblTICKET_PRODUCT
@TicketName VARCHAR(50),
@ProductName VARCHAR(50),
@Quantity INT
AS
-- check business rules
-- correcting for 8. family, neighborhood and community concerts in anywhere but hotels and stadiums cannot sell alcohol to anyone regardless of age unless they are a vip or stakeholder
-- 3797 / 50k tickets are family, neigborhood, community, 5904 are in hotels or stadiums, we canot predict ticket product (alcohol), 16702 are not vip or stakeholders
IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE T.TicketName = @TicketName AND CCT.ConcertTypeName IN ('Family','Neighborhood','Community'))
BEGIN
    PRINT 'WARNING: concert is of type family neighborhood or community...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblVENUE V ON V.VenueID = CC.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE T.TicketName = @TicketName AND VT.VenueTypeName NOT IN ('Hotel', 'Stadium'))
    BEGIN
        PRINT '...venue also not of type hotel or stadium...checking other exclusion criteria...'
        IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder') AND T.TicketName = @TicketName)
        BEGIN
            PRINT '...customer also not of type VIP or stakeholder...checking other exclusion criteria...'
            IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE P.ProductName = @ProductName AND PT.ProductTypeName = 'Alcohol')
            BEGIN
                PRINT '...also buying alcohol...ERROR';
                THROW 50002, 'BREAKS BUSINESS RULE', 1;
            END
        END
    END
END
-- correcting for 7. customers aside from VIP and stakeholders are not allowed to spend more than 100 dollars in total for food, drink, or alcohol unless it is a national or international stadium concert
-- we cannot predict how much they will buy of something, 2074 are stadium, 2463 are national and international,16702 are not vip or stakeholders
IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblVENUE V ON V.VenueID = CC.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE VT.VenueTypeName = 'Stadium' AND T.TicketName = @TicketName)
BEGIN
    PRINT 'WARNING: venue is of type stadium...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE CCT.ConcertTypeName IN ('National','International') AND T.TicketName = @TicketName)
    BEGIN
        PRINT '...and concert of type national or international...checking other exclusion criteria...'
        IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder') AND T.TicketName = @TicketName)
        BEGIN
            PRINT '...and customer not of type VIP or stakeholder...checking other exclusion criteria...'
            IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE P.ProductName = @ProductName AND PT.ProductTypeName IN ('Food', 'Drink', 'Alcohol'))
            BEGIN
                PRINT '...and buying a food drink or alcohol item...checking other exclusion criteria...'
                DECLARE @TotalPrice NUMERIC(5,2) = (SELECT SUM(P.ProductCurrentPrice * TP.Quantity) FROM tblTICKET T JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID JOIN tblPRODUCT P ON P.ProductID = TP.ProductID JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE PT.ProductTypeName IN ('Food', 'Drink', 'Alcohol') AND T.TicketName = @TicketName)
                DECLARE @ProductPrice NUMERIC(4,2) = (SELECT ProductCurrentPrice FROM tblPRODUCT WHERE ProductName = @ProductName)
                SET @TotalPrice = @TotalPrice + (@Quantity * @ProductPrice)
                IF @TotalPrice > 100
                BEGIN
                    PRINT '...and buying this amount of this product will exceed the $100 limit...ERROR';
                    THROW 50002, 'BREAKS BUSINESS RULE', 1;
                END
            END
        END
    END
END
-- correcting for 6. customers under 21 are not allowed to have any alcohol associated with their ticket unless they've spent more than 100 dollars on food
-- no customers < 21, we don't know the other values for more than 100 dollars we do know, 260/2000 products are alcoholic
IF DATEADD(YEAR, -21, GETDATE()) < (SELECT C.CustomerDOB FROM tblCUSTOMER C JOIN tblTICKET T ON T.CustomerID = C.CustomerID WHERE T.TicketName = @TicketName)
BEGIN
    PRINT 'WARNING: customer younger than 21...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE PT.ProductTypeName = 'Alcohol')
    BEGIN
        PRINT '...and the customer is trying to buy alcohol...checking other exclusion criteria...'
        IF EXISTS (SELECT * FROM tblTICKET T JOIN tblTICKET_PRODUCT TP ON TP.ticketID = T.TicketID JOIN tblPRODUCT P ON P.ProductID = TP.ProductID JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeName = 'Food' GROUP BY T.TicketID HAVING SUM(P.ProductCurrentPrice * TP.Quantity) <= 100)
        BEGIN
            PRINT '...and they have not spent more than 100 dollars on food...ERROR';
            THROW 50002, 'BREAKS BUSINESS RULES', 1;
        END
    END
END
-- begin processing
DECLARE @TICKET_ID INT, @PRODUCT_ID INT
-- querying for TicketID from tblTICKET
EXEC GET_TicketID
@GetTicketName = @TicketName,
@GetTicketID = @TICKET_ID OUTPUT
IF @TICKET_ID IS NULL
BEGIN
    PRINT 'ERROR @TICKET_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for ProductID from tblPRODUCT
EXEC GET_ProductID
@GetProductName = @ProductName,
@GetProductID = @PRODUCT_ID OUTPUT
IF @PRODUCT_ID IS NULL
BEGIN
    PRINT 'ERROR @PRODUCT_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblTICKET_PRODUCT (TicketID, ProductID, Quantity)
VALUES (@TICKET_ID, @PRODUCT_ID, @Quantity)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblPRODUCT
GO
CREATE PROCEDURE GET_ProductTypeID
@GetProductTypeName VARCHAR(50),
@GetProductTypeID INT OUTPUT
AS
SET @GetProductTypeID = (SELECT ProductTypeID FROM tblPRODUCT_TYPE WHERE ProductTypeName = @GetProductTypeName)
GO
CREATE PROCEDURE INSERT_tblPRODUCT
@ProductTypeName VARCHAR(50),
@ProductName VARCHAR(50),
@ProductCurrentPrice NUMERIC(4,2),
@ProductDescription VARCHAR(250) NULL
AS
DECLARE @PRODUCT_TYPE_ID INT
-- querying for ProductTypeID from tblPRODUCT_TYPE
EXEC GET_ProductTypeID
@GetProductTypeName = @ProductTypeName,
@GetProductTypeID = @PRODUCT_TYPE_ID OUTPUT
IF @PRODUCT_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @PRODUCT_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblPRODUCT (ProductTypeID, ProductName, ProductCurrentPrice, ProductDescription)
VALUES (@PRODUCT_TYPE_ID, @ProductName, @ProductCurrentPrice, @ProductDescription)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblARTIST_SONG
GO
CREATE PROCEDURE GET_ArtistID
@GetArtistFname VARCHAR(50),
@GetArtistLname VARCHAR(50),
@GetArtistDOB DATE,
@GetArtistID INT OUTPUT
AS
SET @GetArtistID = (SELECT ArtistID FROM tblARTIST WHERE ArtistFname = @GetArtistFname AND ArtistLname = @GetArtistLname AND ArtistDOB = @GetArtistDOB)
GO
CREATE PROCEDURE GET_SongID
@GetSongName VARCHAR(50),
@GetSongID INT OUTPUT
AS
SET @GetSongID = (SELECT SongID FROM tblSONG WHERE SongName = @GetSongName)
GO
CREATE PROCEDURE INSERT_tblARTIST_SONG
@ArtistFname VARCHAR(50),
@ArtistLname VARCHAR(50),
@ArtistDOB DATE,
@SongName VARCHAR(50)
AS
DECLARE @ARTIST_ID INT, @SONG_ID INT
-- querying for ArtistID from tblARTIST
EXEC GET_ArtistID
@GetArtistFname = @ArtistFname,
@GetArtistLname = @ArtistLname,
@GetArtistDOB = @ArtistDOB,
@GetArtistID = @ARTIST_ID OUTPUT
IF @ARTIST_ID IS NULL
BEGIN
    PRINT 'ERROR @ARTIST_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for SongID from tblSONG
EXEC GET_SongID
@GetSongName = @SongName,
@GetSongID = @SONG_ID OUTPUT
IF @SONG_ID IS NULL
BEGIN
    PRINT 'ERROR @SONG_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblARTIST_SONG (ArtistID, SongID)
VALUES (@ARTIST_ID, @SONG_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblSONG_ALBUM
GO
CREATE PROCEDURE GET_AlbumID
@GetAlbumName VARCHAR(50),
@GetAlbumID INT OUTPUT
AS
SET @GetAlbumID = (SELECT AlbumID FROM tblALBUM WHERE AlbumName = @GetAlbumName)
GO
CREATE PROCEDURE INSERT_tblSONG_ALBUM
@SongName VARCHAR(50),
@AlbumName VARCHAR(50)
AS
DECLARE @SONG_ID INT, @ALBUM_ID INT
-- querying for SongID from tblSONG
EXEC GET_SongID
@GetSongName = @SongName,
@GetSongID = @SONG_ID OUTPUT
IF @SONG_ID IS NULL
BEGIN
    PRINT 'ERROR @SONG_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for AlbumID from tblALBUM
EXEC GET_AlbumID
@GetAlbumName = @AlbumName,
@GetAlbumID = @ALBUM_ID OUTPUT
IF @ALBUM_ID IS NULL
BEGIN
    PRINT 'ERROR @ALBUM_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblSONG_ALBUM (SongID, AlbumID)
VALUES (@SONG_ID, @ALBUM_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblALBUM
GO
CREATE PROCEDURE GET_AlbumTypeID
@GetAlbumTypeName VARCHAR(50),
@GetAlbumTypeID INT OUTPUT
AS
SET @GetAlbumTypeID = (SELECT AlbumTypeID FROM tblALBUM_TYPE WHERE AlbumTypeName = @GetAlbumTypeName)
GO
CREATE PROCEDURE INSERT_tblALBUM
@AlbumTypeName VARCHAR(50),
@AlbumName VARCHAR(50),
@AlbumDescription VARCHAR(250) NULL,
@AlbumReleaseDate DATE
AS
DECLARE @ALBUM_TYPE_ID INT
-- querying for AlbumTypeID from tblALBUM_TYPE
EXEC GET_AlbumTypeID
@GetAlbumTypeName = @AlbumTypeName,
@GetAlbumTypeID = @ALBUM_TYPE_ID OUTPUT
IF @ALBUM_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @ALBUM_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblALBUM (AlbumTypeID, AlbumName, AlbumDescription, AlbumReleaseDate)
VALUES (@ALBUM_TYPE_ID, @AlbumName, @AlbumDescription, @AlbumReleaseDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblPRODUCER_ALBUM
GO
CREATE PROCEDURE GET_ProducerID
@GetProducerFname VARCHAR(50),
@GetProducerLname VARCHAR(50),
@GetProducerDOB DATE,
@GetProducerID INT OUTPUT
AS
SET @GetProducerID = (SELECT ProducerID FROM tblPRODUCER WHERE ProducerFname = @GetProducerFname AND ProducerLname = @GetProducerLname AND ProducerDOB = @GetProducerDOB)
GO
CREATE PROCEDURE INSERT_tblPRODUCER_ALBUM
@ProducerFname VARCHAR(50),
@ProducerLname VARCHAR(50),
@ProducerDOB DATE,
@AlbumName VARCHAR(50)
AS
DECLARE @PRODUCER_ID INT, @ALBUM_ID INT
-- querying for ProducerID from tblPRODUCER
EXEC GET_ProducerID
@GetProducerFname = @ProducerFname,
@GetProducerLname = @ProducerLname,
@GetProducerDOB = @ProducerDOB,
@GetProducerID = @PRODUCER_ID OUTPUT
IF @PRODUCER_ID IS NULL
BEGIN
    PRINT 'ERROR @PRODUCER_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for AlbumID from tblALBUM
SET @ALBUM_ID = (SELECT AlbumID FROM tblALBUM WHERE AlbumName = @AlbumName)
IF @ALBUM_ID IS NULL
BEGIN
    PRINT 'ERROR @ALBUM_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblPRODUCER_ALBUM (ProducerID, AlbumID)
VALUES (@PRODUCER_ID, @ALBUM_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblARTIST_LABEL
GO
CREATE PROCEDURE GET_LabelID
@GetLabelName VARCHAR(50),
@GetLabelID INT OUTPUT
AS
SET @GetLabelID = (SELECT LabelID FROM tblLABEL WHERE LabelName = @GetLabelName)
GO
CREATE PROCEDURE INSERT_tblARTIST_LABEL
@ArtistFname VARCHAR(50),
@ArtistLname VARCHAR(50),
@ArtistDOB DATE,
@LabelName VARCHAR(50),
@BeginDate DATE,
@EndDate DATE
AS
DECLARE @ARTIST_ID INT, @LABEL_ID INT
-- querying for ArtistID from tblARTIST
EXEC GET_ArtistID
@GetArtistFname = @ArtistFname,
@GetArtistLname = @ArtistLname,
@GetArtistDOB = @ArtistDOB,
@GetArtistID = @ARTIST_ID OUTPUT
IF @ARTIST_ID IS NULL
BEGIN
    PRINT 'ERROR @ARTIST_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for LabelID from tblLABEL
EXEC GET_LabelID
@GetLabelName = @LabelName,
@GetLabelID = @LABEL_ID OUTPUT
IF @LABEL_ID IS NULL
BEGIN
    PRINT 'ERROR @LABEL_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblARTIST_LABEL (ArtistID, LabelID, BeginDate, EndDate)
VALUES (@ARTIST_ID, @LABEL_ID, @BeginDate, @EndDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblSONG_LINEUP
GO
CREATE PROCEDURE GET_SongLineupTypeID
@GetSongLineupTypeName VARCHAR(50),
@GetSongLineupTypeID INT OUTPUT
AS
SET @GetSongLineupTypeID = (SELECT SongLineupTypeID FROM tblSONG_LINEUP_TYPE WHERE SongLineupTypeName = @GetSongLineupTypeName)
GO
CREATE PROCEDURE INSERT_tblSONG_LINEUP
@ConcertName VARCHAR(50),
@SongName VARCHAR(50),
@SongLineupTypeName VARCHAR(50),
@Duration NUMERIC(8,4)
AS
DECLARE @CONCERT_ID INT, @SONG_ID INT, @SONG_LINEUP_TYPE_ID INT
-- querying for ConcertID from tblCONCERT
EXEC GET_ConcertID
@GetConcertName = @ConcertName,
@GetConcertID = @CONCERT_ID OUTPUT
IF @CONCERT_ID IS NULL
BEGIN
    PRINT 'ERROR @CONCERT_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for SongID from tblSONG
EXEC GET_SongID
@GetSongName = @SongName,
@GetSongID = @SONG_ID OUTPUT
IF @SONG_ID IS NULL
BEGIN
    PRINT 'ERROR @SONG_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for SongID from tblSONG
EXEC GET_SongLineupTypeID
@GetSongLineupTypeName = @SongLineupTypeName,
@GetSongLineupTypeID = @SONG_LINEUP_TYPE_ID OUTPUT
IF @SONG_LINEUP_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @SONG_LINEUP_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblSONG_LINEUP (ConcertID, SongID, SongLineupTypeID, Duration)
VALUES (@CONCERT_ID, @SONG_ID, @SONG_LINEUP_TYPE_ID, @Duration)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblSONG_GENRE
GO
CREATE PROCEDURE GET_GenreID
@GetGenreName VARCHAR(50),
@GetGenreID INT OUTPUT
AS
SET @GetGenreID = (SELECT GenreID FROM tblGENRE WHERE GenreName = @GetGenreName)
GO
CREATE PROCEDURE INSERT_tblSONG_GENRE
@SongName VARCHAR(50),
@GenreName VARCHAR(50)
AS
DECLARE @SONG_ID INT, @GENRE_ID INT
-- querying for SongID from tblSONG
EXEC GET_SongID
@GetSongName = @SongName,
@GetSongID = @SONG_ID OUTPUT
IF @SONG_ID IS NULL
BEGIN
    PRINT 'ERROR @SONG_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for GenreID from tblGENRE
EXEC GET_GenreID
@GetGenreName = @GenreName,
@GetGenreID = @GENRE_ID OUTPUT
IF @GENRE_ID IS NULL
BEGIN
    PRINT 'ERROR @GENRE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblSONG_GENRE (SongID, GenreID)
VALUES (@SONG_ID, @GENRE_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblCONCERT_EMPLOYEE
GO
CREATE PROCEDURE GET_EmployeeID
@GetEmployeeFname VARCHAR(50),
@GetEmployeeLname VARCHAR(50),
@GetEmployeeDOB DATE,
@GetEmployeeID INT OUTPUT
AS
SET @GetEmployeeID = (SELECT EmployeeID FROM tblEMPLOYEE WHERE EmployeeFname = @GetEmployeeFname AND EmployeeLname = @GetEmployeeLname AND EmployeeDOB = @GetEmployeeDOB)
GO
CREATE PROCEDURE GET_EmployeeTypeID
@GetEmployeeTypeName VARCHAR(50),
@GetEmployeeTypeID INT OUTPUT
AS
SET @GetEmployeeTypeID = (SELECT EmployeeTypeID FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeName = @GetEmployeeTypeName)
GO
CREATE PROCEDURE GET_EmployeeRoleID
@GetEmployeeRoleName VARCHAR(50),
@GetEmployeeRoleID INT OUTPUT
AS
SET @GetEmployeeRoleID = (SELECT EmployeeRoleID FROM tblEMPLOYEE_ROLE WHERE EmployeeRoleName = @GetEmployeeRoleName)
GO
CREATE PROCEDURE INSERT_tblCONCERT_EMPLOYEE
@EmployeeFname VARCHAR(50),
@EmployeeLname VARCHAR(50),
@EmployeeDOB DATE,
@EmployeeTypeName VARCHAR(50),
@EmployeeRoleName VARCHAR(50),
@ConcertName VARCHAR(50)
AS
-- testing business rules
-- correcting for 3. a fired employee cannot be assigned to a concert with a stakeholder unless they have worked as a cashier or server in the past 2 years while having a status standard that began at least 5 years ago with an enddate >= today
-- employee fired, stakeholder concert, unless all: cashier or server past 2 years, with status standard from at least 5 years
IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Fired' AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)  -- check if they were fired if they were fired before
BEGIN
    PRINT 'WARNING: employee has been fired before...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblCONCERT CC JOIN tblTICKET T ON T.ConcertID = CC.ConcertID JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName = 'Stakeholder' AND CC.ConcertName = @ConcertName)
    BEGIN
        PRINT '...and this is a stakeholder containing concert...checking other exclusion criteria...'
        IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Standard' AND DATEADD(YEAR, -5, GETDATE()) <= ES.BeginDate AND ES.EndDate >= GETDATE() AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)
        BEGIN
            PRINT '...but they have held a status of standard from at least five years ago with an end date today or after today...checking other exclusion criteria...'
            IF EXISTS (SELECT E.EmployeeID FROM tblCONCERT CC JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID AND CC.ConcertDate >= DATEADD(YEAR, -2, GETDATE()) AND ET.EmployeeTypeName IN ('Cashier', 'Server') AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)
                PRINT '...and they were a cashier or server in the past two years...OK'
            ELSE
            BEGIN
                PRINT '...but they were not a cashier or server in the past two years...ERROR';
                THROW 50002, 'BREAKS BUSINESS RULES', 1;
            END
        END
        ELSE
        BEGIN
            PRINT '...they have not held a status of standard from at least five years ago and/or with an end date today or later...ERROR';
            THROW 50002, 'BREAKS BUSINESS RULES', 1;
        END
    END
END
-- correcting for 4. an employee who has ever been suspended can only work family, neighborhood, community, city concerts and only with a type as a cook
-- check if ever suspended, check if working a concert not family, neighborhood, or community or city, check if not working as type of cook
IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Suspended' AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)  -- check if they were fired if they were fired before
BEGIN
    PRINT 'WARNING: employee has been suspended before...checking other exclusion criteria...'
    IF EXISTS (SELECT * FROM tblCONCERT CC JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE CC.ConcertName = @ConcertName AND CCT.ConcertTypeName NOT IN ('Family', 'Neighborhood', 'Community', 'City'))
    BEGIN
        PRINT '...and working a concert not of type family, neighborhood, community, or city...ERROR';
        THROW 50002, 'BREAKS BUSINESS RULES', 1;
    END
    ELSE
    BEGIN
        PRINT '...but working a concert of type family, neighborhood, community, city...checking other exclusion criteria...'
        IF @EmployeeTypeName = 'Cook'
            PRINT '...and working as a cook...OK'
        ELSE
        BEGIN
            PRINT '...but not working as a cook...ERROR';
            THROW 50002, 'BREAKS BUSINESS RULES', 1;
        END
    END
END
-- correcting for 5. employees can only take on the role of manager and have a type of artist aide or security guard if they have been a technician in the past three years and have never been fired or suspended in the last 5 years considering begin date
IF @EmployeeTypeName IN ('Artist Aide', 'Security')
BEGIN
    PRINT 'WARNING: trying to be an artist aide or security guard...checking other exclusion criteria...'
    IF @EmployeeRoleName = 'Manager'
    BEGIN
        PRINT '...and trying to be a manager...checking other exclusion criteria...'
        IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblCONCERT_EMPLOYEE CE ON CE.EmployeeID = E.EmployeeID JOIN tblCONCERT C ON C.ConcertID = CE.ConcertID JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID WHERE ET.EmployeeTypeName = 'Technician' AND C.ConcertDate >= DATEADD(YEAR, -3, GETDATE()) AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)
        BEGIN
            PRINT '...but they were a technician in the past three years...checking other exclusion criteria...'
            IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE ES.BeginDate >= DATEADD(YEAR, -5, GETDATE()) AND S.StatusName IN ('Fired', 'Suspended') AND E.EmployeeFname = @EmployeeFname AND E.EmployeeLname = @EmployeeLname AND EmployeeDOB = @EmployeeDOB)
            BEGIN
                PRINT '...and they were fired or suspended in the past five years...ERROR';
                THROW 50002, 'BREAKS BUSINESS RULES', 1;
            END
            ELSE
                PRINT '...and they were not fired nor suspended in the past five years...OK'
        END
        ELSE
        BEGIN
            PRINT '...and they were not a technician in the past three years...ERROR';
            THROW 50002, 'BREAKS BUSINESS RULES', 1;
        END
    END
END
-- continue processing
DECLARE @EMPLOYEE_ID INT, @EMPLOYEE_TYPE_ID INT, @EMPLOYEE_ROLE_ID INT, @CONCERT_ID INT
-- querying for EmployeeID from tblEMPLOYEE
EXEC GET_EmployeeID
@GetEmployeeFname = @EmployeeFname,
@GetEmployeeLname = @EmployeeLname,
@GetEmployeeDOB = @EmployeeDOB,
@GetEmployeeID = @EMPLOYEE_ID OUTPUT
IF @EMPLOYEE_ID IS NULL
BEGIN
    PRINT 'ERROR @EMPLOYEE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for EmployeeTypeID from tblEMPLOYEE_TYPE
EXEC GET_EmployeeTypeID
@GetEmployeeTypeName = @EmployeeTypeName,
@GetEmployeeTypeID = @EMPLOYEE_TYPE_ID OUTPUT
IF @EMPLOYEE_TYPE_ID IS NULL
BEGIN
    PRINT 'ERROR @EMPLOYEE_TYPE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for EmployeeRoleID from tblEMPLOYEE_ROLE
EXEC GET_EmployeeRoleID
@GetEmployeeRoleName = @EmployeeRoleName,
@GetEmployeeRoleID = @EMPLOYEE_ROLE_ID OUTPUT
IF @EMPLOYEE_ROLE_ID IS NULL
BEGIN
    PRINT 'ERROR @EMPLOYEE_ROLE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for ConcertID from tblCONCERT
SET @CONCERT_ID = (SELECT ConcertID FROM tblCONCERT WHERE ConcertName = @ConcertName)
IF @CONCERT_ID IS NULL
BEGIN
    PRINT 'ERROR @CONCERT_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblCONCERT_EMPLOYEE (EmployeeID, EmployeeTypeID, EmployeeRoleID, ConcertID)
VALUES (@EMPLOYEE_ID, @EMPLOYEE_TYPE_ID, @EMPLOYEE_ROLE_ID, @CONCERT_ID)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO

-- insert into tblEMPLOYEE_STATUS
GO
CREATE PROCEDURE GET_StatusID
@GetStatusName VARCHAR(50),
@GetStatusID INT OUTPUT
AS
SET @GetStatusID = (SELECT StatusID FROM tblSTATUS WHERE StatusName = @GetStatusName)
GO
CREATE PROCEDURE INSERT_tblEMPLOYEE_STATUS
@EmployeeFname VARCHAR(50),
@EmployeeLname VARCHAR(50),
@EmployeeDOB DATE,
@StatusName VARCHAR(50),
@BeginDate DATE,
@EndDate DATE
AS
DECLARE @EMPLOYEE_ID INT, @STATUS_ID INT
-- querying for EmployeeID from tblEMPLOYEE
EXEC GET_EmployeeID
@GetEmployeeFname = @EmployeeFname,
@GetEmployeeLname = @EmployeeLname,
@GetEmployeeDOB = @EmployeeDOB,
@GetEmployeeID = @EMPLOYEE_ID OUTPUT
IF @EMPLOYEE_ID IS NULL
BEGIN
    PRINT 'ERROR @EMPLOYEE_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- querying for StatusID from tblSTATUS
EXEC GET_StatusID
@GetStatusName = @StatusName,
@GetStatusID = @STATUS_ID OUTPUT
IF @STATUS_ID IS NULL
BEGIN
    PRINT 'ERROR @STATUS_ID IS NULL';
    THROW 50001, 'NULL ID', 1;
END
-- conducting actual insert statement
BEGIN TRAN T1
INSERT INTO tblEMPLOYEE_STATUS (EmployeeID, StatusID, BeginDate, EndDate)
VALUES (@EMPLOYEE_ID, @STATUS_ID, @BeginDate, @EndDate)
IF @@ERROR <> 0
    ROLLBACK TRAN T1
ELSE
    COMMIT TRAN T1
GO
