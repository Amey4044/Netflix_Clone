pipeline {
    agent any

    environment {
        // Docker Hub repository name
        DOCKER_HUB_REPO = "cypher7/netflix-clone"
        // Docker Hub credentials ID (configured in Jenkins)
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
        // Path to Dockerfile (optional: change if Dockerfile is in a subfolder)
        DOCKERFILE_PATH = "."
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    try {
                        // Clone the GitHub repository
                        git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
                    } catch (Exception e) {
                        error "Failed to clone the repository: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        // Build Docker image using the specified Dockerfile path
                        sh "docker build -t ${DOCKER_HUB_REPO}:latest ${DOCKERFILE_PATH}"
                    } catch (Exception e) {
                        error "Docker build failed: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    try {
                        // Push the Docker image to Docker Hub using the credentials stored in Jenkins
                        withDockerRegistry([credentialsId: DOCKER_CREDENTIALS_ID, url: 'https://index.docker.io/v1/']) {
                            sh "docker push ${DOCKER_HUB_REPO}:latest"
                        }
                    } catch (Exception e) {
                        error "Failed to push the image to Docker Hub: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up Docker images to save space
                try {
                    sh "docker rmi ${DOCKER_HUB_REPO}:latest || true"
                } catch (Exception e) {
                    echo "Failed to remove Docker image: ${e.getMessage()}"
                }
            }
        }

        success {
            echo "Docker image successfully pushed to Docker Hub!"
        }

        failure {
            echo "The pipeline failed. Please check the logs for details."
        }
    }
}
