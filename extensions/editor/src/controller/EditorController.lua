local json = require "json"
local parse = require "parse"
local param = require "param"
local property = require "property"
local directory = require "Directory"
local util = require "util"
local fileutil = require "fileutil"



local directoryName = param.directoryName


local dirs = {}
local parent
local title

if directoryName then
	-- get map of dir entries and their attributes --
	local map = directory.entries(directoryName)

	-- sort dir entries --
	local dirEntries = {}
	for entry, attr in pairs(map) do dirEntries[#dirEntries + 1] = entry end
	table.sort(dirEntries)

	-- wrap evrything up --
	for i=1,#dirEntries do
		local entry = dirEntries[i]
		local attr = map[entry]
		dirs[#dirs + 1] = {path = attr.path, name = entry, mode = attr.mode}
	end

	local paths = util.split(directoryName, "/")
	parent = {path = directoryName, name = paths[#paths], mode = "directory"}

	title = paths[#paths]
else
	local system = io.popen("uname -s"):read("*l")

	local drives
	if system == nil then
		drives = {"c:/", "d:/"}
	else
		drives = {"/"}
	end

	for i = 1, #drives do
		dirs[#dirs + 1] = {path = drives[i], name = drives[i], mode = "directory"}
	end

	parent = nil

	title = "/"
end


ngx.say(parse(require("BaselineHtmlTemplate"), {
	title = title,
	externalJS = [[
		<script src="/baseline/static/ace/ace.js" type="text/javascript"></script>
		<script src="/baseline/static/js/init-baseline.js" type="text/javascript"></script>
	]],
	externalCSS = [[
		<link href="/editor/static/editor-favicon.ico" rel="shortcut icon" type="image/vnd.microsoft.icon" />
	]],
	initJS = parse([[
		var vars = {}

		var editor = new Widget.Editor({id: "editor"})
		var editorNavigation = new Widget.EditorNavigation({{dirs}}, {{parent}})
		var editorHeader = new Widget.EditorHeader("{{title}}")

		var editorTemplate = new Widget.EditorTemplate({
			editor: editor.html, 
			navigation: editorNavigation.html, 
			header: editorHeader.html
		})

		Widget.setHtmlToPage(editorTemplate.html);

		editor.init()
		editorNavigation.init()
	]], {
		title = fileutil.escapeCommandlineSpecialCharacters(title),
		dirs = json.encode(dirs),
		parent = json.encode(parent)
	})
}))