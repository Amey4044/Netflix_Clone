pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = "cypher7/netflix-clone"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
        DOCKERFILE_PATH = "."
        IMAGE_TAG = "build-${BUILD_NUMBER}"  // Unique tag for each build
        
        // Kubernetes Config
        K8S_DEPLOYMENT_FILE = "k8s/deployment.yaml"
        K8S_SERVICE_FILE = "k8s/service.yaml"
        KUBECONFIG = "$HOME/.kube/config"  // Ensure Jenkins has access to this
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo "Fetching latest code from GitHub..."
                    if (fileExists('.git')) {
                        sh 'git reset --hard && git clean -df && git pull origin main'
                    } else {
                        git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
                    }
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

        stage('Apply Kubernetes Configurations') {
            steps {
                script {
                    echo "Applying Kubernetes deployment & service..."
                    sh "kubectl apply -f ${K8S_DEPLOYMENT_FILE}"
                    sh "kubectl apply -f ${K8S_SERVICE_FILE}"
                }
            }
        }

        stage('Update Kubernetes Deployment') {
            steps {
                script {
                    echo "Updating Kubernetes deployment with new image..."
                    sh "kubectl set image deployment/netflix-clone netflix-clone=${DOCKER_HUB_REPO}:${IMAGE_TAG}"
                    sh "kubectl rollout status deployment/netflix-clone"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    echo "Verifying Kubernetes deployment..."
                    sh "kubectl get pods"
                    sh "kubectl get svc"
                }
            }
        }
    }

    post {
        always {
            script {
                echo "Cleaning up local Docker images..."
                sh "docker rmi ${DOCKER_HUB_REPO}:${IMAGE_TAG} || true"
            }
        }

        success {
            echo "✅ Deployment successful! Access your Netflix Clone using the service URL."
            sh "minikube service netflix-clone-service --url"
        }

        failure {
            echo "❌ Pipeline failed. Check logs for details."
        }
    }
}
