pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "cypher7/netflix-clone"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
        DOCKERFILE_PATH = "."
        IMAGE_TAG = "latest"
        
        // Kubernetes Config
        K8S_DEPLOYMENT_FILE = "k8s/deployment.yaml"
        K8S_SERVICE_FILE = "k8s/service.yaml"
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "Cloning repository..."
                    git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${DOCKER_HUB_REPO}:${IMAGE_TAG} ${DOCKERFILE_PATH}"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    echo "Logging in to Docker Hub..."
                    withDockerRegistry([credentialsId: DOCKER_CREDENTIALS_ID, url: 'https://index.docker.io/v1/']) {
                        echo "Pushing Docker image to Docker Hub..."
                        sh "docker push ${DOCKER_HUB_REPO}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    echo "Applying Kubernetes configurations..."
                    sh "kubectl apply -f ${K8S_DEPLOYMENT_FILE}"
                    sh "kubectl apply -f ${K8S_SERVICE_FILE}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Checking pod status..."
                    sh "kubectl get pods"
                    echo "Fetching service details..."
                    sh "kubectl get svc"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up Docker images..."
                sh "docker rmi ${DOCKER_HUB_REPO}:${IMAGE_TAG} || true"
            }
        }

        success {
            echo "Deployment successful! Access your Netflix Clone using the service URL."
        }

        failure {
            echo "Pipeline failed. Please check logs."
        }
    }
}
