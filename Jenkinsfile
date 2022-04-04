pipeline {
  options {
    disableConcurrentBuilds(abortPrevious: true)
    skipDefaultCheckout(true)
    ansiColor('xterm')
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: sphinx-build
            image: robinhoodis/sphinx-build:latest
            command:
            - cat
            tty: true
        '''
    }
  }
  stages {
    stage("cleanWS") {
      steps {
        cleanWs()
        // checkout scm
      }
    }
    stage('prepareWS') {
      steps {
        sh 'mkdir -p docs'
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/f5-cnf-lab.git'
        }
      }
    }
    stage('shpinx-build') {
      steps {
        container('sphinx-build') {
          sh 'make -C docs clean html'
        }
      }
    }
    stage('git-commit') {
      steps {
        sh 'mkdir nginx-container'
        dir ( 'nginx-container' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/nginx-container.git'
        }
        sh 'rm -rf nginx-container/html'
        sh 'cp -a docs/_build/html nginx-container/'
        dir ( 'nginx-container' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add .'
          sh 'git commit -m "`New HTML: `date``"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh '/usr/bin/git push origin main'
          }
        }
      }
    }
  }
//  post {
//    always {
//      cleanWs(cleanWhenNotBuilt: false,
//            deleteDirs: true,
//            disableDeferredWipeout: true,
//            notFailBuild: true,
//            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
//                     [pattern: '.propsfile', type: 'EXCLUDE']])
//    }
//  }
}
