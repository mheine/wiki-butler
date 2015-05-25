# Description:
#   Allows hubot to tell a Slack channel when a new user has been created on wiki.ceri.se
#
#
# Configuration:
#   Uh, not quite sure. If you're interested in this, contact me!
#
# Commands:
#   butler wiki     - Check who the latest new user on the Cerise Wiki is.
#	butler test     - Used for testing purposes. Should outpur "Roger that"
#   butler butler	- Returns "How can I be of assistance?"
#
# Author:
#   mheine
#

module.exports = (robot) ->

  # Assuming "butler" is said by any user, in any form
  robot.hear /butler/, (res) ->
    res.send "How can I be of assistance?"


  #Variables used to  handle previously used names
  newUser = ""
  usedNames = []

  #When the command "hubot start" is given, initialize wiki-crawler
  robot.respond /start/i, (res) ->

    res.send "Initializing."
  	
  	#Set an interval, conceptually similar to while(true)
    setInterval () ->
      #Access the MediaWiki API @ wiki.ceri.se   - Limit the query to 25 latest results   
      robot.http("http://wiki.ceri.se/api.php?action=query&list=recentchanges&rclimit=25&format=json")

      #Accept only JSON
      .header('Accept', 'application/json')
        .get() (error, result, body_w) ->

          data = JSON.parse(body_w)

          #Get the array of recent changes as JSON
          recent = data.query.recentchanges 

          #Loop through entire arrayof new changes
          for key, value of recent    
      	  
            for k, v of value

      	      if k is "title"
      	        title = v
      	        #Set the name of the user as newUser. We substring because the title is "Användare:USERNAME"
      	        newUser = title.substring(10)

      	      if k is "revid"
      	        revid = v

      	      if k is "pageid" 
      	        pageid = v

      	      #If the page and revision ID's are both 0, the title contained "Användare:" and the user 
      	      #has NOT been printed before, say the name of the user.
      	      if revid is 0 and pageid is 0 and title.indexOf("Anv\u00e4ndare:") >= 0 and newUser not in usedNames
   	            res.send("A new user, \"" + newUser + "\" has been created. Weyo!")
   	            usedNames.push newUser
   	            return
    , 1000*15 #Perform check every 10 seconds


  #Assuming any  user says "test" at some point, return "Roger that."
  robot.hear /test/i, (res) ->
  	res.send "Roger that."

  #Very similar to "butler start". Loops through the JSON from the Cerise Wiki, and say the latest user created
  robot.hear /wiki/i, (res) ->

  	#Fetch the JSON, limit it to 500 results
  	robot.http("http://wiki.ceri.se/api.php?action=query&list=recentchanges&rclimit=500&format=json")
      .header('Accept', 'application/json')
      .get() (err, result, body) ->
        

        data = JSON.parse(body)

        recent = data.query.recentchanges
 
        for key, value of recent    
      	  
          for k, v of value

      	    if k is "title"
      	      title = v

      	    if k is "revid"
      	      revid = v

      	    if k is "pageid" 
      	      pageid = v

      	    #As soon as a new use is found, say the name of the user
      	    if revid is 0 and pageid is 0 and title.indexOf("Anv\u00e4ndare:") >= 0
   	          res.send("The most recently created user on the wiki is \"" + title.substring(10) + "\".")
   	          return
   	           


