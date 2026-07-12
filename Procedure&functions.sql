USE RutiCh_Tasks2;
GO
EXEC dbo.ResetDatabase_RutiCh_Tasks2;
GO
-------------------------------------------------------------------------
-----1. this func recognize the user.✓🆗
-------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.RecognizeUserID
(
    @UserName NVARCHAR(20),
    @Password NVARCHAR(10)
)
RETURNS INT
AS
BEGIN
    IF @UserName NOT IN
       (
           SELECT UserName FROM dbo.Users
       )
        RETURN 0;
    IF @Password !=
    (
        SELECT Password FROM dbo.Users WHERE @UserName = UserName
    )
        RETURN -1;
    RETURN
    (
        SELECT UserID FROM dbo.Users WHERE @UserName = UserName
    );
END;
GO

--------------------------------------------------------------------------
------2. this func selecting all the employees under this employee.✓🆗
---------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.SelectEmployeesUnderReceive1
(
    @UserID INT
)
RETURNS @Tbl TABLE
(
    UserID INT,
    UserName NVARCHAR(20)
)
AS
BEGIN;
    WITH RecUser
    AS (SELECT UserID,
               UserName
        FROM dbo.Users
        WHERE UserID = @UserID
        UNION ALL
        SELECT dbo.Users.UserID,
               dbo.Users.UserName
        FROM dbo.Users
            INNER JOIN RecUser
                ON dbo.Users.ManagerUser = RecUser.UserID)
    INSERT INTO @Tbl
    SELECT *
    FROM RecUser;
    RETURN;
END;
GO

--------------------------------------------------------------------------
------3. this func bring a mision and all here subtasks.✓🆗
---------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.SelectMisionRec1
(
    @TaskID INT
)
RETURNS @Tbl TABLE
(
    TaskID INT,
    Task NVARCHAR(2000)
)
AS
BEGIN;
    WITH RecTask
    AS (SELECT TaskID,
               Task
        FROM dbo.Tasks
        WHERE TaskID = @TaskID
        UNION ALL
        SELECT dbo.Tasks.TaskID,
               dbo.Tasks.Task
        FROM dbo.Tasks
            JOIN RecTask
                ON dbo.Tasks.ManagerTask = RecTask.TaskID)

    INSERT INTO @Tbl
    SELECT *
    FROM RecTask;
    RETURN;
END;
GO

---------------------------------------------------------------
------4. this func bring a mision and all here fathers.✔️🆗
---------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.selectFathersOfMision1
(
    @TaskID INT
)
RETURNS @Tbl TABLE
(
    ManagerTask INT,
    Task NVARCHAR(2000)
)
AS
BEGIN;
    WITH RecTask
    AS (SELECT ManagerTask,
               Task
        FROM dbo.Tasks
        WHERE TaskID = @TaskID
        UNION ALL
        SELECT t.ManagerTask,
               t.Task
        FROM dbo.Tasks t
            JOIN RecTask rt
                ON rt.ManagerTask = t.TaskID)
    INSERT INTO @Tbl
    SELECT *
    FROM RecTask;
    RETURN;
END;
GO

--------------------------------------------------------------------------
------5. this proc change the status of the mision and the changeDate.✓🆗
---------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE ChangeStatusOfMision
    @Status INT,
    @TaskID INT
AS
UPDATE dbo.Tasks
SET State = @Status
WHERE @TaskID = TaskID;
GO

------------------------------------------------------------------------------------------
------6. this trigger check if all the submisions are done and change there state.✔️🆗
------------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.UpdateStatusOfAllTasks
ON dbo.Tasks
AFTER UPDATE
AS
;
BEGIN
    DECLARE @Manager INT =
            (
                SELECT Inserted.ManagerTask FROM inserted
            );
    IF ((SELECT Inserted.State FROM inserted) = 3)
    BEGIN
        IF (3=ALL (SELECT State FROM Tasks WHERE ManagerTask = @Manager)) EXEC ChangeStatusOfMision @Manager, 3;
    END;
END;
GO


----------------------------------------------------------------------------------------------------------
------7. this proc add a task to tasks when the DoingUser is the CreateUser or under the CreateUser.✔️🆗
----------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC AddTaskToUser
    @CreateDate DATE,
    @Task NVARCHAR(2000),
    @UserCreate INT,
    @UserDoing INT,
    @State INT,
    @ManagerTask INT
