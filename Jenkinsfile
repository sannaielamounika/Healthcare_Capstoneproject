pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/sannaielamounika/Healthcare_Capstoneproject.git'
        IMAGE_NAME = 'healthcare-app'
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'healthcare-cluster'
    }

    stages {
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
                    withCredentials([[ 
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-access-key-id'
                    ]]) {
                        dir('terraform') {
                            sh """
                                terraform init
                                terraform apply -auto-approve \
                                    -var "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" \
                                    -var "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" \
                                    -var "AWS_REGION=$AWS_REGION"
                            """
                        }
                    }
                }
            }
        }

        stage('Update Kubeconfig') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-access-key-id'
                    ]]) {
                        sh """
                            aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
                        """
                    }
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-access-key-id'
                    ]]) {
                        sh """
                            aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                        """
                    }
                }
            }
        }

        stage('Run Selenium Tests') {
            steps {
                script {
                    sh """
                        docker network create selenium-grid || true
                        
                        docker run -d --name selenium-hub --network selenium-grid selenium/hub:latest

                        docker run -d --name chrome-node --network selenium-grid \
                            -e SE_EVENT_BUS_HOST=selenium-hub \
                            -e SE_EVENT_BUS_PUBLISH_PORT=4442 \
                            -e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
                            selenium/node-chrome:latest

                        # Optional: wait for grid to be ready
                        sleep 10

                        # If you have Selenium tests to run, place them here.
                        # Example: docker run --rm --network selenium-grid your-selenium-test-image
                        echo "Selenium Grid is up. Please configure test execution separately."
                    """
                }
            }
        }

        stage('Monitor with Prometheus & Grafana') {
            steps {
                script {
                    sh """
                        kubectl apply -f prometheus/prometheus-deployment.yaml
                        kubectl apply -f grafana/grafana-deployment.yaml
                    """
                }
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
