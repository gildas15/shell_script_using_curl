
#!/bin/bash
# ----------------------------------------------------------------------
# Author : MBA SOB GILDAS (BI EGN)
# Desc : RETREIVE SIU ARCHIVE FROM EFILES
# ----------------------------------------------------------------------
# call source param file
source /opt/application/smile-gw/efiles/params.sh

# declare variable specific to file
stream_id=3601
archive_file="SIU_$(date +"%Y%m%d").zip"
authorization="Basic cTFmVUx1RWZtUVZmamF6RUJVbHBIdVZkbHBjTFIxMlY6STJCNnhDTWJJakxNWmUxWFZYSFFtS1ZiUG9ocjgzSTZndzZkVW5kRThGZW8="


echo "$(date +"%Y-%m-%d:%H:%M:%S") debut du téléchargement de l'archive siu"
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


# check if the retreival of the operationId of the last not downloaded achive file  has been successfull

if [ $? -eq 0 ]
then
echo "$(date +"%Y-%m-%d:%H:%M:%S") operationId $operationId of the last not downloaded archive file has been retreive"
else
echo "$(date +"%Y-%m-%d:%H:%M:%S") error when retreiving the operationId of the last not downloaded archive file"
fi

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

curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" -o SIU.csv && zip SIU_$(date +"%Y%m%d").zip SIU.csv


# check if the files download and archiving was successfull 

if [ $? -eq 0 ]
then
echo "$(date +"%Y-%m-%d:%H:%M:%S") all the files has been downloaded and been archive in a .zip file"
else
echo "$(date +"%Y-%m-%d:%H:%M:%S") error during the download and archiving of siu files"
fi
# copy the archive of siu on the gateway server where the ETL will use it to run the siu project. do not copy if the archive is empty

if unzip -l "$archive_file" | grep -qE '^[ ]*[0-9]+'
then
    cp "$archive_file" /var/opt/data/flat/smile-gw/siu/
    echo "$(date +"%Y-%m-%d:%H:%M:%S") Archive $archive_file has been copied to /var/opt/data/flat/smile-gw/siu/"
else
    echo "$(date +"%Y-%m-%d:%H:%M:%S") Cannot copy the archive file $archive_file to /var/opt/data/flat/smile-gw/siu/ because it is empty"
fi
# delete files that has been downloaded before they have been archive in a .zip file

if unzip -l "$archive_file" | grep -qE '^[ ]*[0-9]+'
then
 rm "$archive_file" SIU.csv
 echo "$(date +"%Y-%m-%d:%H:%M:%S") archive file $archive_file and all csv files exist and has been remove"
else
 rm "$archive_file"
 echo "$(date +"%Y-%m-%d:%H:%M:%S") csv files does not exist"
fi

echo "$(date +"%Y-%m-%d:%H:%M:%S") End of download of siu zip file"

