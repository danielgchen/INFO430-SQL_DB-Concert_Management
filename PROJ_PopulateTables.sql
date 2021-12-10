-- load the database
USE INFO_430_Proj_07
-- populate country
-- > download from https://gist.github.com/radcliff/f09c0f88344a7fcef373
IF EXISTS (SELECT * FROM SYS.SYSOBJECTS WHERE NAME = 'WORKING_COPY_tblCOUNTRY_CountryName')
    BEGIN
        -- >> remove the old data
        DROP TABLE WORKING_COPY_PetData
	END
-- > create the working copy (again)
SELECT * INTO WORKING_COPY_tblCOUNTRY_CountryName FROM RAW_tblCOUNTRY_CountryName
-- > change the datatypes and add a PK
IF EXISTS (SELECT * FROM SYS.SYSOBJECTS WHERE NAME = 'WORKING_COPY_tblCOUNTRY_CountryName_PK')
    BEGIN
        DROP TABLE WORKING_COPY_tblCOUNTRY_CountryName_PK
    END
-- > create the table we need with the PK and proper typing
CREATE TABLE [dbo].[WORKING_COPY_tblCOUNTRY_CountryName_PK] (
    CountryPK INTEGER IDENTITY(1,1) PRIMARY KEY,
    CountryName VARCHAR(50) NOT NULL
) ON [PRIMARY]
-- > then insert our relevant data into the PK working copy
INSERT INTO WORKING_COPY_tblCOUNTRY_CountryName_PK (CountryName)
SELECT CountryName FROM WORKING_COPY_tblCOUNTRY_CountryName
-- > insert into table country
INSERT INTO tblCOUNTRY (CountryName)
SELECT DISTINCT(CountryName) FROM WORKING_COPY_tblCOUNTRY_CountryName_PK WHERE CountryName IS NOT NULL
-- > drop the relevant tables
DROP TABLE WORKING_COPY_tblCOUNTRY_CountryName
DROP TABLE WORKING_COPY_tblCOUNTRY_CountryName_PK
-- populate venue_type
INSERT INTO tblVENUE_TYPE (VenueTypeName)
VALUES ('Club/Bar/Pub'),('Restaurant'),('Hotel'),('Community Center'),('Stadium')
-- populate status
INSERT INTO tblSTATUS (StatusName)
VALUES ('Fired'),('Suspended'),('Standard')
-- populate employee_role
INSERT INTO tblEMPLOYEE_ROLE (EmployeeRoleName)
VALUES ('Manager'),('Vice President'),('President'),('Standard')
-- populate employee_type
INSERT INTO tblEMPLOYEE_TYPE (EmployeeTypeName)
VALUES ('Cashier'),('Cook'),('Server'),('Host'),('Security'),('Salesperson'),('Artist Aide'),('Technician')
-- populate ticket_type
INSERT INTO tblTICKET_TYPE (TicketTypeName)
VALUES ('Standard'),('VIP'),('Special'),('Cheap')
-- populate concert_type
INSERT INTO tblCONCERT_TYPE (ConcertTypeName)
VALUES ('Family'),('Neighborhood'),('Community'),('City'),('State'),('Regional'),('National'),('International')
-- populate customer_type
INSERT INTO tblCUSTOMER_TYPE (CustomerTypeName)
VALUES ('Standard'),('VIP'),('Stakeholder')
-- populate product_type
INSERT INTO tblPRODUCT_TYPE (ProductTypeName)
VALUES ('Food'),('Drink'),('Alcohol'),('Shirt'),('Pants'),('Outerwear'),('Autograph')
-- populate label
DECLARE @NROWS INT = RAND() * 251 + 250  -- randomly 250-500 labels we do 250+1=251 because it floors down
WHILE @NROWS > 0
BEGIN
    DECLARE @VALID INT = 0
    WHILE @VALID <> 1
    BEGIN
        -- >> get the label indexes
        DECLARE @idxA INT = RAND() * 10 + 1
        DECLARE @idxB INT = RAND() * 10 + 1
        DECLARE @idxC INT = RAND() * 10 + 1
        DECLARE @idxD INT = RAND() * 10 + 1
        DECLARE @idxE INT = RAND() * 10 + 1
        -- >> get the label name
        DECLARE @partA VARCHAR(50) = CHOOSE(@idxA, 'small', 'tiny', 'large', 'huge', 'medium', 'extra-large', 'miniscule', 'medium-large', 'average', 'regular')
        DECLARE @partB VARCHAR(50) = CHOOSE(@idxB, 'red', 'orange', 'yellow', 'green', 'teal', 'blue', 'indigo', 'purple', 'pink', 'black')
        DECLARE @partC VARCHAR(50) = CHOOSE(@idxC, 'happy', 'sad', 'angry', 'mild', 'curious', 'concerned', 'inquiring', 'interested', 'fatigued', 'tired')
        DECLARE @partD VARCHAR(50) = CHOOSE(@idxD, 'sky', 'land', 'ocean', 'forest', 'plains', 'grassy', 'beach', 'river', 'lake', 'space')
        DECLARE @partE VARCHAR(50) = CHOOSE(@idxE, 'pear', 'knife', 'hammer', 'vodka', 'whiskey', 'apple', 'notepad', 'tablet', 'table', 'chair')
        DECLARE @LabelName VARCHAR(50) = (SELECT @partA + ' ' + @partB + ' ' + @partC + ' ' + @partD + ' ' + @partE)
        -- >> check if valid
        IF EXISTS (SELECT * FROM tblLABEL WHERE LabelName = @LabelName)
            SET @VALID = 0
        ELSE
            SET @VALID = 1
    END
    -- >> insert into the data
    BEGIN TRAN T1
        INSERT INTO tblLABEL (LabelName)
        VALUES (@LabelName)
    IF @@ERROR <> 0
        ROLLBACK TRAN T1
    ELSE
        COMMIT TRAN T1
    SET @NROWS = @NROWS - 1
END
-- populate producer
INSERT INTO tblPRODUCER (ProducerFname, ProducerLname, ProducerDOB)
SELECT TOP 500 CustomerFname, CustomerLname, DateOfBirth FROM PEEPS.dbo.tblCUSTOMER
-- populate customer
-- > create the temporary table
IF EXISTS (SELECT * FROM SYS.SYSOBJECTS WHERE NAME = 'WORKING_COPY_CUSTOMER')
    BEGIN
        -- >> remove the old data
        DROP TABLE WORKING_COPY_CUSTOMER
	END
CREATE TABLE WORKING_COPY_CUSTOMER (
    CustomerPK INT IDENTITY(1,1) PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL
)
-- > insert data from PEEPS
INSERT INTO WORKING_COPY_CUSTOMER (Fname, Lname, DOB)
SELECT TOP 10000 CustomerFname, CustomerLname, DateOfBirth FROM PEEPS.dbo.tblCUSTOMER
-- > create the actual tblCUSTOMER
DECLARE @NROWS INT = (SELECT COUNT(*) FROM WORKING_COPY_CUSTOMER)  -- declare the number of rows
DECLARE @InsFname VARCHAR(50), @InsLname VARCHAR(50), @InsDOB DATE, @InsTypeName VARCHAR(50)  -- declare the insert parameters
DECLARE @InsTypePK INT, @InsTypeNROWS INT = (SELECT MAX(CustomerTypeID) FROM tblCUSTOMER_TYPE)  -- create the values needed for type searching
WHILE @NROWS > 0
BEGIN
    -- >> get the PK
    SET @InsFname = (SELECT Fname FROM WORKING_COPY_CUSTOMER WHERE CustomerPK = @NROWS)
    SET @InsLname = (SELECT Lname FROM WORKING_COPY_CUSTOMER WHERE CustomerPK = @NROWS)
    SET @InsDOB = (SELECT DOB FROM WORKING_COPY_CUSTOMER WHERE CustomerPK = @NROWS)
    -- >> get the type PK
    DECLARE @InsTypeValid INT = 0
    WHILE @InsTypeValid <> 0
    BEGIN
        SET @InsTypePK = RAND() * @InsTypeNROWS + 1
        IF EXISTS (SELECT * FROM tblCUSTOMER_TYPE WHERE CustomerTypeID = @InsTypePK)
            SET @InsTypeValid = 1
        ELSE
            SET @InsTypeValid = 0
    SET @InsTypeName = (SELECT CustomerTypeName FROM tblCUSTOMER_TYPE WHERE CustomerTypeID = @InsTypePK)
    -- >> insert into the table
    EXEC INSERT_tblCUSTOMER
    @CustomerFname = @InsFname,
    @CustomerLname = @InsLname,
    @CustomerDOB = @InsDOB,
    @CustomerTypeName = @InsTypeName
    SET @NROWS = @NROWS - 1
