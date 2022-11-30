### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Insert data into the Metadata table manually.
insert_metadata <- function(nvrl_id, name, last_name, age, date_of_birth, gender, sample_date, geographical_location, county){
  # Create the complete SQL command for inserting data and print it.
  sql_insert_query = paste0("INSERT INTO Metadata (NVRL_ID, Name, Last_name, Age, Date_of_birth, Gender, Sample_date, Geographical_location, County) VALUES ('", nvrl_id, name, "','", name, "','", last_name, "','", age, "','", date_of_birth,  "','", gender, "','", sample_date, "','", geographical_location, "','", county, "')")
  print(sql_insert_query)
  # Connect to MySQL, execute the query and clear the result.
  rs <- dbSendQuery(con_sql, sql_insert_query)
  dbClearResult(rs);
}

# Insert NVRL_ID.
insert_NVRL_ID_sql <- function(sequence_file_entry){
  NVRL_ID <- sequence_file_entry$NVRL_ID
  # Select NVRL ID.
  sql_query = paste0("SELECT NVRL_ID from Metadata where NVRL_ID = '", NVRL_ID, "'")
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  # If fetched result is more than length 0, it means that it already exists. If length is 0, add new NVRL_ID.
  if (nrow(result) == 0){
    sql_query = paste0("INSERT INTO Metadata (NVRL_ID) VALUES ('", NVRL_ID, "')")
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}  

### Workflow
# Activate data base connection.
db_connect()
# Loop through the sequence_file rows and insert all NVRL_Id in the metadata table.
for (i in 1:nrow(sequences_file)){
  current_entry <- sequences_file[i,]
  insert_NVRL_ID_sql(current_entry)
}
# Deactivate data base connection.
db_disconnect()
