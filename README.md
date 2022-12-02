# This set of scripts uploads flu sequencing data to a mysql database

This set of scripts

-The upload_pipeline.sh file is the parent script to run. It calls the Plate.R, Metadata.R, Sequence.R, Mutation.R, Sequence_mutation.R and mail_report.R files IN THAT ORDER to fill all the relational tables of the NVRL_FLU database.

-All these scripts above use the same two Master_Assembly and Master_Mutation files specified on the connectSQL.R file, which also contains database connect and disconnect functions.

-The structure of the sql database is on the MySQL_NVRL_FLU_DB.txt.

-The Load_Metadata.R file runs on its own and should run AFTER the previous upload_pipeline.sh is completed. It uses a metadata_NVRL_IDs file produced by the mail_report.R file.

