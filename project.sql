CREATE DATABASE ShowmanHouse
ON PRIMARY
(name = 'ShowmanHouse_primary', FILENAME = 'C:\data2\CW_prm.mdf',
size = 20mb, maxsize = 60mb, filegrowth = 5mb),
FILEGROUP ClassWork_FG1
(name = 'ShowmanHouse_FG1_Dat1', FILENAME = 'C:\data2\CW_FG1_Dat1.ndf',
size = 20mb, maxsize = 60mb, Filegrowth = 5mb),
(name = 'ShowmanHouse_FG1_Dat2', FILENAME = 'C:\data2\CW_FG1_Dat2.ndf',
size = 20mb, maxsize = 60mb, Filegrowth = 5mb)
LOG ON
(name = 'ShowmanHouse_Log', FILENAME = 'C:\data2\ShowmanHouse.1df',
size = 10mb, maxsize = 20mb, Filegrowth = 2kb)
GO

---Rerquired schema---
CREATE SCHEMA HumanResources
CREATE SCHEMA Event
CREATE SCHEMA Events
CREATE SCHEMA Management




---CREATING CUSTOMER TABLE---

CREATE TABLE Events.Customers
(
	 CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	 Name CHAR(20) NOT NULL, 
	 ADDRESS VARCHAR(40) NOT NULL,
	 City VARCHAR(10) NOT NULL,
	 State VARCHAR(10) NOT NULL, 
	 Phone INT CHECK(phone like '[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]')NOT NULL
);



----Creating employees table-----
CREATE TABLE HumanResources.Employees
(
	EmployeeID INT PRIMARY KEY IDENTITY(1,1),
	FirstName VARCHAR(40) NOT NULL,
	LastName VARCHAR(40) NOT NULL,
	Address VARCHAR(70) NOT NULL,
	Title VARCHAR(50) CONSTRAINT chktitle CHECK(
	title in('Executive', 'Senior Executive', 'Management Trainee', 'Event Manager', 'Senior Event Manager')),
	Phone VARCHAR (19) CONSTRAINT chkphone CHECK (Phone LIKE(
	'[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'))NOT NULL
)

-------Inserting into HumanResources.Employee ------------

INSERT Humanresources.Employees (FirstName, LastName, Address, title, Phone) VALUES ('Emmanuel', 'Youpy', 'No 2 bode thomans avenue street, surulere', 'Executive', '01-234-8864-772-986')
INSERT Humanresources.Employees (FirstName, LastName, Address, title, Phone) VALUES ('Samuel', 'Guzman', 'Behind GT Bank, No 5, Ikorodu', 'Senior Executive', '01-234-3344-333-386')
INSERT Humanresources.Employees (FirstName, LastName, Address, title, Phone) VALUES ('Gabriella', 'Diob', '18 Avenue str, Badagry', 'Management Trainee',  '01-234-6129-322-453')
INSERT Humanresources.Employees (FirstName, LastName, Address, title, Phone) VALUES ('Anabel', 'Sampson', 'No 1, Agege rd, Ojuelegba', 'Event Manager', '01-234-6489-012-345')
INSERT Humanresources.Employees (FirstName, LastName, Address, title, Phone) VALUES ('Mercy', 'Don', 'First flat, Diamond Str, Ikeja', 'Senior Event Manager', '01-234-6591-333-090') 


SELECT * FROM HumanResources.Employees 




---Creating Table Eventtype---
CREATE TABLE Event.EventType
(
	EventTypeID INT PRIMARY Key IDENTITY(1,1),
	Description VARCHAR(50) Not Null,
	ChargePerPerson MONEY CONSTRAINT cpp 
	CHECK 
	(ChargePerPerson > 0.0)
)


---Inserting into table eventType---
Insert into Event.EventType (Description, ChargePerPerson) values ('UCL', £50)
Insert into Event.EventType (Description, ChargePerPerson) values ('Europa', £30)
Insert into Event.EventType (Description, ChargePerPerson) values ('League', £10)


SELECT * FROM Event.EventType