AS
BEGIN
    IF @UserCreate IN
       (
           SELECT UserId FROM dbo.SelectEmployeesUnderReceive(@UserCreate)
       )
       OR @UserDoing = @UserCreate
    BEGIN
        INSERT INTO dbo.Tasks
        (
            CreateDate,
            Task,
            UserCreate,
            UserDoing,
            State,
            ManagerTask
        )
        VALUES
        (   @CreateDate,         -- CreateDate - date
            @Task,               -- Task - nvarchar(2000)
            @UserCreate,         -- UserCreate - int
            @UserDoing,          -- UserDoing - int
            @State, @ManagerTask -- ManagerUser - int
            );
    END;
    ELSE IF @UserCreate NOT IN
            (
                SELECT UserId FROM dbo.SelectEmployeesUnderReceive(@UserCreate)
            )
        THROW 50010, 'Cannot find a user with this ID.', 1;
    ELSE
        THROW 50011, 'You cannot create a task for user who not under you.', 1;
END;
GO

----------------------------------------------------------------------------------------------
------8. this proc add genarate mision for all the users.✓🆗
----------------------------------------------------------------------------------------------
CREATE OR ALTER PROC AddGanrateMisions
    @ManagerID INT,
    @Task NVARCHAR(2000)
AS
BEGIN
    DECLARE Cursor1 CURSOR FOR SELECT UserId FROM dbo.SelectEmployeesUnderReceive(@ManagerID);
    DECLARE @point INT;
    OPEN Cursor1;

    FETCH NEXT FROM Cursor1
    INTO @point;
    WHILE @@FETCH_STATUS = 0
    BEGIN
	EXEC dbo.AddTaskToUser @CreateDate = '2024-04-04', -- date
	                       @Task = @Task,              -- nvarchar(2000)
	                       @UserCreate = @ManagerID,   -- int
	                       @UserDoing = @point,        -- int
	                       @State = 1,                 -- int
	                       @ManagerTask = NULL         -- int     
        --EXEC (@point);
        FETCH NEXT FROM Cursor1
        INTO @point;
    END;
    CLOSE Cursor1;
    DEALLOCATE Cursor1;
END;
GO


----------------------------------------------------------------------------------------------------
------9. this trigger add make sure that there is only 3 tasks at Tasks with state 'Done'(3). ✓🆗
----------------------------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.AddTaskDelete3MisionsDone
ON dbo.Tasks
AFTER INSERT
AS
BEGIN
    DELETE FROM Tasks
    WHERE 3<ANY
    (
        SELECT ROW_NUMBER() OVER (PARTITION BY Tasks.State ORDER BY Tasks.CreateDate DESC) AS numRows
        FROM Tasks
        WHERE UserDoing =
        (
            SELECT Inserted.UserDoing FROM inserted
        )
              AND State = 3
    );
END;
GO



----------------------------------------------------------------------------------------------
------10. this view sum the Tasks for every user About the State.✓🆗
----------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW SummaryStatusOfTasksForUser
AS
SELECT *
FROM
(
    SELECT UserName,
           State,
           StatusName
    FROM dbo.Tasks
        JOIN dbo.Status
            ON Status.StatusID = Tasks.State
        JOIN dbo.Users
            ON UserDoing = UserID
) AS TaskStatus
PIVOT
(
    COUNT(State)
    FOR [StatusName] IN ([Waiting for treatment], [in treatment], [Done], [Cancel])
) AS TaAndSta;

GO

----------------------------------------------------------------------------------------------
------11. this function select the details of the tasks for the user and here state.✓🆗
----------------------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION MisionsOfUser
(
    @UserName NVARCHAR(20),
    @Password NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN SELECT t.TaskID,
              t.CreateDate,
              t.Task,
              t.UserCreate,
              t.UserDoing,
              t.State,
              t.DateChangeStatus,
              t.ManagerTask,
              CASE
                  WHEN (
                           t.State = 1
                           OR t.State = 2
                       )
                       AND DATEDIFF(MONTH, t.CreateDate, GETDATE()) > 1 THEN
                      '!!!'
                  WHEN (
                           t.State = 1
                           OR t.State = 2
                       )
                       AND DATEDIFF(MONTH, t.CreateDate, GETDATE()) > 1 THEN
                      '!'
                  WHEN t.State = 3 THEN
                      'V'
                  WHEN t.State = 4 THEN
                      'X'
              END AS STATUS1
       FROM dbo.Tasks t
           JOIN Users u
               ON t.UserDoing = u.UserID
       WHERE dbo.RecognizeUserID(@UserName, @Password) = u.UserID;
GO
