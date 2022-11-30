#!/bin/bash

# This script calls different Rscripts in specific order to upload data to mysql tables of the NVRL_FLU database.

# Get the directory that has all the scripts.
scripts_dir="/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Scripts/DB_tables"
uploaded_data_path="/home/gabriel/Desktop/Jose/Projects/NVRL_FLU/Data/Uploaded_data"

# Get the location of the dropbox folder and expected file names.
dropbox_path="/home/gabriel/Dropbox/000_FLU_RUNS"
assembly_file="${dropbox_path}/*Master_Assembly.tsv"
mutation_file="${dropbox_path}/*Master_Mutations.tsv"

# Do if both master files exist on dropbox folder:
if (ls ${assembly_file} 1> /dev/null 2>&1) && (ls ${mutation_file} 1> /dev/null 2>&1);
then
	# Call Rscripts to load tables using the Master_Assembly.tsv file.
	echo "loading table Plate data from Master_Assembly.tsv file"
	Rscript ${scripts_dir}/Plate.R
	echo "loading table Metadata with NVRL_IDs from Master_Assembly.tsv file"
	Rscript ${scripts_dir}/Metadata.R
	echo "loading table Sequences from Master_Assembly.tsv file"
	Rscript ${scripts_dir}/Sequence.R

	# Call Rscripts to load tables using the Master_Mutations.tsv file.
	echo "loading table Mutations from Master_Mutations.tsv file"
	Rscript ${scripts_dir}/Mutation.R
	echo "loading table Sequence_mutation from Master_Mutations.tsv file"
	Rscript ${scripts_dir}/Sequence_mutation.R

	# Call Rscript to generate the Metadata csv with the reportable NVRL_IDs and email it.
	echo "Generating Metadata csv file with reportable NVRL_IDs"
	Rscript ${scripts_dir}/mail_report.R
else
	echo "Missing master files on ${dropbox_path}"
fi

# Move the Master files to the uploaded data folder and remove the metadata_NVRL_IDs file.
mv ${assembly_file} ${mutation_file} ${uploaded_data_path}
rm metadata_NVRL_IDs*




