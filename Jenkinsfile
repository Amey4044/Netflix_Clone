pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'  // Corrected path
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
                        set -e
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
                        set -e
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
                            set -e
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
                            set -e
                            sudo chown jenkins:jenkins ${KUBECONFIG}
                            sudo chmod 600 ${KUBECONFIG}
                            kubectl config view
                            kubectl get nodes

                            if [ -f k8s/deployment.yaml ] && [ -f k8s/service.yaml ]; then
                                kubectl apply -f k8s/deployment.yaml
                                kubectl apply -f k8s/service.yaml
                                kubectl rollout restart deployment/netflix-clone
                                kubectl rollout status deployment/netflix-clone
                            else
                                echo "❌ Kubernetes manifest files not found!"
                                exit 1
                            fi

                            # Debugging Steps
                            kubectl get pods -o wide
                            kubectl logs -l app=netflix-clone --tail=50
                            kubectl get svc netflix-clone -o yaml
                        '''
                    }
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
