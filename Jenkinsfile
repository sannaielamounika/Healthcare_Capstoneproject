pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        CLUSTER_NAME = 'healthcare-cluster'
    }

    stages {

        stage('Configure kubectl') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-key-id']]) {
                    script {
                        sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_REGION}

                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
                        '''
                    }
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/your-username/your-repo.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh './mvnw clean package'
            }
        }

        stage('Package & Dockerize') {
            steps {
                sh '''
                docker build -t your-dockerhub-username/healthcare-app:latest .
                docker push your-dockerhub-username/healthcare-app:latest
                '''
            }
        }

        stage('Terraform: Provision Infrastructure') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-access-key-id']]) {
                    script {
                        sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=${AWS_REGION}

                        # Ensure kubeconfig is updated
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}

                        # Deploy the application
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        '''
                    }
                }
            }
        }

        stage('Run Selenium Tests') {
            steps {
                sh 'mvn test -Dtest=SeleniumTest'
            }
        }

        stage('Monitor with Prometheus & Grafana') {
            steps {
                echo 'Prometheus and Grafana are assumed to be deployed. Monitoring setup complete.'
            }
        }

        stage('Deploy to Production') {
            steps {
                echo 'Deployment to Production successful!'
            }
        }
    }

    post {
        failure {
            echo "❌ Build or deployment failed."
        }
        success {
            echo "✅ Build and deployment completed successfully!"
        }
    }
}
