CREATE TABLE VoterList
(
voterId VARCHAR(15),
name VARCHAR(15) NOT NULL,
mobileNumber VARCHAR(15) UNIQUE,
age int,
);

INSERT INTO VoterList (voterId,name,mobileNumber,age) VALUES('1656465456','Gowtham','9876543210',20)
INSERT INTO VoterList (voterId,name,mobileNumber,age) VALUES('1656465452','Kowsalya','9876543217',16)
INSERT INTO VoterList (voterId,name,mobileNumber,age) VALUES('1656461453','Priya','9876543014',21)
INSERT INTO VoterList (voterId,name,mobileNumber,age) VALUES('27','Anisha','98765904',131)
INSERT INTO VoterList (voterId,name,mobileNumber,age) VALUES('146453','Monisha','9811543014',21)
DELETE FROM VoterList WHERE voterId = '27';
UPDATE VoterList SET name = 'Kowsika' where voterId = '1656461453';
	SELECT * FROM VOTERLIST

---------------------------------------------------------------------------------------------------------------																				
--VIEWS

CREATE VIEW EligibleList AS
SELECT voterId,name,mobileNumber,age FROM VOTERLIST
WHERE age > 18;

SELECT * FROM EligibleList

---------------------------------------------------------------------------------------------------------------
--TRIGGER FOR INSERT

CREATE TRIGGER AfterInsert
ON VOTERLIST
FOR INSERT
AS
BEGIN
	DECLARE @voterId int
	select @voterId = voterId from inserted
	INSERT INTO TriggerDemo_History (voterid,modifiedAt) VALUES (cast(@voterid as nvarchar(10)),'Inserted at ' + CAST(GETDATE() as varchar(50)))
END

---------------------------------------------------------------------------------------------------------------

DISABLE TRIGGER AfterInsert ON VOTERLIST;  

--TRIGGER FOR DELETE	
CREATE TRIGGER AfterDelete
ON VOTERLIST
FOR DELETE
AS
BEGIN
	DECLARE @voterId int
	select @voterId = voterId from deleted
	INSERT INTO TriggerDemo_History (voterid,modifiedAt) VALUES (cast(@voterid as nvarchar(10)),'Deleted at '+ CAST(GETDATE() as varchar(50)))
END

---------------------------------------------------------------------------------------------------------------
DISABLE TRIGGER AfterDelete ON VOTERLIST;  

CREATE TABLE TriggerDemo_History
(
voterid varchar(10),
modifiedAt varchar(1000)
);

SELECT * FROM TriggerDemo_History
---------------------------------------------------------------------------------------------------
--TRIGGER FOR UPDATE
CREATE TRIGGER AFTERUPDATE
ON VOTERLIST
FOR UPDATE
AS
BEGIN
	DECLARE @voterId VARCHAR(15)
	DECLARE @name VARCHAR(15)
	DECLARE @mobileNumber VARCHAR(15)
	DECLARE @age INT
	DECLARE @oldVoterId VARCHAR(15)
	DECLARE @oldName VARCHAR(15)
	DECLARE @oldMobileNumber VARCHAR(15)
	DECLARE @oldAge INT
	DECLARE @AUDITSTRING varchar(1000)
	SELECT * INTO #TABLE FROM inserted
	WHILE(EXISTS(SELECT voterId FROM #TABLE))
	BEGIN
	SET @AUDITSTRING=''
	SELECT TOP 1 @voterId = voterId, @name = name, @age = age, @mobileNumber = mobileNumber FROM #TABLE
	SELECT @oldVoterId = voterId, @oldName = name, @oldAge = age, @oldMobileNumber = mobileNumber FROM deleted WHERE voterId = @voterId
	SET @AUDITSTRING= @voterId +' HAS CHANGED THEIR'
	IF(@oldVoterId<>@voterId)
		SET @AUDITSTRING=@AUDITSTRING+' ID FROM '+@oldVoterId+' TO ' +@voterId
	IF(@oldname<>@name)
		SET @AUDITSTRING=@AUDITSTRING+' NAME FROM '+@oldName+' TO ' +@name
	IF(@oldage<>@age)
		SET @AUDITSTRING=@AUDITSTRING+' AGE FROM '+@oldAge+' TO ' +@age
	IF(@oldMobileNumber<>@mobileNumber)
		SET @AUDITSTRING=@AUDITSTRING+' ID FROM '+@oldMobileNumber+' TO ' +@mobileNumber

	INSERT INTO TriggerDemo_History VALUES(@voterId,@AUDITSTRING)
	DELETE FROM #TABLE WHERE voterId=@voterId
	END
END


---------------------------------------------------------------------------------------------------------------
--INSTEAD OF INSERT
CREATE trigger WHILEINSERT
on VOTERLIST
Instead Of Insert  
as  
Begin  
Declare @voterId VARCHAR(10)  
Select @voterId = voterId from inserted
DECLARE @age int
SELECT @age = age from INSERTED
if(@age > 100)  
Begin  
Raiserror('Invalid Age (Maxinum Age) . Statement Terminated OK', 16, 1)  
return  
End  
else if(@age < 0)  
Begin  
Raiserror('Invalid Age (Mininum Age) . Statement Terminated OK', 16, 1)  
return  
End   
else 
BEGIN
	INSERT INTO TriggerDemo_History VALUES(@voterId,Cast(getdate()as varchar(50)))
END
--Select voterId,name,mobileNumber,age, @voterId from inserted  
End

---------------------------------------------------------------------------------------------------------------
--INSTEAD OF TRIGGER

ALTER trigger WHILE_DELETE
on VOTERLIST
Instead Of DELETE  
as  
Begin  
Declare @voterId VARCHAR(10)  
Select @voterId = voterId from deleted
DECLARE @age int
SELECT @age = age from DELETED
if(@age > 17)  
Begin  
Raiserror('THIS VOTER IS ELIGIBLE FOR VOTING', 16, 1)  
return  
End   
else 
BEGIN
	INSERT INTO TriggerDemo_History VALUES(@voterId,Cast(getdate()as varchar(50)))
END
--Select voterId,name,mobileNumber,age, @voterId from inserted  
End

---------------------------------------------------------------------------------------------------------------

--USER DEFINED FUNCTIONS
-------------------------------------------------------------------------------------------------------------

ALTER FUNCTION eligiblePersons(
)
RETURNS TABLE
AS
RETURN
    SELECT voterid, name, mobileNumber, age FROM VoterList WHERE age > 17;

-- Executing a table-valued function
SELECT * FROM eligiblePersons();

-------------------------------------------------------------------------------------------------------------


