# INFO430 Final Project
## Summary
Relational database hosted on a MS SQL Server to manage two main transactions: **products bought in concerts** and **tickets bought for those concerts**. Employee roles and managerial hierarchy position is also tracked along with the song, artists, and albums played at each concert with their respective genres, types, labels, and producers. Along with tracking concert locations, customer and ticket types, and product price history (due to the volatile nature of prices), our database provides a rich resource and substantial predictive power for OLAP-based analyses in future.
## File Description
All files prefixed with `PROJ_` and suffixed with `.sql` are database construction and modification files. Jupyter Notebooks serve as python based visualizations or methods to speed-up code writing. [Here](https://docs.google.com/presentation/d/1UL4PvbgOnXNts-97n6QuuMhucvEAo3M-hD4OXs8iQAw/edit?usp=sharing) is the presentation associated with this database. Eight computed columns, business rules, and views were created to ensure full group participation. Thus not all may make practical sense and merely serve as demonstrations of complex SQL. Descriptions of each file and their filename are provided below, order should be the order each file is run.

- `PROJ_CreateTables.sql` - SQL to create the database, back up the database, and create all tables using a mix of in-line FKs and `ALTER TABLE` statements
- `PROJ_CreateBusinessRules.sql` - SQL to define eight business rules
- `ProjectStoredProcedureGeneration.ipynb` - Python to create a base version of each stored procedure
- `PROJ_CreateStoredProcedures.sql` - SQL with edited version of stored procedures with nested "getID" sprocs and business rule implementations
- `PROJ_PopulateTables.sql` - SQL to populate each table using a mix of imported CSVs, implicit `INSERT` statements, and synthetic transactions that also check business rules and leverage functions such as `CASE` based random walk and randomization
- `PROJ_CreateComputedColumns.sql` - SQL to create eight computed columns
- `PROJ_CreateViews.sql` - SQL to create views that leverage CTEs and ranking functions
- `ProjectVisualizations.ipynb` - Python to create the visualizations shown in the Google Slides including multi-dimensional-scaling projections for cluster analysis
