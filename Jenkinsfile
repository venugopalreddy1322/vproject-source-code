pipeline {
    agent any 
    environment {
        DOCKER_REGISTRY = 'docker.io/venu1322/vproject'
        DOCKER_CREDS = credentials('dockerhub')
        GIT_CREDS = 'github'
        IMAGE_TAG = ''  // placeholder
    }
    stages {
        stage('Cleanup Stage') {
            steps {
                deleteDir()
            }
        }
        stage('Initialize') {
            steps {
                script {
                    env.IMAGE_TAG = "${DOCKER_REGISTRY}:${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Copy Repo') {
            steps {
                checkout scm
                sh 'ls *'
            }
        }
        stage('Build stage') {
            steps {
                //sh 'docker build -t venu1322/vproject:$BUILD_NUMBER .' 
                script {
                    docker.build(env.IMAGE_TAG)
                }
            }
        }
        stage('Push Docker image to Docherhub') {
            steps{
                sh 'docker push venu1322/vproject:$BUILD_NUMBER'
            }
        }
    }
    post{
        always {
            sh 'docker logout'
        }
    }
}