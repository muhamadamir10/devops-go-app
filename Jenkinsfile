pipeline {
    agent any

    environment {
        IMAGE_NAME = 'devops-go-app'
        VERSION = '1.0.0'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Run Unit Test') {
            steps {
                echo 'Running Go Unit Tests...'
                sh 'docker run --rm -v "$(pwd):/app" -w /app golang:1.22-alpine go test -v ./...'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image version ${VERSION}..."
                sh "docker build --build-arg VERSION=${VERSION} -t ${IMAGE_NAME}:${VERSION} ."
            }
        }

        stage('Compile Binary for Hotfix Mount') {
            steps {
                echo 'Compiling binary to ./bin/app...'
                sh 'mkdir -p bin'
                sh "docker run --rm -v \"\$(pwd):/app\" -w /app golang:1.22-alpine sh -c \"CGO_ENABLED=0 GOOS=linux go build -ldflags='-X main.version=${VERSION}' -o ./bin/app main.go\""
            }
        }

        stage('Deploy Container') {
            steps {
                echo 'Deploying application container...'
                sh """
                    docker stop go-app-container || true
                    docker rm go-app-container || true
                    docker run -d --name go-app-container -p 8080:8080 --restart always -v "\$(pwd)/bin/app:/app/app" ${IMAGE_NAME}:${VERSION}
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Please check logs.'
        }
    }
}