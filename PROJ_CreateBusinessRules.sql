-- use the correct database
USE INFO_430_Proj_07
-- 1. no customers younger than 20 may buy a ticket of type VIP for stadium concerts
GO
CREATE FUNCTION FN_NO_CLT20_VIP_STADIUM ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblTICKET_TYPE TT ON TT.TicketTypeID = T.TicketTypeID
               JOIN tblCONCERT CO ON CO.ConcertID = T.ConcertID
               JOIN tblVENUE V ON V.VenueID = CO.VenueID
               JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
               WHERE DATEADD(YEAR, -20, GETDATE()) < C.CustomerDOB
               AND TT.TicketTypeName = 'VIP'
               AND VT.VenueTypeName = 'Stadium')
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblTICKET WITH NOCHECK
ADD CONSTRAINT CK_NO_CLT20_VIP_STADIUM
CHECK (dbo.FN_NO_CLT20_VIP_STADIUM() = 0)
-- 2. the same customer cannot purchase more than 10 special tickets for an international concert unless they are a stakeholder
GO
CREATE FUNCTION FN_CLT10ST_INT_STAKE ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblCUSTOMER_TYPE CT ON C.CustomerTypeID = CT.CustomerTypeID
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblTICKET_TYPE TT ON T.TicketTypeID = TT.TicketTypeID
               JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
               JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
               WHERE CCT.ConcertTypeName = 'International'
               AND CT.CustomerTypeName <> 'Stakeholder'
               GROUP BY C.CustomerID
               HAVING COUNT(*) > 10)
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblTICKET WITH NOCHECK
ADD CONSTRAINT CK_CLT10ST_INT_STAKE
CHECK (dbo.FN_CLT10ST_INT_STAKE() = 0)
-- 3. a fired employee cannot be assigned to a concert with a stakeholder unless they have worked as a cashier or server in the past 2 years while having a status standard that began at least 5 years ago with an enddate >= today
GO
CREATE FUNCTION FN_NO_FE10YCS_CS2Y5C ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblCUSTOMER_TYPE CT ON C.CustomerTypeID = CT.CustomerTypeID
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblTICKET_TYPE TT ON T.TicketTypeID = TT.TicketTypeID
               JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
               JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID
               JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID
               JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID
               JOIN tblSTATUS S ON S.StatusID = ES.StatusID
               WHERE S.StatusName = 'Fired'
               AND CT.CustomerTypeName = 'Stakeholder'
               AND E.EmployeeID NOT IN (SELECT E.EmployeeID
                                        FROM tblCONCERT CC
                                        JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID
                                        JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID
                                        JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID
                                        JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID
                                        JOIN tblSTATUS S ON S.StatusID = ES.StatusID
                                        WHERE S.StatusName = 'Standard'
                                        AND DATEADD(YEAR, -5, GETDATE()) <= ES.BeginDate
                                        AND ES.EndDate >= GETDATE()
                                        AND CC.ConcertDate >= DATEADD(YEAR, -2, GETDATE())
                                        AND ET.EmployeeTypeName IN ('Cashier', 'Server')))
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblCONCERT_EMPLOYEE WITH NOCHECK
ADD CONSTRAINT CK_NO_FE10YCS_CS2Y5C
CHECK (dbo.FN_NO_FE10YCS_CS2Y5C() = 0)
-- 4. a employee who has ever been suspended can only work family, neighborhood, community, city concerts and only with a type as a cook
GO
CREATE FUNCTION FN_SEWFNCC_ERC ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCONCERT CC
               JOIN tblCONCERT_TYPE CT ON CT.ConcertTypeID = CC.ConcertTypeID
               JOIN tblCONCERT_EMPLOYEE CE ON CE.ConcertID = CC.ConcertID
               JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID
               JOIN tblEMPLOYEE E ON E.EmployeeID = CE.EmployeeID
               JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID
               JOIN tblSTATUS S ON S.StatusID = ES.StatusID
               WHERE S.StatusName = 'Suspended'
               AND (CT.ConcertTypeName NOT IN ('Family', 'Neighborhood', 'Community', 'City')
               OR ET.EmployeeTypeName <> 'Cook'))
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblCONCERT_EMPLOYEE WITH NOCHECK
ADD CONSTRAINT CK_SEWFNCC_ERC
CHECK (dbo.FN_SEWFNCC_ERC() = 0)
-- 5. employees can only take on the role of manager and have a type of artist aide or security guard if they have been a technician in the past three years and have never been fired or suspended in the last 5 years considering begin date
GO
CREATE FUNCTION FN_AASG_PT_FS5Y ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblEMPLOYEE E
               JOIN tblCONCERT_EMPLOYEE CE ON CE.EmployeeID = E.EmployeeID
               JOIN tblEMPLOYEE_ROLE ER ON ER.EmployeeRoleID = CE.EmployeeRoleID
               JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID
               WHERE ET.EmployeeTypeName IN ('Artist Aide', 'Security')
               AND ER.EmployeeRoleName = 'Manager'
               AND E.EmployeeID NOT IN (SELECT E.EmployeeID
                                        FROM tblEMPLOYEE E
                                        JOIN tblCONCERT_EMPLOYEE CE ON CE.EmployeeID = E.EmployeeID
                                        JOIN tblCONCERT C ON C.ConcertID = CE.ConcertID
                                        JOIN tblEMPLOYEE_TYPE ET ON ET.EmployeeTypeID = CE.EmployeeTypeID
                                        WHERE ET.EmployeeTypeName = 'Technician'
                                        AND C.ConcertDate >= DATEADD(YEAR, -3, GETDATE())
                                        AND E.EmployeeID NOT IN (SELECT E.EmployeeID
                                                                    FROM tblEMPLOYEE E
                                                                    JOIN tblEMPLOYEE_STATUS ES ON ES.EmployeeID = E.EmployeeID
                                                                    JOIN tblSTATUS S ON S.StatusID = ES.StatusID
                                                                    WHERE ES.BeginDate >= DATEADD(YEAR, -5, GETDATE())
                                                                    AND S.StatusName IN ('Fired', 'Suspended'))))
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblCONCERT_EMPLOYEE WITH NOCHECK
ADD CONSTRAINT CK_AASG_PT_FS5Y
CHECK (dbo.FN_AASG_PT_FS5Y() = 0)
-- 6. customers under 21 are not allowed to have any alcohol associated with their ticket unless they've spent more than 100 dollars on food
GO
CREATE FUNCTION FN_NO_U21AL_100F ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
               JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
               JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
               WHERE C.CustomerDOB > DATEADD(YEAR, -21, GETDATE())
               AND PT.ProductTypeName = 'Alcohol'
               AND C.CustomerID NOT IN (SELECT C.CustomerID
                                        FROM tblCUSTOMER C
                                        JOIN tblTICKET T ON T.CustomerID = C.CustomerID
                                        JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
                                        JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
                                        JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
                                        WHERE PT.ProductTypeName = 'Food'
                                        GROUP BY C.CustomerID
                                        HAVING SUM(P.ProductCurrentPrice) > 100))
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblTICKET_PRODUCT WITH NOCHECK
ADD CONSTRAINT CK_NO_U21AL_100F
CHECK (dbo.FN_NO_U21AL_100F() = 0)
-- 7. customers aside from VIP and stakeholders are not allowed to spend more than 100 dollars in total for food, drink, or alcohol unless it is a national or international stadium concert
GO
CREATE FUNCTION FN_VS_M100FDA_NI ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
               JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
               JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
               JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
               JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
               WHERE CCT.ConcertTypeName NOT IN ('National', 'International')
               AND CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder')
               AND PT.ProductTypeName IN ('Food', 'Drink', 'Alcohol')
               GROUP BY T.TicketID
               HAVING SUM(P.ProductCurrentPrice * TP.Quantity) > 100)
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblTICKET_PRODUCT WITH NOCHECK
ADD CONSTRAINT CK_VS_M100FDA_NI
CHECK (dbo.FN_VS_M100FDA_NI() = 0)
-- 8. family, neighborhood and community concerts in anywhere but hotels and stadiums cannot sell alcohol to anyone regardless of age unless they are a vip or stakeholder
GO
CREATE FUNCTION FN_NO_ALFNC_UVPHS ()
RETURNS INTEGER
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (SELECT *
               FROM tblCUSTOMER C
               JOIN tblCUSTOMER_TYPE CT ON CT.CustomerTypeID = C.CustomerTypeID
               JOIN tblTICKET T ON T.CustomerID = C.CustomerID
               JOIN tblCONCERT CC ON CC.ConcertID = T.ConcertID
               JOIN tblCONCERT_TYPE CCT ON CCT.ConcertTypeID = CC.ConcertTypeID
               JOIN tblVENUE V ON V.VenueID = CC.VenueID
               JOIN tblVENUE_TYPE VT ON VT.VenueTypeID = V.VenueTypeID
               JOIN tblTICKET_PRODUCT TP ON TP.TicketID = T.TicketID
               JOIN tblPRODUCT P ON P.ProductID = TP.ProductID
               JOIN tblPRODUCT_TYPE PT ON PT.ProductTypeID = P.ProductTypeID
               WHERE VT.VenueTypeName NOT IN ('Hotel', 'Stadium')
               AND CCT.ConcertTypeName IN ('Family', 'Neighborhood', 'Community')
               AND PT.ProductTypeName = 'Alcohol'
               AND CT.CustomerTypeName NOT IN ('VIP', 'Stakeholder'))
        SET @RET = 1
    RETURN @RET
END
GO
ALTER TABLE tblTICKET_PRODUCT WITH NOCHECK
ADD CONSTRAINT CK_NO_ALFNC_UVPHS
CHECK (dbo.FN_NO_ALFNC_UVPHS() = 0)