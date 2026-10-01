local Config = require 'config'

local blips = {} ---@type table<integer, table>
local loaded = false

local function bool(v)
    return v == true or v == 1 or v == '1'
end

local function normalize(row)
    return {
        id = row.id,
        name = row.name,
        x = row.x + 0.0, y = row.y + 0.0, z = row.z + 0.0,
        streetName = row.streetName,
        sprite = tonumber(row.sprite) or 1,
        scale = tonumber(row.scale) or 1.0,
        alpha = tonumber(row.alpha) or 255,
        color = tonumber(row.color) or 0,
        ticked = bool(row.ticked),
        outline = bool(row.outline),
        display = tonumber(row.display) or 0,
        identifier = row.identifier,
        type = row.type or 'blip',
        width = tonumber(row.width) or 50.0,
        height = tonumber(row.height) or 50.0,
    }
end

--- Rows with an identifier are personal blips: only that player (license) sees them.
local function visibleFor(src)
    local lic = GetPlayerIdentifierByType(src, 'license')
    local list = {}
    for _, b in pairs(blips) do
        if not b.identifier or b.identifier == lic then list[#list + 1] = b end
    end
    return list
end

local function syncAll()
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        TriggerClientEvent('rm-custom-blips:sync', src, visibleFor(src))
    end
end

local function isAdmin(src)
    return IsPlayerAceAllowed(src, 'command.blips')
end

-- Same table layout as the popular blips_creator, so existing blips carry over.
MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `global_blips` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(50) NOT NULL DEFAULT 'blip',
            `x` FLOAT(12) NOT NULL DEFAULT '0',
            `y` FLOAT(12) NOT NULL DEFAULT '0',
            `z` FLOAT(12) NOT NULL DEFAULT '0',
            `streetName` VARCHAR(50) NOT NULL DEFAULT '0',
            `sprite` SMALLINT(6) NOT NULL DEFAULT '0',
            `scale` FLOAT(12) NOT NULL DEFAULT '0',
            `alpha` TINYINT(4) UNSIGNED NOT NULL DEFAULT '0',
            `color` SMALLINT(6) NOT NULL DEFAULT '0',
            `ticked` BIT(1) NOT NULL DEFAULT b'0',
            `outline` BIT(1) NOT NULL DEFAULT b'0',
            `display` TINYINT(3) NOT NULL DEFAULT '0',
            `identifier` VARCHAR(80) NULL DEFAULT NULL,
            `type` VARCHAR(10) NOT NULL,
            `height` FLOAT(12) NOT NULL DEFAULT '50',
            `width` FLOAT(12) NOT NULL DEFAULT '50',
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
    ]])
    for _, row in ipairs(MySQL.query.await('SELECT * FROM `global_blips`') or {}) do
        blips[row.id] = normalize(row)
    end
    loaded = true
    syncAll()
end)

lib.callback.register('rm-custom-blips:get', function(src)
    while not loaded do Wait(100) end
    return visibleFor(src)
end)

lib.callback.register('rm-custom-blips:adminList', function(src)
    if not isAdmin(src) then return nil end
    local list = {}
    for _, b in pairs(blips) do list[#list + 1] = b end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end)

---@param data table blip fields from the client menu
local function clean(data)
    local t = type(data.type) == 'string' and data.type or 'blip'
    if t ~= 'radius' and t ~= 'area' then t = 'blip' end
    local name = tostring(data.name or 'Blip'):sub(1, 50)
    return {
        name = name ~= '' and name or 'Blip',
        x = tonumber(data.x) or 0.0, y = tonumber(data.y) or 0.0, z = tonumber(data.z) or 0.0,
        streetName = tostring(data.streetName or ''):sub(1, 50),
        sprite = math.floor(math.max(0, math.min(1000, tonumber(data.sprite) or 1))),
        scale = math.max(0.1, math.min(3.0, tonumber(data.scale) or 1.0)),
        alpha = math.floor(math.max(0, math.min(255, tonumber(data.alpha) or 255))),
        color = math.floor(math.max(0, math.min(85, tonumber(data.color) or 0))),
        ticked = data.ticked == true,
        outline = data.outline == true,
        display = math.floor(math.max(0, math.min(10, tonumber(data.display) or 4))),
        type = t,
        width = math.max(1.0, math.min(5000.0, tonumber(data.width) or 50.0)),
        height = math.max(1.0, math.min(5000.0, tonumber(data.height) or 50.0)),
    }
end

lib.callback.register('rm-custom-blips:save', function(src, data)
    if not isAdmin(src) or type(data) ~= 'table' then return false end
    local b = clean(data)
    local id = tonumber(data.id)
    if id and blips[id] then
        MySQL.update.await([[
            UPDATE `global_blips` SET name = ?, x = ?, y = ?, z = ?, streetName = ?, sprite = ?, scale = ?, alpha = ?,
            color = ?, ticked = ?, outline = ?, display = ?, type = ?, width = ?, height = ? WHERE id = ?
        ]], { b.name, b.x, b.y, b.z, b.streetName, b.sprite, b.scale, b.alpha, b.color, b.ticked and 1 or 0,
            b.outline and 1 or 0, b.display, b.type, b.width, b.height, id })
        b.id = id
        b.identifier = blips[id].identifier
    else
        b.id = MySQL.insert.await([[
            INSERT INTO `global_blips` (name, x, y, z, streetName, sprite, scale, alpha, color, ticked, outline, display, type, width, height)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]], { b.name, b.x, b.y, b.z, b.streetName, b.sprite, b.scale, b.alpha, b.color, b.ticked and 1 or 0,
            b.outline and 1 or 0, b.display, b.type, b.width, b.height })
        if not b.id then return false end
    end
    blips[b.id] = b
    syncAll()
    return b.id
end)

lib.callback.register('rm-custom-blips:delete', function(src, id)
    id = tonumber(id)
    if not isAdmin(src) or not id or not blips[id] then return false end
    MySQL.query.await('DELETE FROM `global_blips` WHERE id = ?', { id })
    blips[id] = nil
    syncAll()
    return true
end)

lib.addCommand('blips', {
    help = 'Create / edit map blips',
    restricted = Config.commandGroup,
}, function(src)
    TriggerClientEvent('rm-custom-blips:menu', src)
end)
