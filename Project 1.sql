CREATE DATABASE ShowmanHouse
ON PRIMARY
(
    NAME=ShowmanHouse_Data,
    FILENAME='C:\SqlData++\SH_prm.mdf',
    MAXSIZE=50mb,SIZE=20mb,
    FILEGROWTH=2mb
)
LOG ON
(
	NAME=ShowmanHouse_Log,
	FILENAME='C:\SqlData++\SH_prm_1.ndf',
	MAXSIZE=10mb,SIZE=4mb,
	FILEGROWTH=2kb)
Go

sp_help
Drop Database ShowmanHouse

-----creating schema------

USE  ShowmanHouse

CREATE SCHEMA HumanResources
CREATE SCHEMA [Event]
CREATE SCHEMA [Events]
CREATE SCHEMA Management

create table Events.Customer
(
	CustomerID int primary key identity,
	Name char(30) not null,
	Address varchar(50) not null,
	City varchar(30) not null,
	State varchar(30) not null,
	Phone nvarchar(19) check(phone like '[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9]')NOT NULL,
	customertype varchar(20),
);


create table HumanResources.Employee
(
	Employee_ID int primary key identity(1,1),
	First_Name varchar(30) not null,
	Last_Name varchar(30) not null,
	Address varchar(50) not null,
	Title VARCHAR(100) CONSTRAINT chktitle CHECK
(
title in
(
'Executive', 'Senior Executive', 'Management Trainee', 'Event Manager', 'Senior Event Manager'
)
),
Phone VARCHAR (19) CONSTRAINT chkphone CHECK 
(
Phone LIKE
(
'[0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'
)
)
NOT NULL
)

Go

drop table HumanResources.Employee

-------Inserting into HumanResources.Employee ------------

SET IDENTITY_INSERT HumanResources.Employee ON

SET IDENTITY_INSERT HumanResources.Employee OFF

	INSERT Humanresources.Employee (First_Name, Last_Name, Address, title, Phone) VALUES ('James', 'Rodriguez','30 Gerrard Road Lagos','Executive','01-345-6789-012-345')
	INSERT Humanresources.Employee (First_Name, Last_Name, Address, title, Phone) VALUES ('John','Dowd','12 Greene Avenue Ikeja','Senior Executive','01-345-6789-012-345')
	INSERT Humanresources.Employee (First_Name, Last_Name, Address, title, Phone) VALUES ('Mary','Okoro','70 Cole Street Lagos','Management Trainee','01-345-6789-012-345')
	INSERT Humanresources.Employee (First_Name, Last_Name, Address, title, Phone) VALUES ('Jake','Tapper','11 White Street Lagos','Event Manager','01-345-6789-012-345')
	INSERT Humanresources.Employee (First_Name, Last_Name, Address, title, Phone) VALUES ('Mario','Mandzukic','22 Oba Akran Avenue Lagos','Senior Event Manager','01-345-6789-012-345')

SELECT * FROM HumanResources.Employee

Create table Management.Events 
(
	EventID INT IDENTITY(1,1) PRIMARY KEY,
	EventName varchar(99) not null, 
	EventTypeID int constraint fkEventTypeID foreign key references Event.EventType(EventTypeID)Not Null, 
	Location varchar(99) not null,
	StartDate datetime not null, 
	EndDate datetime not null,
	StaffRequired int not null,
	EmployeeID INT CONSTRAINT fkemployeeid FOREIGN KEY REFERENCES HumanResources.Employee(Employee_ID)NOT NULL,
	CustomerID INT CONSTRAINT fkcustomerid FOREIGN KEY REFERENCES EVENTS.Customer(CustomerID) NOT NULL,
	NoOfpeople INT CONSTRAINT chknoofpeople CHECK (NoOfpeople>=50) NOT NULL
)
Go

----------Insert into management.events-------------

	INSERT Management.Events values (EventName, EventTypeID, Location, StartDate, EndDate, Staffrequired, EmployeeID, CustomerID, NoOfpeople)

	INSERT INTO Management.Events (EventName, Location, StartDate, EndDate, StaffRequired, EmployeeID, CustomerID, NoOfpeople) VALUES ('Chat','BN','12/5/2010','11/1/2011',500,1,3,200)
	INSERT INTO Management.Events VALUES ('Show', 1, 'HN', '12/2/2010', '12/11/2011', 100, 2, 4, 60)
	INSERT INTO Management.Events VALUES ('Music', 3, 'TH', '2/2/2010', '11/1/2011', 500, 1, 3, 200)
	INSERT INTO Management.Events VALUES ('Online', 4, 'HN', '12/2/2010', '12/11/2011', 100, 2, 4, 60)

