USE [master]
GO
/****** Object:  Database [TicketAmateur]    Script Date: 12/9/2019 1:53:47 PM ******/
CREATE DATABASE [TicketAmateur]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TicketAmateur', FILENAME = N'D:\rdsdbdata\DATA\TicketAmateur.mdf' , SIZE = 9024KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'TicketAmateur_log', FILENAME = N'D:\rdsdbdata\DATA\TicketAmateur_log.ldf' , SIZE = 8384KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [TicketAmateur] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TicketAmateur].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TicketAmateur] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TicketAmateur] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TicketAmateur] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TicketAmateur] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TicketAmateur] SET ARITHABORT OFF 
GO
ALTER DATABASE [TicketAmateur] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TicketAmateur] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TicketAmateur] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TicketAmateur] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TicketAmateur] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TicketAmateur] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TicketAmateur] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TicketAmateur] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TicketAmateur] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TicketAmateur] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TicketAmateur] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TicketAmateur] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TicketAmateur] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TicketAmateur] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TicketAmateur] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TicketAmateur] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TicketAmateur] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TicketAmateur] SET RECOVERY FULL 
GO
ALTER DATABASE [TicketAmateur] SET  MULTI_USER 
GO
ALTER DATABASE [TicketAmateur] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TicketAmateur] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TicketAmateur] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TicketAmateur] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [TicketAmateur] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [TicketAmateur] SET QUERY_STORE = OFF
GO
USE [TicketAmateur]
GO
ALTER DATABASE SCOPED CONFIGURATION SET IDENTITY_CACHE = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [TicketAmateur]
GO
/****** Object:  User [ticketamateur]    Script Date: 12/9/2019 1:53:49 PM ******/
CREATE USER [ticketamateur] FOR LOGIN [ticketamateur] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [admin]    Script Date: 12/9/2019 1:53:49 PM ******/
CREATE USER [admin] FOR LOGIN [admin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [ticketamateur]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ticketamateur]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [ticketamateur]
GO
ALTER ROLE [db_owner] ADD MEMBER [admin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [admin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [admin]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetList]    Script Date: 12/9/2019 1:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnGetList] 
(
	@list Varchar( Max ) 
) 
Returns @templist Table ( item Integer not null, primary key( item ) ) 
As  
BEGIN
/* FUNCTION takes a comma separated list of integers and returns a table
written by Tom Muck
*/
	-- Declare an index variable for looping 
	Declare @index Integer

	-- Declare a variable to hold a single item
	Declare @item Varchar( Max )

	-- The @list variable will be pulled apart at the commas
	-- until nothing is left 
	WHILE @list Is Not Null
	BEGIN

		-- Find the comma
		Select @index = CharIndex( ',', @list )

		-- if there is no comma, must be finished 
		If @index = 0 
		BEGIN
		  -- Get the last item and set @list to null to end loop 
		  SELECT @item = Ltrim(Rtrim(@list))
		  SELECT @list = null
		END
		-- Not last item
		ELSE 
		BEGIN
		  -- Set the @item variable to element up to comma 
		  SET @item = Ltrim( Rtrim( Left( @list, @index - 1 ) ) )
		  -- Remove item from string. @list becomes shorter 
		  SET @list = Right( @list, Len( @list ) - @index ) 
		END

		-- Insert/Update goes in place of PRINT
		--PRINT @item
		IF NOT Exists (SELECT 1 FROM @templist WHERE item = @item) 
		BEGIN
			INSERT @templist (item) VALUES (@item)
		END

	
	END -- While @list Is Not Null

	RETURN 


END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetTotalPurchase]    Script Date: 12/9/2019 1:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetTotalPurchase](@userEventId int)
RETURNS FLOAT
AS   
-- Returns the stock level for the product.  
BEGIN  
 DECLARE @ret float;  
	DECLARE @totalSeats int;
    SELECT @totalSeats = count(*) from usereventseats where userEventId = @userEventId;
	SELECT @ret = @totalSeats * price FROM [events] e INNER JOIN usersevents u
	ON e.eventid = u.EventId where u.UserEventId = @usereventid
	return @ret;
END; 

