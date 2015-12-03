# Description:
#

circleAPI = "https://circleci.com/api/v1/project/sky-uk/"
deployingMessages = [
  "Be brave. Just let this happen.",
  "It's important to me that you're happy"
]

{SlackBotListener} = require 'hubot-slack'

buildRegex = /.*Success:.+#(.+)\); .+ in (.+) \((.+)\).*/i

callbackTest = (res) ->
    buildNumber = res.match[1].replace(/.*\//, '')
    project = res.match[2].replace(/.*\//, '')
    branch = res.match[3].replace(/.*\//, '')

    unless branch is "master"
      res.send "Build   #{buildNumber} "
      res.send "Project #{project} "
      res.send "Branch  #{branch} "


      res.send "Ignoring build #{buildNumber} of #{project} since branch #{branch} is not master."
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

      robot.http("http://skymobile-deployer.stage-cf.sky.com/hooks/circle")
        .header('Content-Type', 'application/json')
        .post(data) (err, resp, body) ->
          if resp.statusCode isnt 200
            res.send "Deployment failed"
            return
          res.send "Deployment complete"

module.exports = (robot) ->

  robot.listeners.push new SlackBotListener(robot, buildRegex, callbackTest)

