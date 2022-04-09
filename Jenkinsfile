pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: sphinx
            image: robinhoodis/sphinx:0.0.24
            imagePullPolicy: IfNotPresent
            command:
            - cat
            tty: true
        '''
    }
  }
  stages {
    stage('mkdir docs') {
      steps {
        sh 'mkdir docs'
      }
    }
    stage('checkout sphinx-theme') {
      steps {
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/sphinx-theme.git'
        }
      }
    }
    stage('checkout docs') {
      steps {
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/docs.git'
        }
      }
    }
    stage('make html') {
      steps {
        container('sphinx') {
          // sh '[ -f docs/requirements.txt ] && /usr/bin/pip3 install -r docs/requirements.txt -U'
          sh '/usr/bin/make -C docs clean html'
        }
      }
    }
    stage('copy html') {
      steps {
        sh 'mkdir nginx'
        dir ( 'nginx' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/nginx.git'
        }
        sh 'rm -rf nginx/html'
        sh 'cp -a docs/_build/html nginx/'
      }
    }
    stage('git-commit') {
      steps {
        dir ( 'nginx' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add -A'
          sh 'git diff --quiet && git diff --staged --quiet || git commit -am "New HTML: `date`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
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
