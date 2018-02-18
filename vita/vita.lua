local defsave = require("defsave.defsave")
local chrono = require("chrono.chrono")
local pack = require("pack.pack")

local M = {}

M.resources = {}

M.defsave_filename = "vita" -- filename to use with defsave
M.defsave_key = "vita"
M.initiated = false
M.vita_data_filename = "/vita/blank_data.lua"
M.vita_data = {}
M.pack_obfuscation_key = "vita"
M.pack_use_obfuscation = false

function M.update(dt)
	if M.initiated == false then
		M.init()
	end
end

function M.init()
	M.vita_data = assert(loadstring(sys.load_resource(M.vita_data_filename)))()
	defsave.load(M.defsave_filename)
	M.resources = pack.decompress(defsave.get(M.defsave_filename, M.defsave_key), M.pack_obfuscation_key, M.pack_use_obfuscation) or {}
	pprint(M.resources)
	M.setup()
	M.initiated = true
end

function M.final()
	M.save()
end

-- Sets up resources based on JSON file, creates any missing
function M.setup()
	for i,v in pairs(M.vita_data) do
		if M.resources[i] == nil then
			if M.verbose == true then print("Vita: Setting up new resource " .. i) end
			M.create_resource(i, v.count, v.natural_max, v.regenerate_amount, v.regenerate_time)
		end
	end
end

function M.create_resource(resource, count, natural_max, regenerate_amount, regenerate_time)
	if M.verbose == true then print("Vita: Creating resource " .. resource) end
	M.resources[resource] = {}
	M.resources[resource].id = resource
	M.resources[resource].count = count
	M.resources[resource].natural_max = natural_max
	M.resources[resource].regenerate_amount = regenerate_amount
	M.resources[resource].regenerate_time = regenerate_time
end

-- You should save data with vita.save() whenever you do normal game saves
function M.save()
	M.update_defsave()
	defsave.save_all()	
end

-- You can update data into DefSave without saving right now
function M.update_defsave()
	defsave.set(M.defsave_filename, M.defsave_key, pack.compress(M.resources, M.pack_obfuscation_key, M.pack_use_obfuscation))
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