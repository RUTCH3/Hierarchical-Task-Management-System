# Tasks — Hierarchical Task Management System (T-SQL / SQL Server)

A relational database system for managing tasks within an organizational hierarchy, built entirely in T-SQL for Microsoft SQL Server. The project models a company where managers assign tasks to employees under them, tasks can be broken down into sub-tasks, and task status propagates automatically up the hierarchy.

## Overview

The system is composed of:
- **Database schema** (`Database_Ruti_Tasks.sql`) — table definitions, constraints, and a reset/seed procedure with sample data.
- **Business logic layer** (`Procedure&functions.sql`) — user-defined functions, stored procedures, triggers, and a view implementing the core application logic.
- **Execution script** (`Exec.sql`) — a demonstration script that calls every object in the system with sample inputs.

## Schema

- **Users** — employees, each with an optional `ManagerUser` (self-referencing FK), forming an organizational tree.
- **Status** — lookup table for task states (Waiting for treatment, In treatment, Done, Cancel).
- **Tasks** — each task has a creator, an assignee, a status, and an optional parent task (`ParentTask` / `ManagerTask`), forming a task tree that mirrors the org structure.

## Key Features

### Recursive Hierarchy Traversal (Recursive CTEs)
- `SelectEmployeesUnderReceive1` — returns a manager and every employee under them, at any depth.
- `SelectMisionRec1` — returns a task and all of its sub-tasks, at any depth.
- `selectFathersOfMision1` — returns the full chain of parent tasks above a given task.

### Authentication & Access Control
- `RecognizeUserID` — validates a username/password pair and returns the user's ID (or an error code if invalid).
- `AddTaskToUser` — inserts a new task only if the creator is the assignee or is above the assignee in the management hierarchy; otherwise raises a custom error via `THROW`.

### Automation (Triggers)
- `UpdateStatusOfAllTasks` — after a task is updated, checks whether all of a parent task's sub-tasks are marked "Done," and if so, automatically marks the parent as "Done" too.
- `AddTaskDelete3MisionsDone` — enforces a business rule that limits how many completed ("Done") tasks are retained per user.

### Bulk Operations
- `AddGanrateMisions` — uses a T-SQL cursor to iterate over every employee under a manager and generate the same task for each of them.

### Reporting
- `SummaryStatusOfTasksForUser` — a `PIVOT`-based view summarizing, per user, how many tasks are in each status.
- `MisionsOfUser` — a table-valued function returning a user's tasks along with a computed status indicator (e.g., overdue flags, done/cancelled markers).

## Technologies

- Microsoft SQL Server / T-SQL
- Recursive CTEs
- Scalar & table-valued user-defined functions
- Stored procedures with parameterized logic and custom error handling (`THROW`)
- DML triggers (`AFTER INSERT`, `AFTER UPDATE`)
- Cursors
- `PIVOT` queries and views

## Notes

This was built as an academic database-design project, focused on demonstrating hierarchical data modeling and the range of logic that can be pushed down into the database layer (functions, procedures, triggers, views) rather than the application layer.
