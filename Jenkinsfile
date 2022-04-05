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
          - name: sphinx-build
            image: robinhoodis/sphinx-build:latest
            imagePullPolicy: IfNotPresent
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
         stage("Test changeset") {
             when {
                 changeset "nginx-container/html/**"
             }
             steps {
                 echo("changeset works")
             }
         }

         stage("Display changeset?") {
             steps {
                 script {
                     def changeLogSets = currentBuild.changeSets
                     echo("changeSets=" + changeLogSets)
                     for (int i = 0; i < changeLogSets.size(); i++) {
                         def entries = changeLogSets[i].items
                         for (int j = 0; j < entries.length; j++) {
                             def entry = entries[j]
                             echo "${entry.commitId} by ${entry.author} on ${new Date(entry.timestamp)}: ${entry.msg}"
                             def files = new ArrayList(entry.affectedFiles)
                             for (int k = 0; k < files.size(); k++) {
                                 def file = files[k]
                                 echo " ${file.editType.name} ${file.path}"
                             }
                         }
                     }
                 }
             }
         }
    stage('git-commit') {
      when { changeset "nginx-container/html/**"}
      steps {
        dir ( 'nginx-container' ) {
          sh 'git config user.email "robin@mordasiewicz.com"'
          sh 'git config user.name "Robin Mordasiewicz"'
          sh 'git add .'
          sh 'git commit -m "New HTML: `date`"'
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
