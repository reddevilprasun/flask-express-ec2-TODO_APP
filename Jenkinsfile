pipeline{
  agent any
  environment {
    BACKEND_URL = "http://localhost:5000"
    MONGO_URL = credentials('mongo-url')
  }
  stages {
    // Clone the repository
    stage('Clone repository') {
      steps {
         git branch: 'main', url: 'https://github.com/reddevilprasun/flask-express-ec2-TODO_APP.git'
      }
    }

    // Setup flask backend
    stage('Setup flask backend') {
      steps {
        dir('backend') {
          // Install Python virtual environment package and set up virtual environment
          sh 'python3 -m venv venv'
          
          // Activate virtual environment and install requirements with the appropriate flag
          sh '''
            . venv/bin/activate
            pip3 install --break-system-packages -r requirements.txt
          '''
          
          // Set environment variables
          sh 'echo "MONGO_URL=$MONGO_URL" > .env'

          // Restart flask with pm2 or start if not running
          sh 'pm2 restart flask-backend'
        }
      }
    }

    // Setup express frontend
    stage('Setup express frontend') {
      steps {
        dir('frontend') {
          sh 'npm install'
          sh 'echo "BACKEND_URL=$BACKEND_URL" > .env'

          // Restart express with pm2 or start if not running
          sh 'pm2 restart express-frontend'
        }
      }
    }

  }

  post {
    always {
      echo 'Deployment completed'
    }
  }
    
}