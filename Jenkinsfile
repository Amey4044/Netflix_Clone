pipeline {
    agent any

    environment {
<<<<<<< HEAD
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        DOCKER_TAG = 'build-${BUILD_NUMBER}'
=======
        DOCKER_HUB_REPO = "cypher7/netflix-clone"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
        DOCKERFILE_PATH = "."
        IMAGE_TAG = "build-${BUILD_NUMBER}"  // Unique tag for each build
        
        // Kubernetes Config
        K8S_DEPLOYMENT_FILE = "k8s/deployment.yaml"
        K8S_SERVICE_FILE = "k8s/service.yaml"
        KUBECONFIG = "$HOME/.kube/config"  // Ensure Jenkins has access to this
>>>>>>> a84d9ca03e9810dc2c6056b2a6caa1001e717393
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    echo 'Fetching latest code from GitHub...'
                    checkout scm
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh 'docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                script {
                    echo 'Logging in to Docker Hub...'
                    withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                        sh 'docker push ${DOCKER_IMAGE}:${DOCKER_TAG}'
                    }
                }
            }
        }

<<<<<<< HEAD
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Deploying to Kubernetes...'
                    sh 'kubectl set image deployment/netflix-clone netflix-clone=${DOCKER_IMAGE}:${DOCKER_TAG} --namespace=default'
                }
            }
        }
=======
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
>>>>>>> a84d9ca03e9810dc2c6056b2a6caa1001e717393
    }
}
