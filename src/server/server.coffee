express = require 'express'
busboy = require 'connect-busboy'
fs = require 'fs-extra'

nx = require './nexrad'
config = require './config'

version1 = 'v1'
version2 = 'v1.1'
baseurl1 = "/#{version1}/nexrad"
baseurl2 = "/#{version2}/nexrad"

app = express()
app.use busboy()
app.use express.static __dirname + '/'
app.use '/docs', express.static __dirname + '/docs'
app.use '/static', [ express.static __dirname + '/bower_components', express.static __dirname + '/static' ]

# radar = new nx.L2D()
# radar.setFileResource 'KTLX20130520_210330_V06'
# console.log radar.parseMHB()

###
@api {post} /v1.1/nexrad/radial All Radial Data
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed radial blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} headers Decoded header block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    },
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    },
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    }
}
###
app.post "#{baseurl2}/radial", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						symbology = radar.parsePSB('radial')
						console.log 'Returning processed data.'
						res.json
							headers: headers
							description: description
							symbology: symbology
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1.1/nexrad/headers Header Data
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed header blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} headers Decoded header block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    }
}
###
app.post "#{baseurl2}/headers", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						console.log 'Returning processed data.'
						res.json
							headers: headers
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1.1/nexrad/description Description Data
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed description blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} description Decoded description block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    }
}
###
app.post "#{baseurl2}/description", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						console.log 'Returning processed data.'
						res.json
							description: description
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1.1/nexrad/symbology/radial Symbology Data (Radial)
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed symbology blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} symbology Decoded symbology block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    }
}
###
app.post "#{baseurl2}/symbology/radial", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						symbology = radar.parsePSB('radial')
						console.log 'Returning processed data.'
						res.json
							symbology: symbology
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1.1/nexrad/symbology Symbology Data (Raster)
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed symbology blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} symbology Decoded symbology block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "row": {
            "1": {
                "data": [
                    "14",
                    "14",
                    "6"
                ],
                "bytes": "12591"
            }
        }
    }
}
###
app.post "#{baseurl2}/symbology/raster", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						symbology = radar.parsePSB('raster')
						console.log 'Returning processed data.'
						res.json
							symbology: symbology
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1.1/nexrad/graphic_alpha Graphic Alphanumeric Data
@apiGroup Nexrad
@apiVersion 1.1.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed graphic alphanumeric blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} graphic_alpha Decoded graphic alphanumeric block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "graphic_alpha": {
        "divider": 27,
        "blockid": "15846",
        "pages": {
            "1": {
                "data": {
                    "messages": {
                        "1": {
                            "text_color": "0",
                            "pos_i": 0,
                            "message": " CIR STMID  10    M0 992    Y1 439    U0  12    M0 402    N1 824    A1          "
                        }
                    }
                },
                "vectors": {
                    "1": {
                        "pos_i_begin": 4,
                        "pos_j_begin": 0,
                        "pos_j_end": 0
                    },
                    "color": "3"
                }
            },
            "number": "1",
            "length": "574"
        }
    }
}
###
app.post "#{baseurl2}/graphic_alpha", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						graphic_alpha = radar.parseGAB()
						console.log 'Returning processed data.'
						res.json
							graphic_alpha: graphic_alpha
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1/nexrad/radial All Data (Deprecated)
@apiGroup Radial
@apiVersion 1.0.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed data
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} headers Decoded header block
@apiSuccess (200 OK) {Object} description Decoded description block
@apiSuccess (200 OK) {Object} symbology Decoded symbology block
@apiSuccess (200 OK) {Object} graphic_alpha Decoded graphic alphanumeric block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    },
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    },
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    },
    "graphic_alpha": {
        "divider": 27,
        "blockid": "15846",
        "pages": {
            "1": {
                "data": {
                    "messages": {
                        "1": {
                            "text_color": "0",
                            "pos_i": 0,
                            "message": " CIR STMID  10    M0 992    Y1 439    U0  12    M0 402    N1 824    A1          "
                        }
                    }
                },
                "vectors": {
                    "1": {
                        "pos_i_begin": 4,
                        "pos_j_begin": 0,
                        "pos_j_end": 0
                    },
                    "color": "3"
                }
            },
            "number": "1",
            "length": "574"
        }
    }
}
###
app.post "#{baseurl1}/radial", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						symbology = radar.parsePSB('radial')
						graphic_alpha = radar.parseGAB()
						console.log 'Returning processed data.'
						res.json
							headers: headers
							description: description
							symbology: symbology
							graphic_alpha: graphic_alpha
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1/nexrad/radial/headers Header Data (Deprecated)
@apiGroup Radial
@apiVersion 1.0.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed header blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} headers Decoded header block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "headers": {
        "code": "27",
        "date": "2012-06-19T17:00:00.000Z",
        "numberOfBlocks": "3"
    }
}
###
app.post "#{baseurl1}/radial/headers", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						console.log 'Returning processed data.'
						res.json
							headers: headers
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1/nexrad/radial/description Description Data (Deprecated)
@apiGroup Radial
@apiVersion 1.0.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed description blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} description Decoded description block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "description": {
        "divider": -1,
        "latitude": 35.333,
        "tabularoffset": "0"
    }
}
###
app.post "#{baseurl1}/radial/description", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						console.log 'Returning processed data.'
						res.json
							description: description
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1/nexrad/radial/symbology Symbology Data (Deprecated)
@apiGroup Radial
@apiVersion 1.0.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed symbology blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} symbology Decoded symbology block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "symbology": {
        "divider": "65535",
        "blockid": "1",
        "radial": {
            "0": {
                "colorValues": [
                    "0",
                    "0",
                    "0"
                ],
                "numOfRLE": "19",
                "angledelta": 0.9,
                "startangle": 136.1
            }
        }
    }
}
###
app.post "#{baseurl1}/radial/symbology", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						symbology = radar.parsePSB('radial')
						console.log 'Returning processed data.'
						res.json
							symbology: symbology
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

