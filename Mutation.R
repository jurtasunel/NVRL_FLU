### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Get the fks based on the reference of the mutation_file.
mutdata_standard_fk <- function(mutations_file_entry){
  # Sql select command.
  sql_query = paste0("SELECT ID, Segment FROM Reference WHERE Description = '", mutations_file_entry$Reference, "'")
  rs <- dbSendQuery(con_sql, sql_query)
  res <- dbFetch(rs)
  dbClearResult(rs)
  # Get the fk on different variables and store them in data frame to return it.
  fk_ref_ID <- res$ID
  Segment <- res$Segment
  fk_info <- data.frame(fk_ref_ID, Segment)
  return(fk_info)
}
# Get the data in standard format from the mutation_file.
mutdata_standard_format <- function(mutations_file_entry){

  Position_Aa <- mutations_file_entry$Ref.Pos
  Reference_Aa <- mutations_file_entry$Ref.AA
  Mutation_Aa <- mutations_file_entry$Query.AA
  # Return the data as a data frame.
  standard_info <- data.frame(Position_Aa, Reference_Aa, Mutation_Aa)
  return(standard_info)
  
}

# Insert data into the mutation table. Takes a list(FK_Reference_ID = , Segment = , Position_Aa = , Reference_Aa = , Mutation_Aa = ) as input.
insert_mutdata_sql <- function(sqldata_list){
  # Check if mutation already exists by selecting it before adding it.
  sql_query = paste0("SELECT FK_Reference_ID, Position_Aa, Mutation_Aa from Mutation where FK_Reference_ID = '", sqldata_list$FK_Reference_ID, "' AND Position_Aa = '", sqldata_list$Position_Aa, "' AND Mutation_Aa = '", sqldata_list$Mutation_Aa, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  # If fetched result is more than length 0, it means that it already exists. If length is 0, add new Mutation
  if (nrow(result) == 0){
    sql_query <- paste0("INSERT INTO Mutation (FK_Reference_ID, Segment, Position_Aa, Reference_Aa, Mutation_Aa) VALUES ('", sqldata_list$FK_Reference_ID, "', '", sqldata_list$Segment, "', '", sqldata_list$Position_Aa, "', '", sqldata_list$Reference_Aa, "', '", sqldata_list$Mutation_Aa, "')")
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
  }
}

### Workflow
# Activate data base connection.
db_connect()
# Loop through the mutations file.
for (i in 1:nrow(mutations_file)){
  # Store the current entry.
  current_entry <- mutations_file[i,]
  # Get the data using the mutdata functions.
  muts_data <- mutdata_standard_format(current_entry)
  muts_data_fk <- mutdata_standard_fk(current_entry)
  
  # Make the list to input the insert function.
  mutations_data <- list(FK_Reference_ID = muts_data_fk$fk_ref_ID,
                         Segment = muts_data_fk$Segment,
                         Position_Aa = muts_data$Position_Aa,
                         Reference_Aa = muts_data$Reference_Aa,
                         Mutation_Aa = muts_data$Mutation_Aa)
  # Insert the data into the mutation table.
  insert_mutdata_sql(mutations_data)
}
# Deactivate data base connection
db_disconnect()

















