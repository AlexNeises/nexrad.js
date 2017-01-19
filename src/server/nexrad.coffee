fs = require 'fs-extra'
_ = require 'lodash'
ProgressBar = require 'progress'

POSITION = 0

class L3D
	constructor: () ->
		@handle = null
		@filename = null

		@msg_header_block = null
		@msg_header_block_offset = null

		@description_block = null
		@description_block_offset = null

		@symbology_block = null
		@symbology_block_offset = null

		@graphic_block = null
		@graphic_block_offset = null

		@initializeVariables()

	initializeVariables: () ->
		@msg_header_block = {}
		@description_block = {}
		@symbology_block = {}
		@graphic_block = {}

		@msg_header_block_offset = 30
		@description_block_offset = 48

	setFileResource: (file) ->
		@filename = file
		@handle = fs.readFileSync file

	hex2dec: (num) ->
		return parseInt(num, 16).toString(10)

	dec2hex: (num) ->
		return parseInt(num, 10).toString(16)

	bin2dec: (num) ->
		return parseInt(num, 2).toString(10)

	dec2bin: (num) ->
		return parseInt(num, 10).toString(2)
	
	readByte: (negativeRange = false) ->
		pos = POSITION
		POSITION += 1
		try
			@hex2dec(@handle.toString('hex', pos, pos + 1))
		catch e
			console.error e

	readHalfWord: (negativeRange = false) ->
		if negativeRange
			pos = POSITION
			POSITION += 2
			try
				@dec2negdec @handle.readInt16BE pos
			catch e
				console.error e
		else
			pos = POSITION
			POSITION += 2
			try
				@hex2dec(@handle.toString('hex', pos, pos + 2))
			catch e
				console.error e

	readWord: (negativeRange = false) ->
		if negativeRange
			pos = POSITION
			POSITION += 4
			try
				@dec2negdec @handle.readInt32BE pos
			catch e
				console.error e
		else
			pos = POSITION
			POSITION += 4
			try
				@hex2dec(@handle.toString('hex', pos, pos + 4))
			catch e
				console.error e

	str_split: (string, splitLength) ->
		if splitLength is null
			splitLength = 1
		if string is null or splitLength < 1
			return false
		string += ''
		chunks = []
		pos = 0
		len = string.length
		while pos < len
			chunks.push(string.slice(pos, pos += splitLength))
		return chunks

	parseRLE: () ->
		valueArray = []
		pos = POSITION
		POSITION += 1
		data = @handle.toString('hex', pos, pos + 1)
		split_data = @str_split(data, 1)

		length = @hex2dec(split_data[0])
		value = @hex2dec(split_data[1])

		if @description_block.mode is 1 and @description_block.code >= 16 and @description_block.code <= 21
			if value >= 8
				value -= 8
			else if value < 8
				value = 0

		i = 1
		while i <= length
			valueArray.push value
			i++

		return valueArray

	dec2negdec: (val, bits) ->
		binaryPadding = null
		binaryValue = @dec2bin(val)

		if val.length < bits
			paddingBits = bits - binaryValue.length
			i = 1
			while i <= paddingBits
				binaryPadding += '0'
				i++
			binaryValue = binaryPadding + binaryValue

		if binaryValue[0] is 1
			binaryValue = binaryValue.replace('0', 'x')
			binaryValue = binaryValue.replace('1', '0')
			binaryValue = binaryValue.replace('x', '1')
			negDecimalValue = (@bin2dec(binaryValue) + 1) * -1

			return negDecimalValue
		else
			return val

	sec2hms: (sec) ->
		d = Number(sec)
		h = Math.floor(d / 3600)
		m = Math.floor(d % 3600 / 60)
		s = Math.floor(d % 3600 % 60)
		(if h > 0 then h + ':' + (if m < 10 then '0' else '') else '') + m + ':' + (if s < 10 then '0' else '') + s

	julianToGregorian: (n) ->
		a = n + 32044
		b = Math.floor((4 * a + 3) / 146097)
		c = a - Math.floor(146097 * b / 4)
		d = Math.floor((4 * c + 3) / 1461)
		e = c - Math.floor(1461 * d / 4)
		f = Math.floor((5 * e + 2) / 153)
		D = e + 1 - Math.floor((153 * f + 2) / 5)
		M = f + 3 - 12 - Math.round(f / 10)
		Y = 100 * b + d - 4800 + Math.floor(f / 10)
		new Date(Y, M, D)

	parsePages: () ->
		console.log 'Parsing pages...'
		page = {}
		page.data = {}
		page.data.messages = {}
		page.data.vectors = {}
		page.number = @readHalfWord()
		page['length'] = @readHalfWord()
		totalBytesToRead = page['length']
		messageID = 0
		vectorID = 0
		while totalBytesToRead > 0
			console.log "#{totalBytesToRead} bytes left to read..."
			packetCode = @readHalfWord()
			packetLength = @readHalfWord()
			if (packetCode * 1) is 8
				messageID++
				page.data.messages[messageID] = {}
				page.data.messages[messageID].text_color = @readHalfWord()
				page.data.messages[messageID].pos_i = @readHalfWord(true)
				page.data.messages[messageID].pos_j = @readHalfWord(true)
				page.data.messages[messageID].message = ''

				packetBytesToRead = packetLength - 6

				j = 0
				while j < packetBytesToRead
					page.data.messages[messageID].message += String.fromCharCode @readByte()
					j++
				totalBytesToRead -= (packetLength * 1 + 4)
			else if (packetCode * 1) is 10
				page.data.vectors.color = @readHalfWord()
				packetBytesToRead = packetLength - 2
				while packetBytesToRead > 0
					vectorID++
					page.data.vectors[vectorID] = {}
					page.data.vectors[vectorID].pos_i_begin = @readHalfWord(true)
					page.data.vectors[vectorID].pos_j_begin = @readHalfWord(true)
					page.data.vectors[vectorID].pos_i_end = @readHalfWord(true)
					page.data.vectors[vectorID].pos_j_end = @readHalfWord(true)

					packetBytesToRead -= 8
				totalBytesToRead -= (packetLength * 1 + 4)
		return page

	parseMHB: () ->
		console.log 'Processing headers...'
		POSITION = @msg_header_block_offset
		@msg_header_block.code = @readHalfWord()
		@msg_header_block.date = @julianToGregorian(@readHalfWord() * 1 + 2440586.5)
		@msg_header_block.time = @sec2hms(@readWord(true))
		@msg_header_block.len = @readWord()
		@msg_header_block.sourceID = @readHalfWord()
		@msg_header_block.destinationID = @readHalfWord()
		@msg_header_block.numberOfBlocks = @readHalfWord()

		return @msg_header_block

	parsePDB: () ->
		console.log 'Processing description...'
		POSITION = @description_block_offset
		@description_block.divider = @readHalfWord(true)
		@description_block.latitude = @readWord() / 1000
		@description_block.longitude = @readWord(true) / 1000
		@description_block.height = @readHalfWord(true)
		@description_block.code = @readHalfWord(true)
		@description_block.mode = @readHalfWord()
		@description_block.volumecoveragepattern = @readHalfWord()
		@description_block.sequencenumber = @readHalfWord()

		@description_block.scannumber = @readHalfWord()
		@description_block.scandate = @julianToGregorian(@readHalfWord() * 1 + 2440586.5)
		@description_block.scantime = @sec2hms(@readWord(), true)
		@description_block.generationdate = @julianToGregorian(@readHalfWord() * 1 + 2440586.5)
		@description_block.generationtime = @sec2hms(@readWord(), true)
		@description_block.productspecific_1 = @readHalfWord()
		@description_block.productspecific_2 = @readHalfWord()
		@description_block.elevationnumber = @readHalfWord()

		@description_block.productspecific_3 = @readHalfWord() / 10
		@description_block.threshold_1 = @readHalfWord()
		@description_block.threshold_2 = @readHalfWord()
		@description_block.threshold_3 = @readHalfWord()
		@description_block.threshold_4 = @readHalfWord()
		@description_block.threshold_5 = @readHalfWord()
		@description_block.threshold_6 = @readHalfWord()
		@description_block.threshold_7 = @readHalfWord()
		@description_block.threshold_8 = @readHalfWord()
		@description_block.threshold_9 = @readHalfWord()

		@description_block.threshold_10 = @readHalfWord()
		@description_block.threshold_11 = @readHalfWord()
		@description_block.threshold_12 = @readHalfWord()
		@description_block.threshold_13 = @readHalfWord()
		@description_block.threshold_14 = @readHalfWord()
		@description_block.threshold_15 = @readHalfWord()
		@description_block.threshold_16 = @readHalfWord()
		@description_block.productspecific_4 = @readHalfWord()
		@description_block.productspecific_5 = @readHalfWord()
		@description_block.productspecific_6 = @readHalfWord()

		@description_block.productspecific_7 = @readHalfWord()
		@description_block.productspecific_8 = @readHalfWord()
		@description_block.productspecific_9 = @readHalfWord()
		@description_block.productspecific_10 = @readHalfWord()
		@description_block.version = @readByte()
		@description_block.spot_blank = @readByte()
		@description_block.symbologyoffset = @readWord()
		@description_block.graphicoffset = @readWord()
		@description_block.tabularoffset = @readWord()

		return @description_block

	parseRasterLayers: () ->
		@symbology_block.layerdivider = @readHalfWord()
		@symbology_block.layerlength = @readWord()
		@symbology_block.layerpacketcode = @dec2hex(@readHalfWord())
		@symbology_block.layerpacketcode2 = @dec2hex(@readHalfWord())
		@symbology_block.layerpacketcode3 = @dec2hex(@readHalfWord())
		@symbology_block.i_coord_start = @readHalfWord()
		@symbology_block.j_coord_start = @readHalfWord()
		@symbology_block.x_scale_int = @readHalfWord()
		@symbology_block.x_scale_fraction = @readHalfWord()
		@symbology_block.y_scale_int = @readHalfWord()
		@symbology_block.y_scale_fraction = @readHalfWord()
		@symbology_block.num_of_rows = @readHalfWord()
		@symbology_block.packing_descriptor = @readHalfWord()
		@symbology_block.row = {}

		i = 0
		len = parseInt @symbology_block.num_of_rows, 10
		bar = new ProgressBar('  Processing... [:bar] :percent - Processing block :current of :total...',
			complete: '='
			incomplete: ' '
			width: 20
			total: len
		);
		while i < @symbology_block.num_of_rows
			rowBytes = @readHalfWord()
			if isNaN rowBytes
				rowBytes = 0
			@symbology_block.row[i] = {}
			@symbology_block.row[i].data = []
			@symbology_block.row[i].bytes = rowBytes

			j = 0
			while j < rowBytes
				tempColorValues = @parseRLE()
				if @symbology_block.row[i].data?
					@symbology_block.row[i].data = _.concat @symbology_block.row[i].data, tempColorValues
				else
					@symbology_block.row[i].data = tempColorValues
				j++
			bar.tick()
			i++

	parseRadialLayers: () ->
		@symbology_block.layerdivider = @readHalfWord()
		@symbology_block.layerlength = @readWord()
		@symbology_block.layerpacketcode = @dec2hex(@readHalfWord())
		@symbology_block.layerindexoffirstrangebin = @readHalfWord()
		@symbology_block.layernumberofrangebins = @readHalfWord()
		@symbology_block.i_centerofsweep = @readHalfWord()
		@symbology_block.j_centerofsweep = @readHalfWord()
		@symbology_block.scalefactor = @readHalfWord() / 1000
		@symbology_block.numberofradials = @readHalfWord()

		i = 0
		allAngles = []
		@symbology_block.radial = {}
		len = parseInt @symbology_block.numberofradials, 10
		bar = new ProgressBar('  Processing... [:bar] :percent - Processing block :current of :total...',
			complete: '='
			incomplete: ' '
			width: 20
			total: len
		);
		while i < @symbology_block.numberofradials
			number_of_rles = @readHalfWord()
			startAngle = @readHalfWord() / 10
			allAngles.push startAngle
			angleDelta = @readHalfWord() / 10

			if !isNaN startAngle
				@symbology_block.radial[startAngle] = {}

				@symbology_block.radial[startAngle].numOfRLE = number_of_rles
				@symbology_block.radial[startAngle].angledelta = angleDelta
				@symbology_block.radial[startAngle].startangle = startAngle

				j = 0
				allcolors = []
				newcolors = []

				while j < number_of_rles * 2
					tempColorValues = @parseRLE()
					if @symbology_block.radial[startAngle].colorValues?
						@symbology_block.radial[startAngle].colorValues = _.concat @symbology_block.radial[startAngle].colorValues, tempColorValues
					else
						@symbology_block.radial[startAngle].colorValues = tempColorValues
					j++
			bar.tick()
			i++

	validateFile: () ->
		console.log 'Validating file format...'
		POSITION = @description_block_offset
		validation = @readHalfWord(true)
		POSITION = 0
		return validation

	parsePSB: (type) ->
		console.log 'Parsing symbology...'
		@symbology_block_offset = (@description_block.symbologyoffset * 2) + @msg_header_block_offset
		POSITION = @symbology_block_offset

		@symbology_block.divider = @readHalfWord()
		@symbology_block.blockid = @readHalfWord()
		@symbology_block.blocklength = @readWord()
		@symbology_block.numoflayers = @readHalfWord()

		i = 1
		while i <= @symbology_block.numoflayers
			if type is 'radial'
				@parseRadialLayers()
			if type is 'raster'
				@parseRasterLayers()
			i++
		return @symbology_block

	parseGAB: () ->
		@graphic_block_offset = @description_block.graphicoffset * 2 + @msg_header_block_offset
		POSITION = @graphic_block_offset

		@graphic_block.divider = @readHalfWord(true)
		@graphic_block.blockid = @readHalfWord()
		@graphic_block.block_length = @readWord()
		@graphic_block.num_of_pages = @readHalfWord()

		i = 1
		@graphic_block.pages = {}
		while i <= @graphic_block.num_of_pages
			@graphic_block.pages[i] = @parsePages()
			i++
		return @graphic_block

