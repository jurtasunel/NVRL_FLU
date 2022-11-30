### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Get only the accession number from the assembly ID which also has the HN profile and the segment separated by underscores.
get_acsnum_from_name <- function(assembly_seq_name){
  underscorepos <- unlist(gregexpr("_", assembly_seq_name)) # Get the positions of the underscores.
  acsnum_underscore <- underscorepos[which(underscorepos > 4)[1]] # The first underscore after the forth position separates the accession number (some accessions have underscore before 4th position splitting the name in two).
  acs_num <- substr(assembly_seq_name, start = 1, stop = acsnum_underscore-1)
}
# Get the sequence table information from the sequence_file that is in standard non changing format and never NA.
seqdata_standard_format <- function(sequences_file_entry, is.reportable = TRUE){
  # By default, reportable is TRUE and if stated false as argument will become FALSE.
  reportable = is.reportable
  sequence <- sequences_file_entry$Sequence
  barcode <- sequences_file_entry$Barcode
  coverage <- sequences_file_entry$Coverage
  completion <- sequences_file_entry$Completion
  # If completion values is NA, save it as a 0 to match the sql data type.
  if (is.na(completion) == TRUE){completion <- 0}
  # Store the information in a data frame and return it.
  standard_info <- data.frame(reportable, sequence, barcode, coverage, completion)
  return(standard_info)
}
# Get the fk from the sequence_file that is never NA.
seqdata_standard_fks <- function(sequence_file_entry){
  # Get the fk_assembly_ID using the Assembly sequence name.
  ref_acs_num <- get_acsnum_from_name(sequence_file_entry$Assembly_Sequence_name)
  sql_query = paste0("SELECT ID FROM Reference WHERE Accession_number = '", ref_acs_num, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  fk_assembly_ID <- dbFetch(rs)$ID
  dbClearResult(rs)
  # Get the fk_metadata_ID using the NVRL_ID.
  sql_query = paste0("SELECT ID FROM Metadata WHERE NVRL_ID = '", sequence_file_entry$NVRL_ID, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  fk_metadata_ID <- dbFetch(rs)$ID
  dbClearResult(rs)
  # Get the fk_plate_ID using the plate name.
  sql_query = paste0("SELECT ID FROM Plate WHERE Name = '", sequence_file_entry$PlateName, "'")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  fk_plate_ID <- dbFetch(rs)$ID
  dbClearResult(rs)
  # Store the information in a data frame and return it.
  fk_information <- data.frame(fk_assembly_ID, fk_metadata_ID, fk_plate_ID)
  return(fk_information)
}
# Get the values that can be NA on the sequence_file.
seqdata_na_values <- function(sequence_file_entry){
  # Get the fk_reference_ID based on the assessment column of the sequence file.
  sql_query = paste0("SELECT ID FROM Reference WHERE Description = '", sequence_file_entry$Assessment_Sequence_name, "'")
  rs <- dbSendQuery(con_sql, sql_query)
  fk_ref_ID <- dbFetch(rs)$ID
  dbClearResult(rs)
  # Get the similarity.
  similarity <- sequence_file_entry$Similarity
  seq_na_data <- data.frame(fk_ref_ID, similarity)
  return(seq_na_data)
}

# Insert standard data that is no NA on the sequences_file into sequence table. Gets a list(Sequence = , FK_Plate_ID = , Reportable = , Barcode = , FK_Metadata_ID = , Coverage = , Completion = , FK_Assembly_ID = ) as input.
insert_standard_seqdata_sql <- function(sqldata_list){
  
  sql_query = paste0("INSERT INTO Sequence (Sequence, FK_Plate_ID, Reportable, Barcode, FK_Metadata_ID, Coverage, Completion, FK_Assembly_ID) VALUES ('", sqldata_list$Sequence, "', '", sqldata_list$FK_Plate_ID, "', ", sqldata_list$Reportable, ", '", sqldata_list$Barcode, "', '", sqldata_list$FK_Metadata_ID, "', '", sqldata_list$Coverage, "', '", sqldata_list$Completion, "', '", sqldata_list$FK_Assembly_ID, "')")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  dbClearResult(rs)
}
# Update data that might be NA on the sequences_file into the sql sequence table based on maximum ID. Gets a list(FK_Reference_ID =, Similarity = ) as input.
update_na_seqdata_sql <- function(sqldata_list){
  # Get maximun ID of reference. This can be done because sequences are added one after one on loop, so whenever this function is called for non NA values, it will be the latest one with the biggest curent ID.
  sql_max_query <- "SELECT MAX(ID) FROM Sequence"
  rs <- dbSendQuery(con_sql, sql_max_query)
  max_ID <- dbFetch(rs)$`MAX(ID)`
  dbClearResult(rs)
  # Send the update query.
  sql_query = paste0("UPDATE Sequence SET FK_Reference_ID = '", sqldata_list$FK_Reference_ID, "', Similarity = '", sqldata_list$Similarity, "' where (ID = '", max_ID, "')")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  dbClearResult(rs)
}
# Checks if an entry of the sequence file exists. If it exists returns 1, if it doesn't returns 0.
check_sequence_exist <- function(sequence_file_entry){
  sql_query = paste0("SELECT FK_Plate_ID, Barcode, FK_Assembly_ID FROM Sequence WHERE (FK_Plate_ID=(SELECT ID FROM Plate WHERE Name = '", sequence_file_entry$PlateName, "') AND Barcode = '", sequence_file_entry$Barcode, "' AND FK_Assembly_ID=(SELECT ID FROM Reference WHERE Accession_number = '", get_acsnum_from_name(sequence_file_entry$Assembly_Sequence_name),"'))")
  #print(sql_query)
  rs <- dbSendQuery(con_sql, sql_query)
  result <- dbFetch(rs)
  dbClearResult(rs)
  result <- nrow(result)
  return(result)
}

### Workflow
# Activate data base connection.
db_connect()
# Loop through the rows of the sequence_file.
for (i in 1:nrow(sequences_file)){
  # Get the current entry.
  current_entry <- sequences_file[i,]
  
  # Do only if current entry doesn't exist yet.
  if (check_sequence_exist(current_entry) == 0){
    
    # Get the standard data and the fk data using the seqdata_standard_format and seqdata_standard_fks functions.
    seqs_data <- seqdata_standard_format(current_entry)
    fk_data <- seqdata_standard_fks(current_entry)
    # Make the list to input the insert_standard_seqdata_sql function.
    sequence_data <- list(Sequence = seqs_data$sequence,
                        FK_Plate_ID = fk_data$fk_plate_ID,
                        Reportable = seqs_data$reportable,
                        Barcode = seqs_data$barcode,
                        FK_Metadata_ID = fk_data$fk_metadata_ID,
                        Coverage = seqs_data$coverage,
                        Completion = seqs_data$completion,
                        FK_Assembly_ID = fk_data$fk_assembly_ID)
    # Insert the data into sql sequence table.
    insert_standard_seqdata_sql(sequence_data)
  
    # If the assessment_Sequence_name is not NA:
    if (is.na(current_entry$Assessment_Sequence_name) == FALSE){
      # Get the data similarity and fk_reference_ID usign the seqdata_na_values function
      seqs_data_na <- seqdata_na_values(current_entry)
      # Make the list required to input the insert_na_seqdata_sql function.
      sequence_data_na <- list(FK_Reference_ID = seqs_data_na$fk_ref_ID,
                               Similarity = seqs_data_na$similarity)
      # Insert the two values using the insert_na_seqdata_sql function.
      update_na_seqdata_sql(sequence_data_na)
    }
  }
}
# Deactivate data base connection
db_disconnect()



















