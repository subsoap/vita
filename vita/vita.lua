local defsave = require("defsave.defsave")
local chrono = require("chrono.chrono")

local M = {}

M.resources = {}

M.defsave_filename = "vita" -- filename to use with defsave
M.defsave_key = "vita"
M.initiated = false
M.vita_data_filename = "/vita/blank_data.lua"

function M.update(dt)
	if M.initiated == false then
		M.init()
	end
end

function M.init()
	
	defsave.load(M.defsave_filename)
	M.resources = defsave.get(M.defsave_filename, M.defsave_key)
	M.initiated = true
end

function M.final()
	M.save()
end

-- You should save data with vita.save() whenever you do normal game saves
function M.save()
	M.update_defsave()
	defsave.save_all()	
end

-- You can update data into DefSave without saving right now
function M.update_defsave()
	defsave.set(M.defsave_filename, M.defsave_key, M.resources)
end

-- Add an amount to a resource tag, if not exist it's created
function M.add(tag, amount)
end

-- Consumes an amount
function M.consume(tag, amount)
end

-- Gets the total amount of a resource tag available
function M.get(tag)
end

-- Regenerates a resource tag by its regenerate amount
function M.regenerate(tag)
end

return M