### Libraries.
source("connectSQL.R") # Call the connectSQL.R file like a library to use its functions.

# Get all NVRL_IDs from metadata with reportable status. Returns a dataframe with NVRL_IDs and empty metadata columns.
get_metadata_df <- function(){
  
  # Get the NVRL_ID from Metadata table where Sequence is reportable using the inner join syntax.
  sql_query = paste0("SELECT NVRL_ID FROM Metadata meta inner join Sequence s on meta.ID=s.FK_Metadata_ID AND s.Reportable = 1")
  rs <- dbSendQuery(con_sql, sql_query)
  NVRL_IDs <- dbFetch(rs)$NVRL_ID
  dbClearResult(rs)
  
  # Create Metadata data frame
  empty_cols <- c("Age", "DOB(YYYY-MM-DD)", "Gender", "Sample_date(YYYY-MM-DD)", "Geographical_location", "County")
  metadata_df <- data.frame(NVRL_IDs)
  metadata_df[, empty_cols] <- ""
 
  return(metadata_df) 
}

### Workflow
# Connect to database.
db_connect()
# Get the 
metadata_df <- get_metadata_df()
# Disconnect from database.
db_disconnect()
# Write the metadata df as csv.
write.csv(metadata_df, paste0("metadata_NVRL_IDs_", Sys.Date(), ".csv"), row.names = FALSE)

# Configure the gmail credentials.
gm_auth_configure(path = "/home/gabriel/Desktop/Jose/NVRL_documents/GmailReporting/GmailCredentials.json")
# Create test email
test_email <- gm_mime() %>%
  gm_to("jose.urtasunelizari@ucd.ie, gabo.gonzalez@ucd.ie") %>%
  gm_from("jose.urtasunelizari.reporting@gmail.com") %>%
  gm_subject("Metadata csv with NVRL_IDs") %>%
  gm_text_body("Hi,
  
Please find attached a csv file with the NVRL_IDs of the reportable sequences.
Disclaimer: This is an automated message, if you have any
questions please contact me at jose.urtasunelizari@ucd.ie
Best wishes,
Josemari") %>%
  gm_attach_file(paste0("/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Scripts/DB_tables/metadata_NVRL_IDs_", Sys.Date(), ".csv"))

# Send the email.
gm_send_message(test_email)

