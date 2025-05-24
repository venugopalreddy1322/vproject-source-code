pipeline {
    agent any 
    environment {
        DOCKER_REGISTRY = 'venu1322/vproject'
        //DOCKER_CREDS = credentials('dockerhub')
        
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
                //sh 'docker build -t venu1322/vproject:$BUILD_NUMBER .' 
                script {
                    env.imageTag = "${DOCKER_REGISTRY}:${env.BUILD_NUMBER}"
                    docker.build(imageTag)
                }
            }
        }
        stage('Push Docker image to Docherhub') {
            steps{
                //sh 'docker push venu1322/vproject:$BUILD_NUMBER'
                script {
                    //imageTag = "${DOCKER_REGISTRY}:${env.BUILD_NUMBER}"
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        sh "docker push ${imageTag}"
                    }
                }
            }
        }
    }
    post {
        success {
            echo "✅ Docker image built and pushed successfully: ${imageTag}"
        }
        failure {
            echo "❌ Pipeline failed. Check logs."
        }
    }
}