/*
CREATE FUNCTION dbo.ufnGetInventoryStock(@ProductID int)  
RETURNS int   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @ret int;  
    SELECT @ret = SUM(p.Quantity)   
    FROM Production.ProductInventory p   
    WHERE p.ProductID = @ProductID   
        AND p.LocationID = '6';  
     IF (@ret IS NULL)   
        SET @ret = 0;  
    RETURN @ret;  
END; */
GO
/****** Object:  Table [dbo].[DB_Errors]    Script Date: 12/9/2019 1:53:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DB_Errors](
	[ErrorID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](100) NULL,
	[ErrorNumber] [int] NULL,
	[ErrorState] [int] NULL,
	[ErrorSeverity] [int] NULL,
	[ErrorLine] [int] NULL,
	[ErrorProcedure] [varchar](max) NULL,
	[ErrorMessage] [varchar](max) NULL,
	[ErrorDateTime] [datetime] NULL,
 CONSTRAINT [PK_DB_Errors] PRIMARY KEY CLUSTERED 
(
	[ErrorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Events]    Script Date: 12/9/2019 1:53:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Events](
	[eventid] [varchar](255) NOT NULL,
	[eventname] [varchar](1024) NULL,
	[image] [varchar](1024) NULL,
	[startTime] [time](7) NULL,
	[startDate] [date] NULL,
	[timeTBA] [bit] NULL,
	[dateTBA] [bit] NULL,
	[price] [money] NULL,
	[info] [nvarchar](max) NULL,
	[venueid] [int] NULL,
 CONSTRAINT [PK_Events] PRIMARY KEY CLUSTERED 
(
	[eventid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Seats]    Script Date: 12/9/2019 1:53:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Seats](
	[seatid] [int] IDENTITY(1,1) NOT NULL,
	[seat] [nvarchar](3) NULL,
	[row] [nvarchar](3) NULL,
	[section] [nvarchar](3) NULL,
	[venueid] [int] NULL,
 CONSTRAINT [PK_Seats] PRIMARY KEY CLUSTERED 
(
	[seatid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserEventSeats]    Script Date: 12/9/2019 1:53:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserEventSeats](
	[UserEventId] [int] NULL,
	[Seatid] [int] NULL,
	[UserEventSeatId] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_UserEventSeats] PRIMARY KEY CLUSTERED 
(
	[UserEventSeatId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 12/9/2019 1:53:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[userID] [bigint] NOT NULL,
	[username] [nvarchar](50) NULL,
	[password] [nvarchar](255) NULL,
	[email] [nvarchar](255) NULL,
	[firstname] [nvarchar](50) NULL,
	[lastname] [nvarchar](50) NULL,
	[address1] [nvarchar](50) NULL,
	[address2] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[state] [nvarchar](2) NULL,
	[zipcode] [nvarchar](50) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UsersEvents]    Script Date: 12/9/2019 1:53:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersEvents](
	[UserEventId] [int] IDENTITY(1,1) NOT NULL,
	[EventId] [varchar](255) NOT NULL,
	[UserId] [bigint] NOT NULL,
	[OrderDate] [datetime] NULL,
	[Tax] [money] NULL,
 CONSTRAINT [PK_UsersEvents] PRIMARY KEY CLUSTERED 
(
	[UserEventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Venues]    Script Date: 12/9/2019 1:53:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Venues](
	[venueid] [int] IDENTITY(1,1) NOT NULL,
	[venueName] [nvarchar](128) NULL,
	[venueCity] [varchar](128) NULL,
	[venueState] [varchar](128) NULL,
 CONSTRAINT [PK_Venues] PRIMARY KEY CLUSTERED 
(
	[venueid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191022-225848]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191022-225848] ON [dbo].[Events]
(
	[venueid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191125-101118]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191125-101118] ON [dbo].[Events]
(
	[startDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191112-225625]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191112-225625] ON [dbo].[Seats]
(
	[venueid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20191112-232419]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191112-232419] ON [dbo].[Seats]
(
	[seat] ASC,
	[row] ASC,
	[section] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191022-225550]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191022-225550] ON [dbo].[UserEventSeats]
(
	[Seatid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191112-225800]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191112-225800] ON [dbo].[UserEventSeats]
(
	[UserEventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20191112-225824]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191112-225824] ON [dbo].[Users]
(
	[username] ASC,
	[password] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20191022-225453]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191022-225453] ON [dbo].[UsersEvents]
(
	[EventId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [NonClusteredIndex-20191022-225514]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191022-225514] ON [dbo].[UsersEvents]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20191112-225904]    Script Date: 12/9/2019 1:53:53 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20191112-225904] ON [dbo].[Venues]
(
	[venueName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Seats]  WITH CHECK ADD  CONSTRAINT [FK_Seats_Venues] FOREIGN KEY([venueid])
REFERENCES [dbo].[Venues] ([venueid])
GO
ALTER TABLE [dbo].[Seats] CHECK CONSTRAINT [FK_Seats_Venues]
GO
ALTER TABLE [dbo].[UserEventSeats]  WITH CHECK ADD  CONSTRAINT [FK_UserEventSeats_Seats] FOREIGN KEY([Seatid])
REFERENCES [dbo].[Seats] ([seatid])
GO
ALTER TABLE [dbo].[UserEventSeats] CHECK CONSTRAINT [FK_UserEventSeats_Seats]
GO
ALTER TABLE [dbo].[UserEventSeats]  WITH CHECK ADD  CONSTRAINT [FK_UserEventSeats_UsersEvents] FOREIGN KEY([UserEventId])
REFERENCES [dbo].[UsersEvents] ([UserEventId])
GO
ALTER TABLE [dbo].[UserEventSeats] CHECK CONSTRAINT [FK_UserEventSeats_UsersEvents]
GO
ALTER TABLE [dbo].[UsersEvents]  WITH CHECK ADD  CONSTRAINT [FK_UsersEvents_Events] FOREIGN KEY([EventId])
REFERENCES [dbo].[Events] ([eventid])
GO
ALTER TABLE [dbo].[UsersEvents] CHECK CONSTRAINT [FK_UsersEvents_Events]
GO
ALTER TABLE [dbo].[UsersEvents]  WITH CHECK ADD  CONSTRAINT [FK_UsersEvents_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([userID])
GO
ALTER TABLE [dbo].[UsersEvents] CHECK CONSTRAINT [FK_UsersEvents_Users]
GO
/****** Object:  StoredProcedure [dbo].[usp_DB_ErrorsDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_DB_ErrorsDelete] 
    @ErrorID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[DB_Errors]
	WHERE  [ErrorID] = @ErrorID

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_DB_ErrorsInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_DB_ErrorsInsert] 
    @UserName varchar(100) = NULL,
    @ErrorNumber int = NULL,
    @ErrorState int = NULL,
    @ErrorSeverity int = NULL,
    @ErrorLine int = NULL,
    @ErrorProcedure varchar(MAX) = NULL,
    @ErrorMessage varchar(MAX) = NULL,
    @ErrorDateTime datetime = NULL
AS 

	
	INSERT INTO [dbo].[DB_Errors] ([UserName], [ErrorNumber], [ErrorState], [ErrorSeverity], [ErrorLine], [ErrorProcedure], [ErrorMessage], [ErrorDateTime])
	SELECT @UserName, @ErrorNumber, @ErrorState, @ErrorSeverity, @ErrorLine, @ErrorProcedure, @ErrorMessage, @ErrorDateTime
	COMMIT


GO
/****** Object:  StoredProcedure [dbo].[usp_DB_ErrorsSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_DB_ErrorsSelect] 
    @ErrorID int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [ErrorID], [UserName], [ErrorNumber], [ErrorState], [ErrorSeverity], [ErrorLine], [ErrorProcedure], [ErrorMessage], [ErrorDateTime] 
	FROM   [dbo].[DB_Errors] 
	WHERE  ([ErrorID] = @ErrorID OR @ErrorID IS NULL) 

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_DB_ErrorsUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_DB_ErrorsUpdate] 
    @ErrorID int,
    @UserName varchar(100) = NULL,
    @ErrorNumber int = NULL,
    @ErrorState int = NULL,
    @ErrorSeverity int = NULL,
    @ErrorLine int = NULL,
    @ErrorProcedure varchar(MAX) = NULL,
    @ErrorMessage varchar(MAX) = NULL,
    @ErrorDateTime datetime = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[DB_Errors]
	SET    [UserName] = @UserName, [ErrorNumber] = @ErrorNumber, [ErrorState] = @ErrorState, [ErrorSeverity] = @ErrorSeverity, [ErrorLine] = @ErrorLine, [ErrorProcedure] = @ErrorProcedure, [ErrorMessage] = @ErrorMessage, [ErrorDateTime] = @ErrorDateTime
	WHERE  [ErrorID] = @ErrorID
	
	-- Begin Return Select <- do not remove
	SELECT [ErrorID], [UserName], [ErrorNumber], [ErrorState], [ErrorSeverity], [ErrorLine], [ErrorProcedure], [ErrorMessage], [ErrorDateTime]
	FROM   [dbo].[DB_Errors]
	WHERE  [ErrorID] = @ErrorID	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventExists]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_EventExists] 
    @eventid varchar(255),
   @exists INT OUTPUT  
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	


	SELECT @exists = count(*) 
	FROM   [dbo].[Events] 
	WHERE  [eventid] = @eventid 

	return @exists

GO
/****** Object:  StoredProcedure [dbo].[usp_EventsDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_EventsDelete] 
    @eventid varchar(255)
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[Events]
	WHERE  [eventid] = @eventid

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventsGenerateDummySales]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_EventsGenerateDummySales]
@eventid varchar(255)

AS
--Fill up a random number of seats in venue
SET IMPLICIT_TRANSACTIONS OFF
DECLARE @venueCapacity int
DECLARE @venueid int
DECLARE @randomSales int
DECLARE @counter int
DECLARE @userid bigint
DECLARE @userEventId int
DECLARE @seat int
DECLARE @numberOfVenues int


SELECT @venueid = venueid from [events] where eventid = @eventid
-- if no venue in the events table, set a random venue
if(@venueid is null) BEGIN
	SELECT TOP 1  @venueid=venueid  FROM venues ORDER BY newid()
	UPDATE [events] SET venueid = @venueid WHERE eventid = @eventid
END

		
SELECT @venueCapacity = COUNT(*) FROM seats WHERE venueid = @venueid
;

 
		
--print 'venue id ' 
--print  @venueid
-- get a random number below the venue capacity for sales
SET @randomSales = ABS(CHECKSUM(NEWID()) % @venueCapacity) 
SET @counter = 1	

SELECT * INTO #users FROM (
select u.userid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
FROM users u 
CROSS JOIN users b 
cross join users c 

cross join users 
)a
where a.RowNumber <= @randomsales/2
and CAST(a.userid as int) < 100000
ORDER BY newid()

INSERT UsersEvents (EventId, UserId, OrderDate, Tax) 
select @eventid as eventid, userid, getdate() as orderdate, 0 as tax FROM #users 

SELECT *, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber into #seats from seats where venueid = @venueid


SELECT distinct userEventId, eventid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
INTO #usersEvents FROM usersEvents e
where e.eventid = @eventid

INSERT userEventSeats (seatid, userEventId)
SELECT distinct s.seatid, userEventId

FROM #usersEvents e
INNER JOIN #seats s
ON e.RowNumber = s.rowNumber 
where e.eventid = @eventid

DROP TABLE #seats
DROP TABLE #users
DROP TABLE #usersEvents
--COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventsGenerateDummySales_1116]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_EventsGenerateDummySales_1116]
@eventid varchar(255), @venueName varchar(255), 
@venueCity varchar(255), @venueState varchar(255)

AS
--Fill up a random number of seats in venue
SET IMPLICIT_TRANSACTIONS OFF
DECLARE @venueCapacity int
DECLARE @venueid int
DECLARE @randomSales int
DECLARE @counter int
DECLARE @userid bigint
DECLARE @userEventId int
DECLARE @seat int
DECLARE @numberOfVenues int
-- check for venue from event already in DB
SELECT @venueid = venueid from [events] where eventid = @eventid
-- check for venue based on venue name
IF @venueid is null BEGIN
	SELECT @venueid = venueid FROM venues WHERE venueName = @venueName
END
-- if no venue in the events table or venues table, set a random venue
if(@venueid is null) BEGIN
	-- none found, use venue name from event and create a new one based on an existing random venue
	SELECT TOP 1  @venueid = venueid  FROM venues ORDER BY newid()
	DECLARE @newvenueid int
	INSERT venues (venuename, venueCity, venueState) VALUES (@venueName,@venueCity, @venueState)
	SET @newvenueid = SCOPE_IDENTITY()
	-- create new venue, duplicate seat chart from random venue
	INSERT INTO seats
	SELECT seat, row, section, @newvenueid as venueid FROM seats WHERE venueid = @venueid
	SET @venueid = @newvenueid
END ELSE BEGIN
	UPDATE venues SET venueCity = @venueCity, venueState = @venueState 
	WHERE venueid = @venueid
END
UPDATE [events] SET venueid = @venueid WHERE eventid = @eventid
		
SELECT @venueCapacity = COUNT(*) FROM seats WHERE venueid = @venueid


 
		
--print 'venue id ' 
--print  @venueid
-- get a random number below the venue capacity for sales
SET @randomSales = ABS(CHECKSUM(NEWID()) % @venueCapacity) 
SET @counter = 1	

SELECT * INTO #users FROM (
select u.userid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
FROM users u 
CROSS JOIN users b 
cross join users c 

cross join users 
)a
where a.RowNumber <= @randomsales/2
and CAST(a.userid as int) < 100000
ORDER BY newid()

INSERT UsersEvents (EventId, UserId, OrderDate, Tax) 
select @eventid as eventid, userid, getdate() as orderdate, 0 as tax FROM #users 

SELECT *, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber into #seats from seats where venueid = @venueid


SELECT distinct userEventId, eventid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
INTO #usersEvents FROM usersEvents e
where e.eventid = @eventid

INSERT userEventSeats (seatid, userEventId)
SELECT distinct s.seatid, userEventId

FROM #usersEvents e
INNER JOIN #seats s
ON e.RowNumber = s.rowNumber 
where e.eventid = @eventid

DROP TABLE #seats
DROP TABLE #users
DROP TABLE #usersEvents
--COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventsGenerateDummySales_OLD]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[usp_EventsGenerateDummySales_OLD]
@eventid varchar(255)

AS
--Fill up a random number of seats in venue

DECLARE @venueCapacity int
DECLARE @venueid int
DECLARE @randomSales int
DECLARE @counter int
DECLARE @userid bigint
DECLARE @userEventId int
DECLARE @seat int
DECLARE @numberOfVenues int


SELECT @venueid = venueid from [events] where eventid = @eventid
-- if no venue in the events table, set a random venue
if(@venueid is null) BEGIN
	SELECT TOP 1  @venueid=venueid  FROM venues ORDER BY newid()
	UPDATE [events] SET venueid = @venueid WHERE eventid = @eventid
END

		
SELECT @venueCapacity = COUNT(*) FROM seats WHERE venueid = @venueid
;

 
		
--print 'venue id ' 
--print  @venueid
-- get a random number below the venue capacity for sales
SET @randomSales = ABS(CHECKSUM(NEWID()) % @venueCapacity) 
SET @counter = 1	
--print 'Random Sales: '
--print @randomSales
-- loop through random sale count until all items inserted
SELECT * into #users FROM users 
SELECT * into #seats from seats where venueid = @venueid
WHILE @counter < @randomSales 
	BEGIN

			SELECT TOP 1 @userid = userid FROM #users ORDER BY newid(); -- get random user
			--print 'UserId'
			--print @userid
			-- make a userevent (user purchase to an event)
			INSERT UsersEvents (EventId, UserId, OrderDate, Tax) VALUES (@eventId, @userId, getdate(), 0);
			SELECT @userEventId = SCOPE_IDENTITY();
					
			--pick a random seat that hasn't been sold
			SELECT TOP 1 @seat = seatid FROM #seats WHERE
				seatid NOT IN (select seatid FROM UserEventSeats u
			INNER JOIN UsersEvents e
			ON u.UserEventId = e.UserEventId WHERE e.eventid = @eventid
			and venueid = @venueid ) and venueid = @venueid
			ORDER BY newid()
			/*
			print 'Seat id'
			print @seat
			print 'counter'
			print @counter
			*/
			INSERT INTO UserEventSeats (UserEventId, Seatid) VALUES (@userEventId,@seat)
						
		SET @counter = @counter + 1
		
	END		
