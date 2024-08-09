														#/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/conf$ cat sonar-scanner.properties 
														#Configure here general information about the environment, such as SonarQube server connection details for example
														#No information about specific project should appear here
														
														#----- Default SonarQube server
														#sonar.host.url=http://localhost:9000
														
														#----- Default source code encoding
														#sonar.sourceEncoding=UTF-8
														
														#sonar.projectKey=<project name>
														#sonar.projectBaseDir=/home/jenkins/workspace/
														
														#sonar.sourceEncoding=UTF-8 
														#sonar.scm.exclusions.disabled=true 
														#sonar.host.url=https://sonar.qube.net/ 
														#sonar.exclusions=**/*.xml,**/*.css,**/*.js,**/*json,**/*.html,**/*.phtml 
														#sonar.login= 1269fffcc0a1316dbf63beac6b
														
														#  Path : /var/lib/jenkins/tools/hudson.plugins.sonar.SonarRunnerInstallation/sonar-scanner/conf

verpipeline 
{
    parameters {
    string( name: 'Branch',
            defaultValue: 'develop',
            description: 'Enter the branch name:')
    }        
    agent {
     label 'Master'   
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: 'refs/heads/'+ params.Branch]], doGenerateSubmoduleConfigurations: false, extensions: [pruneStaleBranch()], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins-ssh-key', url: 'git@bitbucket.org:<Repo>.git']]])
                
            }
        }
        stage ("Composer Install") {
            steps {
                sh '/usr/bin/php8.4 /usr/local/bin/composer install -v --no-dev --prefer-dist'
             
            }
        }
        
        stage ("Scan-folder Creation") {
            steps {
                sh 'cp -r vendor/ vendor_new '
             
            }
        }
        
    //     //install php8.1
    //     //usr/bin/php8.1 /usr/local/bin/composer install -v --no-dev --prefer-dist
    //     //sudo apt-get install php8.1-pdo-mysql
    //     //sudo update-alternatives --set php /usr/bin/php8.1 -TO SWITCH PHP VER
    //     //sudo chmod -R 775  /ROOT_OF_YOUR_APP/vendor/
    //     //sudo chown -R $USER:$USER /ROOT_OF_YOUR_APP/vendor/
        
    //     // configure login parameter in AWS param store / jenkins creds
        
         
        stage("Sonar-Scanning") {
            steps {
                script {
                    // def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonarqube') {
                    //    sh "${scannerHome}/bin/sonar-scanner "
                    sh """cp ${scannerHome}/conf/* . """
                    sh """${scannerHome}/bin/sonar-scanner -D sonar.projectBaseDir=/home/jenkins/workspace/ \
                    -D sonar.sources=vendor_new/ \
                    -D sonar.filesize.limit=25 \
                    -D sonar.branch.name=${params.Branch} \
                    -D sonar.exclusions= """
                    //module-payu-india/** """
                    // -D sonar.pullrequest.base=develop \
                    // -D sonar.pullrequest.branch=Update \
                    // -D sonar.pullrequest.key=3390 """
                    
                  }
                }
            }
        }
    }    
    post {
        always {
            cleanWs()
        }
    }
    
}
