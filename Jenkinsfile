pipeline {
    agent any

    environment {
        NODE_VERSION = "18.x"
        IMAGE_NAME = "amey4044/netflix-clone"
        KUBE_NAMESPACE = "default"
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
                    echo "Setting up Node.js..."
                    sh 'curl -fsSL https://deb.nodesource.com/setup_18.x | bash -'
                    sh 'apt-get install -y nodejs'
                    sh 'node -v'
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo "Installing dependencies..."
                    sh 'npm install'
                }
            }
        }

        stage('Build React App') {
            steps {
                script {
                    echo "Building the React app..."
                    sh 'npm run build'
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh 'docker build -t $IMAGE_NAME:latest .'
                }
            }
        }

        stage('Push to Docker Hub') {
            environment {
                DOCKER_USERNAME = credentials('docker-username')
                DOCKER_PASSWORD = credentials('docker-password')
            }
            steps {
                script {
                    echo "Logging into Docker Hub..."
                    sh 'echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin'
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to Kubernetes..."
                    sh 'kubectl apply -f k8s/deployment.yaml -n $KUBE_NAMESPACE'
                    sh 'kubectl apply -f k8s/service.yaml -n $KUBE_NAMESPACE'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build and Deployment Successful!'
        }
        failure {
            echo '❌ Build or Deployment Failed!'
        }
    }
}
