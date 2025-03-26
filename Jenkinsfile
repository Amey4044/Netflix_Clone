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
                git branch: 'main', credentialsId: 'git-credentials', url: 'git@github.com:your-repo/netflix-clone.git'
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    sh 'pnpm install --frozen-lockfile'
                    sh 'pnpm run build'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh 'docker login -u $DOCKER_CREDENTIALS_USR -p $DOCKER_CREDENTIALS_PSW'
                    sh 'docker build -t $DOCKER_IMAGE:latest .'
                    sh 'docker push $DOCKER_IMAGE:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
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
