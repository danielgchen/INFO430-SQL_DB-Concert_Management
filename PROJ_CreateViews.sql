-- use database
USE INFO_430_Proj_07
-- 1. retrieve top 100 artists based on counts of songs for artists (artists ranked)
GO
CREATE VIEW VW_RANK_ARTISTS_ON_GENRE_SONG_COUNT AS 
WITH CTE_Artists (PK, Fname, Lname, DOB, SongCount, CountRank) AS (
    SELECT AR.ArtistID, AR.ArtistFname, AR.ArtistLname, AR.ArtistDOB, COUNT(S.SongID), RANK() OVER (ORDER BY COUNT((S.SongID)) DESC)
    FROM tblARTIST AR
    JOIN tblARTIST_SONG ARS ON ARS.ArtistID = AR.ArtistID
    JOIN tblSONG S ON S.SongID = ARS.SongID
    GROUP BY AR.ArtistID, AR.ArtistFname, AR.ArtistLname, AR.ArtistDOB
)
SELECT *
FROM CTE_Artists
WHERE CountRank <= 100
-- 2. view the most bought products so count for concerts by concert type and show the first five percentiles
GO
CREATE VIEW VW_PERCNPRODS_CONCERTS_BY_CONCERT_TYPE AS
WITH CTE_Concerts (PK, "Concert Name", "Concert Type", "Venue", "Venue Type", "Total Revenue", "Percentile") AS (
    SELECT CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName, SUM(TP.Quantity * P.ProductCurrentPrice), NTILE(100) OVER (PARTITION BY CCT.ConcertTypeName ORDER BY SUM(TP.Quantity * P.ProductCurrentPrice) DESC)
    FROM tblCONCERT CC
    JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
    JOIN tblVENUE V ON V.VenueID = CC.VenueID
    JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
    JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
    JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
    JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
    GROUP BY CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName
)
SELECT *
FROM CTE_Concerts
WHERE Percentile <= 5
-- 3. retrieve customer information for those who tickets in stadiums with the rank of their total ticket revenue (price ranked)
GO
CREATE VIEW VW_CUST_STADIUM_TICKET_REVENUE AS
WITH CTE_Customer (PK, Fname, Lname, DOB, TypeName, Revenue, RevenueRank) AS (
    SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, C.CustomerDOB, CT.CustomerTypeName, SUM(T.Price), DENSE_RANK() OVER (ORDER BY SUM(T.Price) DESC)
    FROM tblCUSTOMER C
    JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
    JOIN tblTICKET T ON T.CustomerID = C.CustomerID
    JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
    JOIN tblVENUE V ON V.VenueID = CC.VenueID
    JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
    WHERE VT.VenueTypeName = 'Stadium' 
    GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname, C.CustomerDOB, CT.CustomerTypeName
)
SELECT *
FROM CTE_Customer
-- 4. rank the total number of employees that have worked for each concert and partition it by venue type
GO
CREATE VIEW VW_EMPLOYEE_COUNT_PER_CONCERT_VENUE_TYPE AS
WITH CTE_Concerts (PK, "Concert Name", "Concert Type", "Venue", "Venue Type", "Employee Count", "Count Rank") AS (
    SELECT CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName, COUNT(DISTINCT(E.EmployeeID)), DENSE_RANK() OVER (PARTITION BY VT.VenueTypeName ORDER BY COUNT(DISTINCT(E.EmployeeID)) DESC)
    FROM tblCONCERT CC
    JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
    JOIN tblVENUE V ON V.VenueID = CC.VenueID
    JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
    JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID
    JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID
    GROUP BY CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName
)
SELECT *
FROM CTE_Concerts
-- 5. rank the total revenue brought in by not food, drink, or alcohol products for each concert for tickets of type not cheap and get the top 10
GO
CREATE VIEW VW_REVENUE_NOTFDA_PRODUCTS_NOTCHP_TICKETS_PER_CONCERT AS
WITH CTE_Concerts (PK, "Concert Name", "Concert Type", "Venue", "Venue Type", "Total Revenue", "Revenue Rank") AS (
    SELECT CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName, SUM(TP.Quantity * P.ProductCurrentPrice), DENSE_RANK() OVER (ORDER BY SUM(TP.Quantity * P.ProductCurrentPrice) DESC)
    FROM tblCONCERT CC
    JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
    JOIN tblVENUE V ON V.VenueID = CC.VenueID
    JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
    JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
    JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
    JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
    JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
    JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
    WHERE PT.ProductTypeName NOT IN ('Food', 'Drink', 'Alcohol')
    AND TT.TicketTypeName <> 'Cheap'
    GROUP BY CC.ConcertID, CC.ConcertName, CCT.ConcertTypeName, V.VenueName, VT.VenueTypeName
)
SELECT *
FROM CTE_Concerts
WHERE "Revenue Rank" <= 10
-- 6. rank the customers by the total number products they bought for concerts that are not family or neighborhood or city and get the top 500 customers ranked (we can't distinguish if people are tied so we say rank <= 500 this is the same logic for RANK functions used above and below)
GO
CREATE VIEW VW_CUST_PRODCOUNT_NOTFNC_CONCERTS AS
WITH CTE_Customer (PK, Fname, Lname, DOB, TypeName, ProductCount, CountRank) AS (
    SELECT C.CustomerID, C.CustomerFname, C.CustomerLname, C.CustomerDOB, CT.CustomerTypeName, SUM(TP.Quantity), RANK() OVER (ORDER BY SUM(TP.Quantity) DESC)
    FROM tblCUSTOMER C
    JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
    JOIN tblTICKET T ON T.CustomerID = C.CustomerID
    JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
    JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
    JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
    JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
    WHERE CCT.ConcertTypeName NOT IN ('Family', 'Neighborhood', 'City')
    GROUP BY C.CustomerID, C.CustomerFname, C.CustomerLname, C.CustomerDOB, CT.CustomerTypeName
)
SELECT *
FROM CTE_Customer
WHERE CountRank <= 500
-- 7. select the top 1 percentile and bottom 100th percentile of employees based on the total revenue brought in by products their concert they worked at sold
GO
CREATE VIEW VW_EXTREME_EMPLOYEE_RELATED_CONCERT_REVENUE AS
WITH CTE_Employee (PK, Fname, Lname, DOB, ProductRevenue, RevenuePercentile) AS (
    SELECT E.EmployeeID, E.EmployeeFname, E.EmployeeLname, E.EmployeeDOB, SUM(TP.Quantity), NTILE(100) OVER (ORDER BY SUM(TP.Quantity) DESC)
    FROM tblEMPLOYEE E
    JOIN tblCONCERT_EMPLOYEE CE ON CE.EmployeeID = E.EmployeeID
    JOIN tblCONCERT CC ON CC.ConcertID = CE.ConcertID
    JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
    JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
    JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
    GROUP BY E.EmployeeID, E.EmployeeFname, E.EmployeeLname, E.EmployeeDOB
)
SELECT *
FROM CTE_Employee
WHERE RevenuePercentile = 1
OR RevenuePercentile = 100
-- 8. get the top 0.1 percentile of songs based on the times they were played on hotels, stadiums and restuarants and national and international concerts
GO
CREATE VIEW VW_HSR_AND_NATINT_CONCERT_PLAY_NUMBER_PER_SONG AS
WITH CTE_Song (PK, SongName, PlayNumber, CountPercentile) AS (
    SELECT S.SongID, S.SongName, COUNT(*), NTILE(1000) OVER (ORDER BY COUNT(*) DESC)
    FROM tblSONG S
    JOIN tblSONG_LINEUP SL ON SL.SongID = S.SongID
    JOIN tblCONCERT CC ON SL.ConcertID = CC.ConcertID
    JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
    JOIN tblVENUE V ON V.VenueID = CC.VenueID
    JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
    WHERE CCT.ConcertTypeName IN ('National', 'International')
    AND VT.VenueTypeName IN ('Hotel', 'Stadium', 'Restaurant')
    GROUP BY S.SongID, S.SongName
)
SELECT *
FROM CTE_Song
WHERE CountPercentile = 1