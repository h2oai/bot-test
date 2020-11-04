#!groovy

@Library('test-shared-library@1.1') _

import groovy.json.JsonOutput

def slackNotificationChannel = "slack-bot-test"

def notifySlack(text, channel, attachments) {
    def slackURL = 'https://hooks.slack.com/services/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'

    def payload = JsonOutput.toJson([text: text,
        channel: channel,
        attachments: attachments
    ])

    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slackURL}"
}

def getGitAuthor = {
    def commit = sh(returnStdout: true, script: 'git rev-parse HEAD')
    author = sh(returnStdout: true, script: "git --no-pager show -s --format='%an' ${commit}").trim()
}

def getLastCommitMessage = {
    message = sh(returnStdout: true, script: 'git log -1 --pretty=%B').trim()
}

def getBuildColor(){
    def color = ""
    if(currentBuild.result=="SUCCESS"){
        color = "good"
    } else if (currentBuild.result=="FAILURE"){
        color = "danger"
    }else{
        color = "warning"
    }
    return color
}

node {
    try {
         stage('Checkout'){
            sh 'env'
            deleteDir()
            checkout scm
        }
    }
    catch (hudson.AbortException ae) {
        // I ignore aborted builds, but you're welcome to notify Slack here
        echo "THIS IS ABORT EXCEPTION"
    }
    catch (e) {
        def buildStatus = "Failed"
        echo "THIS IS CATCH BLOCK"
        notifySlack("", slackNotificationChannel, [
            [
                title: "${env.JOB_NAME}, build #${env.BUILD_NUMBER}",
                title_link: "${env.BUILD_URL}",
                color: "danger",
                author_name: "${author}",
                text: "${buildStatus}",
                fields: [
                    [
                        title: "Branch",
                        value: "${env.GIT_BRANCH}",
                        short: true
                    ],
                    [
                        title: "Last Commit",
                        value: "${message}",
                        short: false
                    ],
                    [
                        title: "Error",
                        value: "${e}",
                        short: false
                    ]
                ]
            ]
        ])

        throw e
    }
    finally {
        stage('Notify Slack') {
            def buildColor = getBuildColor()
            def buildStatus = currentBuild.result
            echo "BUILD RESULT: ${currentBuild.result}"
            def message = getLastCommitMessage()
            def author = getGitAuthor()
            def jobName = "${env.JOB_NAME}"

            // Strip the branch name out of the job name (ex: "Job Name/branch1" -> "Job Name")
            jobName = jobName.getAt(0..(jobName.indexOf('/') - 1))


            notifySlack("", slackNotificationChannel, [
                [
                    title: "${jobName}, build #${env.BUILD_NUMBER}",
                    title_link: "${env.BUILD_URL}",
                    color: "${buildColor}",
                    author_name: "${author}",
                    text: "${buildStatus}\n${author}",
                    fields: [
                        [
                            title: "Branch",
                            value: "${env.GIT_BRANCH}",
                            short: true
                        ],
                        [
                            title: "Last Commit",
                            value: "${message}",
                            short: false
                        ]
                    ]
                ]
            ])
        }
    }

}
