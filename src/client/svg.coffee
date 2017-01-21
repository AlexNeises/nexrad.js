radians = (degrees) ->
	degrees * (Math.PI / 180)

drawPolygon = (polygon, color, stroke) ->
	if polygon.length < 3
		console.log 'Bad Polygon'
	else
		v1 = if isNaN polygon[0][0] then 0 else polygon[0][0]
		v2 = if isNaN polygon[0][1] then 0 else polygon[0][1]
		v3 = if isNaN polygon[1][0] then 0 else polygon[1][0]
		v4 = if isNaN polygon[1][1] then 0 else polygon[1][1]
		v5 = if isNaN polygon[2][0] then 0 else polygon[2][0]
		v6 = if isNaN polygon[2][1] then 0 else polygon[2][1]
		v7 = if isNaN polygon[3][0] then 0 else polygon[3][0]
		v8 = if isNaN polygon[3][1] then 0 else polygon[3][1]

		# polygon = draw.polyline(v1 + ',' + v2 + ' ' + v3 + ',' + v4 + ' ' + v5 + ',' + v6 + ' ' + v7 + ',' + v8).fill(color).attr stroke: color, 'stroke-width': '0.05em'
		# path = d3.curveLinearClosed([[v1, v2], [v3, v4], [v5, v6], [v7, v8]])
		poly = [
			{
				x: v1
				y: v2
			}
			{
				x: v3
				y: v4
			}
			{
				x: v5
				y: v6
			}
			{
				x: v7
				y: v8
			}
		]
		
		cvsContainer.beginPath()
		cvsContainer.moveTo v1, v2
		cvsContainer.lineTo v3, v4
		cvsContainer.lineTo v5, v6
		cvsContainer.lineTo v7, v8
		cvsContainer.closePath()
		# cvsContainer.lineWidth = 0.1
		# cvsContainer.strokeStyle = stroke
		# cvsContainer.stroke()
		cvsContainer.fillStyle = color
		cvsContainer.fill()
		
		# container.selectAll('g').data([ poly ]).enter().append('polygon').attr('points', (d) ->
		# 	d.map( (d) ->
		# 		[
		# 			d.x
		# 			d.y
		# 		].join ','
		# 	).join ' '
		# ).attr('fill', color).attr('width', width).attr('height', height).style('pointer-events', 'all')

		# polygon = draw.polyline(v1 + ',' + v2 + ' ' + v3 + ',' + v4 + ' ' + v5 + ',' + v6 + ' ' + v7 + ',' + v8).fill color
		# polygons.push polygon.node.outerHTML

renderNexrad = (data) ->
	now = Date.now()
	polyCount = 0
	
	_.each data.symbology.radial, (radial, i) ->
		radialPosition = 0
		angleDelta = radial.angledelta || 1
		radialAngle = radial.startangle

		_.each radial.colorValues, (colorValue, idx) ->
			if colorValue > 0
				polygon = []
				polygon.push([
					(Math.cos(radians(radialAngle - 90)) * radialPosition * zoomScale) + (width / 2.0),
					(Math.sin(radians(radialAngle - 90)) * radialPosition * zoomScale) + (height / 2.0)
				])
				polygon.push([
					(Math.cos(radians((radialAngle - 90) + angleDelta)) * radialPosition * zoomScale) + (width / 2.0),
					(Math.sin(radians((radialAngle - 90) + angleDelta)) * radialPosition * zoomScale) + (height / 2.0)
				])

				polygon.push([
					(Math.cos(radians((radialAngle - 90) + angleDelta)) * (radialPosition + 1) * zoomScale) + (width / 2.0),
					(Math.sin(radians((radialAngle - 90) + angleDelta)) * (radialPosition + 1) * zoomScale) + (height / 2.0)
				])
				polygon.push([
					(Math.cos(radians(radialAngle - 90)) * (radialPosition + 1) * zoomScale) + (width / 2.0),
					(Math.sin(radians(radialAngle - 90)) * (radialPosition + 1) * zoomScale) + (height / 2.0)
				])

				drawPolygon polygon, colorTable[colorValue], strokeTable[colorValue]
				polyCount++
			radialPosition++
	polyCount: polyCount, renderTimer: Date.now() - now

shadeColor = (color, percent) ->
	f = parseInt(color.slice(1), 16)
	t = if percent < 0 then 0 else 255
	p = if percent < 0 then percent * -1 else percent
	R = f >> 16
	G = f >> 8 & 0x00FF
	B = f & 0x0000FF
	'#' + (0x1000000 + (Math.round((t - R) * p) + R) * 0x10000 + (Math.round((t - G) * p) + G) * 0x100 + Math.round((t - B) * p) + B).toString(16).slice(1)

i = 0
polygons = []

mouseMove = false
mouseEvent = null
mouseElement = null
badAngleDeltaCount = 0
zoomScale = 1
width = window.innerWidth - 50
# width = 960
# height = 500
height = window.innerHeight - 50
colorTable = [ '#000000', '#000D00', '#012402', '#065108', '#1CBB20', '#26ED2B', '#FFFD38', '#F6CD2E', '#FDAC2A', '#FD8424', '#BD0711', '#FC0D1B', '#FC6467', '#FD96CD', '#FC28FC', '#FFFFFF' ]
strokeTable = [ shadeColor('#000000', -0.15), shadeColor('#000D00', -0.15), shadeColor('#012402', -0.15), shadeColor('#065108', -0.15), shadeColor('#1CBB20', -0.15), shadeColor('#26ED2B', -0.15), shadeColor('#FFFD38', -0.15), shadeColor('#F6CD2E', -0.15), shadeColor('#FDAC2A', -0.15), shadeColor('#FD8424', -0.15), shadeColor('#BD0711', -0.15), shadeColor('#FC0D1B', -0.15), shadeColor('#FC6467', -0.15), shadeColor('#FD96CD', -0.15), shadeColor('#FC28FC', -0.15), shadeColor('#FFFFFF', -0.15) ]
totalRenderTime = 0

