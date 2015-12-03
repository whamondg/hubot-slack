# Description:
# Hubot plugin that listens to circle CI messages and triggers deployments

{SlackBotListener} = require 'hubot-slack'

circleAPI = "https://circleci.com/api/v1/project/sky-uk/"
deployingMessages = [
  "Be brave. Just let this happen.",
  "It's important to me that you're happy"
]

buildRegex = /.*Success:.+#(.+)\); .+ in (.+) \((.+)\).*/i

stagingDeployer = "http://skymobile-deployer.stage-cf.sky.com/hooks/circle"

module.exports = (robot) ->
  stagingCallback = (res) ->
    buildNumber = res.match[1].replace(/.*\//, '')
    project = res.match[2].replace(/.*\//, '')
    branch = res.match[3].replace(/.*\//, '')

    unless branch is "master"
      res.send "Ignoring build #{buildNumber} of #{project} since branch '#{branch}' is not master."
      res.send "There is immense joy in just watching"
    else
      buildURL = circleAPI + "/#{project}/#{buildNumber}"
      res.send "Deploying #{project} build #{buildNumber} to Staging"
      res.send res.random deployingMessages

      data = JSON.stringify({
        "payload": {
          "build_url" : buildURL
        }
      })

      robot.http(stagingDeployer)
        .header('Content-Type', 'application/json')
        .post(data) (err, resp, body) ->
          if resp.statusCode isnt 200
            res.send "Deployment failed"
            return
          res.send "Deployment complete"

  robot.listeners.push new SlackBotListener(robot, buildRegex, stagingCallback)

