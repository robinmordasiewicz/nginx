pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
  triggers {
    upstream(upstreamProjects: "docs", threshold: hudson.model.Result.SUCCESS)
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: sphinx
            image: robinhoodis/sphinx:0.0.45
            imagePullPolicy: IfNotPresent
            command:
            - cat
            tty: true
        '''
    }
  }
  stages {
    stage('INIT') {
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('mkdir tmp') {
      steps {
        sh 'mkdir tmp'
      }
    }
    stage('checkout sphinx-theme') {
      steps {
        sh 'mkdir -p tmp/theme'
        dir ( 'tmp/theme' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/sphinx-theme.git'
        }
      }
    }
    stage('checkout docs') {
      steps {
        sh 'mkdir -p tmp/docs'
        dir ( 'tmp/docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/f5-cnf-lab.git'
        }
      }
    }
    stage('merge sources') {
      steps {
        sh 'mkdir docs'
        sh 'cp -aR tmp/theme/* docs/'
        sh 'cp -aR tmp/docs/* docs/'
        sh 'rm -rf tmp/'
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
        sh 'cp -R docs/_build/html nginx/'
      }
    }
    stage('clean up docs folder') {
      steps {
        container('sphinx') {
          sh 'id'
          sh 'ls -al'
          sh 'rm -rf docs'
        }
      }
    }
    stage('Commit new HTML') {
      steps {
        dir ( 'nginx' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git diff --quiet && git diff --staged --quiet || git commit -am "`date`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            // sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
            // 'git diff --quiet && git diff --staged --quiet || git push --tags'
            sh 'git push origin main'
           // sh 'git push origin `cat ../VERSION`'
            // sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
          }
        }
      }
    }
    stage('cleap up nginx folder') {
      steps {
        container('sphinx') {
          sh 'id'
          sh 'ls -al'
          sh 'rm -rf nginx'
        }
      }
    }
  }
  post {
    always {
      cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
    }
  }
}