canvas = d3.select('body').append('canvas').attr('id', 'map').attr('width', width).attr('height', height)
context = canvas.node().getContext('2d')
context.lineJoin = 'round'
context.lineCap = 'round'
context.strokeStyle = '#FFFFFF'

cvsContainer = d3.select('body').append('canvas').attr('id', 'radar').attr('width', width).attr('height', height).node().getContext('2d')

projection = d3.geoMercator().translate([width / 2, height / 2]).center([-97.278, 35.333]).scale(3000)
path = d3.geoPath(projection).context(context)


# path = d3.geoPath().context(context)


d3.json('../static/counties.json', (error, us) ->
	if error
		throw error
	land = topojson.feature(us, us.objects.land)
	counties = topojson.mesh(us, us.objects.counties, (a, b) ->
		return a isnt b and !(a.id / 1000 ^ b.id / 1000)
	)
	states = topojson.mesh(us, us.objects.states, (a, b) ->
		return a isnt b
	)

	context.translate(0, 0)
	context.scale(1, 1)
	context.beginPath()
	path(land)
	context.fillStyle = '#000000'
	context.lineWidth = 1
	context.strokeStyle = '#FFFFFF'
	context.stroke()
	context.fill()

	context.beginPath()
	path(counties)
	context.lineWidth = 0.1
	context.strokeStyle = '#FFFFFF'
	context.stroke()

	context.beginPath()
	path(states)
	context.lineWidth = 0.5
	context.strokeStyle = '#FFFFFF'
	context.stroke()

	d3.select('#radar').call(d3.zoom().scaleExtent([1, 25]).on('zoom', () ->
		cvsContainer.save()
		cvsContainer.clearRect(0, 0, width, height)
		cvsContainer.translate(d3.event.transform.x, d3.event.transform.y)
		cvsContainer.scale(d3.event.transform.k, d3.event.transform.k)
		renderNexrad nx0
		cvsContainer.restore()

		context.save()
		context.clearRect(0, 0, width, height)
		context.translate(d3.event.transform.x, d3.event.transform.y)
		context.scale(d3.event.transform.k, d3.event.transform.k)
		
		context.beginPath()
		path(land)
		context.fillStyle = '#000000'
		context.lineWidth = 1
		context.strokeStyle = '#FFFFFF'
		context.stroke()
		context.fill()

		context.beginPath()
		path(counties)
		context.lineWidth = 0.1
		context.strokeStyle = '#FFFFFF'
		context.stroke()

		context.beginPath()
		path(states)
		context.lineWidth = 0.5
		context.strokeStyle = '#FFFFFF'
		context.stroke()

		context.restore()
	))
)
d3.select(self.frameElement).style("height", height + "px")
# d3.json('../static/counties.json', (error, us) ->
# 	if error
# 		throw error
# 	svg.insert('path', '.graticule').datum(topojson.feature(us, us.objects.land)).attr('class', 'land').attr('d', path)
# 	svg.insert('path', '.graticule').datum(topojson.mesh(us, us.objects.counties, (a, b) ->
# 		return a isnt b and !(a.id / 1000 ^ b.id / 1000)
# 	)).attr('class', 'county-boundary').attr('d', path)
# 	svg.insert('path', '.graticule').datum(topojson.mesh(us, us.objects.states, (a, b) ->
# 		return a isnt b
# 	)).attr('class', 'state-boundary').attr('d', path)
# )

# projection = d3.geoMercator().translate([width / 2, height / 2]).center([-85.922, 30.565]).scale(1000)
# path = d3.geoPath(projection)
# svg = d3.select('body').append('svg').attr('id', 'map').attr('width', width).attr('height', height).call(d3.zoom().scaleExtent([1, 25]).on('zoom', () ->
# 	d3.event.transform.x = Math.min(0, Math.max(d3.event.transform.x, width - width * d3.event.transform.k))
# 	d3.event.transform.y = Math.min(0, Math.max(d3.event.transform.y, height - height * d3.event.transform.k))
# 	redraw()
# 	svg.attr('transform', d3.event.transform)
# ))
# redraw()

# cvsContainer = d3.select('body').append('canvas').attr('width', width).attr('height', height).call(d3.zoom().scaleExtent([1, 25]).on('zoom', () ->
# 	cvsContainer.save()
# 	cvsContainer.clearRect(0, 0, width, height)
# 	cvsContainer.translate(d3.event.transform.x, d3.event.transform.y)
# 	cvsContainer.scale(d3.event.transform.k, d3.event.transform.k)
# 	renderNexrad nx0
# 	cvsContainer.restore()
# )).node().getContext('2d')

# svgContainer = d3.select('body').append('svg').attr('id', 'radar').attr('width', width).attr('height', height).call(d3.zoom().scaleExtent([1, 25]).on('zoom', () ->
# 	d3.event.transform.x = Math.min(0, Math.max(d3.event.transform.x, width - width * d3.event.transform.k))
# 	d3.event.transform.y = Math.min(0, Math.max(d3.event.transform.y, height - height * d3.event.transform.k))
# 	svgContainer.attr('transform', d3.event.transform)
# )).append('g')
# container = svgContainer.append('g')

renders = renderNexrad nx0

# console.log renders