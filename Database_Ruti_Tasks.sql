--USE [master];
----------------------------------------------
--CREATE DATABASE RutiCh_Tasks2
--awner : Ruti
--------------------------------------------
USE RutiCh_Tasks2;
---------------------------------------------------------------------
GO
CREATE PROC ResetDatabase_RutiCh_Tasks2
AS
BEGIN
    ---------------------------------------------------------------------------
    ----drop tables
    ---------------------------------------------------------------------------
    DROP TABLE IF EXISTS dbo.Tasks;
    DROP TABLE IF EXISTS dbo.Users;
    DROP TABLE IF EXISTS dbo.[Status];

    ------------------------------------------------------------------------------------------------------
    ----CREATE TABLEs 
    ------------------------------------------------------------------------------------------------------
    CREATE TABLE dbo.Users
    (
        UserID INT IDENTITY(1, 1) NOT NULL,
        UserName NVARCHAR(15)
            UNIQUE NOT NULL,
        [Password] NVARCHAR(10)
            UNIQUE NOT NULL CHECK ([Password] LIKE '________'
                                   OR [Password] LIKE '_________'
                                   OR [Password] LIKE '__________'
                                  ),
        ManagerUser INT,
        CONSTRAINT PK_UsersUserID
            PRIMARY KEY CLUSTERED (UserID ASC) ON [PRIMARY],
        CONSTRAINT FK_UserManagerUser
            FOREIGN KEY (ManagerUser)
            REFERENCES dbo.Users (UserID)
    );

    CREATE TABLE [Status]
    (
        StatusID INT IDENTITY(1, 1),
        StatusName NVARCHAR(50),
		CONSTRAINT PK_StatusStatusID
            PRIMARY KEY CLUSTERED (StatusID ASC) ON [PRIMARY]
    );

    CREATE TABLE Tasks
    (
        TaskID INT IDENTITY(1, 1) NOT NULL,
        CreateDate DATE,
        Task NVARCHAR(2000),
        UserCreate INT,
            --FOREIGN KEY REFERENCES Users (UserID),
        UserDoing INT,
            --FOREIGN KEY REFERENCES Users (UserID),
        [State] INT
            FOREIGN KEY REFERENCES [Status] (StatusID),
        DateChangeStatus DATE,
        ParentTask INT NULL,
            --FOREIGN KEY REFERENCES Users (UserID) ,
        CONSTRAINT PK_TaskTaskID
            PRIMARY KEY CLUSTERED (TaskID ASC) ON [PRIMARY]
    );
    -------------------------------------------------------
    --------insert to tables
    -------------------------------------------------------
    INSERT INTO dbo.Users
    (
        [UserName],
        [Password],
        [ManagerUser]
    )
    VALUES
    ('Manager', '12#6#5*67', NULL),
    ('yosi H', '12345**8', 1),
    ('Meir B', '22AaSDFG', 4),
    ('David S', 'davids234', 2);
    INSERT INTO [Status]
    VALUES
    ('Waiting for treatment'),
    ('in treatment'),
    ('Done'),
    ('Cancel');
    INSERT INTO Tasks
    (
        [CreateDate],
        [Task],
        [UserCreate],
        [UserDoing],
        [State],
        [DateChangeStatus],
        [ParentTask]
    )
    VALUES
    ('2024-03-01', 'call to leaving workers', 1, 2, 2, '2024-03-11', NULL),
    ('2024-03-02', 'call yosi', 1, 2, 3, '2024-03-10', 1),
    ('2024-03-02', 'call dani', 2, 2, 3, '2024-03-10', 1),
    ('2024-03-02', 'call miriam', 1, 2, 2, '2024-03-11', 1),
    ('2024-03-09', 'find miriams phone', 2, 4, 3, '2024-03-11', 4),
    ('2024-03-20', 'orgenize purim party', 2, 4, 2, '2024-03-26', NULL),
    ('2024-03-20', 'Take care of refreshments', 4, 4, 2, '2024-03-25', 6),
    ('2024-03-20', 'print orders', 4, 3, 1, '2024-03-25', 6),
    ('2024-03-20', 'invite a catering', 4, 3, 1, '2024-03-26', 7);
END;
