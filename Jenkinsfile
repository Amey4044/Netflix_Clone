pipeline {
    agent any

    triggers {
        // Trigger build on GitHub push events
        githubPush() // This line sets up the GitHub webhook trigger
    }

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone-main-app'
        KUBECONFIG_PATH = '/var/lib/jenkins/.kube/config'
        PNPM_HOME = "/var/lib/jenkins/.local/share/pnpm"
        PATH = "${PNPM_HOME}:${PATH}:/usr/local/bin:/usr/bin:/usr/sbin"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout code from the main branch
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
                        echo "✅ PNPM installed successfully!"
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

        stage('Deploy to AWS EKS') {
            steps {
                script {
                    withEnv(["KUBECONFIG=${KUBECONFIG_PATH}"]) {
                        sh '''#!/bin/bash
                            echo "🚀 Setting Kubernetes context to AWS EKS..."
                            kubectl config use-context arn:aws:eks:ap-south-1:905418132848:cluster/netflix-eks-cluster

                            echo "✅ Verifying connection..."
                            kubectl cluster-info
                            kubectl get nodes

                            echo "🔄 Deploying Netflix Clone using Helm..."
                            helm upgrade --install netflix-clone ./netflix-clone-chart/ -n netflix --create-namespace

                            echo "📌 Fetching Running Pods..."
                            kubectl get pods -n netflix -o wide
                            kubectl logs -l app=netflix-clone -n netflix --tail=50

                            echo "🔍 Fetching Service Info..."
                            kubectl get svc netflix-clone-service -n netflix -o yaml
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo '🚀 Deployment to AWS EKS successful! ✅'
        }
        failure {
            echo '❌ Deployment failed. Check logs for details.'
        }
    }
}
