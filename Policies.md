# Image Scanning Policies

Add the following Image Scanning policies in Sysdig secure:


## Blocking images running as root

* Gate: Dockerfile
* Sub-type: Effective user
* Params:
  * Type: blacklist
  * Users: root
* Action: Stop


## Stop secrets from being leaked

* Gate: Secret scans
* Sub-type: Content regex checks
* Params:
  * Contet regex name: ['AWS_ACCESS_KEY', 'AWS_SECRET_KEY', 'PRIV_KEY', 'DOCKER_AUTH', 'API_KEY']
* Action: Warn

We'll use Warn in this exercise, but this should be a Stop in production.


## Filtering known vulnerabilities

CVE-2019-1010083 affects flask <1.0, a crafted JSON can be used to cause a DOS.
https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2019-1010083

* Gate: Vulnerabilities
* Sub-type: Package
* Params:
  * Package type: non-os
  * Severity: high
* Action: Warn


## Detecting a malicious library

* Gate: Package
* Sub-type: Blacklist
* Params:
  * Name: jeilyfish
* Action: Warn


* Gate: Dockerfile
* Sub-type: Instruction
* Params:
  * Check: like
  * Instruction: RUN
  * Value: .*jeIlyfish.*
* Action: Warn


* Gate: Files
* Sub-type: Name match
* Params:
  * Regex: jeIlyfish\/_jellyfish\.py
* Action: Warn


## Extra exercise: Block port 22

The dockerfile is exposing the port 22. This would allow anyone to log in into the container.

No one should run commands in a container, maybe for debug, but accessing via kubectl and not ssh.

Tasks:

1. Add a policy rule to **Stop** containers exposing port 22.
2. Trigger a repository build.
3. Confirm in the build results that the policy rule for the port 22 has been activated.


## Extra exercise: Block openssh-server

Apart from exposing the port 22, we should block the actual service providing ssh.

The package openssh-server should not be able to run in a container.

Tasks:

1. Add a policy rule to **Stop** containers using the openssh package.
2. Trigger a repository build.
3. Confirm in the build results that the policy rule has been activated.


## Extra exercise: Clean the image

Can you remove all the security threats from this image, so it can pass the image scanning?
