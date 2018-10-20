## Download from S3 to Local
```
docker run --rm \
  --env access_key=${ACCESS_KEY} \
  --env secret_key=${SECRET_KEY} \
  --env s3_host_base=${HOST} \
  --env s3_host_bucket_template=${HOST_BUCKET_TEMPLATE} \
  --env cmd=sync-s3-to-local \
  --env SRC_S3=${BUCKET} \
  -v ${LOCAL_PATH}:/opt/dest \
  gthill77/s3cmd
```
