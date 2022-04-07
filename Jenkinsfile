pipeline {
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: sphinx-build
            image: robinhoodis/sphinx-build:0.0.12
            imagePullPolicy: IfNotPresent
            command:
            - cat
            tty: true
        '''
    }
  }
  stages {
    stage('checkout scm') {
      steps {
        sh 'mkdir docs'
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/docs.git'
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
    stage('copy-html') {
      steps {
        sh 'mkdir nginx-container'
        dir ( 'nginx-container' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/nginx-container.git'
        }
        sh 'rm -rf nginx-container/html'
        sh 'cp -a docs/_build/html nginx-container/'
      }
    }
    stage('clean up build directory') {
      steps {
        sh 'rm -rf docs'
      }
    }
    stage('git-commit') {
      steps {
        dir ( 'nginx-container' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add -A'
          sh 'git diff --quiet && git diff --staged --quiet || git commit -am "New HTML: `date`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh 'git diff --quiet && git diff --staged --quiet || git push'
          }
        }
      }
    }
    stage('clean up') {
      steps {
        sh 'rm -rf nginx-container'
        sh 'rm -rf docs'
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
