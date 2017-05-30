mouseMove = false
mouseEvent = null
mouseElement = null
badAngleDeltaCount = 0
zoomScale = 1
width = window.innerWidth - 50
height = window.innerHeight - 50
totalRenderTime = 0

svg = d3.select('body').append('svg').attr('width', 500).attr('height', 500)
defs = svg.append('svg:defs')

defs.append('svg:pattern').attr('id', 'radarPng').attr('width', 500).attr('height', 500).attr('patternUnits', 'userSpaceOnUse').append('svg:image').attr('xlink:href', '../static/radar.png').attr('width', 500).attr('height', 500).attr('x', 0).attr('y', 0)

canvas = d3.select('body').append('canvas').attr('id', 'map').attr('width', width).attr('height', height)
context = canvas.node().getContext('2d')
context.lineJoin = 'round'
context.lineCap = 'round'
context.strokeStyle = '#FFFFFF'

cvsContainer = d3.select('body').append('canvas').attr('id', 'radar').attr('width', width).attr('height', height).node().getContext('2d')

projection = d3.geoMercator().translate([width / 2, height / 2]).center([-97.278, 35.333]).scale(3000)
path = d3.geoPath(projection).context(context)

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
	context.strokeStyle = 'rgba(255, 255, 255, 0)'
	context.stroke()

	context.beginPath()
	path(states)
	context.lineWidth = 0.5
	context.strokeStyle = '#FFFFFF'
	context.stroke()

	d3.select('#radar').call(d3.zoom().scaleExtent([1, 25]).on('zoom', () ->
		opacity = d3.event.transform.k / 25
		cvsContainer.save()
		cvsContainer.clearRect(0, 0, width, height)
		cvsContainer.translate(d3.event.transform.x, d3.event.transform.y)
		cvsContainer.scale(d3.event.transform.k, d3.event.transform.k)
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
		context.strokeStyle = 'rgba(255, 255, 255, ' + opacity + ')'
		context.stroke()

		context.beginPath()
		path(states)
		context.lineWidth = 0.5
		context.strokeStyle = '#FFFFFF'
		context.stroke()

		context.restore()
	))
)

svgContainer = d3.select('body').append('svg').attr('width', 500).attr('height', 500)
svgContainer.append('rectangle').attr('x', 0).attr('y', 0).attr('width', 500).attr('height', 500).style('fill', '#FFFFFF').style('fill', 'url(#radarPng)')

d3.select(self.frameElement).style("height", height + "px")