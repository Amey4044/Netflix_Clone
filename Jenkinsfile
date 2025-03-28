pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cypher7/netflix-clone'
        KUBE_CONFIG = credentials('kubeconfig-id') // Kubernetes credentials in Jenkins
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials') // DockerHub credentials in Jenkins
        VITE_TMDB_API_KEY = credentials('tmdb-api-key') // Add this in Jenkins credentials
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
                        . $HOME/.bashrc  # Fixed: Using dot instead of source
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
                    withKubeConfig([credentialsId: 'kubeconfig-id']) {
                        sh '''
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
            echo 'Deployment successful! ✅'
        }
        failure {
            echo 'Deployment failed ❌'
        }
    }
}
