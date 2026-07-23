// ============================================================
// Jenkinsfile — testpgbuild CI/CD Pipeline
// ============================================================
// Prerequisites (Jenkins Credentials):
//   chinook-db-creds  → Username/Password  (admin / admin@123)
//   chinook-db-host   → Secret Text        (e.g. localhost)
// ============================================================

pipeline {

    agent any

    parameters {
        choice(
            name        : 'ENVIRONMENT',
            choices     : ['dev', 'staging', 'prod'],
            description : 'Target deployment environment'
        )
        booleanParam(
            name         : 'SKIP_SEED',
            defaultValue : false,
            description  : 'Skip seeding sample data (set true for staging/prod)'
        )
        booleanParam(
            name         : 'SKIP_TESTS',
            defaultValue : false,
            description  : 'Skip running test suites'
        )
        booleanParam(
            name         : 'DRY_RUN',
            defaultValue : false,
            description  : 'Preview migrations without applying them'
        )
        booleanParam(
            name         : 'ROLLBACK',
            defaultValue : false,
            description  : 'Roll back the last migration instead of deploying'
        )
        string(
            name         : 'ROLLBACK_STEPS',
            defaultValue : '1',
            description  : 'Number of migrations to roll back (used when ROLLBACK=true)'
        )
    }

    environment {
        ROOT_DIR = 'D:\\testpgbuild'
        DB_NAME  = 'chinook'
        DB_PORT  = '5432'
    }

    options {
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    stages {

        // ── Stage 1: Checkout ──────────────────────────────────
        stage('Checkout') {
            steps {
                checkout scm
                powershell '''
                    Write-Host "Workspace: $env:WORKSPACE"
                    Write-Host "Branch   : $(git rev-parse --abbrev-ref HEAD)"
                    Write-Host "Commit   : $(git rev-parse --short HEAD)"
                '''
            }
        }

        // ── Stage 2: Validate ──────────────────────────────────
        stage('Validate') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    powershell '''
                        & "$env:ROOT_DIR\\scripts\\build\\validate.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }

        // ── Stage 3: Database Setup ────────────────────────────
        stage('Database Setup') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    powershell '''
                        & "$env:ROOT_DIR\\scripts\\deploy\\setup-database.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }

        // ── Stage 4: Rollback OR Migrations ───────────────────
        stage('Migrations') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    script {
                        if (params.ROLLBACK) {
                            powershell """
                                & "$env:ROOT_DIR\\scripts\\deploy\\rollback.ps1" `
                                    -DBHost     $env:DB_HOST `
                                    -DBPort     $env:DB_PORT `
                                    -DBUser     $env:DB_USER `
                                    -DBPassword $env:DB_PASS `
                                    -DBName     $env:DB_NAME `
                                    -RootDir    $env:ROOT_DIR `
                                    -LogDir     "$env:ROOT_DIR\\logs" `
                                    -Steps      ${params.ROLLBACK_STEPS}
                                if (\$LASTEXITCODE -ne 0) { exit \$LASTEXITCODE }
                            """
                        } else {
                            def dryRunFlag = params.DRY_RUN ? '-DryRun' : ''
                            powershell """
                                & "$env:ROOT_DIR\\scripts\\deploy\\deploy-migrations.ps1" `
                                    -DBHost     $env:DB_HOST `
                                    -DBPort     $env:DB_PORT `
                                    -DBUser     $env:DB_USER `
                                    -DBPassword $env:DB_PASS `
                                    -DBName     $env:DB_NAME `
                                    -RootDir    $env:ROOT_DIR `
                                    -LogDir     "$env:ROOT_DIR\\logs" `
                                    ${dryRunFlag}
                                if (\$LASTEXITCODE -ne 0) { exit \$LASTEXITCODE }
                            """
                        }
                    }
                }
            }
        }

        // ── Stage 5: Deploy Database Objects ──────────────────
        stage('Deploy Objects') {
            when { expression { !params.ROLLBACK } }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    powershell '''
                        & "$env:ROOT_DIR\\scripts\\deploy\\deploy-objects.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }

        // ── Stage 6: Seed Data ─────────────────────────────────
        stage('Seed Data') {
            when {
                allOf {
                    expression { !params.SKIP_SEED }
                    expression { !params.ROLLBACK  }
                    expression { !params.DRY_RUN   }
                }
            }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    powershell '''
                        & "$env:ROOT_DIR\\scripts\\deploy\\deploy-seeds.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }

        // ── Stage 7: Tests ─────────────────────────────────────
        stage('Tests') {
            when {
                allOf {
                    expression { !params.SKIP_TESTS }
                    expression { !params.ROLLBACK   }
                    expression { !params.DRY_RUN    }
                }
            }
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'chinook-db-creds',
                                     usernameVariable: 'DB_USER',
                                     passwordVariable: 'DB_PASS'),
                    string(credentialsId: 'chinook-db-host',
                           variable: 'DB_HOST')
                ]) {
                    powershell '''
                        & "$env:ROOT_DIR\\scripts\\test\\test-connection.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

                        & "$env:ROOT_DIR\\scripts\\test\\run-tests.ps1" `
                            -DBHost     $env:DB_HOST `
                            -DBPort     $env:DB_PORT `
                            -DBUser     $env:DB_USER `
                            -DBPassword $env:DB_PASS `
                            -DBName     $env:DB_NAME `
                            -RootDir    $env:ROOT_DIR `
                            -LogDir     "$env:ROOT_DIR\\logs"
                        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCEEDED for environment: ${params.ENVIRONMENT}"
        }
        failure {
            echo "Pipeline FAILED. Check logs at D:\\testpgbuild\\logs\\"
        }
        always {
            archiveArtifacts artifacts: 'logs/*.log', allowEmptyArchive: true
        }
    }
}
