## Credits
This repo is essentially a copy of [hochzehn/s3cmd-docker](https://github.com/hochzehn/s3cmd-docker) and [sekka1/docker-s3cmd](https://github.com/sekka1/docker-s3cmd), but allows you to specify a host other than the default AWS host (e.g DigitalOcean Spaces which is S3 compatible).

## Description
* Docker container with s3cmd support. Pull and run this image in order to upload/download between S3 host and local machine.
* This also has support for deployment as a kubernetes pod and IAM.

**_NOTE_**: If your access is configured through AWS IAM, it is not necessary to pass the following env vars:
```bash
--env access_key=${ACCESS_KEY} 
--env secret_key=${SECRET_KEY}
```
If you do not pass but IAM is not configured properly then the tasks will fail.

## Upload from Local to S3
```
docker run --rm \
  --env access_key=${ACCESS_KEY} \
  --env secret_key=${SECRET_KEY} \
  --env s3_host_base=${HOST} \
  --env s3_host_bucket_template=${HOST_BUCKET_TEMPLATE} \
  --env cmd=sync-local-to-s3 \
  --env DEST_S3=${BUCKET} \
  -v ${LOCAL_FILE}:/opt/src \
  gthill77/s3cmd-docker
```

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
  gthill77/s3cmd-docker
```

## Optional args
* If you want this to run periodically at a specified interval, you can do so by adding to env vars:

    * _NOTE_: If no interval is given then it will only execute once and exit.
```bash
--env interval=${SECONDS}
```

## Examples of env vars
* AWS
```bash
HOST = s3.amazonaws.com
HOST_BUCKET_TEMPLATE = "%(bucket)s.s3.amazonaws.com"
```
* DigitalOcean
```bash
HOST = nyc3.digitaloceanspaces.com
HOST_BUCKET_TEMPLATE = "%(bucket)s.nyc3.digitaloceanspaces.com"
```

## Kubernetes Support
You may also run this in a kubernetes pod as follows:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: s3cmd
  labels:
    name: s3cmd
spec:
  restartPolicy: Never
  containers:
  - name: s3cmd
    image: gthill77/s3cmd-docker:latest
    imagePullPolicy: Always
    volumeMounts:
    - readOnly: false
      mountPath: /opt/dest
      name: data
    env:
      - name: s3_host_base
        value: s3.amazonaws.com
      - name: s3_host_bucket_template
        value: "%(bucket)s.s3.amazonaws.com"
      - name: cmd
        value: sync-s3-to-local
      - name: SRC_S3
        value: s3://${BUCKET}/${PATH}
      # Optional: if you would like to set an interval to repeat process (in seconds).
      - name: interval
        value: '10'
  volumes:
    - name: data
      hostPath:
        path: /data
        type: DirectoryOrCreate
```

### kube2iam Support
If you have kube2iam configured and installed in your cluster you may add the IAM role to metadata:
```yaml
annotations:
    iam.amazonaws.com/role: ${IAM_ROLE}
```
More info on kube2iam [here](https://github.com/jtblin/kube2iam)
