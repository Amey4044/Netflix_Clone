pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "amey4044/netflix-clone"
        DOCKER_TAG = "latest"
        KUBE_DEPLOYMENT = "netflix-clone"
        KUBE_NAMESPACE = "default"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Amey4044/Netflix_Clone.git'
            }
        }

        stage('Build React App') {
            steps {
                script {
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE:$DOCKER_TAG ."
                    sh "docker tag $DOCKER_IMAGE:$DOCKER_TAG $DOCKER_IMAGE:$(git rev-parse --short HEAD)"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub-credentials', url: 'https://index.docker.io/v1/']) {
                        sh "docker push $DOCKER_IMAGE:$DOCKER_TAG"
                        sh "docker push $DOCKER_IMAGE:$(git rev-parse --short HEAD)"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh """
                    kubectl set image deployment/$KUBE_DEPLOYMENT netflix-app=$DOCKER_IMAGE:$DOCKER_TAG -n $KUBE_NAMESPACE
                    kubectl rollout status deployment/$KUBE_DEPLOYMENT -n $KUBE_NAMESPACE
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Build or Deployment failed.'
        }
    }
}
