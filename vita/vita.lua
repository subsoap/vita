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
		if v.natural_max == nil then
			v.natural_max = M.vita_data[v.id].natural_max
			M.resources[resource].natural_max = M.vita_data[v.id].natural_max
		end
		if v.count < v.natural_max then
			M.regenerate(v.id, dt)
		end
	end
end

function M.init()
	M.vita_data = assert(loadstring(sys.load_resource(M.vita_data_filename)))()
	defsave.load(M.defsave_filename)
	if defsave.get(M.defsave_filename, M.defsave_key) ~= nil then
		M.resources = pack.decompress(defsave.get(M.defsave_filename, M.defsave_key), M.pack_obfuscation_key, M.pack_use_obfuscation) or {}
	else
		M.resources = {}
	end
	--pprint(M.resources)
	M.setup()
	----[[
	for i,v in pairs(M.resources) do
		local time_difference = chrono.get_time() - v.last_sync
		if time_difference >= v.natural_max * v.regenerate_time then
			M.set_to_max(v.id)
			M.resources[v.id].last_sync = chrono.get_time()
		else
			M.regenerate(v.id, time_difference)
		end
		
	end
	--]]
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
	M.resources[resource].extra = 0 -- extra count which you consume last and don't want to count in regeneration TODO implement
	M.resources[resource].natural_max = natural_max
	M.resources[resource].regenerate_amount = regenerate_amount
	M.resources[resource].regenerate_time = regenerate_time
	M.resources[resource].regenerate_time_left = 0
	M.resources[resource].regenerate_extra_time_left = 0
	M.resources[resource].last_sync = chrono.get_time()
end

function M.resource_exists(tag)
	if not M.resources[tag] then
		return false
	end
	return true
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

-- Set the amount of a resource tag count based on an amount
function M.set(tag, amount)
	M.resources[tag].count = amount
	M.regenerate(tag)
end

-- Set the amount of a resource tag extra count based on an amount - most of the time you want to use use add_extra
function M.set_extra(tag, amount)
	M.resources[tag].extra = amount
end

-- Sets the amount of a resource tag count to its natural max value - instantly refill energy
function M.set_to_max(tag)
	M.resources[tag].count = M.resources[tag].natural_max
end

-- Changes the natural max value of a resourc tag
function M.set_natural_max(tag, amount)
	M.resources[tag].natural_max = amount
end

-- Add an amount to a resource tag base amount - generally don't do this, use add_extra instead
function M.add(tag, amount)
	amount = amount or 1
	M.resources[tag].count = M.resources[tag].count + amount
end

-- Add an amount to a resoure tag extra amount such as when using real money to buy extra hearts or getting them from friends
function M.add_extra(tag, amount)
	amount = amount or 1
	M.resources[tag].extra = M.resources[tag].extra + amount
end

-- Consumes an amount, returns false if amount is more than currently has
function M.consume(tag, amount)
	assert(M.resource_exists(tag), "Vita: Resource " .. tostring(tag) .. " does not exist in resources table")
	-- TODO implement using extra amount
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

-- Gets the natural max amount of a resource tag
function M.get_max(tag)
	return M.resources[tag].natural_max
end

-- Gets the total amount of a resource tag available including extra energy
function M.get_total(tag)
	return M.resources[tag].count + M.resources[tag].extra
end

-- Regenerates a resource tag by its regenerate amount
function M.regenerate(tag, dt)
	dt = dt or 0
	if M.get(tag) >= M.get_max(tag) then
		M.resources[tag].regenerate_time_left = 0
		M.resources[tag].regenerate_extra_time_left = 0
		return
	end
	if M.resources[tag].regenerate_time_left < 0 then
		M.add(tag)
		M.resources[tag].regenerate_time_left = M.resources[tag].regenerate_time_left + M.resources[tag].regenerate_time
	end	
	if M.get_regeneration_time(tag) > 0 or M.get_regenerate_extra_time_left(tag) > 0 then
		M.resources[tag].regenerate_time_left = M.resources[tag].regenerate_time_left - dt
		if M.resources[tag].regenerate_time_left <= 0 then
			M.add(tag)
			if M.resources[tag].regenerate_extra_time_left <= 0 then
				M.resources[tag].regenerate_time_left = 0
			else
				M.resources[tag].regenerate_extra_time_left = M.resources[tag].regenerate_extra_time_left - M.resources[tag].regenerate_time
				M.resources[tag].regenerate_time_left = M.resources[tag].regenerate_time_left + M.resources[tag].regenerate_time
			end
			if M.resources[tag].regenerate_extra_time_left <= 0 then
				M.resources[tag].regenerate_extra_time_left = 0
			end
		end
		M.resources[tag].last_sync = chrono.get_time()
	end
	if M.resources[tag].regenerate_time_left < 0 then
		M.regenerate(tag)
	end
end

-- Get time until next regeneration of a resource tag
function M.get_regeneration_time(tag)
	return M.resources[tag].regenerate_time_left
end
function M.get_regenerate_extra_time_left(tag)
	return M.resources[tag].regenerate_extra_time_left
end

return M