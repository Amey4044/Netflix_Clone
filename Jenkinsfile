pipeline {
    agent any

    environment {
        IMAGE_NAME = "amey4044/netflix-clone"
        IMAGE_TAG = "latest"
        DOCKER_HUB_CREDENTIALS = "docker-hub-credentials"
        KUBECONFIG_PATH = "/home/jenkins/.kube/config"
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo 'Cloning the repository...'
                    checkout scm
                }
            }
        }

        stage('Setup Node.js') {
            steps {
                script {
                    echo 'Setting up Node.js...'
                    sh '''
                        sudo apt-get update
                        sudo apt-get install -y nodejs npm
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo 'Installing dependencies...'
                    sh '''
                        npm install
                    '''
                }
            }
        }

        stage('Build React App') {
            steps {
                script {
                    echo 'Building the React application...'
                    sh '''
                        npm run build
                    '''
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh '''
                        docker build -t $IMAGE_NAME:$IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    withDockerRegistry([credentialsId: DOCKER_HUB_CREDENTIALS, url: '']) {
                        sh '''
                            docker push $IMAGE_NAME:$IMAGE_TAG
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh '''
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful!'
        }
        failure {
            echo '❌ Build or Deployment Failed!'
        }
    }
}
