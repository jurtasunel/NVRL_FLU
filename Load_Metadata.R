### Libraries.
library(RMariaDB) # package DBI-based for connection to MySQL.
library(DBI) # package for R-Databases communication.
library(seqinr) # package for handling fasta files into R.
library(readODS) # package to read ods libreoffice files into R.
library(gmailr)
library(stringr) # handle strings and pattern matching.
library(lubridate)

### Constants
# Set working directory to the location of the scripts.
setwd("/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Scripts/DB_tables")
# Load the metadata file.
datapath = "/home/gabriel/Dropbox/000_FLU_RUNS/"
metadata_path = paste0(datapath, list.files(datapath, "metadata_NVRL_IDs"))
metadata_file <- read.csv(metadata_path, header = TRUE, stringsAsFactors = FALSE)
# Get the path to the uploaded data folder.
uploaded_data_path = "/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Data/Uploaded_data"
# Define constants for log into MySQL and access the NVRL_FLU database.
USER <- "NVRL"
PSW <- "Abm@Hs4#6xj3"
DB_NAME <- "NVRL_FLU"
HOST <- "localhost"
# Define global variable for MySQL connection.
con_sql = NULL

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

# Change reportable status from 1 to 0 for a given NVRL_ID.
update_non_rep <- function(NVRL_ID){
  sql_query = paste0("UPDATE Sequence SET Reportable = 0 WHERE FK_Metadata_ID =(SELECT ID FROM Metadata WHERE NVRL_ID = '", NVRL_ID, "')")
  # print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  dbClearResult(rs)
}
# Check NVRL_ID format.
is_NVRL_ID <- function(NVRL_ID){
  
  # Match the input argument to the regular expression of an NVRL_ID format.
  if (grepl("\\d{2}\\D\\d{5,8}", NVRL_ID) == TRUE){
    result <- TRUE
    } else {result <- FALSE}

  return(result)
}

# Update the different columns on the metadata table.
update_age <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$Age) == TRUE || metadata_file_entry$Age == "" || metadata_file_entry$Age == "#N/A" || metadata_file_entry$Age == "NA")){
    
    sql_query = paste0("UPDATE Metadata SET AGE = '", metadata_file_entry$Age,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}
update_dob <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$DOB.YYYY.MM.DD.) == TRUE || metadata_file_entry$DOB.YYYY.MM.DD. == "" || metadata_file_entry$DOB.YYYY.MM.DD. == "#N/A" || metadata_file_entry$DOB.YYYY.MM.DD. == "NA")){
    
    # Format date to match sql date format.
    sql_date <- dmy(gsub("/", "", metadata_file_entry$DOB.YYYY.MM.DD.))
    
    sql_query = paste0("UPDATE Metadata SET Date_of_birth = '", sql_date,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}
update_gender <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$Gender) == TRUE || metadata_file_entry$Gender == "" || metadata_file_entry$Gender == "#N/A" || metadata_file_entry$Gender == "NA")){
    
    sql_query = paste0("UPDATE Metadata SET Gender = '", metadata_file_entry$Gender,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}
update_sampledate <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$Sample_date.YYYY.MM.DD.) == TRUE || metadata_file_entry$Sample_date.YYYY.MM.DD. == "" || metadata_file_entry$Sample_date.YYYY.MM.DD. == "#N/A" || metadata_file_entry$Sample_date.YYYY.MM.DD. == "NA")){
    
    # Format date to match sql date format.
    sql_date <- dmy(gsub("/", "", metadata_file_entry$Sample_date.YYYY.MM.DD.))
    
    sql_query = paste0("UPDATE Metadata SET Sample_date = '", sql_date,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}
update_geograp <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$Geographical_location) == TRUE || metadata_file_entry$Geographical_location == "" || metadata_file_entry$Geographical_location == "#N/A" || metadata_file_entry$Geographical_location == "NA")){
    
    sql_query = paste0("UPDATE Metadata SET Geographical_location = '", metadata_file_entry$Geographical_location,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}
update_county <- function(metadata_file_entry){
  
  # Do the update only if the value is not NA or empty.
  if (!(is.na(metadata_file_entry$County) == TRUE || metadata_file_entry$County == "" || metadata_file_entry$County == "#N/A" || metadata_file_entry$County == "NA")){
    
    sql_query = paste0("UPDATE Metadata SET County = '", metadata_file_entry$County,"' WHERE NVRL_ID = '", metadata_file_entry$NVRL_IDs, "'")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}

### Workflow
print("Loading Metadata table from metadata_NVRL_IDs")
# Connect to database.
db_connect()
# Loop through the metadata file rows.
for (i in 1:nrow(metadata_file)){
  # Get the current entry from the metadata file.
  current_entry <- metadata_file[i,]
  
  # If 
  if (is_NVRL_ID(current_entry$NVRL_IDs) == TRUE){
    update_age(current_entry)
    update_dob(current_entry)
    update_gender(current_entry)
    update_sampledate(current_entry)
    update_geograp(current_entry)
    update_county(current_entry)
  } else{
    update_non_rep(current_entry$NVRL_IDs)
  }
}
# Disconnect from database.
db_disconnect()

print(paste0("Moving metadata_NVRL_IDs file from ", datapath, " to ", uploaded_data_path))
system(paste0("mv ", datapath, list.files(datapath, "metadata_NVRL_IDs"), " ", uploaded_data_path))










