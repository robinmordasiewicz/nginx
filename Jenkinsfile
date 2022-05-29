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
          - name: marp
            image: robinhoodis/marp:latest
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
        script {
          def currentBuild.incremented = 'false'
        }
        echo "currentBuild.incremented = ${currentBuild.incremented}"
      }
    }
    stage('Increment VERSION') {
      when {
        beforeAgent true
        not { changeset "VERSION" }
      }
      steps {
        container('ubuntu') {
          sh 'sh increment-version.sh'
        }
        script {
          currentBuild.incremented = 'true'
        }
        echo "currentBuild.incremented = ${currentBuild.incremented}"
      }
    }
    stage('checkout sphinx-theme') {
//      when {
//        beforeAgent true
//        expression {currentBuild.incremented == 'true'}
//      }
      steps {
        sh 'mkdir -p sphinx-theme'
        dir ( 'sphinx-theme' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/sphinx-theme.git'
        }
      }
    }
    stage('checkout docs') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        sh 'mkdir -p docs'
        dir ( 'docs' ) {
          git branch: 'main', url: 'https://github.com/robinmordasiewicz/f5-cnf-lab.git'
        }
      }
    }
    stage('merge sources') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        sh 'cp -aR sphinx-theme/_static docs/'
        sh 'cp -aR sphinx-theme/_templates docs/'
        sh 'cp -aR sphinx-theme/Makefile docs/'
      }
    }
    stage('make html') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        container('sphinx') {
          sh 'make -C docs clean html'
        }
      }
    }
    stage('copy html') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        sh 'mv docs/_build/html html'
      }
    }
    stage('Build/Push Container') {
      when {
        beforeAgent true
        allOf {
          expression {currentBuild.incremented == 'true'}
          expression {
            container('ubuntu') {
              sh(returnStatus: true, script: 'skopeo inspect docker://docker.io/robinhoodis/nginx:`cat VERSION`') == 1
            }
          }
        }
      }
      steps {
        container(name: 'kaniko', shell: '/busybox/sh') {
          script {
            sh '''
            /kaniko/executor --dockerfile=Dockerfile \
                             --context=`pwd` \
                             --destination=robinhoodis/nginx:`cat VERSION` \
                             --destination=robinhoodis/nginx:latest \
                             --cache=true
            '''
          }
        }
      }
    }
    stage('remove tmp folders') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        sh 'rm -rf html'
        sh 'rm -rf docs'
        sh 'rm -rf sphinx-theme'
      }
    }
    stage('Commit new VERSION') {
      when {
        beforeAgent true
        expression {currentBuild.incremented == 'true'}
      }
      steps {
        sh 'git config user.email "nginx@example.com"'
        sh 'git config user.name "nginx pipeline"'
        sh 'git add VERSION'
        sh 'git commit -m "`cat VERSION`"'
        // sh 'git add VERSION && git diff --quiet && git diff --staged --quiet || git commit -m "`cat VERSION`"'
        // sh 'git tag -a `cat VERSION` -m "`cat VERSION`" || echo "Tag: `cat VERSION` already exists"'
        withCredentials([gitUsernamePassword(credentialsId: 'github-pat', gitToolName: 'git')]) {
          //sh 'git diff --quiet && git diff --staged --quiet || git push origin main'
          // sh 'git push origin main'
          sh 'git push origin HEAD:main'
          sh 'git push --tags'
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
