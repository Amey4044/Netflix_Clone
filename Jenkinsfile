pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'
        PNPM_HOME = "/var/lib/jenkins/.local/share/pnpm"
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
                    sh '''#!/bin/bash
                        curl -fsSL https://get.pnpm.io/install.sh | sh -
                        echo "export PATH=/var/lib/jenkins/.local/share/pnpm:$PATH" >> ~/.bashrc
                        echo "export PATH=/var/lib/jenkins/.local/share/pnpm:$PATH" >> ~/.profile
                        . ~/.bashrc
                        . ~/.profile
                        echo "PNPM installed successfully!"
                        pnpm --version
                    '''
                }
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    sh '''#!/bin/bash
                        export PATH="/var/lib/jenkins/.local/share/pnpm:$PATH"
                        which pnpm
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
                        sh '''#!/bin/bash
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
                        sh '''#!/bin/bash
                            sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
                            sudo chmod -R 700 /var/lib/jenkins/.kube

                            kubectl config use-context minikube

                            if [ -f k8s/deployment.yaml ] && [ -f k8s/service.yaml ]; then
                                kubectl apply -f k8s/deployment.yaml
                                kubectl apply -f k8s/service.yaml
                                kubectl rollout restart deployment/netflix-clone
                                kubectl rollout status deployment/netflix-clone
                            else
                                echo "❌ Kubernetes manifest files not found!"
                                exit 1
                            fi

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
