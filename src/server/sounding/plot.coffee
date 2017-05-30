fs = require 'fs'
d3 = require 'd3'
jsdom = require 'jsdom'

class Plot
	constructor: () ->

	@::createBoundaryRect = (id, hgt, width) ->
		chartWidth = 500
		chartHeight = 500

		arc = d3.arc().outerRadius(chartWidth / 2 - 10).innerRadius(0)
		colors = d3.scaleOrdinal(d3.schemeCategory20)
		pieData = [12, 31]
		outputLocation = 'pie.svg'
		jsdom.env(
			html: '<html><head></head><body></body></html>'
			features:
				QuerySelector: true
			done: (errors, window) ->
				body = window.document.querySelector 'body'

				svg = window.document.querySelector('body').append('div').attr('class', 'container')
					.append('svg')
						.attr(
							xmlns: 'http://www.w3.org/2000/svg'
							width: chartWidth
							height: chartHeight
						)
					.append('g')
						.attr('transform', 'translate(' + chartWidth / 2 + ',' + chartWidth / 2 + ')')

				svg.selectAll('.arc')
					.data(d3.pie()(pieData))
						.enter()
					.append('path')
						.attr(
							class: 'arc'
							d: arc
							fill: (d, i) ->
								colors[i]
							stroke: '#fff'
						)
				fs.writeFileSync(outputLocation, window.d3.select('.container').html())
		)

# class Plot
# 	constructor: () ->
# 		@SVG_NS = 'http://www.w3.org/2000/svg'
# 		@Elements =
# 			SKEW_T_BOUNDARY: 'skewTBoundary'
# 			TEMP_TRACE: 'tempTrace'
# 			DEWPT_TRACE: 'dewptTrace'
# 			SB_PARCEL_TRACE: 'sbParcelTrace'
# 			ML_PARCEL_TRACE: 'mlParcelTrace'
# 			ISOTHERMS: 'isotherms'
# 			ISOBARS: 'isobars'
# 			MIXING_RATIOS: 'mixingRatios'
# 			DRY_ADIABATS: 'dryAdiabats'
# 			MOIST_ADIABATS: 'moistAdiabats'
# 			WIND_BARBS: 'windBarbs'
# 			ISOBAR_LABELS: 'pLabels'
# 			ISOTHERM_LABELS: 'tLabels'

# 			VIRTUAL_TEMP_TRACE: 'TvTrace'
# 			VIRTUAL_PARCEL_TRACE: 'sbParcelTraceTv'

# 			HODO_BOUNDARY: 'hodographBoundary'
# 			WINDSPEED_RADII: 'windRadii'
# 			HODO_AXES: 'hodoAxes'

# 			hodoTrace:
# 				KM_0_3: 'Hodo_km_0_3'
# 				KM_3_6: 'Hodo_km_3_6'
# 				KM_6_9: 'Hodo_km_6_9'
# 				KM_gt_9: 'Hodo_km_gt_9'

# 			classes:
# 				BOUNDARY: 'bdy'
# 				TRACE: 'trace'
# 				KM_0_3: 'km_0_3'
# 				KM_3_6: 'km_3_6'
# 				KM_6_9: 'km_6_9'
# 				KM_gt_9: 'km_gt_9'

# 	@::createBoundaryRect = (id, hgt, width) ->
# 		rect = doc.createElementNS @SVG_NS, 'rect'
# 		rect.id = id
# 		rect.setAttribute 'class', @Elements.classes.BOUNDARY
# 		rect.setAttribute 'height', hgt.toString()
# 		rect.setAttribute 'width', width.toString()
# 		console.log rect

root = exports ? window
root.Plot = Plot