#!/bin/bash
#header
echo ""
echo "SAP HANA Lifecycle Management"
echo "*****************************"
echo ""

#global vriables
SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
TARGET_DIR="$SCRIPT_PATH/extracted";
TARGET_DIR_SPECIFIED='';
SAPCAR_PATH="/usr/sap/hostctrl/exe/SAPCAR"
HAS_WARNING=''

#Loging logic
TIMESTAMP=$(date +%s)
LOG_FILE=""
TEMP_LOG=""

function log {
	if [[ $LOG_FILE ]] ; then 
		echo $1>>"$LOG_FILE"
	else
		TEMP_LOG="$TEMP_LOG\n$1"
	fi
}

function updateLogLocation {
	LOG_FILE="$TARGET_DIR/extract$TIMESTAMP.log"
	echo -e $TEMP_LOG>>"$LOG_FILE"
}


function overwriteTargetDir {
	deleteTargetDir 
	rc=$?
	if [[ $rc -ne 0 ]] ; then
		return $rc
	fi
	createTargetDir
	rc=$?
	if [[ $rc -ne 0 ]] ; then
		return $rc
	fi
}

function deleteTargetDir {
	log "[INFO] Deleting target directory $TARGET_DIR..."
	rm -r -f "$TARGET_DIR"; 
	rc=$?
	if [[ $rc -ne 0 ]] ; then
		log "[ERROR] Failed to delete $TARGET_DIR"
	fi
	return $rc;
}

function createTargetDir {
	log "[INFO] Creating target directory $TARGET_DIR..."
	mkdir -p "$TARGET_DIR"; 
	rc=$?
	if [[ $rc -ne 0 ]] ; then
		log "[ERROR] Failed to create $TARGET_DIR"
	fi
	return  $rc
}

function createNewTargetDir {
	INDEX='1'
	while [[ -e $TARGET_DIR ]] ; do
		TARGET_DIR="$SCRIPT_PATH/extracted$INDEX"
		INDEX=$(( $INDEX + 1 ))
	done
	createTargetDir
}

function handleTargetDirError { 
	if [[ $? -ne 0 ]] ; then #note that return code of last command in if-else bodies is evaluated
		echo "[ERROR] Error in handling target directory"
		log "[ERROR] Error in handling target directory"
		printLogAndExit 1
	else
		log "[INFO] Using target directory $TARGET_DIR"
	fi 
}

function printHelp {
	            echo "USAGE: $0 [-t <target directory>] [-a <SAPCAR path>]"
		    echo ""
                    echo "This script extracts all *.SAR files in its directory to a target directory."
                    echo "Optional arguments:"

		    echo "      -h : Displays the help information"
                    echo "      -t <target directory> : The directory path where the SAP HANA component archives will be extracted in"
                    echo "              [default: -t ./extracted<first free index> e.g './extracted2']"
                    echo "              WARNING: the content of the given path will be overwritten and will be created if it does not exist"
                    echo "      -a <SAPCAR path> : The path to the SAPCAR executable"
                    echo "              Default is /usr/sap/hostctrl/exe/SAPCAR"
                    exit 1
}

function handleUserInput {
	# Parse command line options.
	while getopts t:a:h OPT; do
	    case ${OPT} in
		t)
		    TARGET_DIR="${OPTARG}"
		    TARGET_DIR=$(readlink -m "$TARGET_DIR")
		    TARGET_DIR_SPECIFIED=1
		    ;;
		a)
		    SAPCAR_PATH="${OPTARG}"
		    ;;
		h) 
		    printHelp
		    ;;	
		\?)
		    # getopts issues an error message
		    printHelp
		    ;;
	    esac
	done

	if [[ $TARGET_DIR_SPECIFIED ]] ; then
		
		if [[ -e $TARGET_DIR &&  ! -d $TARGET_DIR ]] ; then
			log "[ERROR] Specified target directory path '$TARGET_DIR' is not a valid directory."
			echo "[ERROR] Specified target directory path '$TARGET_DIR' is not a valid directory."
			printLogAndExit 1
		elif [[ ! -e $TARGET_DIR  ]] ; then
			createTargetDir	
			handleTargetDirError	
		fi
		# if directory exists - do nothing and extract content inside it
	elif [[ -e $TARGET_DIR ]] ; then
		while : ; do
			read -p "The default target directory '$TARGET_DIR' already exists. Do you want to overwrite it?(y/n)[n]" yn
			case $yn in
				[Yy]* ) 
					overwriteTargetDir; 
					handleTargetDirError; 
					break;;
				[Nn]* ) 
					createNewTargetDir; 
					handleTargetDirError; 
					echo "New target directory '$TARGET_DIR' created"
					break;;
				* )  if [ $yn ] ; then 
					echo "Invalid input. Enter y/n or return" 					
				     else
					createNewTargetDir
					handleTargetDirError
					echo "New target directory '$TARGET_DIR' created"
					break ; 
				     fi;;
			esac
		done
		
	else
		createNewTargetDir
		handleTargetDirError
	fi

	updateLogLocation

	if [[ -e $SAPCAR_PATH ]] ; then
		echo "[INFO] SAPCAR found in the following location: $SAPCAR_PATH">>"$LOG_FILE"	
	else
		log "[ERROR] No SAPCAR found in the following location: $SAPCAR_PATH. Please use -a option to specify path to SAPCAR"
		echo "[ERROR] No SAPCAR found in the following location: $SAPCAR_PATH. Please use -a option to specify path to SAPCAR"
		printLogAndExit 1
	fi
}

