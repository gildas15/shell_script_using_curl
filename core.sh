#!/bin/bash
# ----------------------------------------------------------------------
# Author : MBA SOB GILDAS (BI EGN)
# Desc : RETREIVE CORE ARCHIVE FROM EFILES
# ----------------------------------------------------------------------
# call source param file
source /opt/application/smile-gw/efiles/params.sh

# declare variable specific to file
stream_id=3237
archive_file="SMILE-COREFR-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
authorization="Basic UVViMjhaTWpjRTJVckNHQU1rRkFwZHBpbmlHSUJUTEs6b1BTaklKaUJJcWY3bnRmRw=="


echo "$(date +"%Y-%m-%d:%H:%M:%S") debut du téléchargement de l'archive core"
# Get the api backbone access token

access_token=$(curl -k -v -X POST -H "Content-Type: $content_type" -H "Authorization: $authorization" -H "Accept: $accept" -d "grant_type=$grant_type" "$api_backbone_token_url" | jq -r '.access_token')

# check if api backbone token retrival has been successfull

if [ $? -eq 0 ]
	then
	echo "$(date +"%Y-%m-%d:%H:%M:%S") api backbone access token has been retreived"
else
	echo "$(date +"%Y-%m-%d:%H:%M:%S") error when retreiving api backbone access token"
fi
# Get the operationId of the last not downloaded achive file

operationId=$(curl -k -X GET -H "Authorization: Bearer $access_token" "$url_to_get_operationId_archive?q=sort=$sort&streamId=$stream_id&limit=$limit&download=$download" | jq -r '.[0].operationId')

if [ "$operationId" = "null" ]
	then
	echo "$(date +"%Y-%m-%d:%H:%M:%S") operation_id is empty. no file to download because all file present on efiles has been downloaded already"
# check if not download file exist
else

	echo "$(date +"%Y-%m-%d:%H:%M:%S") operationId $operationId of the last not downloaded archive file has been retreive"

	# Get the jwt token for file download

	jwt_token=$(curl -k -v -X POST -H "Content-Type: $content_type" -H "Authorization: Bearer $access_token" -d "grant_type=$grant_type" "$url_jwt_token" | jq -r '.accessToken')

	# check if the retreival of the jwt_token  has been successfull

	if [ $? -eq 0 ]
		then
		echo "$(date +"%Y-%m-%d:%H:%M:%S") the jwt_token for file download has been retreive"
	else
		echo "$(date +"%Y-%m-%d:%H:%M:%S") error when retreiving the jwt_token for file download"
	fi

	# Get corefr files from eFiles and archive them in a .tar.gz file

	curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf SMILE-COREFR-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T - 

	# check if the files download and archiving was successfull 

	if [ $? -eq 0 ]
		then
		echo "$(date +"%Y-%m-%d:%H:%M:%S") all the files has been downloaded and been archive in a .tar.gz file"
	else
		echo "$(date +"%Y-%m-%d:%H:%M:%S") error during the download and archiving of core files"
	fi
	# copy the archive of corefr on the gateway server where the ETL will use it to run the core project. do not copy if the archive is empty

	if tar -tzf "$archive_file" | grep -q '.'
		then
		cp "$archive_file" /var/opt/data/flat/smile-gw/corefr/
		echo "$(date +"%Y-%m-%d:%H:%M:%S") Archive $archive_file has been copied to /var/opt/data/flat/smile-gw/corefr/"
		#copy archive file on dev Gateway
		scp /var/opt/data/flat/smile-gw/corefr/$archive_file smile-gw@10.235.75.107:/var/opt/data/flat/smile-gw/corefr/
		echo "$(date +"%Y-%m-%d:%H:%M:%S") Archive $archive_file has been copied to DEV Gateway"
	else
		echo "$(date +"%Y-%m-%d:%H:%M:%S") Cannot copy the archive file $archive_file to /var/opt/data/flat/smile-gw/corefr/ because it is empty"
	fi
	# delete files that has been downloaded before they have been archive in a .tar.gz file

	if tar -tzf "$archive_file" | grep -q '.'
		then
		 rm "$archive_file" SMILE-COREFR-*.csv
		 echo "$(date +"%Y-%m-%d:%H:%M:%S") archive file $archive_file and all csv files exist and has been remove"
	else
		 rm "$archive_file"
		 echo "$(date +"%Y-%m-%d:%H:%M:%S") csv files does not exist"
	fi

		echo "$(date +"%Y-%m-%d:%H:%M:%S") End of download of archive core"

fi
