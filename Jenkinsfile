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
      environment {
        AN_ACCESS_KEY = credentials('voltpass')
      }
      steps {
        cleanWs()
        checkout scm
        sh 'ls -al'
        container('ubuntu') {
          sh('sh xvfb.sh ${AN_ACCESS_KEY_USR} ${AN_ACCESS_KEY_PSW}')
        }
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