DROP TABLE #users
		DROP TABLE #seats



	

	---
	/*
	select * from UsersEvents
	select * from userEventSeats
	SELECT distinct seatid, eventid  from userEventSeats inner join usersevents on usereventseats.usereventid
	= usersevents.usereventid order by eventid, seatid
	*/
	/*
	DELETE FROM userEventSeats
	DELETE FROM usersEvents
	*/

GO
/****** Object:  StoredProcedure [dbo].[usp_EventsGenerateDummySalesNew]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[usp_EventsGenerateDummySalesNew]
@eventid varchar(255), @venueName varchar(255)

AS
--Fill up a random number of seats in venue
SET IMPLICIT_TRANSACTIONS OFF
DECLARE @venueCapacity int
DECLARE @venueid int
DECLARE @randomSales int
DECLARE @counter int
DECLARE @userid bigint
DECLARE @userEventId int
DECLARE @seat int
DECLARE @numberOfVenues int
-- check for venue from event already in DB
SELECT @venueid = venueid from [events] where eventid = @eventid
-- check for venue based on venue name
IF @venueid is null BEGIN
	SELECT @venueid = venueid FROM venues WHERE venueName = @venueName
END
-- if no venue in the events table or venues table, set a random venue
if(@venueid is null) BEGIN
	-- none found, use venue name from event and create a new one based on an existing random venue
	SELECT TOP 1  @venueid = venueid  FROM venues ORDER BY newid()
	DECLARE @newvenueid int
	INSERT venues (venuename) VALUES (@venueName)
	SET @newvenueid = SCOPE_IDENTITY()
	-- create new venue, duplicate seat chart from random venue
	INSERT INTO seats
	SELECT seat, row, section, @newvenueid as venueid FROM seats WHERE venueid = @venueid
	SET @venueid = @newvenueid
END
UPDATE [events] SET venueid = @venueid WHERE eventid = @eventid
		
SELECT @venueCapacity = COUNT(*) FROM seats WHERE venueid = @venueid


 
		
--print 'venue id ' 
--print  @venueid
-- get a random number below the venue capacity for sales
SET @randomSales = ABS(CHECKSUM(NEWID()) % @venueCapacity) 
SET @counter = 1	

SELECT * INTO #users FROM (
select u.userid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
FROM users u 
CROSS JOIN users b 
cross join users c 

cross join users 
)a
where a.RowNumber <= @randomsales/2
and CAST(a.userid as int) < 100000
ORDER BY newid()

INSERT UsersEvents (EventId, UserId, OrderDate, Tax) 
select @eventid as eventid, userid, getdate() as orderdate, 0 as tax FROM #users 

SELECT *, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber into #seats from seats where venueid = @venueid


SELECT distinct userEventId, eventid, ROW_NUMBER() OVER(ORDER BY newid()) AS RowNumber
INTO #usersEvents FROM usersEvents e
where e.eventid = @eventid

INSERT userEventSeats (seatid, userEventId)
SELECT distinct s.seatid, userEventId

FROM #usersEvents e
INNER JOIN #seats s
ON e.RowNumber = s.rowNumber 
where e.eventid = @eventid

DROP TABLE #seats
DROP TABLE #users
DROP TABLE #usersEvents
--COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventsInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_EventsInsert] 
	@eventid varchar(255),
    @eventname varchar(100) = NULL,
    --@image varbinary(MAX) = NULL,
    @startTime varchar(255) = NULL,
    @startDate date = NULL,
    @timeTBA bit = NULL,
    @dateTBA bit = NULL,
   
    @price varchar(255) = NULL,
    @info nvarchar(MAX) = NULL
AS 
	SET IMPLICIT_TRANSACTIONS OFF
	
	DECLARE @starttimeformatted time(7)
	SET @starttimeformatted = CAST(@startTime as TIME(7))
	DECLARE @priceformatted money
	SET @priceformatted = CAST(@price as money)
	BEGIN TRY
		INSERT INTO [dbo].[Events] (eventid, [eventname],  [startTime], [startDate], [timeTBA], [dateTBA],  [price], [info])
		SELECT @eventid, @eventname, @starttimeformatted, @startDate, @timeTBA, @dateTBA,  @priceformatted, @info
	
           
	END TRY
	BEGIN CATCH
		DECLARE @RC int
		DECLARE @UserName varchar(100)
		DECLARE @ErrorNumber int
		DECLARE @ErrorState int
		DECLARE @ErrorSeverity int
		DECLARE @ErrorLine int
		DECLARE @ErrorProcedure varchar(max)
		DECLARE @ErrorMessage varchar(max)
		DECLARE @ErrorDateTime datetime
		SET @username = SUSER_SNAME()
		SET @ErrorNumber =  ERROR_NUMBER()
		SET @ErrorState = ERROR_STATE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorLine = ERROR_LINE()
		SET @ErrorProcedure = ERROR_PROCEDURE()
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorDateTime = getdate()
		EXECUTE  [dbo].[usp_DB_ErrorsInsert] 
			@UserName,
			 @errorNumber,
			 @ErrorState,
			 @ErrorSeverity,
			 @ErrorLine,
			 @ErrorProcedure,
			 @ErrorMessage,
			 @ErrorDateTime
		 
	END CATCH
	COMMIT
	/**/