function printLogAndExit {
	echo "Execution finished with $1">>"$LOG_FILE"
	echo "Log file: $LOG_FILE"
	exit $1
}

#======ARCHIVE MANAGEMENT=========

#list of all sar archives for extraction
ARCHIVES=()
#common archive names of server tar parts.
TAR_COMMON_NAMES=()

function findTarCommonNames {
	OLDIFS=$IFS
	IFS=$'\n'
	declare -a TARS=($(find "$SCRIPT_PATH" -maxdepth 1 -regex '.*P[0-9]+\.[Tt][Aa][Rr]'));	
	for tarPartPath in "${TARS[@]}" ; do
		log "[INFO] Detected server tar archive part at $tarPartPath"

		regex="(.*)P[0-9]+\.[Tt][Aa][Rr]"
		tarName=$(basename "$tarPartPath");
		[[ $tarName =~ $regex ]]
		name="${BASH_REMATCH[1]}"
		
		alreadyFound=false;		
		for found in "${TAR_COMMON_NAMES[@]}"; do 
			if [[ "$found" == "$name" ]] ; then 
				alreadyFound=true; 
				break; 
			fi
		done
		if ! $alreadyFound ; then
			TAR_COMMON_NAMES+=($name)
		fi
	done
	IFS=$OLDIFS
}