class L2D
	constructor: () ->
		@handle = null
		@filename = null

		@msg_header_block = null
		@msg_header_block_offset = null

		@description_block = null
		@description_block_offset = null

		@symbology_block = null
		@symbology_block_offset = null

		@graphic_block = null
		@graphic_block_offset = null

		@initializeVariables()

	initializeVariables: () ->
		@msg_header_block = {}
		@description_block = {}
		@symbology_block = {}
		@graphic_block = {}

		@msg_header_block_offset = 0
		@description_block_offset = 48

	setFileResource: (file) ->
		@filename = file
		@handle = fs.readFileSync file

	hex2dec: (num) ->
		return parseInt(num, 16).toString(10)

	dec2hex: (num) ->
		return parseInt(num, 10).toString(16)

	bin2dec: (num) ->
		return parseInt(num, 2).toString(10)

	dec2bin: (num) ->
		return parseInt(num, 10).toString(2)
	
	readByte: (negativeRange = false) ->
		pos = POSITION
		POSITION += 1
		try
			@hex2dec(@handle.toString('hex', pos, pos + 1))
		catch e
			console.error e

	readHalfWord: (negativeRange = false) ->
		if negativeRange
			pos = POSITION
			POSITION += 2
			try
				@dec2negdec @handle.readInt16BE pos
			catch e
				console.error e
		else
			pos = POSITION
			POSITION += 2
			try
				@hex2dec(@handle.toString('hex', pos, pos + 2))
			catch e
				console.error e

	readWord: (negativeRange = false) ->
		if negativeRange
			pos = POSITION
			POSITION += 4
			try
				@dec2negdec @handle.readInt32BE pos
			catch e
				console.error e
		else
			pos = POSITION
			POSITION += 4
			try
				@hex2dec(@handle.toString('hex', pos, pos + 4))
			catch e
				console.error e

	readString: (size) ->
		pos = POSITION
		POSITION += size
		try
			@handle.toString('utf8', pos, pos + size)
		catch e
			console.error e

	str_split: (string, splitLength) ->
		if splitLength is null
			splitLength = 1
		if string is null or splitLength < 1
			return false
		string += ''
		chunks = []
		pos = 0
		len = string.length
		while pos < len
			chunks.push(string.slice(pos, pos += splitLength))
		return chunks

	dec2negdec: (val, bits) ->
		binaryPadding = null
		binaryValue = @dec2bin(val)

		if val.length < bits
			paddingBits = bits - binaryValue.length
			i = 1
			while i <= paddingBits
				binaryPadding += '0'
				i++
			binaryValue = binaryPadding + binaryValue

		if binaryValue[0] is 1
			binaryValue = binaryValue.replace('0', 'x')
			binaryValue = binaryValue.replace('1', '0')
			binaryValue = binaryValue.replace('x', '1')
			negDecimalValue = (@bin2dec(binaryValue) + 1) * -1

			return negDecimalValue
		else
			return val

	sec2hms: (sec) ->
		d = Number(sec)
		h = Math.floor(d / 3600)
		m = Math.floor(d % 3600 / 60)
		s = Math.floor(d % 3600 % 60)
		(if h > 0 then h + ':' + (if m < 10 then '0' else '') else '') + m + ':' + (if s < 10 then '0' else '') + s

	julianToGregorian: (n) ->
		a = n + 32044
		b = Math.floor((4 * a + 3) / 146097)
		c = a - Math.floor(146097 * b / 4)
		d = Math.floor((4 * c + 3) / 1461)
		e = c - Math.floor(1461 * d / 4)
		f = Math.floor((5 * e + 2) / 153)
		D = e + 1 - Math.floor((153 * f + 2) / 5)
		M = f + 3 - 12 - Math.round(f / 10)
		Y = 100 * b + d - 4800 + Math.floor(f / 10)
		new Date(Y, M, D)

	getDate: (n) ->
		ms = n * 24 * 60 * 60 * 1000
		d = new Date ms

	parseMHB: () ->
		console.log 'Processing headers...'
		POSITION = @msg_header_block_offset
		@msg_header_block.tape = @readString(9)
		@msg_header_block.extension = @readString(3)
		@msg_header_block.date = @getDate(@readWord())
		@msg_header_block.time = @readWord()
		@msg_header_block.icao = @readString(4)
		POSITION += 12
		@msg_header_block.msg_size = @readHalfWord()
		@msg_header_block.channels = @readByte()
		@msg_header_block.type = @readByte()
		@msg_header_block.seq_id = @readHalfWord()
		@msg_header_block.jdate = @readHalfWord()
		@msg_header_block.msday = @readWord()
		@msg_header_block.msg_seg = @readHalfWord()

		return @msg_header_block

root = exports ? window
root.L3D = L3D
root.L2D = L2D