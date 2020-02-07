pipeline {
    agent {
       kubernetes {
           yaml """
apiVersion: v1 
kind: Pod 
metadata: 
    name: img 
    annotations:
      container.apparmor.security.beta.kubernetes.io/img: unconfined
      container.seccomp.security.alpha.kubernetes.io/img: unconfined
spec: 
    containers: 
      - name: img
        image: sysdiglabs/img
        command: ['cat']
        tty: true
"""
       }
   }

    parameters { 
        string(name: 'DOCKER_REPOSITORY_STAGE', defaultValue: '', description: 'Name of the image to be built for scanning (e.g.: sysdigworkshop/dummy-staging)') 
        string(name: 'DOCKER_REPOSITORY_PROD', defaultValue: '', description: 'Name of the image to be built for production (e.g.: sysdigworkshop/dummy)') 
    }
    
    environment {
        DOCKER = credentials('docker-sysdigworkshop-repository-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                container("img") {
                    checkout scm
                }
            }
        }
        stage('Build Image') {
            steps {
                container("img") {
                    sh "img build -f Dockerfile -t ${params.DOCKER_REPOSITORY_STAGE} ."
                }
            }
        }
        stage('Push Staging Image') {
            steps {
                container("img") {
                    sh "img login -u ${DOCKER_USR} -p ${DOCKER_PSW}"
                    sh "img push ${params.DOCKER_REPOSITORY_STAGE}"
                    sh "echo ${params.DOCKER_REPOSITORY_STAGE} > sysdig_secure_images"
                }
            }
        }
        stage('Scanning Image') {
            steps {
                sysdigSecure engineCredentialsId: 'sysdig-secure-sysdigworkshop-api-credentials', name: 'sysdig_secure_images'
            }
        }
        stage('Push Production Image') {
            steps {
                container("img") {
                    sh "img login -u ${DOCKER_USR} -p ${DOCKER_PSW}"
                    sh "img tag ${params.DOCKER_REPOSITORY_STAGE} ${params.DOCKER_REPOSITORY_PROD}"
                    sh "img push ${params.DOCKER_REPOSITORY_PROD}"
                    sh "echo ${params.DOCKER_REPOSITORY_PROD} > sysdig_secure_images"
                }
            }
        }
   }
}
