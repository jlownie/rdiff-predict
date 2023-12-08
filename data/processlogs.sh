#!/bin/bash

# Function for extracting a field from the log file
function extractField()
{
	logfile=$1
	fieldname=$2
	outputfile=$tempdir/$fieldname
	
	debugmsg "Extracting $fieldname from $logfile to $outputfile"
	
	# Column header
	echo $fieldname > $outputfile
	
	# Column data
	grep $fieldname $logfile | cut -d ' ' -f 2 >> $outputfile
}

# Essentially this is a placeholder so I can later implement a verbose CLI switch
function debugmsg()
{
	echo $1
}

# The names of the fields in the log files
fieldnames="ElapsedTime SourceFileSize MirrorFiles MirrorFileSize NewFiles NewFileSize DeletedFiles DeletedFileSize ChangedFiles ChangedSourceSize ChangedMirrorSize IncrementFiles IncrementFileSize TotalDestinationSizeChange"

# Dirs
tempdirroot=/tmp
tempdir=$tempdirroot/rdiff-predict

# Files for fields
elapsed=$tempdir/elapsed

### Code execution starts here

# Prepare temp dir
mkdir -p $tempdir > /dev/null

# Process logs
for logfile in $(ls logs/*.log); do
	debugmsg "Processing $logfile"
	
	# Extract each field to its own file
	for field in $fieldnames; do extractField $logfile $field; done
	
	# Combine all the columns into a single file
	
	# First put together a list of all the output files
	filelist=""
	for field in $fieldnames; do filename=$tempdir/$field; filelist="$filelist $filename"; done
	
	debugmsg "Combining files $filelist"
	csvfile=$(echo $logfile | sed 's:logs/::' | sed 's/.log//').csv
	debugmsg "Writing to $csvfile"
	paste -d ',' $filelist > $csvfile
done
