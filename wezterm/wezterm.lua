local wezterm = require("wezterm")
local config = {}

-- HELPER FUNCTIONS
local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function read_file(path)
	local file = io.open(path, "rb") -- r read mode and b binary mode
	if not file then
		return nil
	end
	local content = file:read("*a") -- *a or *all reads the whole file
	file:close()
	return content
end

local function get_current_theme()
	return read_file(os.getenv("HOME") .. "/.config/wezterm/current_theme")
end

local function table_has_key(table, key)
	return table[key] ~= nil
end

-- OPTIONS
-- Auto-hide tab bar
config.hide_tab_bar_if_only_one_tab = true

-- Font
config.font = wezterm.font("JetBrains Mono")

-- Color Scheme
local color_scheme = get_current_theme()
local color_scheme_tbl = {
	["catppuccin\n"] = "Catppuccin Mocha",
	["gruvbox\n"] = "Gruvbox Dark (Gogh)",
}
if table_has_key(color_scheme_tbl, color_scheme) then
	config.color_scheme = color_scheme_tbl[color_scheme]
else
	config.color_scheme = "Batman"
end

-- Window opacity
config.window_background_opacity = 1.0

-- Check if fish shell exists and spawn a fish shell in login mode
if file_exists("/usr/local/bin/fish") then
	config.default_prog = { "/usr/local/bin/fish", "-l" }
elseif file_exists("/usr/bin/fish") then
	config.default_prog = { "/usr/bin/fish", "-l" }
elseif file_exists("/opt/homebrew/bin/fish") then
	config.default_prog = { "/opt/homebrew/bin/fish", "-l" }
end

config.warn_about_missing_glyphs = false

return config
