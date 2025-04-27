pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sannaielamounika/Healthcare_Capstoneproject.git'
        IMAGE_NAME = 'healthcare-app'
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        GITHUB_PAT = credentials('github-pat')
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id') // AWS credentials ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key') // AWS credentials ID
        AWS_REGION = 'us-east-1' // Set AWS region
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: GIT_REPO, branch: 'master', credentialsId: 'github-pat'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh './mvnw clean install'
                }
            }
        }

        stage('Package & Dockerize') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                        sh "docker tag $IMAGE_NAME $DOCKER_USERNAME/$IMAGE_NAME:${BUILD_NUMBER}"
                        sh "docker push $DOCKER_USERNAME/$IMAGE_NAME:${BUILD_NUMBER}"

                        // Optional: also push latest tag
                        sh "docker tag $IMAGE_NAME $DOCKER_USERNAME/$IMAGE_NAME:latest"
                        sh "docker push $DOCKER_USERNAME/$IMAGE_NAME:latest"
                    }
                }
            }
        }

        stage('Terraform: Provision Infrastructure') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                                      string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        dir('terraform') {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve -var="AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" -var="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" -var="AWS_REGION=$AWS_REGION"'
                        }
                    }
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                }
            }
        }

        stage('Run Selenium Tests') {
            steps {
                script {
                    sh 'docker-compose -f selenium/docker-compose.yml up -d'
                    // Add your Selenium test scripts here
                }
            }
        }

        stage('Monitor with Prometheus & Grafana') {
            steps {
                script {
                    sh 'kubectl apply -f prometheus/prometheus-deployment.yaml'
                    sh 'kubectl apply -f grafana/grafana-deployment.yaml'
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                script {
                    sh 'kubectl apply -f k8s/production-deployment.yaml'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and deployment were successful!'
        }
        failure {
            echo '❌ Build or deployment failed.'
        }
    }
}
