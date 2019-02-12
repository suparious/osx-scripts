#!/bin/bash
## example data
#2019-02-11 13:02:31 lendesk-pos-dev-sp-bucket-logs
#2019-02-11 13:02:23 lendesk-pos-dev-sp-codedeploy
#2019-02-11 13:03:31 lendesk-pos-dev-sp-core-client-app
#2019-02-11 13:02:36 lendesk-pos-dev-sp-core-client-app-logs
#2019-02-11 13:04:06 lendesk-pos-dev-sp-files
#2019-02-11 13:03:13 lendesk-pos-dev-sp-logs
#2019-02-11 13:03:17 lendesk-pos-dev-sp-verification-id-upload

TARGET_ENV="dev-sp"

del_s3_bucket_obj()
{
    local bucket_name=$1
    local obj_type=$2
    local query="{Objects: $obj_type[].{Key:Key,VersionId:VersionId}}"
    local s3_objects=$(aws s3api list-object-versions --bucket ${bucket_name} --output=json --query="$query")
    if ! (echo $s3_objects | grep -q '"Objects": null'); then
        aws s3api delete-objects --bucket "${bucket_name}" --delete "$s3_objects"
    fi
}

for bucket_name in `aws s3 ls | grep $TARGET_ENV | awk -F " " {'print $3'}`; do
  del_s3_bucket_obj $bucket_name 'Versions'
  del_s3_bucket_obj $bucket_name 'DeleteMarkers'
  aws s3 rb s3://$bucket_name --force
done