###
@api {post} /v1/nexrad/radial/graphic_alpha Graphic Alphanumeric Data (Deprecated)
@apiGroup Radial
@apiVersion 1.0.0
@apiParam {Binary} file NEXRAD-specific binary data file
@apiDescription Returns all processed graphic alphanumeric blocks
@apiError (409 Conflict) Conflict No file uploaded
@apiError (415 Unsupported Media Type) UnsupportedMediaType File is not valid NEXRAD data
@apiErrorExample {json} Error Response:
HTTP/1.1 4xx
{
    "status": "4xx",
    "error": "Error description"
}
@apiSuccess (200 OK) {Object} graphic_alpha Decoded graphic alphanumeric block
@apiSuccessExample {json} Success Response:
HTTP/1.1 200 OK
{
    "graphic_alpha": {
        "divider": 27,
        "blockid": "15846",
        "pages": {
            "1": {
                "data": {
                    "messages": {
                        "1": {
                            "text_color": "0",
                            "pos_i": 0,
                            "message": " CIR STMID  10    M0 992    Y1 439    U0  12    M0 402    N1 824    A1          "
                        }
                    }
                },
                "vectors": {
                    "1": {
                        "pos_i_begin": 4,
                        "pos_j_begin": 0,
                        "pos_j_end": 0
                    },
                    "color": "3"
                }
            },
            "number": "1",
            "length": "574"
        }
    }
}
###
app.post "#{baseurl1}/radial/graphic_alpha", (req, res, next) ->
	if not fs.existsSync 'tmp_uploads/'
		fs.mkdirSync 'tmp_uploads/'
	if req.busboy?
		req.pipe req.busboy
		req.busboy.on 'file', (fieldname, file, filename, encoding, mimetype) ->
			console.log "Uploading #{filename} with #{encoding} encoding and #{mimetype} mimetype"

			fstream = fs.createWriteStream __dirname + '/tmp_uploads/' + filename
			file.pipe fstream
			fstream.on 'close', () ->
				console.log "Finished uploading #{filename}"
				file = 'tmp_uploads/' + filename
				if file?
					radar = new nx.L3D()
					radar.setFileResource file
					if radar.validateFile() is -1
						headers = radar.parseMHB()
						description = radar.parsePDB()
						graphic_alpha = radar.parseGAB()
						console.log 'Returning processed data.'
						res.json
							graphic_alpha: graphic_alpha
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
					else
						res.status 415
						res.json
							status: 415
							error: "File is not valid NEXRAD data"
						fs.remove "tmp_uploads/#{filename}", (err) ->
							if err
								console.error err
							else
								console.log "#{filename} successfully removed."
	else
		res.status 409
		res.json
			status: 409
			error: "No file uploaded"

app.get '*', (req, res) ->
	res.json
		data: false

app.listen config.port
console.log "Listening on port #{config.port}."