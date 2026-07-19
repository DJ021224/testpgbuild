pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('DB Deploy') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'chinook-creds', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS'),
          string(credentialsId: 'chinook-host', variable: 'DB_HOST')
        ]) {
          script {
            if (isUnix()) {
              sh '''#!/bin/bash
for f in procedures/*; do
  if [ -f "$f" ]; then
    echo "Applying $f"
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d chinook -f "$f"
  fi
done
'''
            } else {
              powershell '''
$env:PGPASSWORD = $env:DB_PASS
Get-ChildItem -Path procedures -File | ForEach-Object {
  Write-Host "Applying $($_.FullName)"
  psql -h $env:DB_HOST -U $env:DB_USER -d chinook -f $_.FullName
}
'''
            }
          }
        }
      }
    }
  }
  post {
    success { echo 'Deployment succeeded' }
    failure { echo 'Deployment failed' }
  }
}
