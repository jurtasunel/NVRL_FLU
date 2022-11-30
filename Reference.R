### This script is designed to use the reference_file loaded on the connectSQL.R

### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

### FUNCTIONS.
# Insert data into the reference table from fasta file and segments dictionary file.
insert_ref_segfile <- function(is.assembly = TRUE){
  # Read segments file
  segments_file <- read_ods(segments_path)
  segment <- segments_file$Segment[segments_file$Accession_number==acs_num]
  ### ###
  assembly = ifelse(is.assembly,1,0)
  # Read the fasta file with the read.fasta function from seqinr.
  # Read the calc sheet with the segments and accession numbers with read_ods from readODS.
  
  # Loop through the lenght of the fasta file (the number of sequences on the file).
  for (i in 1:length(fasta_file)){
    # Extract the different elements from the fasta file.
    ref_seq <- fasta_file[[i]]
    description <- names(fasta_file)[i]
    acs_num <- unlist(strsplit(names(fasta_file)[i], "/"))[1]
    # Get the segment of the sequence by comparing the accession number to the segment dictionary file.
    segment <- segments_file$Segment[segments_file$Accession_number==acs_num]
    # Create the complete SQL command for inserting data and print it.
    sql_insert_query = paste0("INSERT INTO Reference (Accession_number, Ref_sequence, Segment, Description) VALUES ('", acs_num, "', '", ref_seq, "', '", segment, "', '", description,"')")
    print(sql_insert_query)
    # Connect to MySQL, execute the query and clear the result.
    rs <- dbSendQuery(con_sql, sql_insert_query)
    dbClearResult(rs);
  }
}
# Insert references to reference table in mysql from standard fasta file named _REFS.fas.
insert_ref <- function(is.assembly = TRUE){
  assembly = ifelse(is.assembly,1,0) # By default assembly = TRUE and becomes 1. If false, write FALSE as function argument and assembly will become 0.
  for (i in 1:length(reference_file)){
    underscorepos <- unlist(gregexpr("_", names(reference_file)[i])) # Get the positions of the underscores.
    acsnum_underscore <- underscorepos[which(underscorepos > 4)[1]] # The first underscore after the forth position separates the accession number (some accessions have underscore before 4th position splitting the name in two).
    acs_num <- substr(names(reference_file)[i], start = 1, stop = acsnum_underscore-1) # Get the string between position 1 and the position of the acsnum_underscore. Subtract one so the underscore after the name doesn't appear. 
    ref_seq <- gsub(pattern = "-", replacement = "", x = reference_file[[i]]); # Remove the "-" 
    segment <- tail(unlist(strsplit(names(reference_file)[i], "_", fixed = TRUE)), 1)
    description <- names(reference_file)[i]
    upload_date <- Sys.Date()
    sql_query = paste0("INSERT INTO Reference (Accession_number, Ref_sequence, Segment, Description, Assembly, Upload_date) VALUES ('", acs_num, "', '", ref_seq, "', '", segment, "', '", description, "', '", assembly, "', '", upload_date, "');")
    print(sql_query)
    rs <- dbSendQuery(con_sql, sql_query)
    dbClearResult(rs)
    
  }
}
# Inserts new reference data on mysql reference table. Gets a list(Accession_number = , Ref_sequence = , Segment = , Description = , Assembly = , Upload_date = ) as input.
insert_ref_sql <- function(sqldata_list){
  sql_query = paste0("INSERT INTO Reference (Accession_number, Ref_sequence, Segment, Description, Assembly, Upload_date) VALUES ('", Accession_number, "', '", Ref_sequence, "', '", Segment, "', '", Description, "', '", Assembly, "', '", Upload_date, "');")
  rs <- dbSendQuery(con_sql, sql_query)
  dbClearResult(rs)
  
}
# Update columns of Reference table based on condition.
update_ref_sql <- function(data_to_update){
  sql_query = paste0("UPDATE Reference SET Assembly = '", 0, "' where (Accession_number = '", data_to_update, "')")
  rs <- dbSendQuery(con_sql, sql_query)
  dbClearResult(rs)
}

# Get the assembly yes/no boolean, upload date, description and sequence from a fasta file. Returns general_info data frame with assembly, upload_date, description, ref_seq.
ref_general <- function(reference_file_entry, is.assembly = TRUE){
  assembly = ifelse(is.assembly, 1, 0) # By default assembly = TRUE and becomes 1. If false, write FALSE as function argument and assembly will become 0.
  upload_date <- Sys.Date()
  description <- names(reference_file_entry)
  ref_seq <- gsub(pattern = "-", replacement = "", x = reference_file_entry[[1]])
  general_info <- data.frame(assembly, upload_date, description, ref_seq)
  return(general_info)
}
# Get the accession numbers and segment from Gabo standard fasta files named _REFS.fas. Returns standard_info data frame with acs_num and segment.
ref_standard_format <- function(reference_file_entry){
  underscorepos <- unlist(gregexpr("_", names(reference_file_entry))) # Get the positions of the underscores.
  acsnum_underscore <- underscorepos[which(underscorepos > 4)[1]] # The first underscore after the forth position separates the accession number (some accessions have underscore before 4th position splitting the name in two).
  acs_num <- substr(names(reference_file_entry), start = 1, stop = acsnum_underscore-1)
  segment <- tail(unlist(strsplit(names(reference_file_entry), "_", fixed = TRUE)), 1)
  standard_info <- data.frame(acs_num, segment)
  return(standard_info)
}
# Get the accession number and segment from non standard fasta files. Returns alt_info data frame with acs_num and segment.
ref_alt_format <- function(reference_file_entry){
  segment = 4
  acs_num <- unlist(strsplit(names(reference_file_entry), "_", fixed = TRUE))[1]
  alt_info <-  data.frame(acs_num, segment)
  return(alt_info)
}

# Get accession numbers from all existing entries on the Reference table. Returns a vector.
get_existing_acsnum <- function(){
  
  sql_query = "SELECT Accession_number FROM Reference"
  rs <- dbSendQuery(con_sql, sql_query)
  # Store the IDs on a temporal variable.
  existing_acsnum <- dbFetch(rs)
  # By default, dbFetch stores variable into a dataframe, so save it as a vector.
  existing_acsnum <- existing_acsnum$Accession_number
  dbClearResult(rs)
  return(existing_acsnum)
}
# Get the reference ID of a given plate based on its accession number.
get_reference_ID <- function(ref_accession_number) {
  # Create the complete command for selecting data.
  sql_select_query = paste0("SELECT ID FROM Reference WHERE Accession_number = '", ref_accession_number, "'")
  # Connect to MySQL and get execute the query.
  rs <- dbSendQuery(con_sql, sql_select_query)
  result <- dbFetch(rs)[1,1]
  dbClearResult(rs)
  return(result)
}









