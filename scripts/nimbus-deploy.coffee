# Description:
#

circleAPI = "https://circleci.com/api/v1/project"
deployingMessages = [
  "Be brave. Just let this happen.",
  "It's important to me that you're happy"
]

{SlackBotListener} = require 'hubot-slack'

buildRegex = /.*Success:.+#(.+); .+ in (.+) \((.+)\).*/i

callbackTest = (res) ->
  res.send "YO"

module.exports = (robot) ->

  robot.listeners.push new SlackBotListener(robot, buildRegex, callbackTest)




  robot.hear /.*Success:.+#(.+); .+ in (.+) \((.+)\).*/i, (res) ->
    buildNumber = res.match[1]
    project = res.match[2]
    branch = res.match[3]

    unless branch is "master"
      res.send "Ignoring build #{buildNumber} of #{project} since it isn't on the master."
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
