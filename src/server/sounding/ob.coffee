Calc = require 'calc'

class Ob
	constructor: (p, T, Td, windspd, winddir, hgt) ->
		@NODATA = null
		@p = p
		@T = T
		@Td = Td
		@windspd = windspd
		@winddir = winddir
		@hgt = hgt

	@::pressure = () ->
		@p

	@::hasPressure = () ->
		@p isnt @NODATA

	@::temperature = () ->
		@T

	@::hasTemperature = () ->
		@T isnt @NODATA

	@::dewpoint = () ->
		@Td

	@::hasDewpoint = () ->
		@Td isnt @NODATA

	@::windSpeed = () ->
		@windspd

	@::windDir = () ->
		@winddir

	@::hasWind = () ->
		@windspd isnt @NODATA and @winddir isnt @NODATA

	@::height = () ->
		@hgt

	@::hasHeight = () ->
		@hgt isnt @NODATA

	@::hasSatMixingRatio = () ->
		@hasTemperature() and @hasPressure()

	@::satMixingRatio = () ->
		if not @hasSatMixingRatio()
			return @NODATA
		Calc.mixingRatio(@pressure(), @temperature())

	@::hasMixingRatio = () ->
		@hasDewpoint() and @hasPressure()

	@::mixingRatio = () ->
		Calc.mixingRatio(@pressure(), @dewpoint())

	@::hasVirtualTemp = () ->
		@hasMixingRatio() and @hasTemperature()

	@::virtualTemp = () ->
		if not @hasVirtualTemp()
			return @NODATA
		Calc.virtualTempAtMixingRatio(@temperature(), @mixingRatio())

	asOb = (rawProfilePt) ->
		new Ob(pt.pres, pt.tmpc, pt.dwpc, pt.sknt, pt.drct, pt.hght)

root = exports ? window
root.Ob = Ob