------------Check ----------------

SELECT * FROM Management.Event

1 for Show
2 for Chat
3 for Music
4 for Online


create table Event.EventType
(
	EventTypeID int primary key identity(1,1),
	Description Varchar(100) Not Null,
	ChargePerPerson Money CONSTRAINT chkchargeperperson CHECK 
	(ChargePerPerson>0.0)
)
go

SET IDENTITY_INSERT Event.EventType ON
SET IDENTITY_INSERT Event.EventType OFF

Insert into Event.EventType (Description, ChargePerPerson) values ('Joyful', 2)
Insert into Event.EventType (Description, ChargePerPerson) values ('Sad', 4)
Insert into Event.EventType (Description, ChargePerPerson) values ('Sad', 3)
Insert into Event.EventType (Description, ChargePerPerson) values ('Disappointed', 3)


Select * from Event.EventType



-------creating tables-------

CREATE TABLE Management.Payments
(
	PaymentID INT IDENTITY(1,1) CONSTRAINT pkpaymentid PRIMARY KEY(PaymentID)NOT NULL,
	EventID INT CONSTRAINT fkeventid FOREIGN KEY REFERENCES Management.Events(EventID),
	PaymentAmount MONEY NOT NULL,
	Paymentdate DATETIME NOT NULL,
	CreditCardNumber VARCHAR(5) CONSTRAINT chkcreditcardnumber CHECK(CreditCardNumber LIKE('[0-9][0-9]-[0-9][0-9]')),
	CardHoldersName VARCHAR(40),
	CreditCardExpdate DATETIME CONSTRAINT chkcreditcardexpdate CHECK (CreditCardExpdate>GETDATE())NOT NULL,
	PaymentMethodID INT CONSTRAINT fkpaymentmethodid FOREIGN KEY REFERENCES Management.Paymentmethods(PaymentmethodID) NOT NULL,
	chequeNo INT,

SET IDENTITY_INSERT Management.Payments ON

);
	
----TRIGER-PaymentDate should be less than or equal to the start date of the event.------

CREATE TRIGGER trgPayDate_less_StartDate_Payments
ON [Management].[Payments]
FOR INSERT ,UPDATE
AS
	BEGIN
		DECLARE @PaymentDate DATETIME
		DECLARE @StartDate DATETIME
		SELECT @PaymentDate=PaymentDate FROM Inserted 
		SELECT @StartDate=@StartDate FROM Management.Events
		IF (@PaymentDate < @StartDate)
		BEGIN
		PRINT 'PaymentDate phai nho hon StarDate of the Events'
		ROLLBACK TRAN
	END

-------TRIGGER PaymentDate cannot be less than the current date.----

CREATE TRIGGER Trg_Paydate_cannot_currentDate
ON Management.Payments 
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

---------------TRGGER Chequeno------------------

CREATE TRIGGER [Management].[trgChequeno_Payment] 
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
		UPDATE Managerment.Payments SET Chequeno=NULL
		END
	END
END

-------TRIGGER PaymentAmount = ChargePerPerson * NoOfPeople-----------

CREATE TRIGGER [Management].[TrgPaymentAmount]
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
	FROM [Event].EventTypes e JOIN Management.Events m ON  e.EventTypeID=m.EventTypeID
	JOIN Inserted ON m.EventID=Inserted.EventID	
			
	IF (@PaymentAmount!=@NIIT)
	BEGIN
	PRINT 'PaymentAmount=Chargeperperson*NoOfpeople'
	ROLLBACK TRAN
	END
	
END
	
--------------------insert into Management.Payments --------------------

SET IDENTITY_INSERT HumanResources.Employee ON

SET IDENTITY_INSERT HumanResources.Employee OFF

INSERT Management.Payments (PaymentID, CardHoldersName, PaymentAmount, EventID, PaymentDate,PaymentMethodID,
CreditCardNumber, CreditCardExpdate, Chequeno)
VALUES	(001,'Lucas Billiat', 18, 100,'2/16/2018',3,'09-09','12/22/2018',3)

SET IDENTITY_INSERT HumanResources.Employee OFF

