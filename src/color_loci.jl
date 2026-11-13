# SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
# Copyright (c) 2021-2026 Neal McKee. All rights reserved.

using Colors

# Temperature and mired domain limits
const T_PLANCKIAN_MIN = 1667.0
const T_PLANCKIAN_MAX = 25000.0

const T_DAYLIGHT_MIN = 4000.0
const T_DAYLIGHT_MAX = 25000.0
const MIRED_DAYLIGHT_MAX = 1e6 / T_DAYLIGHT_MIN  # 250.0 MK^-1
const MIRED_DAYLIGHT_MIN = 1e6 / T_DAYLIGHT_MAX  # 40.0 MK^-1

"""
	planckian_locus(T::Real, Y::Real)

Compute the xyY color coordinates of the Planckian (blackbody) locus at temperature `T` (in Kelvin)
and luminance `Y`.

Valid temperature range: 1667 K to 25000 K.
"""
function planckian_locus(T::Real, Y::Real)
	invT = inv(T)
	if T_PLANCKIAN_MIN <= T <= 4000
		x = @evalpoly(invT, 0.179910, 0.8776956e3, -0.2343589e6, -0.2661239e9)
		if T <= 2222
			y = @evalpoly(x, -0.20219683, 2.18555832, -1.34811020, -1.10638469)
		else
			y = @evalpoly(x, -0.16748867, 2.09137015, -1.37418593, -0.9549476)
		end
	elseif 4000 <= T <= T_PLANCKIAN_MAX
		x = @evalpoly(invT, 0.240390, 0.2226347e3, 2.1070379e6, -3.0258469e9)
		y = @evalpoly(x, -0.37001483, 3.75112997, -5.87338670, 3.0817580)
	else
		throw(DomainError(T, "Temperature must be between $T_PLANCKIAN_MIN K and $T_PLANCKIAN_MAX K"))
	end
	return xyY(x, y, Y)
end

"""
	daylight_locus(T::Real, Y::Real)

Compute the xyY color coordinates of the CIE Daylight locus at temperature `T` (in Kelvin)
and luminance `Y`.

Valid temperature range: 4000 K to 25000 K.
"""
function daylight_locus(T::Real, Y::Real)
	invT = inv(T)
	if T_DAYLIGHT_MIN <= T <= 7000
		x = @evalpoly(invT, 0.244063, 0.09911e3, 2.9678e6, -4.6070e9)
	elseif 7000 < T <= T_DAYLIGHT_MAX
		x = @evalpoly(invT, 0.237040, 0.24748e3, 1.9018e6, -2.0064e9)
	else
		throw(DomainError(T, "Temperature must be between $T_DAYLIGHT_MIN K and $T_DAYLIGHT_MAX K"))
	end
	y = @evalpoly(x, -0.275, 2.870, -3.0)
	return xyY(x, y, Y)
end
