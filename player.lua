
fixture("mineunit/core")

local players = {}

_G.minetest.check_player_privs = function(player_or_name, ...)
	local player_privs
	if type(player_or_name) == "table" then
		player_privs = player_or_name._privs
	else
		player_privs = players[player_or_name]._privs
	end
	local missing_privs = {}
	local has_priv = false
	local arg={...}
	for _,priv in ipairs(arg) do
		if player_privs[priv] then
			has_priv = true
		else
			table.insert(missing_privs, priv)
		end
	end
	return has_priv, missing_privs
end

_G.minetest.get_player_by_name = function(name)
	return players[name]
end

--
-- Mineunit player fixture API
--

fixture("mineunit/metadata")

local Player = {}
--
-- Mineunit player API methods
--
function Player:_set_player_control_state(control, value)
	self._controls[control] = value and value
end
function Player:_reset_player_controls()
	self._controls = {}
end

--
-- Minetest player API methods
--
function Player:get_player_control()
	return table.copy(self._controls)
end
function Player:get_player_name()
	return self._name
end

mineunit_export_object(Player, {
	name = "Player",
	constructor = function(self, name, privs)
		local obj = {
			_name = name or "SX",
			_privs = privs or { server = 1, test_priv=1 },
			_controls = {},
			_meta = MetaDataRef(),
		}
		players[obj._name] = obj
		setmetatable(obj, Player)
		return obj
	end,
})