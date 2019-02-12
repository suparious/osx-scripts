#!/bin/bash


TARGET_ENV="dev-supa"

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
