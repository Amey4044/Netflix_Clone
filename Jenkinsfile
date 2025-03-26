pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "cypher7/netflix-clone"   // Docker repository
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"  // Jenkins Docker credentials ID
        DOCKERFILE_PATH = "."   // Path to the Dockerfile
        IMAGE_TAG = "latest"  // Image tag
        
        // Kubernetes Config
        K8S_DEPLOYMENT_FILE = "k8s/deployment.yaml"  // Path to your Kubernetes deployment file
        K8S_SERVICE_FILE = "k8s/service.yaml"        // Path to your Kubernetes service file
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "Cloning repository from GitHub..."
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
                    echo "Updating Kubernetes deployment and service..."
                    sh "kubectl apply -f ${K8S_DEPLOYMENT_FILE}"  // Apply deployment changes
                    sh "kubectl apply -f ${K8S_SERVICE_FILE}"     // Apply service changes
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying Kubernetes deployment..."
                    sh "kubectl get pods"    // Get pod status
                    sh "kubectl get svc"     // Get service details
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
            echo "Pipeline failed. Please check the logs."
        }
    }
}
