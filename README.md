# se-workshop
SE workshop

## Code snippets

You might need these snippets during the workshop, so they are provided here so you can Copy & Paste

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