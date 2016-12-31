express = require 'express'
busboy = require 'connect-busboy'
fs = require 'fs-extra'

nx = require './nexrad'
config = require './config'

version = 'v1'
baseurl = "/#{version}/nexrad"

app = express()
app.use busboy()

app.post "#{baseurl}/radial", (req, res, next) ->
	req.pipe req.busboy
	req.busboy.on 'file', (fieldname, file, filename) ->
		console.log "Uploading #{filename}"

		fstream = fs.createWriteStream __dirname + '/uploads/' + filename
		file.pipe fstream
		fstream.on 'close', () ->
			console.log "Finished uploading #{filename}"
			file = 'uploads/' + filename
			if file?
				radar = new nx.NexradDecoder()
				radar.setFileResource file
				headers = radar.parseMHB()
				description = radar.parsePDB()
				symbology = radar.parsePSB()
				console.log 'Returning processed data.'
				res.json
					headers: headers
					description: description
					symbology: symbology
			else
				res.json
					data: false
			
			fs.remove "uploads/#{filename}", (err) ->
				if err
					console.error err
				else
					console.log "#{filename} successfully removed."

app.get '*', (req, res) ->
	res.json
		data: false

app.listen config.port
console.log "Listening on port #{config.port}."