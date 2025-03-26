pipeline:
  agent: any
  environment:
    NODE_VERSION: "18.x"
    IMAGE_NAME: "amey4044/netflix-clone"
    KUBE_NAMESPACE: "default"
  stages:
    - stage: Checkout Code
      steps:
        - checkout:
            scm: git
            url: "https://github.com/Amey4044/Netflix_Clone.git"
            branch: "main"

    - stage: Setup Node.js
      steps:
        - script:
            - echo "Setting up Node.js"
            - curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | bash -
            - apt-get install -y nodejs
            - node -v

    - stage: Install Dependencies
      steps:
        - script:
            - echo "Installing dependencies..."
            - npm install

    - stage: Build React App
      steps:
        - script:
            - echo "Building the React app..."
            - npm run build

    - stage: Dockerize
      steps:
        - script:
            - echo "Building Docker image..."
            - docker build -t $IMAGE_NAME:latest .

    - stage: Push to Docker Hub
      steps:
        - script:
            - echo "Logging into Docker Hub..."
            - echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            - echo "Pushing image to Docker Hub..."
            - docker push $IMAGE_NAME:latest

    - stage: Deploy to Kubernetes
      steps:
        - script:
            - echo "Deploying to Kubernetes..."
            - kubectl apply -f k8s/deployment.yaml -n $KUBE_NAMESPACE
            - kubectl apply -f k8s/service.yaml -n $KUBE_NAMESPACE

  post:
    always:
      - script:
          - echo "Build or Deployment completed!"
    failure:
      - script:
          - echo "Build or Deployment failed!"
