#!/bin/sh -e

#
# main entry point to run s3cmd
#
S3CMD_PATH=/opt/s3cmd/s3cmd
S3CMD_CONFIG=/root/.s3cfg

#
# Check for required parameters
#
if [ -z "${access_key}" ]; then
    echo "ERROR: The environment variable key is not set."
    exit 1
fi

if [ -z "${secret_key}" ]; then
    echo "ERROR: The environment variable secret is not set."
    exit 1
fi

#
# Set user provided key and secret in .s3cfg file
#
echo "" >> "$S3CMD_CONFIG"
echo "access_key=${access_key}" >> "$S3CMD_CONFIG"
echo "secret_key=${secret_key}" >> "$S3CMD_CONFIG"

#
# Add region base host if it exist in the env vars
#
if [ "${s3_host_base}" != "" ]; then
  echo "host_base = ${s3_host_base}" >> "$S3CMD_CONFIG"
fi

if [ "${s3_host_bucket_template}" != "" ]; then
  echo "host_bucket = ${s3_host_bucket_template}" >> "$S3CMD_CONFIG"
fi

# Check whether to run a pre-defined command
if [ -n "${cmd}" ]; then
  #
  # sync-s3-to-local - copy from s3 to local
  #
  if [ "${cmd}" = "sync-s3-to-local" ]; then
      echo ${SRC_S3}
      ${S3CMD_PATH} sync $* ${SRC_S3} /opt/dest/
  fi

  #
  # sync-local-to-s3 - copy from local to s3
  #
  if [ "${cmd}" = "sync-local-to-s3" ]; then
      ${S3CMD_PATH} sync $* /opt/src/ ${DEST_S3}
  fi
else
  ${S3CMD_PATH} $*
fi

#
# Finished operations
#
echo "Finished s3cmd operations"