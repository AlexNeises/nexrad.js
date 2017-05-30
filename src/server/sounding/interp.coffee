Observation = require 'ob'

class Interpolate
	@NODATA = null

	numbers = (p, pClosests, valClosests) ->
		v1 = valClosests.bottom
		v2 = valClosests.top
		p1 = pClosests.bottom
		p2 = pClosests.top
		v1 + (v2 - v1) * Math.log(p1 / p) / Math.log(p1 / p2)

	observation = (p, pClosests, obClosests) ->
		v1 = obClosests.bottom
		v2 = obClosests.top
		p1 = pClosests.bottom
		p2 = pClosests.top

		pInterp = @NODATA
		TInterp = @NODATA
		TdInterp = @NODATA
		hInterp = @NODATA
		windSpdInterp = @NODATA
		windDirInterp = @NODATA

		if v1.hasPressure() and v2.hasPressure()
			pressureClosests =
				bottom: v1.pressure()
				top: v2.pressure()
			pInterp = @numbers p, pClosests, pressureClosests

		if v1.hasTemperature() and v2.hasTemperature()
			tempClosests =
				bottom: v1.temperature()
				top: v2.temperature()
			TInterp = @numbers p, pClosests, tempClosests

		if v1.hasDewpoint() and v2.hasDewpoint()
			dewptClosests =
				bottom: v1.dewpoint()
				top: v2.dewpoint()
			TdInterp = @numbers p, pClosests, dewptClosests

		if v1.hasHeight() and v2.hasHeight()
			hgtClosests =
				bottom: v1.height()
				top: v2.height()
			hInterp = @numbers p, pClosests, hgtClosests

		if v1.hasWind() and v2.hasWind()
			windSpdClosests =
				bottom: v1.windSpeed()
				top: v2.windSpeed()
			windSpdInterp = @numbers p, pClosests, windSpdClosests

			windDirClosests =
				bottom: v1.windDir()
				top: v2.windDir()
			windDirInterp = @numbers p, pClosests, windDirClosests

		new Observation pInterp, TInterp, TdInterp, windSpdInterp, windDirInterp, hInterp

root = exports ? window
root.Interpolate = Interpolate