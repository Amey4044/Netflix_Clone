pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/netflix-clone"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
            }
        }

        stage('Setup Node.js') {
            steps {
                script {
                    sh """
                        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                        sudo apt-get install -y nodejs
                        node -v
                    """
                }
            }
        }

        stage('Build React App') {
            steps {
                script {
                    sh """
                        npm install
                        npm run build
                    """
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    sh """
                        docker build -t $DOCKER_IMAGE:latest .
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: '']) {
                        sh "docker push $DOCKER_IMAGE:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                        kubectl apply -f k8s/deployment.yaml
                        kubectl rollout status deployment/netflix-clone
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Build or Deployment failed."
        }
        success {
            echo "Pipeline completed successfully!"
        }
    }
}