function extractTarArchives { 
	declare -a extracted=()
	OLDIFS=$IFS	
	for prefix in 	${TAR_COMMON_NAMES[@]} ; do
		partsRegex='.*'$prefix'P[0-9]+\.[Tt][Aa][Rr]';
		IFS=$'\n'
		declare -a PARTS=($(find "$SCRIPT_PATH" -maxdepth 1 -regex $partsRegex | sort -u));
		arguments="--directory '$TARGET_DIR' -xvM"
		for part in ${PARTS[@]} ; do
			arguments="$arguments -f '$part'"
		done
		IFS=$OLDIFS
		echo "Extracting tar files with prefix $prefix ..."
		log "[INFO] Extracting tar files with prefix $prefix ..."
		#redirect only error stream to log, because we need stdout content
		command="tar $arguments 2>>\"$LOG_FILE\"";
		output=($(eval $command));
		if [[ $? -eq 0 ]] ; then
			log "[INFO] done"
			extracted+=(${output//$'\n'/ })
		else
			echo "[WARNING] Failed to extract tar files with prefix $prefix"
			log "[WARNING] Failed to extract tar files with prefix $prefix"
			HAS_WARNING=1
		fi
	done

	#remove duplicate entries
	uniqueExtractedFiles=($(echo "${extracted[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
	log "[INFO] Extracted files : ${uniqueExtractedFiles[*]} ";
	for i in "${!uniqueExtractedFiles[@]}"; do 
		ARCHIVES+=( "$TARGET_DIR/${uniqueExtractedFiles[$i]}" )
	done
}

function handleTars {
	findTarCommonNames
	log "[INFO] Extracting tar archives for following prefixes : ${TAR_COMMON_NAMES[*]} ";
	extractTarArchives
}

function extractSar {
	archive=$1
	target=$2
	$SAPCAR_PATH -R "$target" -manifest SIGNATURE.SMF -xf "$archive," >> "$LOG_FILE" 2>&1
}

function extractHLM {
	archive=$1
	target="$TARGET_DIR/SAP_HANA_HLM"
	extractSar "$archive" "$target" 
	rc=$?	
	if [[ $rc -ne 0 ]] ; then
		return $rc
	fi
	cp "$archive" "$target"
}

function extractSars {
	log "[INFO] Detecting SAP HANA Components' SAR archives in $SCRIPT_PATH..."
	OLDIFS=$IFS
	IFS=$'\n'
	ARCHIVES+=($(find "$SCRIPT_PATH" -maxdepth 1 -iname '*\.SAR')); 

	for archive in "${ARCHIVES[@]}" ; do
		log "[INFO] detected archive $archive"
	done

	for archive in "${ARCHIVES[@]}" ; do
		echo "Extracting archive $archive..."
		log "[INFO] Extracting $archive..."

		filename=$(basename "$archive")
		hlmRegex=".*SAPHANALM.*"
		shaRegex=".*SAPHOSTAGENT.*"
		if [[ $filename =~ $hlmRegex ]] ; then
			extractHLM "$archive"
		elif [[ $filename =~ $shaRegex ]] ; then
			extractSar "$archive" "$TARGET_DIR/SAP_HOST_AGENT"
		else
			mkdir -p "$TARGET_DIR/tmp"
			extractSar "$archive" "$TARGET_DIR/tmp"
			SUBDIR=`find $TARGET_DIR/tmp/* -maxdepth 1 -type d|head -1`
			if [ -n "$SUBDIR" ] ; then
				if [ -f "$TARGET_DIR/tmp/SIGNATURE.SMF" ] ; then
					mv "$TARGET_DIR/tmp/SIGNATURE.SMF" $SUBDIR
					log "[INFO] Signature file $TARGET_DIR/tmp/SIGNATURE.SMF relocated"
				elif [ ! -f "$SUBDIR/SIGNATURE.SMF" ] ; then
					log "[INFO] There is no signature file for archive $archive"
				fi
			fi
			find "$TARGET_DIR/tmp" -maxdepth 1 -mindepth 1 -exec mv -t "$TARGET_DIR" {} +
			log "[INFO] Content of the archive $archive moved to $TARGET_DIR"
			
			rm -rf "$TARGET_DIR/tmp"
		fi

		if [[ $? -eq 0 ]] ; then
			log "[INFO] done"
		else
			log "[WARNING] Failed to extract $archive"
			echo "[WARNING] Failed to extract $archive"
			HAS_WARNING=1
		fi
	done
	IFS=$OLDIFS
}

function printHintLines {
	declare -a HDBLCMS=()
	OLDIFS=$IFS
	IFS=$'\n'
	declare -a SERVER_DIRS=($(find "$TARGET_DIR" -maxdepth 1 -iname '*DATABASE*'));
	IFS=$OLDIFS
	for serverDir in "${SERVER_DIRS[@]}" ; do
		if [[ -f $serverDir/hdblcm ]] ; then
			HDBLCM_FOUND=1
			HDBLCMS+=( "Command Line Interface: '$serverDir/hdblcm' --component_root '$TARGET_DIR'" )
			HDBLCMS+=( "Graphical User Interface: '$serverDir/hdblcmgui' --component_root '$TARGET_DIR'" )
		fi
	done

	declare -a SHA_LINES=()
	IFS=$'\n'
	declare -a SHA_DIRS=($(find "$TARGET_DIR" -maxdepth 1 -iname 'SAP_HOST_AGENT'));	
	for shaDir in "${SHA_DIRS[@]}" ; do
		if [[ -f $shaDir/saphostexec ]] ; then
			SHA_FOUND=1
			SHA_LINES+=( "'$shaDir/saphostexec'" )
		fi
	done
	IFS=$OLDIFS
	echo ""
	echo ""
	if [[ $HDBLCM_FOUND ]] ; then
		echo "To update the SAP HANA system using hdblcm(gui), use the following lines:"
		for hdblcm in "${HDBLCMS[@]}" ; do
			echo $hdblcm
		done
	else
		echo "To install or update the SAP HANA components:"
		echo "  - For SPS08 or older SAP HANA systems - start hdblcm or hdblcmgui from an SAP HANA installation medium using option --component_root '$TARGET_DIR'"
  		echo "  - For SPS09 or newer systems - start hdblcm or hdblcmgui from <installation_path>/<SID>/hdblcm using option --component_root '$TARGET_DIR' or use the hdblcm Web user interface."

		log "To install or update the SAP HANA components:"
		log "  - For SPS08 or older SAP HANA systems - start hdblcm or hdblcmgui from an SAP HANA installation medium using option --component_root '$TARGET_DIR'"
  		log "  - For SPS09 or newer systems - start hdblcm or hdblcmgui from <installation_path>/<SID>/hdblcm using option --component_root '$TARGET_DIR' or use the hdblcm Web user interface."
	fi
	echo ""
	if [[ $SHA_FOUND ]] ; then
		shaOption="install"
		if [[ -e /usr/sap/hostctrl/exe/saphostexec ]] ; then
			shaOption="upgrade"
		fi
		echo "To $shaOption the SAP Host Agent, use the following command:"
		for shaLine in "${SHA_LINES[@]}" ; do
			echo $shaLine -$shaOption
		done
	fi
	echo ""
}

#==============================================
#----------------- main -----------------------
#==============================================

handleUserInput $@
handleTars
extractSars
printHintLines

if [[ $HAS_WARNING ]] ; then
	echo "Done with warnings!"
	printLogAndExit 2
else
	echo "Done"
	printLogAndExit 0
fi