---Creating Table Events---
CREATE TABLE Management.Events 
(
	EventID INT IDENTITY(1,1) PRIMARY KEY,
	EventName VARCHAR(30) NOT NULL, 
	EventTypeID INT CONSTRAINT EvTyID FOREIGN KEY REFERENCES Event.EventType(EventTypeID), 
	Location VARCHAR(30) NOT NULL,
	StartDate DATETIME NOT NULL, 
	EndDate DATETIME NOT NULL,
	StaffRequired INT NOT NULL,
	EmployeeID INT CONSTRAINT empid FOREIGN KEY REFERENCES HumanResources.Employees(EmployeeID),
	CustomerID INT CONSTRAINT custorid FOREIGN KEY REFERENCES Events.Customers(CustomerID) ,
	NoOfpeople INT CONSTRAINT nop CHECK (NoOfpeople>=50) NOT NULL
)


--INSERT Management.Events (EventName, Location, StartDate, EndDate, StaffRequired, EmployeeID, CustomerID, NoOfpeople)--
	INSERT INTO Management.Events (EventName, Location, StartDate, EndDate, StaffRequired, NoOfpeople) 
	VALUES ('UCL', 'Sincity', 20/2/2010, 22/2/2010, 10, 80)
	INSERT INTO Management.Events (EventName, Location, StartDate, EndDate, StaffRequired, NoOfpeople)
	VALUES ('Street Canival', 'Candelea', 2/2/2011, 5/2/2011, 30, 100)
	INSERT INTO Management.Events (EventName, Location, StartDate, EndDate, StaffRequired, NoOfpeople)
	VALUES ('SoundBlast', 'Stadium', 18/7/2012, 25/67/2012, 20, 90)


	SELECT * FROM Management.Events




CREATE TABLE Management.Paymentmethods
(
Paymentmethodid INT IDENTITY (1,1) PRIMARY KEY,
Description VARCHAR(100) CONSTRAINT ctdescription 
CHECK (description in ('cash','cheque','credit card'))
)


-----insertting into Paymethods table--------------

INSERT Management.paymentmethods(description) VALUES('cash')
INSERT Management.paymentmethods(description) VALUES('cheque')
INSERT Management.paymentmethods(description) VALUES('credit card')

SELECT * FROM Management.Paymentmethods



----Required indexes---
CREATE NONCLUSTERED INDEX Idx1_Payment
ON Management.Payments(EventID)

CREATE NONCLUSTERED INDEX Idx2_Payment
ON Management.Payments(PaymentID)

CREATE NONCLUSTERED INDEX Idx3_Payment
ON Management.Paymentmethods(PaymentMethodID)



---Creating Views---
CREATE VIEW EventPaymentPendingDetails
AS
	SELECT p.PaymentDate, e.EventID, e.EventName, e.EventTypeID, e.Location,
		e.StartDate, e.EndDate, e.StaffRequired, e.CustomerID,
		e.EmployeeID,e.NoOfPeople
	FROM Management.Events e JOIN Management.Payments p ON e.EventID=p.EventID



----Details of staff > 25---

CREATE VIEW eventsafff
AS
SELECT * 
FROM Management.Events
WHERE Staffrequired>25


------Create logins name-----
CREATE LOGIN Willam 
WITH PASSWORD ='0000'

CREATE LOGIN Sam
WITH PASSWORD ='0000'

CREATE LOGIN Chris 
WITH PASSWORD ='0000'

CREATE LOGIN Sara
WITH PASSWORD ='0000'



-----Creating USER----
CREATE USER Willam FOR LOGIN Willam
CREATE USER Sam FOR LOGIN Sam
CREATE USER Chris FOR LOGIN Chris
CREATE USER Sara FOR LOGIN Sara


--Adding Users Roles----
SP_ADDROLE 'administrator'

SP_ADDROLE 'developers'

--Adding Role Member--
SP_ADDROLEMEMBER 'administrator','Chris'
SP_ADDROLEMEMBER 'developers','Willam'
SP_ADDROLEMEMBER 'developers','Sam'
SP_ADDROLEMEMBER 'developers','Sara'


---Permissions---
GRANT ALL
TO administrator

GRANT SELECT , INSERT ,UPDATE,DELETE,EXECUTE,REFERENCES,CREATE VIEW,CREATE TABLE,CREATE RULE,CREATE PROCEDURE,CREATE FUNCTION
TO developers


---creating backup---
BACKUP DATABASE ShowmanHouse 
 TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\ShowmanHouse.bak'



