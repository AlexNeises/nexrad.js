Observation = require 'ob'

class Calc
	@NODATA = null
	@R_dry = 287.04
	@Cp_dry = 1005.7
	@poissonDry = @R_dry / @Cp_dry
	@pRef = 1000.0

	temp_CtoK = (T) ->
		T + 273.15

	temp_KtoC = (T) ->
		T - 273.15

	log10 = (x) ->
		Math.log(x) / Math.log(10)

	potentialTemp = (p, T) ->
		Tk = @temp_CtoK T
		theta = Tk * Math.pow(@pRef / p, @poissonDry)
		@temp_KtoC theta

	satVaporPres = (T) ->
		Tk = @temp_CtoK T
		a0 = 23.832241 - 5.02808 * @log10 Tk
		a1 = 1.3816e-7 * Math.pow(10, 11.344 - 0.0303998 * Tk)
		a2 = 0.0081328 * Math.pow(10, 3.49149 - 1302.8844 / Tk)
		Math.pow(10, a0 - a1 + a2 - 2949.076 / Tk)

	mixingRatio = (p, T) ->
		es = @satVaporPres T
		622 * es / (p - es)

	thetaE = (p, T) ->
		Tk = @temp_CtoK T
		expArg = -2.6518986 * @mixingRatio(p, T) / Tk
		thetaS = @temp_CtoK(@potentialTemp(p, T)) / Math.exp expArg
		@temp_KtoC thetaS

	lclT_from_TTd = (T, Td) ->
		Tk = @temp_CtoK T
		Tdk = @temp_CtoK Td
		denom = 1 / (Tdk - 56) + Math.log(Tk / Tdk) / 800
		@temp_KtoC 1 / denom + 56

	presAtDryAdiabat = (T, theta) ->
		Tk = @temp_CtoK T
		theta_K = @temp_CtoK theta
		@pRef * Math.pow Tk / theta_K, 1 / @poissonDry

	tempAtMixingRatio = (p, r) ->
		m = r * p / (622 + r)
		x = 0.0498646455 * @log10(m) + 2.4082965
		temp = Math.pow(m, 0.0915) - 1.2035
		Tk = Math.pow(10, x) - 7.07475 + 38.9114 * temp * temp
		@temp_KtoC Tk

	lcl = (p, T, Td) ->
		theta = @potentialTemp p, T
		T_LCL + @lclT_from_TTd T, Td
		new Observation @presAtDryAdiabat(T_LCL, theta), T_LCL, T_LCL, NODATA, NODATA, NODATA

	virtualTempAtMixingRatio = (T, r) ->
		Tk = @temp_CtoK T
		Tvk = Tk * (1 + 0.61 * r / 1000)
		@temp_KtoC Tvk

	tempAtDryAdiabat = (p, theta) ->
		thetaK = @temp_CtoK theta
		Tk = thetaK * Math.pow p / @pRef, @poissonDry
		@temp_KtoC Tk

	tempAtThetaE = (p, thetae) ->
		TguessK = 253.16
		adjustment = 120
		thetaSGuess = @temp_CtoK @thetaE p, @temp_KtoC TguessK
		i = 0
		eps = 1e-6
		maxIterations = 50
		thetaS_K = @temp_CtoK thetae

		while i < maxIterations and Math.abs(thetaSGuess - thetaS_K) > eps
			adjustment /= 2
			if thetaSGuess < thetaS_K
				TguessK += adjustment
			else
				TguessK -= adjustment
			thetaSGuess = @temp_CtoK @thetaE p, @temp_KtoC TguessK
			i++
		@temp_KtoC TguessK

	thetaE_from_thetaW = (thetaw) ->
		es = @satVaporPres thetaw
		rs = 622 * es / (1000 - es)
		thetaw_K = @temp_CtoK thetaw
		thetae_K = thetaw_K * Math.exp((3.376 / thetaw_K - 0.00254) * rs * (1 + 0.81e-3 * rs))
		@temp_KtoC thetae_K

	tempAtMoistAdiabat = (p, thetaw) ->
		thetae = @thetaE_from_thetaW thetaw
		@tempAtThetaE p, thetae

root = exports ? window
root.Calc = Calc