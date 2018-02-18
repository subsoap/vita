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
	for k,v in pairs(M.resources) do
		if v.count < v.natural_max then
			M.regenerate(tag, dt)
		end
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
	M.resources[resource].regenerate_time_left = 0
	M.resources[resource].regenerate_extra_time_left = 0
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
	amount = amount or 1
	M.resources[tag].count = M.resources[tag].count + amount
end

-- Consumes an amount, returns false if amount is more than currently has
function M.consume(tag, amount)
	amount = amount or 1
	if amount > M.resources[tag].count then return false end
	M.resources[tag].count = M.resources[tag].count - amount
	if amount == 1 then
		if M.resources[tag].regenerate_time_left > 0 then
			M.resources[tag].regenerate_extra_time_left = M.resources[tag].regenerate_extra_time_left + M.resources[tag].regenerate_time
		else
			M.resources[tag].regenerate_time_left = M.resources[tag].regenerate_time
		end
	else
		if M.resources[tag].regenerate_time_left > 0 then
			M.resources[tag].regenerate_extra_time_left = M.resources[tag].regenerate_extra_time_left + M.resources[tag].regenerate_time * amount
		else
			M.resources[tag].regenerate_time_left = M.resources[tag].regenerate_time
			M.resources[tag].regenerate_extra_time_left = M.resources[tag].regenerate_extra_time_left + M.resources[tag].regenerate_time * (amount - 1)
		end		
	end
	return true
end

-- Gets the total amount of a resource tag available
function M.get(tag)
	return M.resources[tag].count
end

-- Regenerates a resource tag by its regenerate amount
function M.regenerate(tag, dt)
end

-- Get time until next regeneration of a resource tag
function M.get_regeneration_time(tag)
end

return M