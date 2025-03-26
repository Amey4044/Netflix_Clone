pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "cypher7/netflix-clone"
        DOCKER_TAG = "latest"
        K8S_NAMESPACE = "netflix-clone"
        DEPLOYMENT_NAME = "netflix-app"
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
                    echo 'Setting up Node.js and npm...'
                    sh '''
                        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                        sudo apt-get update
                        sudo apt-get install -y nodejs npm
                        node -v
                        npm -v
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo 'Installing project dependencies...'
                    sh 'npm install'
                }
            }
        }

        stage('Build React App') {
            steps {
                script {
                    echo 'Building the React application...'
                    sh 'npm run build'
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    echo 'Building the Docker image...'
                    sh '''
                        docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                    '''
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    echo 'Logging in to Docker Hub and pushing the image...'
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push $DOCKER_IMAGE:$DOCKER_TAG
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes using Helm and ArgoCD...'
                    sh '''
                        kubectl create namespace $K8S_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
                        helm upgrade --install $DEPLOYMENT_NAME helm/netflix-chart -n $K8S_NAMESPACE \
                        --set image.repository=$DOCKER_IMAGE --set image.tag=$DOCKER_TAG
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment Successful!"
        }
        failure {
            echo "❌ Build or Deployment Failed!"
        }
    }
}
