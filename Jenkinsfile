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
            imagePullPolicy: IfNotPresent
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
    stage('Increment VERSION') {
      when {
        beforeAgent true
        not { changeset "VERSION" }
      }
      steps {
        container('ubuntu') {
          sh 'sh increment-version.sh'
        }
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
        sh 'mv docs/_build/html html'
      }
    }
    stage('Build/Push Container') {
      when {
        beforeAgent true
        expression {
          container('ubuntu') {
            sh(returnStatus: true, script: 'skopeo inspect docker://docker.io/robinhoodis/nginx:`cat VERSION`') == 1
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
      steps {
        sh 'rm -rf html'
        sh 'rm -rf docs'
        sh 'rm -rf tmp'
      }
    }
    stage('Commit new VERSION') {
      when {
        beforeAgent true
        not { changeset "VERSION" }
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
      cleanWs(cleanWhenNotBuilt: false,
            deleteDirs: true,
            disableDeferredWipeout: true,
            notFailBuild: true,
            patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                       [pattern: '.propsfile', type: 'EXCLUDE']])
    }
  }
}
