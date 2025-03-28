pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBECONFIG_PATH = '/var/lib/jenkins/.minikube/config'  // Updated Kubeconfig path
        PNPM_HOME = "${HOME}/.local/share/pnpm"
        PATH = "${PNPM_HOME}:${PATH}:/usr/local/bin:/usr/bin:/usr/sbin"
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
                    sh '''
                        curl -fsSL https://get.pnpm.io/install.sh | sh -
                        echo "PNPM installed successfully!"
                        pnpm --version
                    '''
                }
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    sh '''
                        pnpm install --frozen-lockfile
                        pnpm run build
                    '''
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker build -t $DOCKER_IMAGE:latest .
                            docker push $DOCKER_IMAGE:latest
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withEnv(["KUBECONFIG=${KUBECONFIG_PATH}"]) {
                        sh '''
                            chmod 600 ${KUBECONFIG}
                            kubectl config view
                            kubectl get nodes
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                            kubectl rollout restart deployment/netflix-clone

                            # Debugging Steps
                            kubectl get pods -o wide
                            kubectl logs -l app=netflix-clone --tail=50
                            kubectl get svc netflix-clone -o yaml
                        '''
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    sh '''
                        which argocd  # Debugging step
                        argocd app sync netflix-clone
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '🚀 Deployment successful! ✅'
        }
        failure {
            echo '❌ Deployment failed. Check logs for details.'
        }
    }
}
