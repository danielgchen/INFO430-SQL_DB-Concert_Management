-- use database
USE INFO_430_Proj_07
-- there wasn't much variation we could identify so we started creating really complex queries that may not have business applications but demonstrate complexity through multiple joins
-- 1. total ticket price by concert types within past five years for VIP tickets
GO
CREATE FUNCTION CC_STP_CT_5PYRS (@PK INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @RET FLOAT = (SELECT SUM(T.Price)
                          FROM tblTICKET T
                          JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
                          JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
                          JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
                          WHERE CC.ConcertDate >= DATEADD(YEAR, -5, GETDATE())
                          AND TT.TicketTypeName = 'VIP'
                          AND CCT.ConcertTypeID = @PK)
    RETURN @RET
END
GO
ALTER TABLE tblCONCERT_TYPE
ADD TotalVIPTicketRevenue
AS (dbo.CC_STP_CT_5PYRS(ConcertTypeID))
-- 2. for international concerts held in stadiums total ticket type revenue
GO
CREATE FUNCTION CC_ICS_ST_PTT (@PK INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @RET FLOAT = (SELECT SUM(T.Price)
                          FROM tblTICKET T
                          JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
                          JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
                          JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
                          JOIN tblVENUE V ON V.VenueID = CC.VenueID
                          JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
                          WHERE TT.TicketTypeID = @PK
                          AND VT.VenueTypeName = 'Stadium'
                          AND CCT.ConcertTypeName = 'International')
    RETURN @RET
END
GO
ALTER TABLE tblTICKET_TYPE
ADD TotalInternationalStadiumTicketRevenue
AS (dbo.CC_ICS_ST_PTT(TicketTypeID))
-- 3. revenue by venue for VIP ticket types and for larger concerts
GO
CREATE FUNCTION CC_VIP_LRGC_PVNE (@PK INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @RET FLOAT = (SELECT SUM(T.Price)
                          FROM tblTICKET T
                          JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
                          JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
                          JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
                          JOIN tblVENUE V ON V.VenueID = CC.VenueID
                          WHERE V.VenueID = @PK
                          AND TT.TicketTypeName = 'VIP'
                          AND CCT.ConcertTypeName NOT IN ('Family', 'Neighborhood', 'City'))
    RETURN @RET
END
GO
ALTER TABLE tblVENUE
ADD TotalVIPLargeConcertTicketRevenue
AS (dbo.CC_VIP_LRGC_PVNE(VenueID))
-- 4. how many songs of genre 'Rock' and 'Jazz' are there for each lineup type song type that were played for over 1 minute (60 seconds)
GO
CREATE FUNCTION CC_RKJZ_60S_PSLT (@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(*)
                          FROM tblSONG_LINEUP_TYPE SLT
                          JOIN tblSONG_LINEUP SL ON SL.SongLineupTypeID = SLT.SongLineupTypeID
                          JOIN tblSONG S ON S.SongID = SL.SongID
                          JOIN tblSONG_GENRE SG ON SG.SongID = S.SongID
                          JOIN tblGENRE G ON G.GenreID = SG.GenreID
                          WHERE G.GenreName IN ('Rock', 'Jazz')
                          AND SL.Duration > 60
                          AND SLT.SongLineupTypeID = @PK)
    RETURN @RET
END
GO
ALTER TABLE tblSONG_LINEUP_TYPE
ADD RockOrJazzSongOverMinuteCount
AS (dbo.CC_RKJZ_60S_PSLT(SongLineupTypeID))
-- 5. number of concerts with customers who are stakeholders for each song if they have also been played as encore
GO
CREATE FUNCTION CC_CSTKE_NUMCC_ENC_PS (@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(DISTINCT(CC.ConcertID))
                          FROM tblCONCERT CC
                          JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
                          JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID
                          JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
                          JOIN tblSONG_LINEUP SL ON SL.ConcertID = CC.ConcertID
                          JOIN tblSONG_LINEUP_TYPE SLT ON SL.SongLineupTypeID = SLT.SongLineupTypeID
                          JOIN tblSONG S ON S.SongID = SL.SongID
                          WHERE SLT.SongLineupTypeName = 'Encore'
                          AND S.SongID = @PK
                          AND CT.CustomerTypeName = 'Stakeholder')
    RETURN @RET
END
GO
ALTER TABLE tblSONG
ADD StakeholderEncoreConcertCount
AS (dbo.CC_CSTKE_NUMCC_ENC_PS(SongID))
-- 6. for each product count the number of concerts it has been sold at where the concert has had a preview song and been national or international
GO
CREATE FUNCTION CC_INTNATCC_PREVSNG_PPRDT (@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(DISTINCT(CC.ConcertID))
                          FROM tblCONCERT CC
                          JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
                          JOIN tblSONG_LINEUP SL ON SL.ConcertID = CC.ConcertID
                          JOIN tblSONG_LINEUP_TYPE SLT ON SLT.SongLineupTypeID = SL.SongLineupTypeID
                          JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
                          JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
                          JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
                          WHERE P.ProductID = @PK
                          AND CCT.ConcertTypeName IN ('National', 'International')
                          AND SLT.SongLineupTypeName = 'Preview')
    RETURN @RET
END
GO
ALTER TABLE tblPRODUCT
ADD NationalInternationalPreviewConcertCount
AS (dbo.CC_INTNATCC_PREVSNG_PPRDT(ProductID))
-- 7. total amount spent on autographs per customer when they have also bought a ticket of type special or standard and the concert was in a restaurant or community center
GO
CREATE FUNCTION CC_ATGPH_SPCSTDT_RESCC_PC (@PK INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @RET FLOAT = (SELECT SUM(TP.Quantity * P.ProductCurrentPrice)
                          FROM tblVENUE_TYPE VT
                          JOIN tblVENUE V ON V.VenueTypeID = VT.VenueTypeID
                          JOIN tblCONCERT CC ON CC.VenueID = V.VenueID
                          JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
                          JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
                          JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
                          JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
                          JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
                          JOIN tblCUSTOMER C ON C.CustomerID = T.CustomerID
                          WHERE PT.ProductTypeName = 'Autograph'
                          AND VT.VenueTypeName IN ('Restaurant', 'Community Center')
                          AND TT.TicketTypeName IN ('Special', 'Standard')
                          AND C.CustomerID = @PK)
    RETURN @RET
END
GO
ALTER TABLE tblCUSTOMER
ADD TotalSpentOnAutographsForResCommCenterSpecialStd
AS (dbo.CC_ATGPH_SPCSTDT_RESCC_PC(CustomerID))
-- 8. how many city or state concerts have an employed served on that sold at least one food or drink related product
GO
CREATE FUNCTION CC_CYSTATECC_FDP_PE (@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(DISTINCT(CC.ConcertID))
                        FROM tblCONCERT CC
                        JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
                        JOIN tblTICKET T ON T.ConcertID = CC.ConcertID
                        JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
                        JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
                        JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
                        JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID
                        JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID
                        WHERE E.EmployeeID = @PK
                        AND PT.ProductTypeName IN ('Food', 'Drink')
                        AND CCT.ConcertTypeName IN ('City', 'State'))
    RETURN @RET
END
GO
ALTER TABLE tblEMPLOYEE
ADD FoodCityStateConcertCount
AS (dbo.CC_CYSTATECC_FDP_PE(EmployeeID))