END
-- > drop the working table
DROP TABLE WORKING_COPY_CUSTOMER
-- populate city
-- > download from https://simplemaps.com/data/us-cities
IF EXISTS (SELECT * FROM SYS.SYSOBJECTS WHERE NAME = 'WORKING_COPY_tblCITY')
    BEGIN
        -- >> remove the old data
        DROP TABLE WORKING_COPY_tblCITY
	END
-- > create the working copy (again)
SELECT * INTO WORKING_COPY_tblCITY FROM RAW_tblCITY
-- > change the datatypes and add a PK
IF EXISTS (SELECT * FROM SYS.SYSOBJECTS WHERE NAME = 'WORKING_COPY_tblCITY_PK')
    BEGIN
        DROP TABLE WORKING_COPY_tblCITY_PK
    END
-- > create the table we need with the PK and proper typing
CREATE TABLE [dbo].[WORKING_COPY_tblCITY_PK] (
    CityPK INTEGER IDENTITY(1,1) PRIMARY KEY,
    CityName VARCHAR(50) NOT NULL
) ON [PRIMARY]
-- > then insert our relevant data into the PK working copy
INSERT INTO WORKING_COPY_tblCITY_PK (CityName)
SELECT DISTINCT(city) FROM WORKING_COPY_tblCITY WHERE city IS NOT NULL 
-- > create the actual tblCITY
DECLARE @NROWS INT = (SELECT COUNT(*) FROM WORKING_COPY_tblCITY_PK)  -- declare the number of rows
DECLARE @InsCityName VARCHAR(50), @InsCountryName VARCHAR(50) = 'United States'  -- hard coded because we're importing from the United States
WHILE @NROWS > 0
BEGIN
    -- >> get the PK
    SET @InsCityName = (SELECT CityName FROM WORKING_COPY_tblCITY_PK WHERE CityPK = @NROWS)
    -- >> insert into the table
    EXEC INSERT_tblCITY
    @CountryName = @InsCountryName,
    @CityName = @InsCityName,
    @CityDescription = NULL
    SET @NROWS = @NROWS - 1
END
-- > drop the relevant tables
DROP TABLE WORKING_COPY_tblCITY
DROP TABLE WORKING_COPY_tblCITY_PK
-- populate venue
GO
CREATE PROCEDURE SYNTX_INSERT_tblVENUE
@NROWS INT
AS
DECLARE @VT_PK INT, @VT_NAME VARCHAR(50), @VT_NROWS INT = (SELECT MAX(VenueTypeID) FROM tblVENUE_TYPE)  -- set up the trackers for venue type
DECLARE @C_PK INT, @C_NAME VARCHAR(50), @C_NROWS INT = (SELECT MAX(CityID) FROM tblCITY)  -- set up the trackers for city
WHILE @NROWS > 0
BEGIN
    -- get the venue type
    DECLARE @VT_VALID INT = 0
    WHILE @VT_VALID <> 1
    BEGIN
        SET @VT_PK = RAND() * @VT_NROWS + 1
        IF EXISTS (SELECT * FROM tblVENUE_TYPE WHERE VenueTypeID = @VT_PK)
            SET @VT_VALID = 1
        ELSE
            SET @VT_VALID = 0
    END
    SET @VT_NAME = (SELECT VenueTypeName FROM tblVENUE_TYPE WHERE VenueTypeID = @VT_PK)
    -- get the city
    DECLARE @C_VALID INT = 0
    WHILE @C_VALID <> 1
    BEGIN
        SET @C_PK = RAND() * @C_NROWS + 1
        IF EXISTS (SELECT * FROM tblCITY WHERE CityID = @C_PK)
            SET @C_VALID = 1
        ELSE
            SET @C_VALID = 0
    END
    SET @C_NAME = (SELECT CityName FROM tblCITY WHERE CityID = @C_PK)
    -- get venue name
    DECLARE @V_VALID INT = 0, @V_NAME VARCHAR(50)
    WHILE @V_VALID <> 1
    BEGIN
        SET @V_NAME = @VT_NAME + ' Venue #' + CAST(CAST((RAND() * POWER(10, 5)) AS INT) AS CHAR(5)) + ' of ' + @C_NAME
        IF EXISTS (SELECT * FROM tblVENUE WHERE VenueName = @V_NAME)
            SET @V_VALID = 0
        ELSE
            SET @V_VALID = 1
    END
    -- execute actual insertion
    EXEC INSERT_tblVENUE
    @VenueTypeName = @VT_NAME,
    @CityName = @C_NAME,
    @VenueName = @V_NAME,
    @VenueDescription = NULL
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblVENUE 3000
-- populate product
GO
CREATE PROCEDURE SYNTX_INSERT_tblPRODUCT_HELPER
@synTx_NeoProductName VARCHAR(50) OUTPUT,
@synTx_NeoProductType VARCHAR(50) OUTPUT
AS
DECLARE @synTx_IndexA INT, @synTx_IndexB INT, @synTx_IndexC INT, @synTx_IndexD INT, @synTx_IndexE INT
DECLARE @synTx_NameA VARCHAR(50), @synTx_NameB VARCHAR(50), @synTx_NameC VARCHAR(50), @synTx_NameD VARCHAR(50), @synTx_NameE VARCHAR(50)
DECLARE @invalid_name INT = 1
WHILE @invalid_name <> 0 
    BEGIN
        -- get five indexes for 10 ^ 4 * 16 possible combinations
        SET @synTx_IndexA = (SELECT RAND() * 10)  -- size
        SET @synTx_IndexB = (SELECT RAND() * 10)  -- color
        SET @synTx_IndexC = (SELECT RAND() * 10)  -- feeling
        SET @synTx_IndexD = (SELECT RAND() * 10)  -- location
        SET @synTx_IndexE = (SELECT RAND() * 16)  -- name
        -- get the product name parts based on the indexes
        SET @synTx_NameA = CHOOSE(@synTx_IndexA, 'small', 'tiny', 'large', 'huge', 'medium', 'extra-large', 'miniscule', 'medium-large', 'average', 'regular')
        SET @synTx_NameB = CHOOSE(@synTx_IndexB, 'red', 'orange', 'yellow', 'green', 'teal', 'blue', 'indigo', 'purple', 'pink', 'black')
        SET @synTx_NameC = CHOOSE(@synTx_IndexC, 'happy', 'sad', 'angry', 'mild', 'curious', 'concerned', 'inquiring', 'interested', 'fatigued', 'tired')
        SET @synTx_NameD = CHOOSE(@synTx_IndexD, 'sky', 'land', 'ocean', 'forest', 'plains', 'grassy', 'beach', 'river', 'lake', 'space')
        SET @synTx_NameE = CHOOSE(@synTx_IndexE, 'fries', 'burger', 'soft drink', 'lemonade', 'wine', 'beer', 't-shirt', 'hoodie', 'jacket', 'shorts', 'khakis', 'pants', 'slacks', 'windbreaker', 'note', 'autograph')
        SET @synTx_NeoProductName = (SELECT @synTx_NameA + ' ' + @synTx_NameB + ' ' + @synTx_NameC + ' ' + @synTx_NameD + ' ' + @synTx_NameE)
        -- check whether the product name is already in table product
        IF NOT EXISTS (SELECT * FROM tblPRODUCT WHERE ProductName = @synTx_NeoProductName)
            BEGIN
                IF @synTx_NeoProductName IS NOT NULL
                    BEGIN
                        -- stop the loop
                        SET @invalid_name = 0
                        -- find the product type
                        SET @synTx_NeoProductType = (SELECT
                                                        CASE
                                                            WHEN @synTx_NameE = 'fries' OR @synTx_NameE = 'burger' THEN 'Food'
                                                            WHEN @synTx_NameE = 'soft drink' OR @synTx_NameE = 'lemonade' THEN 'Drink'
                                                            WHEN @synTx_NameE = 'wine' OR @synTx_NameE = 'beer' THEN 'Alcohol'
                                                            WHEN @synTx_NameE = 't-shirt' OR @synTx_NameE = 'hoodie' THEN 'Shirt'
                                                            WHEN @synTx_NameE = 'shorts' OR @synTx_NameE = 'khakis' OR @synTx_NameE = 'pants' OR @synTx_NameE = 'slacks' THEN 'Pants'
                                                            WHEN @synTx_NameE = 'jacket' OR @synTx_NameE = 'windbreaker' THEN 'Outerwear'
                                                            WHEN @synTx_NameE = 'autograph' OR @synTx_NameE = 'note' THEN 'Autograph'
                                                            ELSE NULL
                                                        END)
                    END
            END
    END
