pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBECONFIG_PATH = '/home/cypher/kubeconfig' // Absolute path to KubeConfig
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials') // DockerHub credentials in Jenkins
        VITE_TMDB_API_KEY = credentials('tmdb-api-key') // TMDB API Key from Jenkins credentials
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
                        . $HOME/.bashrc  # Source the updated bashrc
                        pnpm --version  # Verify installation
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
                        pnpm install --frozen-lockfile
                        pnpm run build
                    '''
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh '''
                        echo "$DOCKER_CREDENTIALS_PSW" | docker login -u "$DOCKER_CREDENTIALS_USR" --password-stdin
                        docker build -t $DOCKER_IMAGE:latest .
                        docker push $DOCKER_IMAGE:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withEnv(["KUBECONFIG=${KUBECONFIG_PATH}"]) { // Use absolute KubeConfig path
                        sh '''
                            kubectl config view
                            kubectl get nodes
                            kubectl set env deployment/netflix-clone VITE_TMDB_API_KEY=${VITE_TMDB_API_KEY}
                            kubectl apply -f k8s/deployment.yaml
                            kubectl apply -f k8s/service.yaml
                        '''
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
            echo '🚀 Deployment successful! ✅'
        }
        failure {
            echo '❌ Deployment failed. Check logs for details.'
        }
    }
}
