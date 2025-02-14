#!/bin/bash
# ----------------------------------------------------------------------
# Author : MBA SOB GILDAS (BI EGN)
# Desc : ARGUMENT TO PASS TO FILE
# ----------------------------------------------------------------------
api_backbone_token_url="https://afi-obs.apibackbone.api.intraorange/oauth/v3/token"
url_to_get_operationId_archive="https://afi-obs.apibackbone.api.intraorange/efiles_demo/v1/files"
url_jwt_token="https://afi-obs.apibackbone.api.intraorange/efiles_demo/v1/token"
url_file_download="https://demo-files.wolf-files-demo-nprod.caas-cnp-apps-v2.com.intraorange/api/v1/files"
content_type="application/x-www-form-urlencoded"
accept="application/json"
grant_type="client_credentials"
limit=1
download="notCompleted"
sort="-creationDate"
