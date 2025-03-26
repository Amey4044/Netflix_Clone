pipeline {
    agent any
    
    environment {
        // Docker Hub repository name
        DOCKER_HUB_REPO = "cypher7/netflix-clone"
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Cloning the GitHub repository
                git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                // Build Docker image using the Dockerfile in the repo
                script {
                    // Ensure Dockerfile is present and build the image
                    sh "docker build -t ${DOCKER_HUB_REPO}:latest ."
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                // Push the Docker image to Docker Hub using the credentials from Jenkins
                withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/']) {
                    script {
                        // Push the Docker image to the specified Docker Hub repository
                        sh "docker push ${DOCKER_HUB_REPO}:latest"
                    }
                }
            }
        }
    }

    post {
        // Cleanup and other post-build actions
        always {
            // Clean up the Docker images locally to save space
            sh "docker rmi ${DOCKER_HUB_REPO}:latest || true"
        }
    }
}
