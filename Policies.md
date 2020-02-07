# Image Scanning Policies Practice.

## Create a new image scanning policy:

In Sysdig secure:

1. Navigate to Image Scanning > Image Scanning Policies > Policies
2. Click "+ Add Policy"
3. Fill:

Name: "Workshop policy"
Description: "Image scanning policy for the SKO workshop."

## Add the following rules:

### Blocking images running as root

* Gate: Dockerfile
* Sub-type: Effective user
* Params:
  * Type: blacklist
  * Users: root
* Action: Stop


### Stop secrets from being leaked

.aws-credentials is a hidden file that contains some AWS credentials.
As it's hidden we missed it, and now we are about to publish it to the world.
This rule will protect us from situations like this one.

* Gate: Secret scans
* Sub-type: Content regex checks
* Params:
  * Contet regex name: ['AWS_ACCESS_KEY', 'AWS_SECRET_KEY', 'PRIV_KEY', 'DOCKER_AUTH', 'API_KEY']
* Action: Stop


### Filtering known vulnerabilities

Flask 0.12.4, used in this image, is affected by CVE-2019-1010083.
Upgrading to flask 1.0> fixes this issue.
CVE-2019-1010083 is, High severty, as that allows a crafted JSON to cause a DOS:
https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-1010083

* Gate: Vulnerabilities
* Sub-type: Package
* Params:
  * Fix available: true
  * Max days since fix: 15
  * Package type: os
  * Severity: high
  * Severity comparison: >=
* Action: Stop


* Gate: Vulnerabilities
* Sub-type: Package
* Params:
  * Fix available: true
  * Max days since fix: 15
  * Package type: non-os
  * Severity: high
  * Severity comparison: >=
* Action: Stop


### Detecting a malicious library


JeIlyfish was a malicious library hiding as another good library: jellyfish.
It's goal was to steal SSH and GPG keys:
https://sysdig.com/blog/malicious-python-libraries-jeilyfish-dateutil/

We can detect it in several ways:

* The library itself being present.
* The instruction to install the library.
* The library files being present.

And these are the rules to block those scenarios:

* Gate: Package
* Sub-type: Blacklist
* Params:
  * Name: jeilyfish
* Action: Stop


* Gate: Dockerfile
* Sub-type: Instruction
* Params:
  * Check: like
  * Instruction: RUN
  * Value: .*jeIlyfish.*
* Action: Stop


* Gate: Files
* Sub-type: Name match
* Params:
  * Regex: .*jeIlyfish\/_jellyfish\.py
* Action: Stop


### Save

Save this policy now.


## Policy Assigments


In Sysdig secure:

1. Navigate to Image Scanning > Image Scanning Policies > Policy Assignments
2. Click "+ Add Policy Assignment"
3. Fill:
  * Registry: docker.io
  * Repository: sysdigworkshop/<yourname>-staging
  * Tag: *

For Repository, use the same name you used for the DOCKER_REPOSITORY_STAGE
parameter in jenkins.

4. Hit Save.


## Let's break this image

This image already contains several vulnerabilities, let's add one more.

Edit the _Dockerfile_ , and add a new line containing `USER root` somewhere in the middle.


## Scan the image and check the results

Let's trigger a build in jenkins to ckeck if the image scanning works.


### Scanning the image

In Jenkins:

1. Navigate to your pipeline.
2. Hit _Build with Parameters_.
3. Fill the parameters with the same values than last time:
   `sysdigworkshop/<yourname>-staging`
   and
   `sysdigworkshop/<yourname>`
4. Hit _Build_

Now wait until the build finishes.


### Browsing the results in Jenkins

1. Navigate to your build details.
2. Navigate to Sysdig Secure Report (FAIL).
3. Are all the expected STOPS present?


### Browsing the results in Sysdig.

1. Navigate to Image Scanning > Scan Results
2. Search for sysdigworkshop and find your image.
3. Check the last scan date, to confirm it contains the data from the last scanning.
4. Navigate into the details.
5. Are all the expected STOPS present?


### Extra question

1. Was the flask vulnerability detected?
2. Why is the flask vulnerability not flagged?


# Extra exercises

Some extra tasks for you to play around this image.

## Block port 22

The dockerfile is exposing the port 22. This would allow anyone to log in into the container.

No one should run commands in a container, maybe for debug, but accessing via kubectl and not ssh.

Tasks:

1. Add a policy rule to **Stop** containers exposing port 22.
2. Trigger a repository build.
3. Confirm in the build results that the policy rule for the port 22 has been activated.


## Block openssh-server

Apart from exposing the port 22, we should block the actual service providing ssh.

The package openssh-server should not be able to run in a container.

Tasks:

1. Add a policy rule to **Stop** containers using the openssh package.
2. Trigger a repository build.
3. Confirm in the build results that the policy rule has been activated.


## Clean the image

Can you fix the security threats from this image, so it can pass the image scanning?
