pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sannaielamounika/Healthcare_Capstoneproject.git'
        IMAGE_NAME = 'healthcare-app'
        AWS_REGION = 'us-east-1' // AWS Region
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: "${GIT_REPO}", branch: 'master', credentialsId: 'github-pat'
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
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker tag ${IMAGE_NAME} $DOCKER_USERNAME/${IMAGE_NAME}:${BUILD_NUMBER}
                            docker push $DOCKER_USERNAME/${IMAGE_NAME}:${BUILD_NUMBER}
                            docker tag ${IMAGE_NAME} $DOCKER_USERNAME/${IMAGE_NAME}:latest
                            docker push $DOCKER_USERNAME/${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Terraform: Provision Infrastructure') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        dir('terraform') {
                            sh """
                                terraform init
                                terraform apply -auto-approve \
                                    -var="AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
                                    -var="AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
                                    -var="AWS_REGION=$AWS_REGION"
                            """
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
                    // You can add selenium test execution commands here
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