GO
CREATE PROCEDURE SYNTX_INSERT_tblPRODUCT
@NROWS INT
AS
DECLARE @synTx_ProductName VARCHAR(50), @synTx_ProductType VARCHAR(50), @synTx_Price NUMERIC(4,2)
WHILE @NROWS > 0
    BEGIN
        -- get the product name and product type
        EXEC SYNTX_INSERT_tblPRODUCT_HELPER
        @synTx_NeoProductName = @synTx_ProductName OUTPUT,
        @synTx_NeoProductType = @synTx_ProductType OUTPUT
        -- get price
        SET @synTx_Price = (SELECT CASE
                                       WHEN @synTx_ProductType = 'Food' THEN RAND() * 20 + 5
                                       WHEN @synTx_ProductType = 'Outerwear' THEN RAND() * 30 + 30
                                       WHEN @synTx_ProductType = 'Shirt' THEN RAND() * 20 + 10
                                       WHEN @synTx_ProductType = 'Pants' THEN RAND() * 20 + 15
                                       WHEN @synTx_ProductType = 'Drink' THEN RAND() * 2 + 2
                                       WHEN @synTx_ProductType = 'Alcohol' THEN RAND() * 10 + 2
                                       WHEN @synTx_ProductType = 'Autograph' THEN RAND() * 20 + 80
                                       ELSE NULL
                                    END)
        -- do the actual insert
        EXEC INSERT_tblPRODUCT
        @ProductName = @synTx_ProductName,
        @ProductTypeName = @synTx_ProductType,
        @ProductCurrentPrice = @synTx_Price,
        @ProductDescription = NULL
        SET @NROWS = @NROWS - 1
    END
