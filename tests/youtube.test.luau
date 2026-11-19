--!strict
local youtube = require("../youtube")
local prefix = "https://www.youtube.com/embed/dQw4w9WgXcQ?playsinline=1&start="

assert(youtube.embed_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ") == prefix .. "0")
assert(youtube.embed_url(" https://youtu.be/dQw4w9WgXcQ?si=123&t=1m30s ") == prefix .. "90")
assert(youtube.embed_url("https://m.youtube.com/shorts/dQw4w9WgXcQ#t=15s") == prefix .. "15")
assert(youtube.embed_url("https://youtube.com/live/dQw4w9WgXcQ?start=45") == prefix .. "45")
assert(youtube.embed_url("https://www.youtube.com/embed/dQw4w9WgXcQ?t=1h2m3s") == prefix .. "3723")
assert(youtube.embed_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=bad") == prefix .. "0")

for _, url in {
	"https://example.com/watch?v=dQw4w9WgXcQ",
	"https://www.youtube.com.example.com/watch?v=dQw4w9WgXcQ",
	"https://www.youtube.com@example.com/watch?v=dQw4w9WgXcQ",
	"https://www.youtube.com/watch?list=dQw4w9WgXcQ",
	"https://www.youtube.com/watch?v=%22dQw4w9WgXcQ",
	"javascript:alert(1)",
	"https://youtu.be/dQw4w9WgXcQ/extra",
} do
	assert(youtube.embed_url(url) == nil, url)
end

local html = youtube.page(prefix .. "15")
assert(html:find("min-width:200px;min-height:200px", 1, true) ~= nil)
assert(html:find("strict-origin-when-cross-origin", 1, true) ~= nil)
assert(html:find("playsinline=1&amp;start=15", 1, true) ~= nil)

local geometry = require("../pip_geometry")
local position = geometry.fit({ width = 1180, height = 850 })
assert(position.x == 668 and position.y == 520)
local compact = geometry.resize({ width = 1180, height = 850 }, position, -1000, -1000)
assert(compact.w == 280 and compact.h == 248)
print("Passed YouTube URL parsing, embed markup and compact player dimensions.")
