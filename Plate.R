### This script is designed to use the sequences_file loaded on the connectSQL.R

### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Get the plate information from sequence_file.
platedata_standard_format <- function(sequences_file_entry){
  plate_name <- sequences_file_entry$PlateName
  sequence_date <- Sys.Date()
  standard_info <- data.frame(plate_name, sequence_date)
  return(standard_info)
}

# Inserts new plate data into mysql database. Gets a list(Name = , Sequence_date = ) as input. 
insert_plate_sql <- function(sqldata_list){
  
  # Check if plate name already exists by selecting it before adding it.
  sql_query = paste0("SELECT Name from Plate WHERE Name = '", sqldata_list$Name, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  # If fetched result is more than length 0, it means that it already exists. If length is 0, add new Plate.
  if (nrow(result) == 0){
    sql_query = paste0("INSERT INTO Plate (Name, Sequence_date) VALUES ('", sqldata_list$Name, "', '", sqldata_list$Sequence_date, "');")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}

### Workflow
# Activate data base connection.
db_connect()
# Loop through the rows on the sequence_file.
for (i in 1:nrow(sequences_file)){
  # Get the current entry.
  current_entry <- sequences_file[i,]
  # Get the plate data using the plate_standard_format function,
  plate_data <- platedata_standard_format(current_entry)
  # Make the plate data list to input the insert_plate function.
  plate_data <- list(Name = plate_data$plate_name,
                     Sequence_date = plate_data$sequence_date)
  # Call the insert_plate function 
  insert_plate_sql(plate_data)
}
# Deactivate data base connection.
db_disconnect()


