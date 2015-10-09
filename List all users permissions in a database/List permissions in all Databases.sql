
-- Script modified by RicardoB. Original runs over a single database.

-- Create Variable Table
DECLARE @List TABLE (ID INT IDENTITY(1,1),
	Script VARCHAR(50),
	DB VARCHAR(50),
	Name VARCHAR(100),
	[Type] VARCHAR(20),
	RoleName VARCHAR(50),
	ObjectName varchar(100),
	[SELECT] varchar(5),
	[INSERT] varchar(5),
	[UPDATE] varchar(5),
	[DELETE] varchar(5),
	[EXECUTE] varchar(5)--,
	)

-- The script does NOT consider Deny
Declare @DB VARCHAR(30)
Set @DB = db_name()


DECLARE @DB_Name varchar(100) 
DECLARE @Command nvarchar(4000)
DECLARE database_cursor CURSOR FOR 
SELECT name 
FROM MASTER.sys.sysdatabases

OPEN database_cursor

FETCH NEXT FROM database_cursor INTO @DB_Name

WHILE @@FETCH_STATUS = 0 
BEGIN 
     SELECT @Command = ' SELECT ''Direct permission'' AS Script, ''' + @DB_Name + ''' AS DB, sl.name as Name ' +
', CASE WHEN isSQLRole = 1 THEN ''Role'' WHEN issqluser = 1 THEN ''SQL User'' WHEN sysusers.isntgroup = 1 THEN ''NT Group'' WHEN sysusers.isntuser = 1 THEN ''NT User'' ELSE ''<n/a>'' END AS Type ' +
', ''(n/a)'' as RoleName ' +
', sysobjects.name as objectname ' +
', CASE WHEN sysprotects_1.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''SELECT'', CASE WHEN sysprotects_2.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''INSERT'' ' +
', CASE WHEN sysprotects_3.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''UPDATE'', CASE WHEN sysprotects_4.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''DELETE'' ' +
', CASE WHEN sysprotects_5.action is null THEN CASE WHEN sysobjects.xtype IN (''U'', ''V'') THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''EXECUTE'' ' +
'from [' + @DB_Name + '].dbo.sysusers ' +
'join master.dbo.syslogins sl on sl.sid = sysusers.sid ' +
'join master.sys.server_principals p on p.sid =  sl.sid and sl.denylogin = 0 and sl.hasaccess = 1 and p.is_disabled = 0 ' +
'full join [' + @DB_Name + '].dbo.sysobjects on ( sysobjects.xtype in ( ''P'', ''U'', ''V'' ) and sysobjects.Name NOT LIKE ''dt%'' ) ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_1  on sysprotects_1.uid = sysusers.uid and sysprotects_1.id = sysobjects.id and sysprotects_1.action = 193 and sysprotects_1.protecttype in ( 204, 205 ) ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_2  on sysprotects_2.uid = sysusers.uid and sysprotects_2.id = sysobjects.id and sysprotects_2.action = 195 and sysprotects_2.protecttype in ( 204, 205 ) ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_3  on sysprotects_3.uid = sysusers.uid and sysprotects_3.id = sysobjects.id and sysprotects_3.action = 197 and sysprotects_3.protecttype in ( 204, 205 ) ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_4  on sysprotects_4.uid = sysusers.uid and sysprotects_4.id = sysobjects.id and sysprotects_4.action = 196 and sysprotects_4.protecttype in ( 204, 205 ) ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_5  on sysprotects_5.uid = sysusers.uid and sysprotects_5.id = sysobjects.id and sysprotects_5.action = 224 and sysprotects_5.protecttype in ( 204, 205 ) ' +
'where (sysprotects_1.action is not null or sysprotects_2.action is not null or sysprotects_3.action is not null or sysprotects_4.action is not null or sysprotects_5.action is not null) ' +
'AND (isSQLRole <> 1 OR isSQLRole IS NULL) ' 

--print @Command

INSERT INTO @List (Script, DB, Name, [Type], RoleName, ObjectName, [SELECT], [INSERT], [UPDATE], [DELETE], [EXECUTE])
 EXEC sp_executesql @Command

SELECT @Command = 'select ''Through Role Permission'' AS Script, ''' + @DB_Name + ''' AS DB, sl.name as Name ' +
', CASE WHEN u.isSQLRole = 1 THEN ''Role'' WHEN u.issqluser = 1 THEN ''SQL User'' WHEN u.isntgroup = 1 THEN ''NT Group'' WHEN u.isntuser = 1 THEN ''NT User'' ELSE ''<n/a>'' END AS Type ' +
', sysusers.name as RoleName ' +
', sysobjects.name as objectname  ' +
', CASE WHEN sysprotects_1.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''SELECT'', CASE WHEN sysprotects_2.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''INSERT'' ' +
', CASE WHEN sysprotects_3.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''UPDATE'', CASE WHEN sysprotects_4.action is null THEN CASE WHEN sysobjects.xtype = ''P'' THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''DELETE'' ' +
', CASE WHEN sysprotects_5.action is null THEN CASE WHEN sysobjects.xtype IN (''U'', ''V'') THEN ''N/A'' ELSE ''No'' END ELSE ''Yes'' END as ''EXECUTE'' ' +
'from [' + @DB_Name + '].dbo.sysusers u ' +
'join master.dbo.syslogins sl on sl.sid = u.sid ' +
'join master.sys.server_principals p on p.sid =  sl.sid and sl.denylogin = 0 and sl.hasaccess = 1 and p.is_disabled = 0 ' +
'join [' + @DB_Name + '].dbo.sysmembers ON sysmembers.memberuid = u.uid ' +
'join [' + @DB_Name + '].dbo.sysusers on sysusers.uid = sysmembers.groupuid ' +
'full join [' + @DB_Name + '].dbo.sysobjects on ( sysobjects.xtype in ( ''P'', ''U'', ''V'') and sysobjects.Name NOT LIKE ''dt%'' )  ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_1  on sysprotects_1.uid = sysusers.uid and sysprotects_1.id = sysobjects.id and sysprotects_1.action = 193 and sysprotects_1.protecttype in ( 204, 205 )  ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_2  on sysprotects_2.uid = sysusers.uid and sysprotects_2.id = sysobjects.id and sysprotects_2.action = 195 and sysprotects_2.protecttype in ( 204, 205 )  ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_3  on sysprotects_3.uid = sysusers.uid and sysprotects_3.id = sysobjects.id and sysprotects_3.action = 197 and sysprotects_3.protecttype in ( 204, 205 )  ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_4  on sysprotects_4.uid = sysusers.uid and sysprotects_4.id = sysobjects.id and sysprotects_4.action = 196 and sysprotects_4.protecttype in ( 204, 205 )  ' +
'left join [' + @DB_Name + '].dbo.sysprotects as sysprotects_5  on sysprotects_5.uid = sysusers.uid and sysprotects_5.id = sysobjects.id and sysprotects_5.action = 224 and sysprotects_5.protecttype in ( 204, 205 ) ' +
'where (sysprotects_1.action is not null or sysprotects_2.action is not null or sysprotects_3.action is not null or sysprotects_4.action is not null or sysprotects_5.action is not null) ' 

INSERT INTO @List (Script, DB, Name, [Type], RoleName, ObjectName, [SELECT], [INSERT], [UPDATE], [DELETE], [EXECUTE])
 EXEC sp_executesql @Command



SELECT @Command = 'select ''Database System Roles'' AS Script, ''' + @DB_Name + ''' as DB, sl.name as Name ' +
', CASE WHEN u.isSQLRole = 1 THEN ''Role'' WHEN u.issqluser = 1 THEN ''SQL User'' WHEN u.isntgroup = 1 THEN ''NT Group'' WHEN u.isntuser = 1 THEN ''NT User'' ELSE ''<n/a>'' END AS Type ' +
', r.name as RoleName ' +
', ''(all database objects)'' [objectname]  ' +
', CASE WHEN r.name IN (''db_datareader'', ''db_owner'') THEN ''Yes'' ELSE ''No'' END [SELECT] ' +
', CASE WHEN r.name IN (''db_datawriter'', ''db_owner'') THEN ''Yes'' ELSE ''No'' END [INSERT] ' +
', CASE WHEN r.name IN (''db_datawriter'', ''db_owner'') THEN ''Yes'' ELSE ''No'' END [UPDATE] ' +
', CASE WHEN r.name IN (''db_datawriter'', ''db_owner'') THEN ''Yes'' ELSE ''No'' END [DELETE] ' +
', CASE WHEN r.name IN (''db_owner'') THEN ''Yes'' ELSE ''No'' END [EXECUTE] ' +
'from [' + @DB_Name + '].dbo.sysusers u ' +
'join master.dbo.syslogins sl on sl.sid = u.sid ' +
'join master.sys.server_principals p on p.sid = sl.sid and sl.denylogin = 0 and sl.hasaccess = 1 and p.is_disabled = 0 ' +
'join [' + @DB_Name + '].dbo.sysmembers ON sysmembers.memberuid = u.uid ' +
'join [' + @DB_Name + '].dbo.sysusers r on r.uid = sysmembers.groupuid ' +
'where r.name like ''db[_]%'' ' 
 

INSERT INTO @List (Script, DB, Name, [Type], RoleName, ObjectName, [SELECT], [INSERT], [UPDATE], [DELETE], [EXECUTE])
 EXEC sp_executesql @Command





     FETCH NEXT FROM database_cursor INTO @DB_Name 
END

CLOSE database_cursor 
DEALLOCATE database_cursor




INSERT INTO @List (Script, DB, Name, [Type], RoleName, ObjectName, [SELECT], [INSERT], [UPDATE], [DELETE], [EXECUTE])
SELECT 'Sysadmin Users' AS Script, 'master' as DB, 
name as Name
, CASE WHEN u.isntgroup = 1 THEN 'NT Group' WHEN u.isntuser = 1 THEN 'NT User' ELSE 'SQL User' END AS Type
, 'sysadmin' as RoleName
, '(all databases and its objects)' [objectname] 
, 'Yes' as [SELECT]
, 'Yes' as [INSERT]
, 'Yes' as [UPDATE]
, 'Yes' as [DELETE]
, 'Yes' as [EXECUTE]
-- from master.dbo.syslogins u WHERE sysadmin = 1 and hasaccess = 1
from master.sys.server_principals p INNER JOIN master.dbo.syslogins u on p.sid =  u.sid where u.sysadmin = 1 and u.denylogin = 0 and u.hasaccess = 1 and p.is_disabled = 0 


select @@ServerName AS Server, ID, Script AS Method, DB, Name, [Type], RoleName, ObjectName, [SELECT], [INSERT], [UPDATE], [DELETE], [EXECUTE] 
From @List
order by Script, Name, RoleName, ObjectName
