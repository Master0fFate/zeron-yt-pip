--!strict
local M = {}
M.base_url = "https://sh.zeron.app/youtube-pip/"

local youtube_hosts = { ["youtube.com"] = true, ["www.youtube.com"] = true, ["m.youtube.com"] = true }

local function query_param(query: string?, key: string): string?
	for name, value in (query or ""):gmatch("([^&=]+)=([^&]*)") do
		if name == key then return value end
	end
	return nil
end

local function seconds(value: string?): number
	if not value or #value > 16 then return 0 end
	local count = value:match("^(%d+)$")
	if count then return math.min(2147483647, tonumber(count) or 0) end
	local hours, rest = value:match("^(%d+)h(.*)$")
	rest = rest or value
	local minutes, tail = rest:match("^(%d+)m(.*)$")
	tail = tail or rest
	local secs = tail:match("^(%d+)s$")
	if tail ~= "" and not secs then return 0 end
	return math.min(2147483647, (tonumber(hours) or 0) * 3600 + (tonumber(minutes) or 0) * 60 + (tonumber(secs) or 0))
end

function M.embed_url(input: string): string?
	if #input > 4096 then return nil end
	local text = input:match("^%s*(.-)%s*$") or ""
	local host, location = text:match("^https?://([^/?#]+)(.*)$")
	if not host or not location then return nil end
	host = host:lower()
	local path = location:match("^[^?#]*") or ""
	local query = location:match("^[^?#]*%?([^#]*)")
	local fragment = location:match("#(.*)$")
	local id
	if host == "youtu.be" then
		id = path:match("^/([%w_%-]+)/?$")
	elseif youtube_hosts[host] then
		if path == "/watch" or path == "/watch/" then
			id = query_param(query, "v")
		else
			id = path:match("^/shorts/([%w_%-]+)/?$") or path:match("^/live/([%w_%-]+)/?$") or path:match("^/embed/([%w_%-]+)/?$")
		end
	end
	if not id or #id ~= 11 or not id:match("^[%w_%-]+$") then return nil end
	local start = seconds(query_param(query, "start") or query_param(query, "t") or query_param(fragment, "t"))
	return `https://www.youtube.com/embed/{id}?playsinline=1&start={start}`
end

function M.page(embed_url: string): string
	local url = embed_url:gsub("&", "&amp;")
	return [[<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="strict-origin-when-cross-origin">
<title>YouTube PiP</title>
<style>
html,body{width:100%;height:100%;margin:0;background:#000}
iframe{display:block;border:0;width:100%;height:100%;min-width:200px;min-height:200px}
</style>
<iframe title="YouTube video player" referrerpolicy="strict-origin-when-cross-origin"
allow="encrypted-media; picture-in-picture; fullscreen" allowfullscreen src="]] .. url .. [["></iframe></html>]]
end

return M
