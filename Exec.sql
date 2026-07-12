----------------------------------------------------------------------------------------------
------Part c: Exec.
----------------------------------------------------------------------------------------------

--1 ✔️🆗
SELECT dbo.RecognizeUserID('Manager', '12#6#5*67');
SELECT dbo.RecognizeUserID('yosi H', '12345**8');
GO

--2 ✔️🆗
SELECT *
FROM dbo.SelectEmployeesUnderReceive1(3);
GO

--3 ✔️🆗
SELECT *
FROM dbo.SelectMisionRec1(1);
GO 
--4 ✔️🆗
SELECT *
FROM dbo.selectFathersOfMision1(3);
GO
--5 ✔️🆗
EXEC dbo.ChangeStatusOfMision @Status = 0, -- int
                              @TaskID = 0; -- int
GO
--6 ✔️🆗
INSERT INTO dbo.Tasks
(
    CreateDate,
    Task,
    UserCreate,
    UserDoing,
    State,
    DateChangeStatus,
    ManagerTask
)
VALUES
(   GETDATE(),                            -- CreateDate - date
    'Talk with orgenization purim party', -- Task - nvarchar(2000)
    2,                                    -- UserCreate - int
    2,                                    -- UserDoing - int
    2,                                    -- State - int
    NULL,                                 -- DateChangeStatus - date
    6                                     -- ManagerTask - int
    );
GO
--7 ✔️🆗
EXEC AddTaskToUser '2024-04-04','Orgenize the documents1',20,10,1,NULL
GO 
--8 ✔️🆗
EXEC AddGanrateMisions 1,'Submit monthly reports'

GO 
--9 ✔️🆗
INSERT INTO dbo.Tasks
(
    CreateDate,
    Task,
    UserCreate,
    UserDoing,
    State,
    DateChangeStatus,
    ManagerTask
)
VALUES
(   GETDATE(), -- CreateDate - date
    'Do Something', -- Task - nvarchar(2000)
    2, -- UserCreate - int
    2, -- UserDoing - int
    2, -- State - int
    NULL, -- DateChangeStatus - date
    NULL  -- ManagerTask - int
    )
GO 
--10 ✔️🆗
SELECT *
FROM dbo.SummaryStatusOfTasksForUser;
GO

--11 ✔️🆗
SELECT *
FROM MisionsOfUser('yosi H', '12345**8');
GO

