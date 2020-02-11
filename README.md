# se-workshop
SE workshop

## Code snippets

You might need these snippets during the workshop, so they are provided here so you can Copy & Paste

### Demoenv handling commands

```
alias demoenv-aws="docker run -ti --rm \
	-v ~/.ssh/id_rsa:/config/ssh-key.pem:ro \
	-v ~/.aws:/config/aws \
	-e CLUSTER_NAME=<your-cluster-name>\
	-e BUCKET_PATH=s3://sysdig-partner-demo-env/ \
	-e ZONE=us-east-1a \
	-e NUM_NODES=1 \
	-e VPC_ID=vpc-04bcfe02f0e598f57 \
	-e PRIVATE_SUBNET_ID=subnet-0b47480ea22274a71 \
	-e PUBLIC_SUBNET_ID=subnet-0d7c808f36dfb0f08 \
	845151661675.dkr.ecr.us-east-1.amazonaws.com/demoenv-aws"
```

### Helm command for agent installation

```
kubectl create ns sysdig-agent

helm install -n sysdig-agent --set sysdig.accessKey=YOUR-KEY-HERE --set sysdig.settings.k8s_cluster_name=foo-bar sysdig-agent stable/sysdig
```

### Deploying Jenkins

```
#Linux
$ curl -sSfL https://github.com/roboll/helmfile/releases/download/v0.98.3/helmfile_linux_amd64 -o /usr/local/bin/helmfile

#Mac
$ curl -sSfL https://github.com/roboll/helmfile/releases/download/v0.98.3/helmfile_darwin_amd64 -o /usr/local/bin/helmfile

$ chmod +x /usr/local/bin/helmfile

$ helmfile sync --concurrency 1

```

Get Jenkins password
```
$ kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

Export Jenkins service localhost using port-forward

```
kubectl -n jenkins port-forward svc/jenkins 8080
```

### Github action workflow

```
name: Sysdig - Build, scan and push Docker Image

on: [push, repository_dispatch]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1

    - name: Build the Docker image
      run: docker build . --file Dockerfile --tag sysdigworkshop/<your-name>:latest

    - name: Scan image
      uses: sysdiglabs/scan-action@v1
      with:
        image-tag: "sysdigworkshop/<your-name>"
        sysdig-secure-token: ${{ secrets.SYSDIG_SECURE_TOKEN }}

```