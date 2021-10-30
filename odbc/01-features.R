library(odbc)
.c <- dbConnect(drv = odbc::odbc(), 
                driver = "{SQL Server}", 
                server = "server_name", 
                database = "database_name")