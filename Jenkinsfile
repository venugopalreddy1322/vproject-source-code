pipeline {
    agent any 
    environment {
        DOCKER_CREDS = credentials('dockerhub')
    }
    stages {
        stage('Cleanup Stage') {
            steps {
                deleteDir()
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
                sh 'docker build -t venu1322/flask-jenkins-test:$BUILD_NUMBER ./gittodockerhub/' 
            }
        }
        stage('Dockerhub Login') {
            steps {
                sh 'echo $DOCKER_CREDS_PSW | docker login --username=$DOCKER_CREDS_USR --password-stdin'
            }
        }
        stage('Push Docker image to Docherhub') {
            steps{
                sh 'docker push venu1322/flask-jenkins-test:$BUILD_NUMBER'
            }
        }
    }
    post{
        always {
            sh 'docker logout'
        }
    }
}