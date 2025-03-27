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
                git branch: 'main', credentialsId: 'git-credentials', url: 'https://github.com/Amey4044/Netflix_Clone.git'
            }
        }

        stage('Install pnpm') {
            steps {
                script {
                    // Install pnpm if it's not available
                    sh 'npm install -g pnpm'
                }
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    sh 'pnpm install --frozen-lockfile'  // Install dependencies using pnpm
                    sh 'pnpm run build'  // Run build using pnpm
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Log in to DockerHub and push the image
                    sh 'docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW'
                    sh 'docker build -t $DOCKER_IMAGE:latest .'
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-id']) {
                        // Apply Kubernetes manifests
                        sh 'kubectl apply -f k8s/deployment.yaml'
                        sh 'kubectl apply -f k8s/service.yaml'
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    // Sync application with ArgoCD
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