GO
/****** Object:  StoredProcedure [dbo].[usp_EventsSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_EventsSelect] 
    @eventid varchar(255)
AS 
	

	SELECT [eventid], [eventname], [image], [startTime], 
	[startDate], [timeTBA], [dateTBA], [price], [info] ,
	v.venueCity, v.venueName, v.venueState, v.venueId
	FROM   [dbo].[Events] e
	INNER JOIN dbo.venues v
	ON e.venueid = v.venueid
	WHERE  ([eventid] = @eventid OR @eventid IS NULL) 

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_EventsUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_EventsUpdate] 
    @eventid varchar(255),
    @eventname varchar(100) = NULL,
    @image varbinary(MAX) = NULL,
    @startTime time(7) = NULL,
    @startDate date = NULL,
    @timeTBA bit = NULL,
    @dateTBA bit = NULL,
    @category nvarchar(100) = NULL,
    @genre nvarchar(50) = NULL,
    @price money = NULL,
    @info nvarchar(MAX) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[Events]
	SET    [eventname] = @eventname, [image] = @image, [startTime] = @startTime, [startDate] = @startDate, [timeTBA] = @timeTBA, [dateTBA] = @dateTBA, [price] = @price, [info] = @info
	WHERE  [eventid] = @eventid
	
	-- Begin Return Select <- do not remove
	SELECT [eventid], [eventname], [image], [startTime], [startDate], [timeTBA], [dateTBA],  [price], [info]
	FROM   [dbo].[Events]
	WHERE  [eventid] = @eventid	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_generateSeatsForSampleVenue]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[usp_generateSeatsForSampleVenue]

@venueid int

AS

-- create venue seating
DECLARE @row int
DECLARE @seat int

DECLARE @maxrows int
DECLARE @maxseats int

SET @maxrows = ABS(CHECKSUM(NEWID()) % 50) + 10
SET @maxseats = ABS(CHECKSUM(NEWID()) % 100) + 20

SET @row = 1
SET @seat = 1
WHILE @row < @maxrows
	BEGIN
		WHILE @seat < @maxseats 
			BEGIN
				INSERT INTO Seats (seat, [row], section, venueid) VALUES (@seat, @row, null, @venueid)
				SET @seat = @seat + 1					
			END
		SET @row = @row + 1
		SET @seat = 1
	END
	SET @row = 1

GO
/****** Object:  StoredProcedure [dbo].[usp_getAllEventSeatsForUser]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_getAllEventSeatsForUser] (@userid int)
AS

SELECT u.[UserEventId], e.[EventId],  [OrderDate],
e.eventname, e.startDate, s.seatid, se.seat, se.[row]
,dbo.fnGetTotalPurchase(u.UserEventId) as TotalPrice
,e.[image], e.[startTime], v.venueCity AS venueCity, v.venueName AS venueName, v.venueState AS VenueState
	FROM   [dbo].[UsersEvents] u
	inner join usereventseats S 
	on u.UserEventId=s.UserEventId
	INNER JOIN events e
	ON u.EventId = e.eventid
	INNER JOIN seats se
	ON S.Seatid = se.seatid
	INNER JOIN Venues AS v
	ON v.venueid = e.venueid

	WHERE  [UserId] = @userid


	ORDER BY e.eventid, se.row, se.seat

GO
/****** Object:  StoredProcedure [dbo].[usp_getEventSeatsForUser]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_getEventSeatsForUser] (@userid int, @eventid varchar(255))
AS

SELECT u.[UserEventId], e.[EventId],  [OrderDate],
e.eventname, e.startDate, s.seatid, se.seat, se.[row]
	FROM   [dbo].[UsersEvents] u
	inner join usereventseats S 
	on u.UserEventId=s.UserEventId
	INNER JOIN events e
	ON u.EventId = e.eventid
	INNER JOIN seats se
	ON S.Seatid = se.seatid

	WHERE  [UserId] = @userid
	AND e.eventid = @eventid

	ORDER BY se.row, se.seat

GO
/****** Object:  StoredProcedure [dbo].[usp_getFutureEventSeatsForUser]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getFutureEventSeatsForUser]
	-- Add the parameters for the stored procedure here
	@userid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT u.[UserEventId], e.[EventId],  [OrderDate],
e.eventname, e.startDate, s.seatid, se.seat, se.[row]
,dbo.fnGetTotalPurchase(u.UserEventId) as TotalPrice
,e.[image], e.[startTime], v.venueCity AS venueCity, v.venueName AS venueName, v.venueState AS VenueState
	FROM   [dbo].[UsersEvents] u
	inner join usereventseats S 
	on u.UserEventId=s.UserEventId
	INNER JOIN events e
	ON u.EventId = e.eventid
	INNER JOIN seats se
	ON S.Seatid = se.seatid
	INNER JOIN Venues AS v
	ON v.venueid = e.venueid

	WHERE  [UserId] = @userid AND startDate > sysdatetime()


	ORDER BY e.startDate, e.eventid, se.row, se.seat


END
GO
/****** Object:  StoredProcedure [dbo].[usp_getSeatsForEvent]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_getSeatsForEvent] (@eventid varchar(255))

AS
DECLARE @venueid int


SELECT @venueid  = venueid from Events WHERE eventid = @eventid

select S.*, SOLD = case when u.seatid IS NULL then 0 else 1 END FROM seats S 
LEFT OUTER JOIN (
select * from usereventseats where usereventid in (
select usereventid from usersevents where eventid = @eventid)) u
ON s.seatid = u.seatid
WHERE s.venueid = @venueid
ORDER BY case when section NOT LIKE '%[^0-9]%' then s.section else cast(section as int) end DESC
, case when [row] NOT LIKE '%[^0-9]%' then s.[row] else cast(s.[row] as int) end DESC,
case when seat NOT LIKE '%[^0-9]%' then s.seat else cast(seat as int) end 
GO
/****** Object:  StoredProcedure [dbo].[usp_getSeatsForEvent_OLD]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_getSeatsForEvent_OLD] (@eventid varchar(255))

AS
DECLARE @venueid int


SELECT @venueid  = venueid from Events WHERE eventid = @eventid

SELECT s.*, SOLD = case when u.seatid IS NULL then 0 else 1 END FROM Seats s 
LEFT OUTER JOIN UserEventSeats u
ON s.seatid = u.seatid
LEFT OUTER JOIN UsersEvents e
ON u.UserEventId = e.UserEventId
WHERE e.EventId = @eventid or e.eventid is null
and s.venueid = @venueid
ORDER BY case when section NOT LIKE '%[^0-9]%' then s.section else cast(section as int) end DESC
, case when [row] NOT LIKE '%[^0-9]%' then s.[row] else cast(s.[row] as int) end DESC,
case when seat NOT LIKE '%[^0-9]%' then s.seat else cast(seat as int) end 
GO
/****** Object:  StoredProcedure [dbo].[usp_loginUser]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_loginUser] (@username varchar(255), @password varchar(255), @loggedin int OUTPUT) AS

SELECT @loggedin = userid  from users where username = @username and password = @password

IF @@ROWCOUNT = 0 return 0
-- if query returns a row, login is successful
RETURN @loggedin
GO
/****** Object:  StoredProcedure [dbo].[usp_loginUser_temp]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_loginUser_temp] (@username varchar(255), @password varchar(255), @loggedin int OUTPUT) AS

SELECT 1 from users where username = @username and password = @password


-- if query returns a row, login is successful
SET @loggedin = @@ROWCOUNT
RETURN @loggedin
GO
/****** Object:  StoredProcedure [dbo].[usp_SeatsDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_SeatsDelete] 
    @seatid int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[Seats]
	WHERE  [seatid] = @seatid

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_SeatsInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_SeatsInsert] 
    @seatid int,
    @seat nvarchar(3) = NULL,
    @row nvarchar(3) = NULL,
    @section nvarchar(3) = NULL,
    @venueid int = NULL,
    @cost money = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [dbo].[Seats] ([seatid], [seat], [row], [section], [venueid], [cost])
	SELECT @seatid, @seat, @row, @section, @venueid, @cost
	
	-- Begin Return Select <- do not remove
	SELECT [seatid], [seat], [row], [section], [venueid], [cost]
	FROM   [dbo].[Seats]
	WHERE  [seatid] = @seatid
	-- End Return Select <- do not remove
               
	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_SeatsSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_SeatsSelect] 
    @venueid int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [seatid], [seat], [row], [section], [venueid]
	FROM   [dbo].[Seats] 
	WHERE  (venueid = @venueid) 
	ORDER BY section, CAST([row] as int), CAST(seat as int)

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_SeatsUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_SeatsUpdate] 
    @seatid int,
    @seat nvarchar(3) = NULL,
    @row nvarchar(3) = NULL,
    @section nvarchar(3) = NULL,
    @venueid int = NULL,
    @cost money = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[Seats]
	SET    [seat] = @seat, [row] = @row, [section] = @section, [venueid] = @venueid, [cost] = @cost
	WHERE  [seatid] = @seatid
	
	-- Begin Return Select <- do not remove
	SELECT [seatid], [seat], [row], [section], [venueid], [cost]
	FROM   [dbo].[Seats]
	WHERE  [seatid] = @seatid	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UserEventSeatsDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UserEventSeatsDelete] 
    @UserEventSeatId int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[UserEventSeats]
	WHERE  [UserEventSeatId] = @UserEventSeatId

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UserEventSeatsInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UserEventSeatsInsert] 
    @UserEventId int = NULL,
    @Seatids varchar(max)
AS 
	SET IMPLICIT_TRANSACTIONS OFF
	
	
	
	INSERT INTO [dbo].[UserEventSeats] ([UserEventId], [Seatid])
	SELECT @UserEventId, Item from fnGetList(@SeatIds)
	
	
               

GO
/****** Object:  StoredProcedure [dbo].[usp_UserEventSeatsSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UserEventSeatsSelect] 
    @UserEventSeatId int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [UserEventSeatId], [UserEventId], [Seatid] 
	FROM   [dbo].[UserEventSeats] 
	WHERE  ([UserEventSeatId] = @UserEventSeatId OR @UserEventSeatId IS NULL) 

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UserEventSeatsUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UserEventSeatsUpdate] 
    @UserEventSeatId int,
    @UserEventId int = NULL,
    @Seatid int = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[UserEventSeats]
	SET    [UserEventId] = @UserEventId, [Seatid] = @Seatid
	WHERE  [UserEventSeatId] = @UserEventSeatId
	
	-- Begin Return Select <- do not remove
	SELECT [UserEventSeatId], [UserEventId], [Seatid]
	FROM   [dbo].[UserEventSeats]
	WHERE  [UserEventSeatId] = @UserEventSeatId	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersDelete] 
    @userID bigint
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[Users]
	WHERE  [userID] = @userID

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersEventsDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersEventsDelete] 
    @UserEventId int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[UsersEvents]
	WHERE  [UserEventId] = @UserEventId

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersEventsInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersEventsInsert] 
    @EventId varchar(255),
    @UserId bigint,    
    @Tax money = NULL,
	@seats varchar(max)
AS 
	SET IMPLICIT_TRANSACTIONS OFF
	
	DECLARE @UserEventId int
	
	INSERT INTO [dbo].[UsersEvents] ([EventId], [UserId], [OrderDate], [Tax])
	VALUES( @EventId, @UserId, getdate(), @Tax)

	SELECT @UserEventId = SCOPE_IDENTITY()
	-- insert/purchase the seats
	exec [usp_UserEventSeatsInsert] @UserEventId , @Seats
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersEventsSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersEventsSelect] 
    @UserId int
AS 
	SET IMPLICIT_TRANSACTIONS OFF

	SELECT min(u.[UserEventId]), e.[EventId],  [OrderDate], [Tax] , e.eventname, e.startDate, count(*) as SeatCount
	FROM   [dbo].[UsersEvents] u
	inner join usereventseats S 
	on u.UserEventId=s.UserEventId
	INNER JOIN events e
	ON u.EventId = e.eventid

	WHERE  [UserId] = @userid
	AND e.startDate > getdate()
	GROUP BY e.eventid, u.UserEventId, orderdate, tax,e.eventname, e.startDate
	ORDER BY e.startdate 


GO
/****** Object:  StoredProcedure [dbo].[usp_UsersEventsUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersEventsUpdate] 
    @UserEventId int,
    @EventId int,
    @UserId bigint,
    @OrderDate datetime = NULL,
    @Tax money = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[UsersEvents]
	SET    [EventId] = @EventId, [UserId] = @UserId, [OrderDate] = @OrderDate, [Tax] = @Tax
	WHERE  [UserEventId] = @UserEventId
	
	-- Begin Return Select <- do not remove
	SELECT [UserEventId], [EventId], [UserId], [OrderDate], [Tax]
	FROM   [dbo].[UsersEvents]
	WHERE  [UserEventId] = @UserEventId	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersInsert]
    
    @username nvarchar(50) = NULL
    ,@password nvarchar(255) = NULL
    ,@email nvarchar(255) = NULL
	/*
    ,@firstname nvarchar(50) = NULL
    ,@lastname nvarchar(50) = NULL
    ,@address1 nvarchar(50) = NULL
    ,@address2 nvarchar(50) = NULL
    ,@city nvarchar(50) = NULL
    ,@state nvarchar(2) = NULL
    ,@zipcode nvarchar(50) = NULL*/
	,@userid int OUTPUT
