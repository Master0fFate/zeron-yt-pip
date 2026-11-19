--!strict
export type Point = { x: number, y: number }
export type Frame = { x: number, y: number, w: number, h: number }
export type Size = { width: number, height: number }

local INSET = 12
local DEFAULT_WIDTH = 500
local DEFAULT_HEIGHT = 318
local MIN_WIDTH = 280
local MIN_HEIGHT = 248

local function fit(window: Size, saved: Frame?): Frame
	local w = math.min(if saved then saved.w else DEFAULT_WIDTH, math.max(1, window.width - 2 * INSET))
	local h = math.min(if saved then saved.h else DEFAULT_HEIGHT, math.max(1, window.height - 2 * INSET))
	local right = math.max(INSET, window.width - w - INSET)
	local bottom = math.max(INSET, window.height - h - INSET)
	return {
		x = math.clamp(if saved then saved.x else right, INSET, right),
		y = math.clamp(if saved then saved.y else bottom, INSET, bottom),
		w = w, h = h,
	}
end

local function resize(window: Size, origin: Frame, dx: number, dy: number): Frame
	local max_w = math.max(1, window.width - origin.x - INSET)
	local max_h = math.max(1, window.height - origin.y - INSET)
	return {
		x = origin.x, y = origin.y,
		w = math.clamp(origin.w + dx, math.min(MIN_WIDTH, max_w), max_w),
		h = math.clamp(origin.h + dy, math.min(MIN_HEIGHT, max_h), max_h),
	}
end

return { fit = fit, resize = resize }