INSERT Management.Payments (PaymentID, CardHoldersName, PaymentAmount, EventID, PaymentDate,PaymentMethodID,
CreditCardNumber,CreditCardExpdate,Chequeno)
VALUES	(002,'Jane Madison', 52, 101,'3/9/2018',3,'09-09','4/30/2018',3)
INSERT Management.Payments (PaymentID,CardHoldersName, PaymentAmount, EventID, PaymentDate,PaymentMethodID,
CreditCardNumber,CreditCardExpdate,Chequeno)
VALUES	(003,'Stylian Petrov', 42, 476,'11/9/2010',2,'11-11','11/15/2010', null)
INSERT Management.Payments (PaymentID,CardHoldersName, PaymentAmount, EventID, PaymentDate,PaymentMethodID,
CreditCardNumber,CreditCardExpdate,Chequeno)
VALUES	(004,'Phil Jones', 32, 144,'10/11/2010',2,'11-11','12/12/2010',1)
INSERT Management.Payments (PaymentID,CardHoldersName, PaymentAmount, EventID, PaymentDate,PaymentMethodID,
CreditCardNumber,CreditCardExpdate,Chequeno)
VALUES	(005,'Michael Schumacher', 22, 144,'10/11/2010',3,'11-11','12/12/2010',1)


USE  ShowmanHouse

CREATE TABLE Management.Paymentmethods
(
paymentmethodid INT IDENTITY PRIMARY KEY,
Description VARCHAR(100) CONSTRAINT chkdescription CHECK (description in ('cash','cheque','credit card'))
)
	
-----insertting into Management.Paymethods--------------

INSERT Management.paymentmethods(description) VALUES('cash')
INSERT Management.paymentmethods(description) VALUES('cheque')
INSERT Management.paymentmethods(description) VALUES('credit card')

SELECT * FROM Management.Paymentmethods

------creating nonclustered index------

CREATE NONCLUSTERED INDEX Index_Payment1
ON Management.Payments(EventID)

CREATE NONCLUSTERED INDEX Index_Payment2
ON Management.Payments(PaymentID)

CREATE NONCLUSTERED INDEX Index_PaymentMethod
ON Management.Paymentmethods(PaymentMethodID)

--------Extracting events details for all the events where the payment is pending---

CREATE VIEW EventPaymentPendingDetails
AS
	SELECT pa.PaymentDate, e.EventID, e.EventName, e.EventTypeID, e.Location,
		e.StartDate, e.EndDate, e.StaffRequired, e.CustomerID,
		e.EmployeeID,e.NoOfPeople
	FROM Management.Events e JOIN Management.Payments pa ON e.EventID=pa.EventID

----Displaying the details of all events where thw staff required is greater than 25------

CREATE VIEW event_safff25
AS
SELECT * 
FROM Management.Events
WHERE Staffrequired>25

-----------------------Create logins name-----------------

USE ShowmanHouse
Go
CREATE LOGIN Willam 
WITH PASSWORD ='123456'

CREATE LOGIN Sam
WITH PASSWORD ='123456'

CREATE LOGIN Chris 
WITH PASSWORD ='123456'

CREATE LOGIN Sara
WITH PASSWORD ='123456'

----------------Creating USER------------------------------

CREATE USER Willam FOR LOGIN Willam
CREATE USER Sam FOR LOGIN Sam
CREATE USER Chris FOR LOGIN Chris
CREATE USER Sara FOR LOGIN Sara

------------Adding Roles--------------

Use ShowmanHouse

Go

SP_ADDROLE 'administrator'

SP_ADDROLE 'developers'

DROP LOGIN Sara

-----------Adding Role Member------------------
SP_ADDROLEMEMBER 'administrator','Chris'
SP_ADDROLEMEMBER 'developers','Willam'
SP_ADDROLEMEMBER 'developers','Sam'
SP_ADDROLEMEMBER 'developers','Sara'

----------Permissions---------

GRANT ALL
TO administrator

GRANT SELECT , INSERT ,UPDATE,DELETE,EXECUTE,REFERENCES,CREATE VIEW,CREATE TABLE,CREATE RULE,CREATE PROCEDURE,CREATE FUNCTION
TO developers

-----creating backup-----

BACKUP DATABASE ShowmanHouse 
 TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\ShowmanHouse.bak'

-------Store crucial data in encrypted format-----

CREATE SYMMETRIC KEY Symkey24
WITH ALGORITHM=TRIPLE_DES
ENCRYPTION  BY PASSWORD = 'thinh'
GO
OPEN SYMMETRIC KEY Symkey24
DECRYPTION BY PASSWORD ='thinh'
GO	
UPDATE  Event.Customer SET FirstName = EncryptByKey(Key_GUID('SymKey24'),FirstName)
Go 
CLOSE SYMMETRIC KEY  SymKey24       

select * from HumanResources.Employee

select * from management.payments



