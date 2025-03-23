pipeline{
  agent any
  environment {
    BACKEND_URL = "http://localhost:5000"
    MONGO_URL = credentials('mongo_url')
  }
  stages {
    // Clone the repository
    stage('Clone repository') {
      steps {
        git 'https://github.com/reddevilprasun/flask-express-ec2-TODO_APP.git'
      }
    }

    // Setup flask backend
    stage('Setup flask backend') {
      steps {
        dir('backend') {
          sh 'pip3 install -r requirements.txt'
          sh 'echo "MONGO_URL=$MONGO_URL" > .env'

          // Restart flask with pm2 or start if not running
          sh 'pm2 restart flask-backend || pm2 start gunicorn --name flask-backend -- gunicorn --bind 0.0.0.0:5000 app:app'
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
          sh 'pm2 restart express-frontend || pm2 start npm --name express-frontend -- start'
        }
      }
    }

  }

  post {
    always {
      // Save the pm2 logs
      sh 'pm2 save'
      echo 'Deployment completed'
    }
  }
    
}