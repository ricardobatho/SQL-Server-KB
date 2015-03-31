-- Scramble data. Irreversible. It renames each character data.
-- 
-- usage
-- exec dbo.[spScrambleData3] 'databaseName', 'dbo', 'tableName','Column1,Column2,Column3,Column4,Column5', @Execute = 0
-- exec dbo.[spScrambleData3] 'databaseName', 'dbo', 'tableName','Column1,Column2,Column3,Column4,Column5', @Execute = 1
GO
CREATE PROCEDURE [dbo].[spScrambleData3]
(
	@Database VARCHAR(200),
	@Schema VARCHAR(200) = 'dbo',
	@Table VARCHAR(200),
	@Columns VARCHAR(2500),
	@Execute BIT = 0
)
AS
BEGIN


SET NOCOUNT ON

/*
declare @Database VARCHAR(200),
	@Schema VARCHAR(200),
	@Table VARCHAR(200),
	@Columns VARCHAR(2500), -- comma separated
	@Execute BIT

select @Database = 'safranetdb',
	@Schema = 'dbo',
	@Table = 'tableName',
	@Columns = 'Column1,Column2,Column3,Column4,Column5',
	@Execute = 0
*/

/* Check Whether it is a Valid Server */
IF @@SERVERNAME NOT IN ('<server1>', '<server2>', '<server3>')
BEGIN
	PRINT 'This procedure is only for development server.'
	RETURN -1
END


/* Sanitize Inputs */
SET @Database = RTRIM(LTRIM(@Database))
SET @Schema = RTRIM(LTRIM(@Schema))
SET @Table = RTRIM(LTRIM(@Table))
SET @Columns = RTRIM(LTRIM(@Columns))


/* Define and Initialize Control Variables */
DECLARE @FullTableName VARCHAR(200)
DECLARE @SqlStmt NVARCHAR(4000)
DECLARE @SqlStmtTmp NVARCHAR(4000)
DECLARE @Column VARCHAR(200)
DECLARE @ColumnType VARCHAR(20)
DECLARE @Param NVARCHAR(100)

SET @Param = N'@ret varchar(200) OUTPUT'
SET @SqlStmtTmp = 'select  @ret = ''['' + s.table_schema + '']'' + ' + '''' + '.' + '''' + ' + ''['' + t.name + '']'' '
SET @SqlStmtTmp = @SqlStmtTmp + 'from ' + @Database + '.dbo.sysobjects t, ' + @Database + '.information_schema.tables s '
SET @SqlStmtTmp = @SqlStmtTmp + 'where t.type = ' + '''' + 'u' + '''' + ' '
SET @SqlStmtTmp = @SqlStmtTmp + 'and t.name = s.table_name and t.name = ' + '''' + @Table + ''''
SET @SqlStmtTmp = @SqlStmtTmp + 'and s.table_schema = ' + '''' + @Schema + ''''
EXECUTE sp_executesql @SqlStmtTmp, @Param, @ret = @FullTableName OUTPUT

IF ISNULL(@FullTableName,'') = ''
	BEGIN
		SELECT 'Table ' + @Table + ' not found in ' + @Schema + ' schema inside ' + @Database + ' database.'
--		RETURN -1
	END
ELSE
	BEGIN
		SET @FullTableName = '[' + @Database + '].' + @FullTableName
	END


/* Define and Initialize Loop Control Variables */
DECLARE	@Idx INT, @NextIdx INT, @Length INT
SELECT @Idx = 0, @NextIdx = 1, @Length = -1


/* Define Table For Sql Statement Display */
DECLARE @TblSqlStmt TABLE
(
	SqlStmt NVARCHAR(4000)
)


/* Define and Initialize Scramble Control Variables */
DECLARE @SymbolList TABLE (Symbol VARCHAR(2), Type CHAR(1), Random VARCHAR(40) DEFAULT RAND())
DECLARE @OrderedSymbolList TABLE (Symbol VARCHAR(2), Type CHAR(1), ID TINYINT IDENTITY(1,1))
DECLARE @SymbolKeyList TABLE (ID TINYINT IDENTITY(1,1), SymbolKey VARCHAR(2))

