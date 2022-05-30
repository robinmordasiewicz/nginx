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
    stage('bypass') {
      when {
        beforeAgent true
        changeset "VERSION"
      }
      steps {
        script {
          currentBuild.result = 'NOT_BUILT'
        }
      }
    }
    stage('INIT') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('Increment VERSION') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('ubuntu') {
          sh 'sh increment-version.sh'
        }
      }
    }
    stage('checkout sphinx-theme') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
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
        expression {currentBuild.result != 'NOT_BUILT'}
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
        expression {currentBuild.result != 'NOT_BUILT'}
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
        expression {currentBuild.result != 'NOT_BUILT'}
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
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        sh 'mv docs/_build/html html'
      }
    }
    stage('Images') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('imagemagick') {
          sh 'sh imagemagick.sh'
        }
      }
    }
    stage('Mermaid Diagrams') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('mermaid-cli') {
          sh 'sh mermaid-cli.sh'
        }
      }
    }
    stage('Python Diagrams') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('diagrams') {
          sh 'sh diagrams.sh'
          sh 'mv docs/diagram1.png ./'
        }
      }
    }
    stage('Videos') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('melt') {
          sh 'sh melt.sh'
          sh 'mv intro.mp4 html/'
        }
      }
    }
    stage('PPTX') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
      }
      steps {
        container('marp-cli') {
          sh 'sh marp-cli.sh'
        }
      }
    }
    stage('Build/Push Container') {
      when {
        beforeAgent true
        allOf {
          expression {currentBuild.result != 'NOT_BUILT'}
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
        script {
          currentBuild.result = "SUCCESS"
        }
        echo "kaniko stage result = ${currentBuild.result}"
      }
    }
    stage('remove tmp folders') {
      when {
        beforeAgent true
        expression {currentBuild.result != 'NOT_BUILT'}
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
        expression {currentBuild.result != 'NOT_BUILT'}
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
