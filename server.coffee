POLL_INTERVAL = 3000
WINDOW_SIZE = 1200

history = new Array(WINDOW_SIZE)

connect = require('connect')
server = connect.createServer(
	connect.favicon(),
	connect.logger(),

	connect.router( (app) ->
		
		app.get('/api/info', (req,resp,next) ->
			
			retVal = JSON.stringify(history)
			resp.writeHead(200,{'content-type':'application/json'})
			resp.end(retVal)
		)
	)
)

do ->
	redis = require('redis')
	redisClient = redis.createClient()

	poller = setInterval( ( ->
		redisClient.info( (err,reply) ->
			if err
				console.log('INFO command failed.')
			else
				info = new Info(reply)
				history.push(info)
				if history.length >= WINDOW_SIZE
					history.shift()
		)
		return
		), POLL_INTERVAL
	)

class Info
	constructor: (rawInfo) ->
		#@rawInfo = rawInfo
		@timestamp = Date.now
		lines = rawInfo.toString().split('\r\n')
		data = undefined
		for line in lines
			data = line.split(':')
			@[data[0]] = data[1]

server.listen(8000)
