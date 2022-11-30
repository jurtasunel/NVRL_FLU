### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Get foreign key IDs from sequence table and mutation table based on reference table.
seqmut_fks <- function(mutations_file_entry){
  
  # Get the ID from sequence table using the NVRL_ID from Metadata table and the Description form the Reference table.
  sql_query = paste0("SELECT ID FROM Sequence WHERE (FK_Metadata_ID =(SELECT ID FROM Metadata WHERE NVRL_ID = '", mutations_file_entry$Query, "') AND FK_Reference_ID = (SELECT ID FROM Reference WHERE Description = '", mutations_file_entry$Reference, "'))")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  FK_Sequence_ID <- dbFetch(rs)$ID
  dbClearResult(rs)

  # Get the ID from mutation table using the AA position and mutation table and the Description form the Reference table.
  sql_query = paste0("SELECT ID FROM Mutation WHERE (Mutation_Aa = '", mutations_file_entry$Query.AA,"' AND Position_Aa = '", mutations_file_entry$Ref.Pos, "' AND FK_Reference_ID =(SELECT ID FROM Reference WHERE Description = '", mutations_file_entry$Reference, "'))")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  FK_Mutation_ID <- dbFetch(rs)$ID
  dbClearResult(rs)
  
  # Get both fks into a data frame to report it.
  fks_info <- data.frame(FK_Sequence_ID, FK_Mutation_ID)
  return(fks_info)
}

# Insert data into the Sequence_mutation table. Gets a list (FK_Sequence_ID =, FK_Mutation_ID =) as input.
insert_seqmutation_sql <- function(sqldata_list){
  
  # Check if plate name already exists by selecting it before adding it.
  sql_query = paste0("SELECT FK_Sequence_ID, FK_Mutation_ID from Sequence_mutation WHERE FK_Sequence_ID = '", sqldata_list$FK_Sequence_ID, "' AND FK_Mutation_ID = '", sqldata_list$FK_Mutation_ID, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  # If fetched result is more than length 0, it means that it already exists. If length is 0, add new Plate.
  if (nrow(result) == 0){
  
    # Create the complete SQL command for inserting data and print it.
    sql_query = paste0("INSERT INTO Sequence_mutation (FK_Sequence_ID, FK_Mutation_ID) VALUES ('", sqldata_list$FK_Sequence_ID, "', '", sqldata_list$FK_Mutation_ID, "')")
    #print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs);
  }
}

### Workflow
# Activate data base connection.
db_connect()
# Loop through the mutations file.
for (i in 1:nrow(mutations_file)){
  
  # Store the current entry and get the fks data.
  current_entry <- mutations_file[i,]
  #print(current_entry)
  seqmuts_data <- seqmut_fks(current_entry)
  # Make the list to input the insert_seqmutation_sql.
  sequencemutation_data <- list(FK_Sequence_ID = seqmuts_data$FK_Sequence_ID,
                                FK_Mutation_ID = seqmuts_data$FK_Mutation_ID)
  
  # Insert the data into the table.
  insert_seqmutation_sql(sequencemutation_data)
  # Deactivate data base connection.
}
# Deactivate data base connection
db_disconnect()
  

  
  