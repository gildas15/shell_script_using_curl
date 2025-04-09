#!/bin/bash
# ----------------------------------------------------------------------
# Author : MBA SOB GILDAS (BI EGN)
# Desc : RETREIVE S4CMS(SMILE,MYSMFRA0, MYSMFRA1, MYSMFRA2, TENANT, FVP et FVC) ARCHIVES FROM EFILES
# ----------------------------------------------------------------------
# call source param file
source /opt/application/smile-gw/efiles/params.sh

# declare variable specific to file
streamIds=(3367 3381 3382 3383 3384 3526)
authorization="Basic M3h5Z085MmVxeUVHR2NpTVlHUTFiWUFZQUdXckk4Qk86QUR5dEwzSjlwd0Rkam0zNA=="

echo "$(date +"%Y-%m-%d:%H:%M:%S") debut du téléchargement des archives S4CMS"

for stream_id in "${streamIds[@]}"; do
# Get the api backbone access token

access_token=$(curl -k -v -X POST -H "Content-Type: $content_type" -H "Authorization: $authorization" -H "Accept: $accept" -d "grant_type=$grant_type" "$api_backbone_token_url" | jq -r '.access_token')

# check if api backbone token retrieval has been successful

	if [ $? -eq 0 ]
		then
		echo "$(date +"%Y-%m-%d:%H:%M:%S") api backbone access token has been retrieved"
	else
		echo "$(date +"%Y-%m-%d:%H:%M:%S") error when retrieving api backbone access token"
	fi
# Get the operationId of the last not downloaded achive file

operationId=$(curl -k -X GET -H "Authorization: Bearer $access_token" "$url_to_get_operationId_archive?q=sort=$sort&streamId=$stream_id&limit=$limit" | jq -r '.[0].operationId')

# check if the operationId is empty
	if [ "$operationId" = "null" ]
		then
		echo "$(date +"%Y-%m-%d:%H:%M:%S") no file to download. Either no file for stream_id=$stream_id exist on efile or all file of stream_id=$stream_id present on efiles has been downloaded already"
		
		else

		echo "$(date +"%Y-%m-%d:%H:%M:%S") operationId $operationId of the last not downloaded archive file has been retreive"

		# Get the jwt token for file download

		jwt_token=$(curl -k -v -X POST -H "Content-Type: $content_type" -H "Authorization: Bearer $access_token" -d "grant_type=$grant_type" "$url_jwt_token" | jq -r '.accessToken')

		# check if the retreival of the jwt_token  has been successfull

		if [ $? -eq 0 ]
		then
			echo "$(date +"%Y-%m-%d:%H:%M:%S") the jwt_token for file download has been retrieve"
		else
			echo "$(date +"%Y-%m-%d:%H:%M:%S") error when retrieving the jwt_token for file download"
		fi

			# check the stream_id
			# if stream_id is for SMILE = lot3
			if [ $stream_id -eq 3367 ]; then

				archive_file="ACQ_CMS-UAT_SMILE-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
				echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot3"
				curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf ACQ_CMS-UAT_SMILE-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T - 
				echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot3"
				# if stream_id is for MYSMFRA0 = lot0
				elif [ $stream_id -eq 3381 ]; then

					archive_file="ACQ_CMS-UAT_MYSMFRA0-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
					echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot0"
					curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf ACQ_CMS-UAT_MYSMFRA0-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T -
					echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot0"
				# if stream_id is for MYSMFRA1 = lot1
				elif [ $stream_id -eq 3382 ]; then

					archive_file="ACQ_CMS-UAT_MYSMFRA1-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
					echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot1"
					curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf ACQ_CMS-UAT_MYSMFRA1-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T -
					echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot1"
				# if stream_id is for MYSMFRA2 = lot2
				elif [ $stream_id -eq 3383 ]; then

					archive_file="ACQ_CMS-UAT_MYSMFRA2-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
					echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot2"
					curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf ACQ_CMS-UAT_MYSMFRA2-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T -
					echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot2"

				# if stream_id is for MYSMTENANT = lot5
				elif [ $stream_id -eq 3384 ]; then

					archive_file="ACQ_CMS-MYSM_TENANT-$(date -d "tomorrow" +"%Y%m%d").tar.gz"
					echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot5"
					curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf ACQ_CMS-MYSM_TENANT-$(date -d "tomorrow" +"%Y%m%d").tar.gz -T -
					echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot5"

				#else stream_id is for FVP & FVC = lot4
				else
					archive_file="CMS-$(date +"%Y%m%d").tar.gz"
					echo "$(date +"%Y-%m-%d:%H:%M:%S") begin downloading archive of lot4"
					curl -k -X GET -L -H "Authorization: Bearer $jwt_token" "$url_file_download/$operationId/content" | tar -xvzf - | tar -cvzf CMS-$(date +"%Y%m%d").tar.gz -T -
					echo "$(date +"%Y-%m-%d:%H:%M:%S") end downloading archive of lot4"
			fi

			if [ $? -eq 0 ]
			then
				echo "$(date +"%Y-%m-%d:%H:%M:%S") all the files has been downloaded and been archive in a .tar.gz file"
				else
				echo "$(date +"%Y-%m-%d:%H:%M:%S") error during the download and archiving of the archive $archive_file"
			fi
			# copy the archive on the gateway server where the ETL will use it to run the core project. do not copy if the archive is empty

			if tar -tzf "$archive_file" | grep -q '.'
			then
				cp "$archive_file" /var/opt/data/flat/smile-gw/s4cms/
				echo "$(date +"%Y-%m-%d:%H:%M:%S") Archive $archive_file has been copied to /var/opt/data/flat/smile-gw/s4cms/"
			#copy archive file on dev Gateway
				scp /var/opt/data/flat/smile-gw/s4cms/$archive_file smile-gw@10.235.75.107:/var/opt/data/flat/smile-gw/s4cms/
				echo "$(date +"%Y-%m-%d:%H:%M:%S") Archive $archive_file has been copied to DEV Gateway"
			else
				echo "$(date +"%Y-%m-%d:%H:%M:%S") Cannot copy the archive file $archive_file to /var/opt/data/flat/smile-gw/s4cms/ because it is empty"
			fi
			# delete files that has been downloaded before they have been archive in a .tar.gz file

			if tar -tzf "$archive_file" | grep -q '.'
			then
				rm "$archive_file" CMStxtExt*.out
				echo "$(date +"%Y-%m-%d:%H:%M:%S") archive file $archive_file and all csv files exist and has been remove"
			else
				rm "$archive_file"
				echo "$(date +"%Y-%m-%d:%H:%M:%S") csv files does not exist"
			fi
	fi
	
done
