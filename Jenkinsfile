pipeline {
  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }
  triggers {
    upstream(upstreamProjects: "sphinx,theme,contentascode,marp-cli", threshold: hudson.model.Result.SUCCESS)
  }
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: puppeteer
            image: robinhoodis/puppeteer:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: terminalizer
            image: robinhoodis/terminalizer:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: ubuntu
            image: robinhoodis/ubuntu:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: sphinx
            image: robinhoodis/sphinx:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: diagrams
            image: robinhoodis/diagrams:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: mermaid-cli
            image: robinhoodis/mermaid-cli:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: marp-cli
            image: robinhoodis/marp-cli:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: imagemagick
            image: robinhoodis/imagemagick:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: melt
            image: robinhoodis/melt:latest
            imagePullPolicy: Always
            command:
            - cat
            tty: true
          - name: kaniko
            image: gcr.io/kaniko-project/executor:debug
            imagePullPolicy: IfNotPresent
            command:
            - /busybox/cat
            tty: true
            volumeMounts:
              - name: kaniko-secret
                mountPath: /kaniko/.docker
          restartPolicy: Never
          volumes:
            - name: kaniko-secret
              secret:
                secretName: regcred
                items:
                  - key: .dockerconfigjson
                    path: config.json
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
    stage('checkout theme') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        sh 'mkdir -p theme'
        dir ( 'theme' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/theme.git'
        }
      }
    }
    stage('checkout docs') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        sh 'mkdir -p docs'
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/contentascode.git'
        }
      }
    }
    stage('Screen Recording') {
      environment {
        AN_ACCESS_KEY = credentials('voltpass')
      }
      steps {
        sh('cp bin/xvfb.sh ./')
        sh('cp bin/puppeteer.sh ./')
        sh('cp theme/install-mouse-helper.js ./')
        sh('cp theme/puppeteer-functions.mjs ./')
        sh('cp docs/distributed-cloud-login.js ./')
        container('puppeteer') {
          sh('./xvfb.sh ${AN_ACCESS_KEY_USR} ${AN_ACCESS_KEY_PSW}')
        }
        sh('rm xvfb.sh puppeteer.sh install-mouse-helper.js distributed-cloud-login.js puppeteer-functions.mjs')
      }
    }
    stage('Commit new VERSION') {
      steps {
        sh 'git config user.email "nginx@example.com"'
        sh 'git config user.name "nginx pipeline"'
        sh 'git add .'
        sh 'git commit -m "new movies"'
        // sh 'git add VERSION && git diff --quiet && git diff --staged --quiet || git commit -m "`cat VERSION`"'
        // sh 'git tag -a `cat VERSION` -m "`cat VERSION`" || echo "Tag: `cat VERSION` already exists"'
        withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
          //sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
          // sh 'git push origin main'
          sh 'git push origin HEAD:main'
          sh 'git push --tags'
        }
        script {
          currentBuild.result = "SUCCESS"
        }
        echo "stage build result = ${currentBuild.result}"
      }
    }
  }
  post {
    always {
      cleanWs(cleanWhenNotBuilt: true,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
    }
  }
}
