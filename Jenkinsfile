pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sannaielamounika/Healthcare_Capstoneproject.git'
        IMAGE_NAME = 'healthcare-app'
        AWS_REGION = 'us-east-1'
        KUBECTL_VERSION = 'v1.23.0'  // Specify the version of kubectl you want
    }

    stages {
        stage('Install kubectl') {
            steps {
                script {
                    // Install kubectl
                    sh """
                    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                    chmod +x ./kubectl
                    mkdir -p ~/bin  // Create bin directory if it doesn't exist
                    mv ./kubectl ~/bin/kubectl  // Move kubectl to ~/bin
                    """
                }
            }
        }

        stage('Configure kubectl') {
            steps {
                script {
                    sh """
                    aws eks --region ${AWS_REGION} update-kubeconfig --name healthcare-cluster
                    """
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git url: "${GIT_REPO}", branch: 'master', credentialsId: 'github-pat'
            }
        }

        stage('Build & Test') {
            steps {
                sh './mvnw clean install'
            }
        }

        stage('Package & Dockerize') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh """
                            echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                            docker build -t ${IMAGE_NAME} . 
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
                        [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-key-id'] 
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
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh 'docker-compose -f selenium/docker-compose.yml up -d'
            }
        }

        stage('Monitor with Prometheus & Grafana') {
            steps {
                sh 'kubectl apply -f prometheus/prometheus-deployment.yaml'
                sh 'kubectl apply -f grafana/grafana-deployment.yaml'
            }
        }

        stage('Deploy to Production') {
            steps {
                sh 'kubectl apply -f k8s/production-deployment.yaml'
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