GO
EXEC SYNTX_INSERT_tblPRODUCT 2000
-- populate product history
GO
CREATE PROCEDURE SYNTX_INSERT_tblPRODUCT_PRICE_HISTORY
@NROWS INT
AS
DECLARE @P_PK INT, @P_NROWS INT = (SELECT MAX(ProductID) FROM tblPRODUCT)
DECLARE @P_Name VARCHAR(50), @P_Price NUMERIC(4,2), @P_BeginDate DATE, @P_EndDate DATE
WHILE @NROWS > 0
BEGIN
    -- get the product name
    DECLARE @P_Valid INT = 0
    WHILE @P_Valid <> 1
    BEGIN
        SET @P_PK = RAND() * @P_NROWS + 1
        IF EXISTS (SELECT * FROM tblPRODUCT WHERE ProductID = @P_PK)
            SET @P_Valid = 1
        ELSE
            SET @P_Valid = 0
    END
    SET @P_Name = (SELECT ProductName FROM tblPRODUCT WHERE ProductID = @P_PK)
    -- set the price (utilize a random walk like model)
    IF EXISTS (SELECT * FROM tblPRODUCT_PRICE_HISTORY WHERE ProductID = @P_PK)  -- we have a previous price recorded
        SET @P_Price = (SELECT TOP 1 Price FROM tblPRODUCT_PRICE_HISTORY WHERE ProductID = @P_PK ORDER BY BeginDate)
    ELSE  -- we don't have a previous price recorded
        SET @P_Price = (SELECT ProductCurrentPrice FROM tblPRODUCT WHERE ProductID = @P_PK)
    -- > change the value by min subtracting 50% maximum adding 50%
    SET @P_Price = @P_Price - (RAND() * @P_Price * 0.5) + (RAND() * @P_Price * 0.5)
    -- > if it's zero we default it to 10 cents
    IF @P_Price = 0.0
        SET @P_Price = 0.10
    -- retrieve the previous end date and set the end date where begin date and end date do not overlap
    IF EXISTS (SELECT * FROM tblPRODUCT_PRICE_HISTORY WHERE ProductID = @P_PK)  -- we have a previous price recorded
    BEGIN
        SET @P_EndDate = (SELECT TOP 1 BeginDate FROM tblPRODUCT_PRICE_HISTORY WHERE ProductID = @P_PK ORDER BY BeginDate)
        SET @P_EndDate = DATEADD(DAY, -1, @P_EndDate)
    END
    ELSE  -- we don't have a previous price recorded
        SET @P_EndDate = GETDATE()
    -- retrieve the begin date considering the largest possible to be a week
    SET @P_BeginDate = DATEADD(DAY, -1 * (RAND() * 7 + 1), @P_EndDate)
    -- perform actual execution
    EXEC INSERT_tblPRODUCT_PRICE_HISTORY
    @ProductName = @P_Name,
    @Price = @P_Price,
    @BeginDate = @P_BeginDate,
    @EndDate = @P_EndDate
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblPRODUCT_PRICE_HISTORY 40000
-- populate employee
INSERT INTO tblEMPLOYEE (EmployeeFname, EmployeeLname, EmployeeDOB)
SELECT TOP 2500 CustomerFname, CustomerLname, DateOfBirth FROM PEEPS.dbo.tblCUSTOMER
-- populate employee status
GO
CREATE PROCEDURE SYNTX_INSERT_tblEMPLOYEE_STATUS
@NROWS INT
AS
DECLARE @E_PK INT, @E_NROWS INT = (SELECT MAX(EmployeeID) FROM tblEMPLOYEE), @E_F VARCHAR(50), @E_L VARCHAR(50), @E_DOB DATE
DECLARE @S_PK INT, @S_NROWS INT = (SELECT MAX(StatusID) FROM tblSTATUS), @S_Name VARCHAR(50)
DECLARE @ES_BeginDate DATE, @ES_EndDate DATE
WHILE @NROWS > 0
BEGIN
    -- get the employee names and dob
    DECLARE @E_Valid INT = 0
    WHILE @E_Valid <> 1
    BEGIN
        SET @E_PK = RAND() * @E_NROWS + 1
        IF EXISTS (SELECT * FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
            SET @E_Valid = 1
        ELSE
            SET @E_Valid = 0
    END
    SET @E_F = (SELECT EmployeeFname FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
    SET @E_L = (SELECT EmployeeLname FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
    SET @E_DOB = (SELECT EmployeeDOB FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
    -- get the status name
    DECLARE @S_Valid INT = 0
    WHILE @S_Valid <> 1
    BEGIN
        SET @S_PK = RAND() * @S_NROWS + 1
        IF EXISTS (SELECT * FROM tblSTATUS WHERE StatusID = @S_PK)
            SET @S_Valid = 1
        ELSE
            SET @S_Valid = 0
    END
    SET @S_Name = (SELECT StatusName FROM tblSTATUS WHERE StatusID = @S_PK)
    -- retrieve the previous end date and set the end date where begin date and end date do not overlap
    IF EXISTS (SELECT * FROM tblEMPLOYEE_STATUS WHERE EmployeeID = @E_PK AND StatusID = @S_PK)  -- we have a previous status recorded
    BEGIN
        SET @ES_EndDate = (SELECT TOP 1 BeginDate FROM tblEMPLOYEE_STATUS WHERE EmployeeID = @E_PK AND StatusID = @S_PK ORDER BY BeginDate)
        SET @ES_EndDate = DATEADD(DAY, -1, @ES_EndDate)
    END
    ELSE  -- we don't have a previous status recorded using up to 5 years in the future and nearest enddate is tomorrow
        SET @ES_EndDate = DATEADD(DAY, RAND() * (365 * 5) + 1, GETDATE())
    -- retrieve the begin date considering the largest possible to be a 10 year contract where it at least began before today if novo creation
    IF EXISTS (SELECT * FROM tblEMPLOYEE_STATUS WHERE EmployeeID = @E_PK AND StatusID = @S_PK)  -- we have a previous status recorded
    BEGIN
        DECLARE @LastStatus VARCHAR(50) = (SELECT TOP 1 S.StatusName FROM tblEMPLOYEE_STATUS ES JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE ES.EmployeeID = @E_PK AND ES.StatusID = @S_PK ORDER BY BeginDate)
        SET @ES_BeginDate = (SELECT CASE  -- like last time we use a probability random walk decision model
                                        WHEN @LastStatus = 'Fired' THEN DATEADD(DAY, -1 * (RAND() * (365 * 4) + 1), @ES_EndDate)
                                        WHEN @LastStatus = 'Suspended' THEN DATEADD(DAY, -1 * (RAND() * (7 * 4) + 1), @ES_EndDate)
                                        WHEN @LastStatus = 'Standard' THEN DATEADD(DAY, -1 * (RAND() * (365 * 2) + 1), @ES_EndDate)
                                        ELSE NULL
                                    END)
    END
    ELSE  -- we don't have a previous status recorded
        SET @ES_BeginDate = DATEADD(DAY, -1 * (RAND() * (365 * 2) + 1), GETDATE())
    -- perform actual execution
    EXEC INSERT_tblEMPLOYEE_STATUS
    @EmployeeFname = @E_F,
    @EmployeeLname = @E_L,
    @EmployeeDOB = @E_DOB,
    @StatusName = @S_Name,
    @BeginDate = @ES_BeginDate,
    @EndDate = @ES_EndDate
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblEMPLOYEE_STATUS 15000
-- populate concert
GO
CREATE PROCEDURE SYNTX_INSERT_tblCONCERT
@NROWS INT
AS
DECLARE @CT_PK INT, @CT_NROWS INT = (SELECT MAX(ConcertTypeID) FROM tblCONCERT_TYPE), @CT_Name VARCHAR(50)
DECLARE @V_PK INT, @V_NROWS INT = (SELECT MAX(VenueID) FROM tblVENUE), @V_Name VARCHAR(50)
DECLARE @C_Name VARCHAR(50), @C_Date DATE
WHILE @NROWS > 0
BEGIN
    -- get the concert type information
    DECLARE @CT_Valid INT = 0
    WHILE @CT_Valid <> 1
    BEGIN
        SET @CT_PK = RAND() * @CT_NROWS + 1
        IF EXISTS (SELECT * FROM tblCONCERT_TYPE WHERE ConcertTypeID = @CT_PK)
            SET @CT_Valid = 1
        ELSE
            SET @CT_Valid = 0
    END
    SET @CT_Name = (SELECT ConcertTypeName FROM tblCONCERT_TYPE WHERE ConcertTypeID = @CT_PK)
    -- get the venue information
    DECLARE @V_Valid INT = 0
    WHILE @V_Valid <> 1
    BEGIN
        SET @V_PK = RAND() * @V_NROWS + 1
        IF EXISTS (SELECT * FROM tblVENUE WHERE VenueID = @V_PK)
            SET @V_Valid = 1
        ELSE
            SET @V_Valid = 0
    END
    SET @V_Name = (SELECT VenueName FROM tblVENUE WHERE VenueID = @V_PK)
    -- get the concert name
    DECLARE @C_Valid INT = 0
    WHILE @C_Valid <> 1
    BEGIN
        SET @C_Name = 'Concert #' + CAST(CAST((RAND() * POWER(10, 5)) AS INT) AS CHAR(5)) + ' at ' + @V_Name
        IF EXISTS (SELECT * FROM tblCONCERT WHERE ConcertName = @C_Name)
            SET @C_Valid = 0
        ELSE
            SET @C_Valid = 1
    END
    -- get the concert date
    DECLARE @SetPast INT = RAND() * 100
    IF @SetPast < 80  -- 80% of the time do this
        SET @C_Date = DATEADD(DAY, (-1 * RAND() * (365 * 50)) - 1, GETDATE())
    ELSE
        SET @C_Date = DATEADD(DAY, RAND() * (365 * 5), GETDATE())
    -- execute the actual transaction
    EXEC INSERT_tblCONCERT
    @ConcertTypeName = @CT_Name,
    @VenueName = @V_Name,
    @ConcertName = @C_Name,
    @ConcertDate = @C_Date,
    @ConcertDescription = NULL
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblCONCERT 10000
-- populate ticket
GO
CREATE PROCEDURE SYNTX_INSERT_tblTICKET
@NROWS INT
AS
DECLARE @C_PK INT, @C_NROWS INT = (SELECT MAX(CustomerID) FROM tblCUSTOMER), @C_F VARCHAR(50), @C_L VARCHAR(50), @C_DOB DATE
DECLARE @CC_PK INT, @CC_NROWS INT = (SELECT MAX(ConcertID) FROM tblCONCERT), @CC_Name VARCHAR(50)
DECLARE @TT_PK INT, @TT_NROWS INT = (SELECT MAX(TicketTypeID) FROM tblTICKET_TYPE), @TT_Name VARCHAR(50)
DECLARE @T_Name VARCHAR(50), @T_Price NUMERIC(10,2)
WHILE @NROWS > 0
BEGIN
    DECLARE @PassBusinessRules INT = 0
    WHILE @PassBusinessRules <> 1
    BEGIN
        -- assume we pass
        SET @PassBusinessRules = 1
        -- get parameters
        -- > get customer
        DECLARE @C_Valid INT = 0
        WHILE @C_Valid <> 1
        BEGIN
            SET @C_PK = RAND() * @C_NROWS + 1
            IF EXISTS (SELECT * FROM tblCUSTOMER WHERE CustomerID = @C_PK)
                SET @C_Valid = 1
            ELSE
                SET @C_Valid = 0
        END
        SET @C_F = (SELECT CustomerFname FROM tblCUSTOMER WHERE CustomerID = @C_PK)
        SET @C_L = (SELECT CustomerLname FROM tblCUSTOMER WHERE CustomerID = @C_PK)
        SET @C_DOB = (SELECT CustomerDOB FROM tblCUSTOMER WHERE CustomerID = @C_PK)
        -- > get concert
        DECLARE @CC_Valid INT = 0
        WHILE @CC_Valid <> 1
        BEGIN
            SET @CC_PK = RAND() * @CC_NROWS + 1
            IF EXISTS (SELECT * FROM tblCONCERT WHERE ConcertID = @CC_PK)
                SET @CC_Valid = 1
            ELSE
                SET @CC_Valid = 0  -- for all of these we don't technically need the CC_Valid = 0 and for the other ones but this helps clarity
        END
        SET @CC_Name = (SELECT ConcertName FROM tblCONCERT WHERE ConcertID = @CC_PK)
        -- > get ticket type
        DECLARE @TT_Valid INT = 0
        WHILE @TT_Valid <> 1
        BEGIN
            SET @TT_PK = RAND() * @TT_NROWS + 1
            IF EXISTS (SELECT * FROM tblTICKET_TYPE WHERE TicketTypeID = @TT_PK)
                SET @TT_Valid = 1
            ELSE
                SET @TT_Valid = 0
        END
        SET @TT_Name = (SELECT TicketTypeName FROM tblTICKET_TYPE WHERE TicketTypeID = @TT_PK)
        -- check business rules
        -- correct for business rule 1. no customers younger than 20 may buy a ticket of type VIP for stadium concerts
        IF DATEADD(YEAR, -20, GETDATE()) < @C_DOB
        BEGIN
            IF EXISTS (SELECT * FROM tblCONCERT C JOIN tblVENUE V ON V.VenueID = C.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE C.ConcertName = @CC_Name AND VT.VenueTypeName = 'Stadium')
            BEGIN
                IF @TT_Name = 'VIP'
                BEGIN
                    SET @PassBusinessRules = 0
                    CONTINUE
                END
            END
        END
        -- correct for 2. the same customer cannot purchase more than 10 special tickets for an international concert unless they are a stakeholder
        IF EXISTS (SELECT * FROM tblCONCERT C JOIN tblCONCERT_TYPE CT ON CT.ConcertTypeID = C.ConcertTypeID WHERE C.ConcertName = @CC_Name AND CT.ConcertTypeName = 'International')
        BEGIN
            IF EXISTS (SELECT * FROM tblCUSTOMER C JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE C.CustomerFname = @C_F AND C.CustomerLname = @C_L AND C.CustomerDOB = @C_DOB AND CT.CustomerTypeName <> 'Stakeholder')  -- could be changed to just CustomerID = @C_PK but we're doing this to be consistent with the sproc
            BEGIN
                IF @TT_Name = 'Special'
                BEGIN
                    IF EXISTS (SELECT * FROM tblCUSTOMER C JOIN tblTICKET T ON T.CustomerID = C.CustomerID JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID WHERE TT.TicketTypeName = 'Special' GROUP BY C.CustomerID HAVING COUNT(*) >= 10)
                    BEGIN
                        SET @PassBusinessRules = 0
                        CONTINUE
                    END
                END
            END
        END
    END
    -- continue getting parameters
    -- > get ticket name
    DECLARE @T_Valid INT = 0
    WHILE @T_Valid <> 1
    BEGIN
        SET @T_Name = @TT_Name + ' Ticket #' + CAST(CAST((RAND() * POWER(10, 5)) AS INT) AS CHAR(5))
        IF EXISTS (SELECT * FROM tblTICKET WHERE TicketName = @T_Name)
            SET @T_Valid = 0
        ELSE
            SET @T_Valid = 1
    END
    -- > get ticket price
    SET @T_Price = (SELECT CASE
                            WHEN @TT_Name = 'VIP' THEN RAND() * 90000 + 10000 + 1
                            WHEN @TT_Name = 'Special' THEN RAND() * 1500 + 1000 + 1
                            WHEN @TT_Name = 'Standard' THEN RAND() * 400 + 100 + 1
                            WHEN @TT_Name = 'Cheap' THEN RAND() * 10 + 5 + 1
                            ELSE NULL
                           END)
    -- perform the actual execution
    EXEC INSERT_tblTICKET
    @CustomerFname = @C_F,
    @CustomerLname = @C_L,
    @CustomerDOB = @C_DOB,
    @TicketTypeName = @TT_Name,
    @ConcertName = @CC_Name,
    @TicketName = @T_Name,
    @Price = @T_Price
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblTICKET 50000
-- populate ticket product
GO
CREATE PROCEDURE SYNTX_INSERT_tblTICKET_PRODUCT
@NROWS INT
AS
DECLARE @T_PK INT, @T_NROWS INT = (SELECT MAX(TicketID) FROM tblTICKET), @T_Name VARCHAR(50)
DECLARE @P_PK INT, @P_NROWS INT = (SELECT MAX(ProductID) FROM tblPRODUCT), @P_Name VARCHAR(50)
DECLARE @Quantity INT
WHILE @NROWS > 0
BEGIN
    DECLARE @PassBusinessRules INT = 0
    WHILE @PassBusinessRules <> 1
    BEGIN
        -- presumptive assumption of passing business rules
        SET @PassBusinessRules = 1
        -- gather the ticket information
        DECLARE @T_Valid INT = 0
        WHILE @T_Valid <> 1
        BEGIN
            SET @T_PK = RAND() * @T_NROWS + 1
            IF EXISTS (SELECT * FROM tblTICKET WHERE TicketID = @T_PK)
                SET @T_Valid = 1
            ELSE
                SET @T_Valid = 0
        END
        SET @T_Name = (SELECT TicketName FROM tblTICKET WHERE TicketID = @T_PK)
        -- gather the product information
        DECLARE @P_Valid INT = 0
        WHILE @P_Valid <> 1
        BEGIN
            SET @P_PK = RAND() * @P_NROWS + 1
            IF EXISTS (SELECT * FROM tblPRODUCT WHERE ProductID = @P_PK)
                SET @P_Valid = 1
            ELSE
                SET @P_Valid = 0
        END
        SET @P_Name = (SELECT ProductName FROM tblPRODUCT WHERE ProductID = @P_PK)
        -- gather the quantity information
        DECLARE @P_Type VARCHAR(50) = (SELECT ProductTypeName FROM tblPRODUCT_TYPE PT JOIN tblPRODUCT P ON P.ProductTypeID = PT.ProductTypeID WHERE P.ProductName = @P_Name)
        SET @Quantity = (SELECT CASE
                                    WHEN @P_Type = 'Alcohol' OR @P_Type = 'Drink' THEN RAND() * 2 + 1
                                    WHEN @P_Type = 'Food' THEN RAND() * 2 + 2
                                    WHEN @P_Type = 'Shirt' THEN RAND() * 5 + 1
                                    WHEN @P_Type = 'Pants' THEN RAND() * 3 + 1
                                    WHEN @P_Type = 'Autograph' THEN RAND() * 10 + 1
                                    WHEN @P_Type = 'Outerwear' THEN 1
                                    ELSE NULL
                                END)
        -- test the business rules
        -- 3797 / 50k tickets are family, neigborhood, community, 5904 are in hotels or stadiums, we canot predict ticket product (alcohol), 16702 are not vip or stakeholders
        IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE T.TicketName = @T_Name AND CCT.ConcertTypeName IN ('Family','Neighborhood','Community'))
        BEGIN
            IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblVENUE V ON V.VenueID = CC.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE T.TicketName = @T_Name AND VT.VenueTypeName NOT IN ('Hotel', 'Stadium'))
            BEGIN
                IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder') AND T.TicketName = @T_Name)
                BEGIN
                    IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE P.ProductName = @P_Name AND PT.ProductTypeName = 'Alcohol')
                    BEGIN
                        SET @PassBusinessRules = 0
                        CONTINUE
                    END
                END
            END
        END
        -- correcting for 7. customers aside from VIP and stakeholders are not allowed to spend more than 100 dollars in total for food, drink, or alcohol unless it is a national or international stadium concert
        -- we cannot predict how much they will buy of something, 2074 are stadium, 2463 are national and international,16702 are not vip or stakeholders
        IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblVENUE V ON V.VenueID = CC.VenueID JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID WHERE VT.VenueTypeName = 'Stadium' AND T.TicketName = @T_Name)
        BEGIN
            IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE CCT.ConcertTypeName IN ('National','International') AND T.TicketName = @T_Name)
            BEGIN
                IF EXISTS (SELECT * FROM tblTICKET T JOIN tblCONCERT CC ON CC.ConcertID = T.TicketID JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder') AND T.TicketName = @T_Name)
                BEGIN
                    IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE P.ProductName = @P_Name AND PT.ProductTypeName IN ('Food', 'Drink', 'Alcohol'))
                    BEGIN
                        DECLARE @TotalPrice NUMERIC(5,2) = (SELECT SUM(P.ProductCurrentPrice * TP.Quantity) FROM tblTICKET T JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID JOIN tblPRODUCT P ON P.ProductID = TP.ProductID JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE PT.ProductTypeName IN ('Food', 'Drink', 'Alcohol') AND T.TicketName = @T_Name)
                        DECLARE @ProductPrice NUMERIC(4,2) = (SELECT ProductCurrentPrice FROM tblPRODUCT WHERE ProductName = @P_Name)
                        SET @TotalPrice = @TotalPrice + (@Quantity * @ProductPrice)
                        IF @TotalPrice > 100
                        BEGIN
                            SET @PassBusinessRules = 0
                            CONTINUE
                        END
                    END
                END
            END
        END
        -- correcting for 6. customers under 21 are not allowed to have any alcohol associated with their ticket unless they've spent more than 100 dollars on food
        -- no customers < 21, we don't know the other values for more than 100 dollars we do know, 260/2000 products are alcoholic
        IF DATEADD(YEAR, -21, GETDATE()) < (SELECT C.CustomerDOB FROM tblCUSTOMER C JOIN tblTICKET T ON T.CustomerID = C.CustomerID WHERE T.TicketName = @T_Name)
        BEGIN
            IF EXISTS (SELECT * FROM tblPRODUCT P JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID WHERE PT.ProductTypeName = 'Alcohol')
            BEGIN
                IF EXISTS (SELECT * FROM tblTICKET T JOIN tblTICKET_PRODUCT TP ON TP.ticketID = T.TicketID JOIN tblPRODUCT P ON P.ProductID = TP.ProductID JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeName = 'Food' GROUP BY T.TicketID HAVING SUM(P.ProductCurrentPrice * TP.Quantity) <= 100)
                BEGIN
                    SET @PassBusinessRules = 0
                    CONTINUE
                END
            END
        END
    END
    -- perform actual insertion
    EXEC INSERT_tblTICKET_PRODUCT
    @TicketName = @T_Name,
    @ProductName = @P_Name,
    @Quantity = @Quantity
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblTICKET_PRODUCT 300000
-- populate concert employee
GO
CREATE PROCEDURE SYNTX_INSERT_tblCONCERT_EMPLOYEE
@NROWS INT
AS
DECLARE @C_PK INT, @C_NROWS INT = (SELECT MAX(ConcertID) FROM tblCONCERT), @C_Name VARCHAR(50)
DECLARE @E_PK INT, @E_NROWS INT = (SELECT MAX(EmployeeID) FROM tblEMPLOYEE), @E_F VARCHAR(50), @E_L VARCHAR(50), @E_DOB DATE
DECLARE @R_PK INT, @R_NROWS INT = (SELECT MAX(EmployeeRoleID) FROM tblEMPLOYEE_ROLE), @R_Name VARCHAR(50)
DECLARE @T_PK INT, @T_NROWS INT = (SELECT MAX(EmployeeTypeID) FROM tblEMPLOYEE_TYPE), @T_Name VARCHAR(50)
WHILE @NROWS > 0
BEGIN
    DECLARE @PassBusinessRules INT = 0
    WHILE @PassBusinessRules <> 1
    BEGIN
        SET @PassBusinessRules = 1  -- presumptive passing corrected later on
        -- get concert information
        DECLARE @C_Valid INT = 0
        WHILE @C_Valid <> 1
        BEGIN
            SET @C_PK = RAND() * @C_NROWS + 1
            IF EXISTS (SELECT * FROM tblCONCERT WHERE ConcertID = @C_PK)
                SET @C_Valid = 1
            ELSE
                SET @C_Valid = 0
        END
        SET @C_Name = (SELECT ConcertName FROM tblCONCERT WHERE ConcertID = @C_PK)
        -- get employee information
        DECLARE @E_Valid INT = 0
        WHILE @E_Valid <> 1
        BEGIN
            SET @E_PK = RAND() * @E_NROWS + 1
            IF EXISTS (SELECT * FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
                SET @E_Valid = 1
            ELSE
                SET @E_Valid = 0
        END
        SET @E_F = (SELECT EmployeeFname FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
        SET @E_L = (SELECT EmployeeLname FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
        SET @E_DOB = (SELECT EmployeeDOB FROM tblEMPLOYEE WHERE EmployeeID = @E_PK)
        -- get role information
        DECLARE @R_Valid INT = 0
        WHILE @R_Valid <> 1
        BEGIN
            SET @R_PK = RAND() * @R_NROWS + 1
            IF EXISTS (SELECT * FROM tblEMPLOYEE_ROLE WHERE EmployeeRoleID = @R_PK)
                SET @R_Valid = 1
            ELSE
                SET @R_Valid = 0
        END
        SET @R_Name = (SELECT EmployeeRoleName FROM tblEMPLOYEE_ROLE WHERE EmployeeRoleID = @R_PK)
        -- get type information
        DECLARE @T_Valid INT = 0
        WHILE @T_Valid <> 1
        BEGIN
            SET @T_PK = RAND() * @T_NROWS + 1
            IF EXISTS (SELECT * FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeID = @T_PK)
                SET @T_Valid = 1
            ELSE
                SET @T_Valid = 0
        END
        SET @T_Name = (SELECT EmployeeTypeName FROM tblEMPLOYEE_TYPE WHERE EmployeeTypeID = @T_PK)
        -- test business rules
        IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Fired' AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)  -- check if they were fired if they were fired before
        BEGIN
            IF EXISTS (SELECT * FROM tblCONCERT CC JOIN tblTICKET T ON T.ConcertID = CC.ConcertID JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID WHERE CT.CustomerTypeName = 'Stakeholder' AND CC.ConcertName = @C_Name)
            BEGIN
                IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Standard' AND DATEADD(YEAR, -5, GETDATE()) <= ES.BeginDate AND ES.EndDate >= GETDATE() AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)
                BEGIN
                    IF EXISTS (SELECT E.EmployeeID FROM tblCONCERT CC JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID AND CC.ConcertDate >= DATEADD(YEAR, -2, GETDATE()) AND ET.EmployeeTypeName IN ('Cashier', 'Server') AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)
                        SET @PassBusinessRules = @PassBusinessRules
                    ELSE
                    BEGIN
                        SET @PassBusinessRules = 0
                        CONTINUE
                    END
                END
                ELSE
                BEGIN
                    SET @PassBusinessRules = 0
                    CONTINUE
                END
            END
        END
        -- correcting for 4. an employee who has ever been suspended can only work family, neighborhood, community, city concerts and only with a type as a cook
        -- check if ever suspended, check if working a concert not family, neighborhood, or community or city, check if not working as type of cook
        IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE S.StatusName = 'Suspended' AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)  -- check if they were fired if they were fired before
        BEGIN
            IF EXISTS (SELECT * FROM tblCONCERT CC JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID WHERE CC.ConcertName = @C_Name AND CCT.ConcertTypeName NOT IN ('Family', 'Neighborhood', 'Community', 'City'))
            BEGIN
                SET @PassBusinessRules = 0
                CONTINUE
            END
            ELSE
            BEGIN
                IF @T_Name <> 'Cook'
                BEGIN
                    SET @PassBusinessRules = 0
                    CONTINUE
                END
            END
        END
        -- correcting for 5. employees can only take on the role of manager and have a type of artist aide or security guard if they have been a technician in the past three years and have never been fired or suspended in the last 5 years considering begin date
        IF @T_Name IN ('Artist Aide', 'Security')
        BEGIN
            IF @R_Name = 'Manager'
            BEGIN
                IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblCONCERT_EMPLOYEE CE ON CE.EmployeeID = E.EmployeeID JOIN tblCONCERT C ON C.ConcertID = CE.ConcertID JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID WHERE ET.EmployeeTypeName = 'Technician' AND C.ConcertDate >= DATEADD(YEAR, -3, GETDATE()) AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)
                BEGIN
                    IF EXISTS (SELECT * FROM tblEMPLOYEE E JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID JOIN tblSTATUS S ON S.StatusID = ES.StatusID WHERE ES.BeginDate >= DATEADD(YEAR, -5, GETDATE()) AND S.StatusName IN ('Fired', 'Suspended') AND E.EmployeeFname = @E_F AND E.EmployeeLname = @E_L AND EmployeeDOB = @E_DOB)
                    BEGIN
                        SET @PassBusinessRules = 0
                        CONTINUE
                    END
                END
                ELSE
                BEGIN
                    SET @PassBusinessRules = 0
                    CONTINUE
                END
            END
        END
    END
    -- do actual insertion
    EXEC INSERT_tblCONCERT_EMPLOYEE
    @ConcertName = @C_Name,
    @EmployeeFname = @E_F,
    @EmployeeLname = @E_L,
    @EmployeeDOB = @E_DOB,
    @EmployeeTypeName = @T_Name,
    @EmployeeRoleName = @R_Name
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblCONCERT_EMPLOYEE 30000
-- populate album type
INSERT INTO tblALBUM_TYPE (AlbumTypeName)
VALUES ('LP/Standard'),('EP/Mini'), ('Compilation'), ('Single'), ('Mixtape'), ('Live')
-- populate genre (html from https://www.google.com/search?q=music+genres&rlz=1C5CHFA_enUS883US883&oq=music+genres&aqs=chrome.0.0i433i512l2j0i512l3j69i65j69i60l2.1430j0j7&sourceid=chrome&ie=UTF-8 then ipython based processing based on <div class="bVj5Zb FozYP"> which was hand found then iterative string splits were done)
INSERT INTO tblGENRE (GenreName)
VALUES ('Rock'),('Pop music'),('Jazz'),('Hip hop music'),('Country music'),('Folk music'),('Heavy metal'),('Blues'),('Popular music'),('Rhythm and blues'),('Classical music'),('Electronic music'),('Punk rock'),('Electronic dance music'),('Soul music'),('Funk'),('Reggae'),('House music'),('Disco'),('Techno'),('Dance music'),('Ambient music'),('Indie rock'),('Alternative rock'),('Gospel music'),('Instrumental'),('Trance music'),('Dubstep'),('Singing'),('Swing music'),('New wave'),('Pop rock'),('Grunge'),('Drum and bass'),('Industrial music'),('Experimental music'),('Ska'),('Contemporary R&amp;B'),('Hardcore'),('Jazz fusion'),('Death metal'),('Breakbeat'),('Emo'),('Hardcore punk'),('Synth-pop'),('World music'),('Progressive rock'),('Downtempo'),('Easy listening'),('Trap music'),('Psychedelic rock')
-- populate songs (i'm noting this isn't really a synthetic transaction it's just a really easy way for us to repeatedly add songs if we ever want to add more in the future and when we reconfigure the databases)
GO
CREATE PROCEDURE SYNTX_INSERT_tblSONG
@NROWS INT
AS
DECLARE @S_Name VARCHAR(50)
WHILE @NROWS > 0
BEGIN
    -- test the name
    DECLARE @S_Valid INT = 0
    WHILE @S_Valid <> 1
    BEGIN
        SET @S_Name = 'Song #' + CAST(CAST(RAND() * POWER(10,8) AS INT) AS CHAR(8))
        IF EXISTS (SELECT * FROM tblSONG WHERE SongName = @S_Name)
            SET @S_Valid = 0
        ELSE
            SET @S_Valid = 1
    END
    -- do actual transaction
    BEGIN TRAN T1
    INSERT INTO tblSONG (SongName) VALUES (@S_Name)
    IF @@ERROR <> 0
        ROLLBACK TRAN T1
    ELSE
        COMMIT TRAN T1
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblSONG 10000
-- populate artists (adding desc zip for another random component to avoid some more overlap between the already overlapping producer, employee and customers)
INSERT INTO tblARTIST (ArtistFname, ArtistLname, ArtistDOB)
SELECT TOP 4000 CustomerFname,CustomerLname,DateOfBirth FROM PEEPS.dbo.tblCUSTOMER ORDER BY CustomerZIP DESC
-- populate song artist
GO
CREATE PROCEDURE SYNTX_INSERT_tblARTIST_SONG
@NROWS INT
AS
DECLARE @A_PK INT, @A_NROWS INT = (SELECT MAX(ArtistID) FROM tblARTIST), @A_F VARCHAR(50), @A_L VARCHAR(50), @A_DOB DATE
DECLARE @S_PK INT, @S_NROWS INT = (SELECT MAX(SongID) FROM tblSONG), @S_Name VARCHAR(50)
WHILE @NROWS > 0
BEGIN
    DECLARE @PKs_Valid INT = 0
    WHILE @PKs_Valid <> 1
    BEGIN
        -- get artist information
        DECLARE @A_Valid INT = 0
        WHILE @A_Valid <> 1
        BEGIN 
            SET @A_PK = RAND() * @A_NROWS + 1
            IF EXISTS (SELECT * FROM tblARTIST WHERE ArtistID = @A_PK)
                SET @A_Valid = 1
            ELSE
                SET @A_Valid = 0
        END
        SET @A_F = (SELECT ArtistFname FROM tblARTIST WHERE ArtistID = @A_PK)
        SET @A_L = (SELECT ArtistLname FROM tblARTIST WHERE ArtistID = @A_PK)
        SET @A_DOB = (SELECT ArtistDOB FROM tblARTIST WHERE ArtistID = @A_PK)
        -- get the song information
        DECLARE @S_Valid INT = 0
        WHILE @S_Valid <> 1
        BEGIN
            SET @S_PK = RAND() * @S_NROWS + 1
            IF EXISTS (SELECT * FROM tblSONG WHERE SongID = @S_PK)
                SET @S_Valid = 1
            ELSE
                SET @S_Valid = 0
        END
        SET @S_Name = (SELECT SongName FROM tblSONG WHERE SongID = @S_PK)
        -- check whether or not this is a valid comparison
        IF EXISTS (SELECT * FROM tblARTIST_SONG WHERE ArtistID = @A_PK AND SongID = @S_PK)
            SET @PKs_Valid = 0
        ELSE
            SET @PKs_Valid = 1
    END
    -- execute transaction
    EXEC INSERT_tblARTIST_SONG
    @ArtistFname = @A_F,
    @ArtistLname = @A_L,
    @ArtistDOB = @A_DOB,
    @SongName = @S_Name
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblARTIST_SONG 5000
-- populate album
GO
CREATE PROCEDURE SYNTX_INSERT_tblALBUM
@NROWS INT
AS
DECLARE @AT_PK INT, @AT_NROWS INT = (SELECT MAX(AlbumTypeID) FROM tblALBUM_TYPE), @AT_Name VARCHAR(50)
DECLARE @A_Name VARCHAR(50), @A_Date DATE
WHILE @NROWS > 0
BEGIN
    -- get the album type information
    DECLARE @AT_Valid INT = 0
    WHILE @AT_Valid <> 1
    BEGIN
        SET @AT_PK = RAND() * @AT_NROWS + 1
        IF EXISTS (SELECT * FROM tblALBUM_TYPE WHERE AlbumTypeID = @AT_PK)
            SET @AT_Valid = 1
        ELSE
            SET @AT_Valid = 0
    END
    SET @AT_Name = (SELECT AlbumTypeName FROM tblALBUM_TYPE WHERE AlbumTypeID = @AT_PK)
    -- get the album information
    DECLARE @A_Valid INT = 0
    WHILE @A_Valid <> 1
    BEGIN
        SET @A_Name = 'Album #' + CAST(CAST(RAND() * POWER(10, 5) AS INT) AS CHAR(5))
        IF EXISTS (SELECT * FROM tblALBUM WHERE AlbumName = @A_Name)
            SET @A_Valid = 0
        ELSE
            SET @A_Valid = 1
    END
    -- get the album release date
    SET @A_Date = DATEADD(DAY, -1 * RAND() * 365 * 50, GETDATE())
    -- execute transaction
    EXEC INSERT_tblALBUM
    @AlbumName = @A_Name,
    @AlbumTypeName = @AT_Name,
    @AlbumDescription = NULL,
    @AlbumReleaseDate = @A_Date
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblALBUM 2000
-- populate song genre
GO
CREATE PROCEDURE SYNTX_INSERT_tblSONG_GENRE
@NROWS INT
AS
DECLARE @S_PK INT, @S_NROWS INT = (SELECT MAX(SongID) FROM tblSONG), @S_Name VARCHAR(50)
DECLARE @G_PK INT, @G_NROWS INT = (SELECT MAX(GenreID) FROM tblGENRE), @G_Name VARCHAR(50)
WHILE @NROWS > 0
BEGIN
    -- get the song information
    DECLARE @S_Valid INT = 0
    WHILE @S_Valid <> 1
    BEGIN
        SET @S_PK = RAND() * @S_NROWS + 1
        IF EXISTS (SELECT * FROM tblSONG WHERE SongID = @S_PK)
            SET @S_Valid = 1
        ELSE
            SET @S_Valid = 0
    END
    SET @S_Name = (SELECT SongName FROM tblSONG WHERE SongID = @S_PK)
    -- get the genre information with a bias for lower PKs based on differential bias system through COF logic
    DECLARE @G_Valid INT = 0
    WHILE @G_Valid <> 1
    BEGIN
        SET @G_PK = RAND() * @G_NROWS + 1
        IF EXISTS (SELECT * FROM tblGENRE WHERE GenreID = @G_PK)  -- initial test for if it's in the genre table
        BEGIN
            DECLARE @PERC INT = RAND() * 100
            IF @PERC >= 90  -- 10% of the time bias towards a very low PK
            BEGIN
                IF @G_PK / @G_NROWS <= 0.1  -- within the top 10% by PK
                    SET @G_Valid = 1
                ELSE
                    SET @G_Valid = 0
            END
            ELSE
            BEGIN
                IF @PERC >= 65  -- another 25% of the time create a top 25% PK
                BEGIN
                    IF @G_PK / @G_NROWS <= 0.25  -- within the top 25% by PK
                        SET @G_Valid = 1
                    ELSE
                        SET @G_Valid = 0
                END
                ELSE  -- the rest of the time
                    SET @G_Valid = 1
            END
        END
        ELSE
            SET @G_Valid = 0
    END
    SET @G_Name = (SELECT GenreName FROM tblGENRE WHERE GenreID = @G_PK)
    -- do the actual execution
    EXEC INSERT_tblSONG_GENRE
    @SongName = @S_Name,
    @GenreName = @G_Name
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblSONG_GENRE 3000
-- populate song album
GO
CREATE PROCEDURE SYNTX_INSERT_tblSONG_ALBUM
@NROWS INT
AS
DECLARE @S_PK INT, @S_NROWS INT = (SELECT MAX(SongID) FROM tblSONG), @S_Name VARCHAR(50)
DECLARE @A_PK INT, @A_NROWS INT = (SELECT MAX(AlbumID) FROM tblALBUM), @A_Name VARCHAR(50)
WHILE @NROWS > 0
BEGIN
    DECLARE @PKs_Valid INT = 0  -- we want to make sure the same album doesn't assigned the same song
    WHILE @PKs_Valid <> 1
    BEGIN
        -- get the song information
        DECLARE @S_Valid INT = 0
        WHILE @S_Valid <> 1
        BEGIN
            SET @S_PK = RAND() * @S_NROWS + 1
            IF EXISTS (SELECT * FROM tblSONG WHERE SongID = @S_PK)
                SET @S_Valid = 1
            ELSE
                SET @S_Valid = 0
        END
        SET @S_Name = (SELECT SongName FROM tblSONG WHERE SongID = @S_PK)
        -- get the album information
        DECLARE @A_Valid INT = 0
        WHILE @A_Valid <> 1
        BEGIN
            SET @A_PK = RAND() * @A_NROWS + 1
            IF EXISTS (SELECT * FROM tblALBUM WHERE AlbumID = @A_PK)
                SET @A_Valid = 1
            ELSE
                SET @A_Valid = 0
        END
        SET @A_Name = (SELECT AlbumName FROM tblALBUM WHERE AlbumID = @A_PK)
        -- test whether or not the pks are valid
        IF EXISTS (SELECT * FROM tblSONG_ALBUM WHERE AlbumID = @A_PK AND SongID = @S_PK)
            SET @PKs_Valid = 0
        ELSE
            SET @PKs_Valid = 1
    END
    -- perform the actual execution
    EXEC INSERT_tblSONG_ALBUM
    @SongName = @S_Name,
    @AlbumName = @A_Name
    SET @NROWS = @NROWS - 1
END
GO
EXEC SYNTX_INSERT_tblSONG_ALBUM 20000
-- populate song lineup type
INSERT INTO tblSONG_LINEUP_TYPE (SongLineupTypeName)
VALUES ('Encore'), ('Standard'), ('Preview')
-- populate song lineup
GO
CREATE PROCEDURE SYNTX_tblSONG_LINEUP
@NROWS INT
AS
DECLARE @S_PK INT, @S_NROWS INT = (SELECT MAX(SongID) FROM tblSONG), @S_Name VARCHAR(50)
DECLARE @C_PK INT, @C_NROWS INT = (SELECT MAX(ConcertID) FROM tblCONCERT), @C_Name VARCHAR(50)
DECLARE @SLT_PK INT, @SLT_NROWS INT = (SELECT MAX(SongLineupTypeID) FROM tblSONG_LINEUP_TYPE), @SLT_Name VARCHAR(50)
DECLARE @Duration NUMERIC(8,4)
WHILE @NROWS > 0
BEGIN
    -- get the song lineup type information
    DECLARE @SLT_Valid INT = 0
    WHILE @SLT_Valid <> 1
    BEGIN
        SET @SLT_PK = RAND() * @SLT_NROWS + 1
        IF EXISTS (SELECT * FROM tblSONG_LINEUP_TYPE WHERE SongLineupTypeID = @SLT_PK)
            SET @SLT_Valid = 1
        ELSE
            SET @SLT_Valid = 0
    END
    SET @SLT_Name = (SELECT SongLineupTypeName FROM tblSONG_LINEUP_TYPE WHERE SongLineupTypeID = @SLT_PK)
    DECLARE @NSONGS INT = (SELECT CASE
                                     WHEN @SLT_Name = 'Encore' THEN RAND() * 3 + 1
                                     WHEN @SLT_Name = 'Standard' THEN RAND() * 11 + 5
                                     WHEN @SLT_Name = 'Preview' THEN RAND() * 2 + 1
                                     ELSE NULL
                                  END)
    -- get the concert information
    DECLARE @C_Valid INT = 0
    WHILE @C_Valid <> 1
    BEGIN
        SET @C_PK = RAND() * @C_NROWS + 1
        IF EXISTS (SELECT * FROM tblCONCERT WHERE ConcertID = @C_PK)
            SET @C_Valid = 1
        ELSE
            SET @C_Valid = 0
    END
    SET @C_Name = (SELECT ConcertName FROM tblCONCERT WHERE ConcertID = @C_PK)
    -- loop through the required number of songs
    WHILE @NSONGS > 0 
    BEGIN
        -- get the song
        DECLARE @S_Valid INT = 0
        WHILE @S_Valid <> 1
        BEGIN
            SET @S_PK = RAND() * @S_NROWS + 1
            IF EXISTS (SELECT * FROM tblSONG WHERE SongID = @S_PK)
            BEGIN
                IF EXISTS (SELECT * FROM tblSONG_LINEUP WHERE ConcertID = @C_PK AND SongID = @S_PK)
                    SET @S_Valid = 0
                ELSE
                    SET @S_Valid = 1
            END
            ELSE
                SET @S_Valid = 0
        END
        SET @S_Name = (SELECT SongName FROM tblSONG WHERE SongID = @S_PK)
        -- get duration
        SET @Duration = RAND() * POWER(10,4)
        -- perform the transaction
        EXEC INSERT_tblSONG_LINEUP
        @SongName = @S_Name,
        @ConcertName = @C_Name,
        @SongLineupTypeName = @SLT_Name,
        @Duration = @Duration
        SET @NSONGS = @NSONGS - 1
    END
    SET @NROWS = @NROWS - 1
END