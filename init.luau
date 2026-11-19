--!strict
local zeron = require("./zeron")("youtube-pip")
local Button = require("@ds/button")
local Icon = require("@ds/icon")
local Text = require("@ds/text")
local geometry = require("./pip_geometry")
local youtube = require("./youtube")

type Point = geometry.Point
type Frame = geometry.Frame

local opened = ui.state("youtube_pip_open", false)
local editing = ui.state("youtube_pip_editing", true)
local input = ui.state("youtube_pip_input", "")
local video = ui.state("youtube_pip_video", "")
local position = ui.state("youtube_pip_position", nil :: Frame?)
local bounds = ui.computed(function() return geometry.fit(ui.window.size:get(), position:get()) end)

local function close()
	opened:set(false)
	video:set("")
	editing:set(true)
end

local function load_video()
	local url = youtube.embed_url(input:peek())
	if not url then
		zeron.toast("Paste a link to a YouTube video.")
		return
	end
	video:set(url)
	editing:set(false)
end

local Player = ui.component(function(): Node
	local gesture: { pointer: Point, frame: Frame }? = nil
	local function begin(e: Point) gesture = { pointer = { x = e.x, y = e.y }, frame = bounds:peek() } end
	local function finish() gesture = nil end
	local function move(e: Point)
		if not gesture then return end
		local origin = gesture.frame
		position:set({ x = origin.x + e.x - gesture.pointer.x, y = origin.y + e.y - gesture.pointer.y, w = origin.w, h = origin.h })
	end
	local function resize(e: Point)
		if not gesture then return end
		position:set(geometry.resize(ui.window.size:peek(), gesture.frame, e.x - gesture.pointer.x, e.y - gesture.pointer.y))
	end

	local function button(label: string, icon: string, click: () -> ()): Node
		return ui.presence(function() return if bounds:get().w >= 420 and icon ~= "close" then "text" else "icon" end,
			function(mode: string): Node
				return Button { label = label, tooltip = label, icon = mode == "icon", tone = "ghost", size = "xs",
					on_click = click, Icon { name = icon, size = 14 }, if mode == "text" then label else nil }
			end)
	end

	return ui.column {
		id = "youtube-mini-player", label = "YouTube picture-in-picture",
		x = function() return bounds:get().x end, y = function() return bounds:get().y end,
		w = function() return bounds:get().w end, h = function() return bounds:get().h end,
		bg = "$background", rounded = "$radius.lg", overflow = "hidden",
		border = 1, border_color = "$border.subtle", shadow = { y = 4, blur = 16, color = "#00000055" },
		ui.row { h = 36, shrink = 0, px = 4, gap = 4, items = "center",
			ui.div { w = 26, h_full = true, items = "center", justify = "center", label = "Move player", cursor = "grab",
				on_press = begin, on_pointer_move = move, on_release = finish, Icon { name = "grip", size = 14 } },
			ui.presence(function() return if editing:get() then "edit" else "view" end, function(mode: string): Node
				if mode == "view" then
					return ui.row { w_full = true, items = "center", gap = 4,
						Text { "YouTube", style = "caption", grow = 1, min_w = 0, truncate = true },
						button("Change video", "pen", function() editing:set(true) end),
					}
				end
				return ui.row { w_full = true, items = "center", gap = 4,
					ui.input { value = input, label = "YouTube link", placeholder = "Paste YouTube link", inputmode = "url",
						h = 26, grow = 1, min_w = 0, px = 6, rounded = 6, bg = "$zeron.secondary.bg", color = "$text.primary",
						on_key = function(e)
							if e.key == "Enter" then load_video(); return true end
							if e.key == "Escape" and video:peek() ~= "" then editing:set(false); return true end
							return false
						end },
					button("Load video", "arrow-right", load_video),
				}
			end, { grow = 1, min_w = 0 }),
			button("Close player", "close", close),
		},
		ui.div { grow = 1, min_h = 0, w_full = true,
			ui.presence(function()
				local size = bounds:get()
				return if size.w >= 204 and size.h >= 248 then video:get() else "small"
			end, function(url: string): Node
				if url == "" or url == "small" then
					return ui.column { w_full = true, h_full = true, items = "center", justify = "center", p = 8,
						Text { if url == "" then "Paste a YouTube link to start." else "Make the player larger to show the video.",
							style = "caption", tone = "secondary", wrap = true } }
				end
				return ui.webview { html = youtube.page(url), base_url = youtube.base_url,
					profile = "ephemeral", messages = false, w_full = true, h_full = true }
			end, { w_full = true, h_full = true }),
		},
		ui.row { h = 10, w_full = true, shrink = 0, justify = "end",
			ui.div { w = 24, h_full = true, label = "Resize player", cursor = "nwse-resize",
				on_press = begin, on_pointer_move = resize, on_release = finish },
		},
	}
end)

zeron.page {
	id = "player", title = "YouTube PiP", icon = "monitor",
	build = function(): Node
		return ui.column {
			id = "youtube-pip-launcher", w_full = true, h_full = true,
			items = "center", justify = "center", gap = "$space.3", p = "$space.5",
			Text { "YouTube PiP", style = "title", role = "heading" },
			Button { "Open player", on_click = function() opened:set(true) end },
		}
	end,
}

zeron.place { at = "#shell-chats", after = function(): Node
	return ui.presence(function() return if opened:get() then "open" else "closed" end, function(mode: string): Node
		if mode == "closed" then return ui.div { w = 0, h = 0 } end
		return ui.layer { placement = { x = "start", y = "start", inset = 0 }, Player {} }
	end)
end }
