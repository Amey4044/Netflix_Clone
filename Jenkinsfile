pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBE_CONFIG = credentials('kubeconfig-id') // Kubernetes credentials in Jenkins
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials') // DockerHub credentials in Jenkins
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Ensure the git repository URL matches the correct URL for your repo
                git branch: 'main', credentialsId: 'git-credentials', url: 'git@github.com:your-repo/netflix-clone.git'
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    // Ensure pnpm is installed, if not, install it before running commands
                    sh 'pnpm install --frozen-lockfile'
                    sh 'pnpm run build'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Correct use of credentials environment variables for Docker login
                    sh 'echo $DOCKER_CREDENTIALS_PASSWORD | docker login -u $DOCKER_CREDENTIALS_USERNAME --password-stdin'
                    sh 'docker build -t $DOCKER_IMAGE:latest .'
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Use the correct kubeconfig credentials in the withKubeConfig block
                    withKubeConfig([credentialsId: 'kubeconfig-id']) {
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl apply -f k8s/service.yaml'
                        sh 'kubectl apply -f k8s/ingress.yaml'
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // Trigger ArgoCD synchronization for the app
                    sh 'argocd app sync netflix-clone'
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful! ✅'
        }
        failure {
            echo 'Deployment failed ❌'
        }
    }
}
