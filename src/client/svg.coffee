radians = (degrees) ->
	degrees * (Math.PI / 180)

drawPolygon = (polygon, color) ->
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

		polygon = draw.polyline(v1 + ',' + v2 + ' ' + v3 + ',' + v4 + ' ' + v5 + ',' + v6 + ' ' + v7 + ',' + v8).fill(color).attr stroke: color, 'stroke-width': '0.05em'

renderNexrad = (data) ->
	now = Date.now()
	polyCount = 0
	
	_.each data.symbology.radial, (radial, i) ->
		radialPosition = 0
		angleDelta = radial.angledelta || 1
		radialAngle = radial.startangle

		j = 0
		_.each radial.colorValues, (colorValue, j) ->
			if colorValue > 0
				polygon = []
				polygon.push([
					(Math.cos(radians(radialAngle - 90)) * radialPosition * zoom) + (width / 2.0),
					(Math.sin(radians(radialAngle - 90)) * radialPosition * zoom) + (height / 2.0)
				])
				polygon.push([
					(Math.cos(radians((radialAngle - 90) + angleDelta)) * radialPosition * zoom) + (width / 2.0),
					(Math.sin(radians((radialAngle - 90) + angleDelta)) * radialPosition * zoom) + (height / 2.0)
				])

				polygon.push([
					(Math.cos(radians((radialAngle - 90) + angleDelta)) * (radialPosition + 1) * zoom) + (width / 2.0),
					(Math.sin(radians((radialAngle - 90) + angleDelta)) * (radialPosition + 1) * zoom) + (height / 2.0)
				])
				polygon.push([
					(Math.cos(radians(radialAngle - 90)) * (radialPosition + 1) * zoom) + (width / 2.0),
					(Math.sin(radians(radialAngle - 90)) * (radialPosition + 1) * zoom) + (height / 2.0)
				])

				drawPolygon polygon, colorTable[colorValue]
				polyCount++
			radialPosition++
			j++
	polyCount: polyCount, renderTimer: Date.now() - now

draw = SVG('radar').size 600, 600
mouseMove = false
mouseEvent = null
mouseElement = null
badAngleDeltaCount = 0
zoom = 5
width = 600
height = 600
polygonReduce = true
colorTable = [ '#000', '#00EAEC', '#01A0F6', '#0000F6', '#00FF00', '#00C800', '#009000', '#FFFF00', '#E7C000', '#FF9000', '#FF0000', '#D60000', '#C00000', '#FF00FF', '#9955C9', '#FFF' ]
totalRenderTime = 0

renders = renderNexrad nx0
console.log renders