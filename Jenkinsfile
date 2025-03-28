pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBECONFIG_PATH = '/var/lib/jenkins/kubeconfig'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        VITE_TMDB_API_KEY = credentials('tmdb-api-key')
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
                        export PNPM_HOME="$HOME/.local/share/pnpm"
                        export PATH="$PNPM_HOME:$PATH"
                        echo "export PNPM_HOME=$HOME/.local/share/pnpm" >> $HOME/.bashrc
                        echo "export PATH=$PNPM_HOME:$PATH" >> $HOME/.bashrc
                        bash -c "source $HOME/.bashrc && pnpm --version"
                    '''
                }
            }
        }

        stage('Install Dependencies & Build') {
            steps {
                script {
                    sh '''
                        export PNPM_HOME="$HOME/.local/share/pnpm"
                        export PATH="$PNPM_HOME:$PATH"
                        bash -c "pnpm install --frozen-lockfile"
                        bash -c "pnpm run build"
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
                        '''
                    }
                }
            }
        }

        stage('Trigger ArgoCD Sync') {
            steps {
                script {
                    sh '''
                        export PATH=$PATH:/usr/local/bin
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