INSERT INTO @SymbolList (Symbol, Type) VALUES ('A', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('B', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('C', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('D', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('E', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('F', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('G', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('H', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('I', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('J', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('K', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('L', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('M', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('N', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('O', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('P', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('Q', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('R', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('S', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('T', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('U', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('V', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('W', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('X', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('Y', 'c')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('Z', 'c')

INSERT INTO @SymbolList (Symbol, Type) VALUES ('1', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('2', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('3', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('4', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('5', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('6', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('7', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('8', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('9', 'n')
INSERT INTO @SymbolList (Symbol, Type) VALUES ('0', 'n')


-- Force the values to repeat
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 5 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 5 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 5 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 5 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 5 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 1 Symbol, Type FROM @SymbolList WHERE Type = 'c' ORDER BY Random

INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 2 Symbol, Type FROM @SymbolList WHERE Type = 'n' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 2 Symbol, Type FROM @SymbolList WHERE Type = 'n' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 2 Symbol, Type FROM @SymbolList WHERE Type = 'n' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 2 Symbol, Type FROM @SymbolList WHERE Type = 'n' ORDER BY Random
INSERT INTO @OrderedSymbolList (Symbol, Type) SELECT TOP 2 Symbol, Type FROM @SymbolList WHERE Type = 'n' ORDER BY Random


DECLARE @CharPair TABLE (ID INT IDENTITY(1,1), LeftCh VARCHAR(2), RightCh VARCHAR(2))
DECLARE @NumPair TABLE (ID INT IDENTITY(1,1), LeftNum CHAR(1), RightNum CHAR(1))


-- Chars
INSERT INTO @CharPair (LeftCh) -- First group
SELECT Symbol FROM @SymbolList WHERE Type = 'c' ORDER BY Symbol

UPDATE p SET RightCh = l.Symbol
FROM @CharPair p
JOIN @OrderedSymbolList l ON p.ID = l.ID AND l.Type = 'c'


-- Numbers
INSERT INTO @NumPair (LeftNum)
SELECT Symbol FROM @SymbolList WHERE Type = 'n' ORDER BY Symbol

UPDATE p SET RightNum = Symbol
FROM @NumPair p
JOIN @OrderedSymbolList l ON p.ID + 26 = l.ID AND l.Type = 'n'


/* Iterate Throughout Specified Columns */
WHILE @NextIdx > 0
BEGIN
	/* Initialize Sql Statement for Scrambling */
	SET @SqlStmt = 'update ' + @FullTableName + ' set '
	
	/* Get Column from List */
	SELECT @NextIdx = CHARINDEX(',', @Columns, @Idx + 1)
	SELECT @Length = CASE WHEN @NextIdx > 0 THEN @NextIdx ELSE LEN(@Columns) + 1 END - @Idx - 1
	SET @Column = LTRIM(RTRIM(SUBSTRING(@Columns, @Idx + 1, @Length)))

	/* Get Column Type */
	SET @SqlStmtTmp = ''
	SET @SqlStmtTmp = 'select @ret=t.name from ' + @Database + '.dbo.syscolumns c, '
	SET @SqlStmtTmp = @SqlStmtTmp + @Database + '.dbo.systypes t, '
	SET @SqlStmtTmp = @SqlStmtTmp + @Database + '.dbo.sysobjects o '
	SET @SqlStmtTmp = @SqlStmtTmp + 'where t.name <> ' + '''' + 'sysname' + '''' + ' '
	SET @SqlStmtTmp = @SqlStmtTmp + 'and o.id = c.id and o.name = ' + '''' + @Table + ''''+ ' '
	SET @SqlStmtTmp = @SqlStmtTmp + 'and c.xtype = t.xtype and c.name=' + '''' +  @Column + ''''
	SET @Param = N'@ret varchar(200) OUTPUT'
	EXECUTE sp_executesql @SqlStmtTmp, @Param, @ret = @ColumnType OUTPUT;

	IF ISNULL(@ColumnType,'') = ''
		BEGIN
			SELECT 'Column ' + @Column + ' not found in ' + @FullTableName + ' object.'
			RETURN
		END

	/* Do the Scramble Magic :P */
	SET @SqlStmt = @SqlStmt + '[' + @Column +  ']='
	IF @ColumnType = 'text' OR @Column = 'ntext'
		BEGIN
			SET @SqlStmt = @SqlStmt + '''Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus at massa vel justo rutrum tristique. Nulla sagittis, eros nec imperdiet ultrices, nisi augue condimentum mi, a tristique turpis metus vitae arcu. Aenean mattis scelerisque tempor. Vivamus a volutpat ipsum. Fusce tincidunt est id ligula sodales viverra pretium lacus suscipit. Sed lacus diam, consequat non sagittis cursus, euismod ac mauris. Quisque vulputate eros vel nulla blandit viverra. Pellentesque lacinia libero id lacus tincidunt posuere. Quisque a lectus mi. Morbi scelerisque vehicula nibh, non imperdiet quam placerat ac.' + CHAR(13) + CHAR(13) + 'Pellentesque placerat diam in urna venenatis pulvinar. Praesent turpis metus, mattis sed semper sed, eleifend sit amet turpis. Integer sagittis volutpat purus, eu venenatis diam euismod id. Nunc enim enim, vulputate eu fringilla nec, auctor in enim. Proin dolor leo, pretium vel consequat a, vehicula ac metus. In sit amet iaculis sem. Nunc ut est laoreet leo commodo euismod.'''
		END
	ELSE
		BEGIN
			DECLARE @ChReplacePrefix VARCHAR(3000)
			DECLARE @ChReplaceSufix VARCHAR(3000)
			SET @ChReplaceSufix = ''

			SELECT @ChReplacePrefix = REPLICATE('REPLACE(', 36) -- 26 char conversions + 10 numbers
			SELECT @ChReplaceSufix = @ChReplaceSufix + ',''' + LeftCh + ''',''' + RightCh + ''')' FROM @CharPair
			SELECT @ChReplaceSufix = @ChReplaceSufix + ',' + LeftNum + ',' + RightNum + ')' FROM @NumPair
			SELECT @ChReplacePrefix = @ChReplacePrefix + 'UPPER(', @ChReplaceSufix = ')' + @ChReplaceSufix

			SET @SqlStmt = @SqlStmt + @ChReplacePrefix + '[' + @Column + ']' + @ChReplaceSufix
		END

	/* Check If Should Execute or Display Sql Statement */
	IF @Execute = CAST(1 AS BIT)
		EXEC sp_executesql @SqlStmt
	ELSE
		INSERT INTO @TblSqlStmt (SqlStmt) VALUES (@SqlStmt)

	/* Reset Loop Variables */
	SET @ColumnType = ''
	SELECT @Idx = @NextIdx

END

/* Check If Should Display Sql Statement */
IF @Execute = CAST(0 AS BIT) BEGIN
	SET NOCOUNT OFF
	SELECT SqlStmt FROM @TblSqlStmt
END

END
