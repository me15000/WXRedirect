USE [web.wxredirect]
GO
/****** Object:  Table [dbo].[url.data]    Script Date: 05/21/2018 16:09:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[url.data](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[link] [varchar](3000) NULL,
	[date] [datetime] NULL,
	[enddate] [datetime] NULL,
	[code] [varchar](50) NOT NULL,
	[tickets] [varchar](96) NULL,
	[ticketsdate] [datetime] NULL,
	[pk] [varchar](50) NULL,
	[cou] [int] NULL,
 CONSTRAINT [PK_url.data] PRIMARY KEY CLUSTERED 
(
	[code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
