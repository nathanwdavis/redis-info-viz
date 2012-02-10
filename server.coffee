POLL_INTERVAL = 2000
WINDOW_SIZE = 600

redis = require('redis')
redisClient = redis.createClient()

connect = require('connect')
server = connect.createServer(
	connect.favicon(),
	connect.logger(),

	connect.router( (app) ->
		
		app.get('/api/info', (req,resp,next) ->
			
			redisClient.info( (err,reply) ->
				if err
					resp.writeHead(400,{'content-type':'application/json'})
					resp.end("Error retrieving INFO")
				else
					resp.writeHead(200,{'content-type':'application/json'})
					info = new Info(reply)
					resp.end(JSON.stringify(info))
			)
		)
	)
)

class Info
	constructor: (rawInfo) ->
		@rawInfo = rawInfo
		lines = rawInfo.toString().split('\r\n')
		data = undefined
		for line in lines
			data = line.split(':')
			@[data[0]] = data[1]

server.listen(8000)
