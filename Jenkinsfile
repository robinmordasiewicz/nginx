pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
  triggers {
    upstream(upstreamProjects: "sphinx,sphinx-theme,f5-cnf-lab", threshold: hudson.model.Result.SUCCESS)
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: ubuntu
            image: robinhoodis/ubuntu:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: sphinx
            image: robinhoodis/sphinx:0.0.48
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
        sh 'cp -aR tmp/docs/* docs/'
        sh 'rm -rf docs/_static'
        sh 'rm -rf docs/_templates'
        sh 'cp -aR tmp/theme/_static docs/'
        sh 'cp -aR tmp/theme/_templates docs/'
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
          sh 'cp -a docs/intro.mp4 nginx/'
      }
    }
    stage('clean up docs folder') {
      steps {
        container('sphinx') {
          sh 'rm -rf docs'
        }
      }
    }
    stage('Commit new HTML') {
//      when {
//        beforeAgent true
//          expression {
//            container('ubuntu') {
//              dir( 'nginx' ) {
//                sh(returnStatus: true, script: '`git ls-files --other --exclude-standard --directory | egrep -v "/$"`') == 0
//              }
//            }
//          }
//      }
      steps {
        dir ( 'nginx' ) {
          sh 'git status' 
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add -A'
          // sh 'git commit -m "`date`"'
          // sh 'git commit -am "`date`"'
          sh 'git diff --quiet && git diff --staged --quiet || git commit -am "`date`"'
          withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
            // sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
            // 'git diff --quiet && git diff --staged --quiet || git push --tags'
            // sh 'git push origin `cat ../VERSION`'
            // sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
            sh 'git push origin main'
          }
          sh 'git status' 
        }
      }
    }
    stage('clean up nginx folder') {
      steps {
        container('sphinx') {
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