AS 
	SET NOCOUNT ON 
	SET IMPLICIT_TRANSACTIONS OFF
	
	-- create a large userid, make sure it's not in db
	SET @userid = abs(CONVERT(INT,CONVERT(BINARY(8), NEWID())))
	WHILE EXISTS (select 1 from users where userid = @userid) BEGIN
		SET @userid = abs(CONVERT(INT,CONVERT(BINARY(8), NEWID())))
	END
	BEGIN TRY
	INSERT INTO [dbo].[Users] ([userID], [username], [password], [email])
	VALUES ( @userID, @username, @password, @email)
	END TRY
	BEGIN CATCH
	DECLARE @RC int
		DECLARE @User varchar(100)
		DECLARE @ErrorNumber int
		DECLARE @ErrorState int
		DECLARE @ErrorSeverity int
		DECLARE @ErrorLine int
		DECLARE @ErrorProcedure varchar(max)
		DECLARE @ErrorMessage varchar(max)
		DECLARE @ErrorDateTime datetime
		SET @user = SUSER_SNAME()
		SET @ErrorNumber =  ERROR_NUMBER()
		SET @ErrorState = ERROR_STATE()
		SET @ErrorSeverity = ERROR_SEVERITY()
		SET @ErrorLine = ERROR_LINE()
		SET @ErrorProcedure = ERROR_PROCEDURE()
		SET @ErrorMessage = ERROR_MESSAGE()
		SET @ErrorDateTime = getdate()
		EXECUTE  [dbo].[usp_DB_ErrorsInsert] 
		@User,
		 @errorNumber,
		 @ErrorState,
		 @ErrorSeverity,
		 @ErrorLine,
		 @ErrorProcedure,
		 @ErrorMessage,
		 @ErrorDateTime
	END CATCH



	return @userid
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersSelect] 
    @userID bigint
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [userID], [username], [password], [email], [firstname], [lastname], [address1], [address2], [city], [state], [zipcode] 
	FROM   [dbo].[Users] 
	WHERE  ([userID] = @userID OR @userID IS NULL) 

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_UsersUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_UsersUpdate] 
    @userID bigint,
    @username nvarchar(50) = NULL,
    @password nvarchar(255) = NULL,
    @email nvarchar(255) = NULL,
    @firstname nvarchar(50) = NULL,
    @lastname nvarchar(50) = NULL,
    @address1 nvarchar(50) = NULL,
    @address2 nvarchar(50) = NULL,
    @city nvarchar(50) = NULL,
    @state nvarchar(2) = NULL,
    @zipcode nvarchar(50) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	IF(@username = '') BEGIN SET @username = null END
	IF(@password = '') BEGIN SET @password = null END
	IF(@email = '') BEGIN SET @email = null END
	IF(@firstname = '') BEGIN SET @firstname = null END
	IF(@lastname = '') BEGIN SET @lastname = null END
	IF(@address1 = '') BEGIN SET @address1 = null END
	IF(@address2 = '') BEGIN SET @address2 = null END
	IF(@city = '') BEGIN SET @city = null END
	IF(@state = '') BEGIN SET @state = null END
	IF(@zipcode = '') BEGIN SET @zipcode = null END

	UPDATE [dbo].[Users]
	SET    [username] = COALESCE(@username, username), 
	[password] = COALESCE(@password, [password]),
	[email] = COALESCE(@email, email),
	[firstname] = COALESCE(@firstname, firstname),
	[lastname] = COALESCE(@lastname, lastname),
	[address1] = COALESCE(@address1, address1),
	[address2] = COALESCE(@address2, address2),
	[city] = COALESCE(@city, city),
	[state] = COALESCE(@state, [state]),
	[zipcode] = COALESCE(@zipcode,zipcode)
	WHERE  [userID] = @userID
	
	-- Begin Return Select <- do not remove
	SELECT [userID], [username], [password], [email], [firstname], [lastname], [address1], [address2], [city], [state], [zipcode]
	FROM   [dbo].[Users]
	WHERE  [userID] = @userID	
	-- End Return Select <- do not remove

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_VenuesDelete]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_VenuesDelete] 
    @venueid int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	DELETE
	FROM   [dbo].[Venues]
	WHERE  [venueid] = @venueid

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_VenuesInsert]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_VenuesInsert] 
    @venueName nvarchar(128) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN
	
	INSERT INTO [dbo].[Venues] ([venueName])
	SELECT @venueName
	
	-- Begin Return Select <- do not remove
	SELECT [venueid], [venueName]
	FROM   [dbo].[Venues]
	WHERE  [venueid] = SCOPE_IDENTITY()
	-- End Return Select <- do not remove
               
	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_VenuesSelect]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_VenuesSelect] 
    @venueid int
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  

	BEGIN TRAN

	SELECT [venueid], [venueName] 
	FROM   [dbo].[Venues] 
	WHERE  ([venueid] = @venueid OR @venueid IS NULL) 

	COMMIT
GO
/****** Object:  StoredProcedure [dbo].[usp_VenuesUpdate]    Script Date: 12/9/2019 1:53:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[usp_VenuesUpdate] 
    @venueid int,
    @venueName nvarchar(128) = NULL
AS 
	SET NOCOUNT ON 
	SET XACT_ABORT ON  
	
	BEGIN TRAN

	UPDATE [dbo].[Venues]
	SET    [venueName] = @venueName
	WHERE  [venueid] = @venueid
	
	-- Begin Return Select <- do not remove
	SELECT [venueid], [venueName]
	FROM   [dbo].[Venues]
	WHERE  [venueid] = @venueid	
	-- End Return Select <- do not remove

	COMMIT
GO
USE [master]
GO
ALTER DATABASE [TicketAmateur] SET  READ_WRITE 
GO
