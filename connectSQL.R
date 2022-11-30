### Libraries.
library(RMariaDB) # package DBI-based for connection to MySQL.
library(DBI) # package for R-Databases communication.
library(seqinr) # package for handling fasta files into R.
library(readODS) # package to read ods libreoffice files into R.
library(gmailr)
#library(ape)

### VARIABLES.
# Set working directory to the location of the scripts.
setwd("/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Scripts/DB_tables")
# Define constants for log into MySQL and access the NVRL_FLU database.
USER <- "XXXX"
PSW <- "XXXX"
DB_NAME <- "NVRL_FLU"
HOST <- "localhost"
# Define global variable for MySQL connection.
con_sql = NULL;

### FUNCTIONS.
# Connect to MySQL Database.
db_connect <- function(){
  con_sql <<- dbConnect(RMariaDB::MariaDB(),
                        user = USER,
                        password = PSW,
                        dbname = DB_NAME,
                        host = HOST);
}
# Disconnect from MySQL Database. 
db_disconnect <- function(){
  dbDisconnect(con_sql);
}
# General select function based on condition.
select_sql <- function(column_to_select, table_to_select, condition_column, condition_entry){
  # Connect to database.
  db_connect()
  # Sql command.
  sql_query = paste0("SELECT ", column_to_select, " FROM ", table_to_select, " WHERE ", condition_column," = '", condition_entry, "'")
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  db_disconnect()
  return(result)
}

# Give the path for a fasta files and metadata files.
datapath = "/home/gabriel/Dropbox/000_FLU_RUNS/"
#reference_path = paste0(datapath, list.files(datapath, "21.fas"))
#reference_file <- read.fasta(reference_path, as.string = TRUE, forceDNAtolower = FALSE, set.attributes = FALSE)
sequences_path = paste0(datapath, list.files(datapath, "Master_Assembly.tsv"))
sequences_file <- read.table(sequences_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE)
mutations_path = paste0(datapath, list.files(datapath, "Master_Mutations.tsv"))
mutations_file <- read.table(mutations_path, sep = "\t", header = TRUE, stringsAsFactors = FALSE)

# Give path for the influenza-segment dictionary file.
# segments_path = "/home/gabriel/Desktop/Jose/Reference_sequences/Influenza_segments.ods"

  





