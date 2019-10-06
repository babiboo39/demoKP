def build_status = false
def test_status = false

pipeline {
    agent any

    environment {
        service_name = "${JOB_NAME}".split('/').first()
        build_tool = sh (script:  '/testSCript.sh specifyBuild' , returnStdout: true).trim()
        env_name = sh (script: '/testScript.sh specifyEnv', returnStdout: true).trim()
    }
    stages {
        stage ('Build & Test') {
            parallel {
                stage ('Build') {
                    steps {
                        script {
                            try {
                                echo "Build Stage is Success"

                                build_status = true
                            } catch (Exception err) {
                                build_status = false
                                echo "The build is fail, send notification"
                            }
                        }
                    }
                }
                stage ('Test') {
                    steps {
                        script {
                            if (env.build_tool == "mvnw") {
                                try {
                                    echo "Use mvnw test"
                                    test_status = true
                                } catch (Exception err) {
                                    test_status = false
                                }
                            } else if (env.build_tool == 'gradlew') {
                                try {
                                    echo "Use gradlew test"
                                    test_status = true
                                } catch (Exception err) {
                                    test_status = false
                                }
                            } else {
                                echo "Can't specify the build tool, exitting..."
                                test_status = false
                            }
                            if (!test_status) {
                                echo "Test stage failed, send notification"
                            }
                        }
                    }
                }
            }
        }

        stage ('Packaging and Dockerize Image') {
            when {
                expression {
                    build_status && test_status
                }
            }
            parallel {
                stage ('Dockerize') {
                    steps {
                        script {
                            echo "This stage is for Dockerize the services"
                        }
                    }
                }
                stage ('Store to OSS') {
                    steps {
                        script {
                            echo "This stage is to packaging the services and store to alibaba OSS"
                        }
                    }
                }
            }
        }

        stage ('Deploy') {
            when {
                expression {
                    build_status && test_status
                }
            }
            steps {
                script {
                    try {
                        sh '''
                            echo "Execute the command to deploy"

                            if [ \$env_name == 'feature' ]; then
                                echo "Notify that the deploy of \${service_name} for environment \${env_name} is success"
                            elif [ \$env_name == 'alpha' ]; then
                                echo "Notify that the deploy of \${service_name} for environment \${env_name} is success, confirm to release or not"
                            fi
                        '''
                        // ask for Version input from user
                        if (env.env_name == 'alpha') {
                            try {
                                timeout(time: 1, unit: 'DAYS') {
                                    env.userChoice = input message: 'Do you want to Release this build?',
                                    parameters: [choice(name: 'Versioning Service', choices: 'no\nyes', description: 'Choose "yes" if you want to release this build')]
                                }
                                if (userChoice == 'no') {
                                    echo "User refuse to release this build, stopping...."
                                }
                            } catch (Exception err) {
                                echo "Notify that The deploy stage for ${service_name} is aborted, send notification"
                            }
                        }
                        
                    } catch (Exception err) {
                        echo "Notify that The deploy stage for ${service_name} is failed, send notification"
                    }
                }
            }
        }

        stage ('Release') {
            when {
                environment name: 'userChoice', value: 'yes'
            }
            steps {
                script {
                    try {
                        timeout(time: 1, unit: 'DAYS') {
                            env.version_name = input (
                                 id: 'version', message: 'Input version name', parameters: [
                                    [$class: 'TextParameterDefinition', description: 'Whatever you type here will be your version', name: 'Version']
                                ]
                            )
                        }
                        try {
                            sh '''
                                echo "Execute command to relase"
                                
                                echo "Notify that the Release stage for \${service_name} is success"                                
                            '''
                        } catch (Exception err) {
                            echo "Notify that the Release stage for ${service_name} is failed"
                        }
                    } catch (Exception err) {
                        echo "Notify that the Release stage for ${service_name} is aborted"
                    }
                }
            }
        }
    }
}