----Store crucial data in encrypted format---
CREATE SYMMETRIC KEY Skey100
WITH ALGORITHM=TRIPLE_DES
ENCRYPTION  BY PASSWORD = 'crusial'

OPEN SYMMETRIC KEY Skey100
DECRYPTION BY PASSWORD ='crusial'
GO	

UPDATE  Event.Customer SET FirstName = EncryptByKey(Key_GUID('SKey100'),FirstName)

CLOSE SYMMETRIC KEY  SKey100 





------Creating Management.payments-----
	CREATE TABLE Management.Payments
(
	PaymentID INT IDENTITY(1,1) CONSTRAINT ctpaymentid PRIMARY KEY(PaymentID),
	EventID INT CONSTRAINT cteventid FOREIGN KEY REFERENCES Management.Events(EventID),
	PaymentAmount MONEY NOT NULL,
	Paymentdate DATETIME NOT NULL,
	CreditCardNumber VARCHAR(5) CONSTRAINT chkcreditcardnumber CHECK(CreditCardNumber LIKE('[0-9][0-9]-[0-9][0-9]')),
	CardHoldersName VARCHAR(30),
	CreditCardExpirydate DATETIME CONSTRAINT chkcreditcardexpdate CHECK (CreditCardExpirydate > GETDATE())NOT NULL,
	PaymentMethodID INT CONSTRAINT ctpaymentmethodid FOREIGN KEY REFERENCES Management.Paymentmethods(PaymentmethodID),
	ChequeNo INT
)

----TRIGER-PaymentDate should <= startdate------
CREATE TRIGGER trgPayDateOne
ON Management.Payments
FOR INSERT ,UPDATE
AS
	BEGIN
		DECLARE @PaymentDate DATETIME
		DECLARE @StartDate DATETIME
		SELECT @PaymentDate=PaymenTDate FROM Inserted 
		SELECT @StartDate=StartDate FROM Management.Events
		IF (@PaymentDate < @StartDate)
		BEGIN
		PRINT 'Event startdate'
		ROLLBACK TRAN
	END
	END




---TRIGGER PaymentDate cannot be less than the current date---
CREATE TRIGGER TrgPaydatecurrentDate
ON [Management].[Payments] 
FOR INSERT , UPDATE
AS
	BEGIN
		DECLARE @Paymentdate DATETIME
		SELECT @Paymentdate=paymentdate
		FROM Inserted 
		IF(@Paymentdate <GETDATE()) 
		BEGIN
		PRINT 'Error'
		ROLLBACK TRAN
	END	
	END

---TRGGER Chequeno--
CREATE TRIGGER ManagementtrgChequenoPayment
ON [Management].[Payments]
FOR INSERT, UPDATE
AS
	BEGIN
		declare @PaymentMethodID INT
		declare @Chequeno INT
		SELECT @PaymentmethodID=PaymentMethodID,@Chequeno=Chequeno FROM Inserted
	END
	IF(@PaymentMethodID=2)
	BEGIN
		IF(@Chequeno IS NULL )
		BEGIN
		PRINT 'Error'
		ROLLBACK TRAN
		END
	END
		ELSE
	BEGIN	
		IF(@Chequeno IS NOT NULL)
		BEGIN		
		UPDATE Management.Payments SET Chequeno=NULL
		END
	END
	

----TRIGGER PaymentAmount = ChargePerPerson * NoOfPeople----
CREATE TRIGGER ManagementTrgPaymentAmount
ON [Management].[Payments]
FOR INSERT
AS
BEGIN
	DECLARE @PaymentAmount MONEY
	DECLARE @Chargeperperson MONEY
	DECLARE @NoOfPeople INT
	DECLARE @NIIT INT
	SELECT @PaymentAmount=PaymentAmount ,
		@Chargeperperson=Chargeperperson,
			@NoOfPeople=NoOfPeople,
	@NIIT=@Chargeperperson*@NoOfPeople 
	FROM [Event].EventType e JOIN Management.Events m ON  e.EventTypeID=m.EventTypeID
	JOIN Inserted ON m.EventID=Inserted.EventID	
			
	IF (@PaymentAmount!=@NIIT)
	BEGIN
	PRINT 'PaymentAmount=Chargeperperson*NoOfpeople'
	ROLLBACK TRAN
	END
	
END



select * from management.payments


