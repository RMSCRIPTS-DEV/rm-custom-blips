local Config = require 'config'

-- ─── Custom icons ────────────────────────────────────────────────────────────────
-- GTA draws every blip from a few texture sheets inside minimap.ytd. A hidden DUI page
-- (html/sheet.html) paints the vanilla sheet plus every blips/<id>.png over its slot,
-- and that page replaces the game's sheet. Any blip using a slot's sprite id then shows
-- the dropped-in image - no build step, just add the PNG and restart the resource.

--- Slots that actually have a PNG in blips/.
local activeSlots = {}
for _, slot in ipairs(Config.Slots) do
    if LoadResourceFile(cache.resource, ('blips/%d.png'):format(slot.id)) then
        activeSlots[#activeSlots + 1] = slot
    end
end

local dui

CreateThread(function()
    if #activeSlots == 0 then return end
    local sheet = Config.sheet

    dui = CreateDui(('nui://%s/html/sheet.html'):format(cache.resource), sheet.width, sheet.height)
    local timeout = GetGameTimer() + 10000
    while not IsDuiAvailable(dui) and GetGameTimer() < timeout do Wait(50) end
    if not IsDuiAvailable(dui) then
        print('^1[rm-custom-blips] blip sheet page did not load^7')
        return
    end

    SendDuiMessage(dui, json.encode({
        action = 'build', sheet = sheet.name, width = sheet.width, height = sheet.height, slots = activeSlots,
    }))
    -- Give the page time to draw before it replaces the real sheet (else blips flash empty).
    Wait(1500)

    local txd = CreateRuntimeTxd('rm_custom_blips')
    CreateRuntimeTextureFromDuiHandle(txd, sheet.name, GetDuiHandle(dui))
    AddReplaceTexture('minimap', sheet.name, 'rm_custom_blips', sheet.name)
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    RemoveReplaceTexture('minimap', Config.sheet.name)
    if dui then DestroyDui(dui) end
end)

-- ─── Static blips (config.lua) ───────────────────────────────────────────────────

local staticBlips = {}

CreateThread(function()
    if not Config.blipsShow then return end
    for _, v in ipairs(Config.Locations) do
        local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(blip, v.sprite)
        SetBlipScale(blip, v.scale or 1.0)
        SetBlipColour(blip, v.color or 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.label or 'Blip')
        EndTextCommandSetBlipName(blip)
        staticBlips[#staticBlips + 1] = blip
    end
end)

-- ─── Database blips (made in-game with /blips) ───────────────────────────────────

local handles = {} ---@type integer[]

local function clearBlips()
    for i = #handles, 1, -1 do
        if DoesBlipExist(handles[i]) then RemoveBlip(handles[i]) end
        handles[i] = nil
    end
end

local function createBlip(b)
    local blip
    if b.type == 'radius' then
        blip = AddBlipForRadius(b.x, b.y, b.z, b.width)
    elseif b.type == 'area' then
        blip = AddBlipForArea(b.x, b.y, b.z, b.width, b.height)
    else
        blip = AddBlipForCoord(b.x, b.y, b.z)
        SetBlipSprite(blip, b.sprite)
        SetBlipScale(blip, b.scale)
        SetBlipAsShortRange(blip, Config.shortRange)
        ShowTickOnBlip(blip, b.ticked)
        ShowOutlineIndicatorOnBlip(blip, b.outline)
        if b.display and b.display > 0 then SetBlipDisplay(blip, b.display) end
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(b.name)
        EndTextCommandSetBlipName(blip)
    end
    SetBlipColour(blip, b.color)
    SetBlipAlpha(blip, b.alpha > 0 and b.alpha or 255)
    handles[#handles + 1] = blip
end

local function render(list)
    clearBlips()
    if not Config.blipsShow then return end
    for _, b in ipairs(list or {}) do createBlip(b) end
end

RegisterNetEvent('rm-custom-blips:sync', render)

CreateThread(function()
    render(lib.callback.await('rm-custom-blips:get', false))
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    clearBlips()
    for _, blip in ipairs(staticBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
    end
end)

-- ─── /blips editor ───────────────────────────────────────────────────────────────

local DISPLAY = {
    { value = 4, label = 'Map + minimap (default)' },
    { value = 2, label = 'Map + minimap (always)' },
    { value = 3, label = 'Map only' },
    { value = 5, label = 'Minimap only' },
}

local function customOptions()
    local list = { { value = 0, label = '- use the sprite id above -' } }
    for _, s in ipairs(activeSlots) do
        list[#list + 1] = { value = s.id, label = ('%s (%d)'):format(s.label, s.id) }
    end
    return list
end

local function streetAt(x, y, z)
    local s1, s2 = GetStreetNameAtCoord(x, y, z)
    local a, b = GetStreetNameFromHashKey(s1), s2 ~= 0 and GetStreetNameFromHashKey(s2) or nil
    return b and b ~= '' and ('%s / %s'):format(a, b) or a
end

local openMenu

---@param b table? existing blip, nil = new blip at the player
local function editBlip(b)
    local pos = GetEntityCoords(cache.ped)
    b = b or { name = 'New blip', x = pos.x, y = pos.y, z = pos.z, sprite = 1, scale = 1.0, alpha = 255,
        color = 0, display = 4, type = 'blip', width = 50.0, height = 50.0 }

    local input = lib.inputDialog(b.id and ('Edit blip #%d'):format(b.id) or 'New blip', {
        { type = 'input', label = 'Name', default = b.name, required = true, max = 50 },
        { type = 'select', label = 'Type', default = b.type, options = {
            { value = 'blip', label = 'Icon' }, { value = 'radius', label = 'Radius (circle)' }, { value = 'area', label = 'Area (rectangle)' },
        } },
        { type = 'number', label = 'Sprite id', default = b.sprite, min = 0, max = 1000,
            description = 'Vanilla id - docs.fivem.net/docs/game-references/blips' },
        { type = 'select', label = 'Custom icon (overrides sprite id)', default = 0, options = customOptions() },
        { type = 'number', label = 'Colour', default = b.color, min = 0, max = 85 },
        { type = 'slider', label = 'Scale', default = b.scale, min = 0.3, max = 2.0, step = 0.1 },
        { type = 'slider', label = 'Opacity', default = b.alpha, min = 0, max = 255, step = 5 },
        { type = 'select', label = 'Display', default = b.display > 0 and b.display or 4, options = DISPLAY },
        { type = 'checkbox', label = 'Tick', checked = b.ticked },
        { type = 'checkbox', label = 'Outline', checked = b.outline },
        { type = 'number', label = 'Width / radius (radius & area)', default = b.width, min = 1, max = 5000 },
        { type = 'number', label = 'Height (area)', default = b.height, min = 1, max = 5000 },
    })
    if not input then return openMenu() end

    local data = {
        id = b.id, x = b.x, y = b.y, z = b.z, streetName = streetAt(b.x, b.y, b.z),
        name = input[1], type = input[2], sprite = (input[4] and input[4] > 0) and input[4] or input[3],
        color = input[5], scale = input[6], alpha = input[7], display = input[8],
        ticked = input[9], outline = input[10], width = input[11], height = input[12],
    }
    if lib.callback.await('rm-custom-blips:save', false, data) then
        lib.notify({ type = 'success', description = 'Blip saved' })
    else
        lib.notify({ type = 'error', description = 'Could not save blip' })
    end
    openMenu()
end

local function blipActions(b)
    lib.registerContext({
        id = 'rm_custom_blips_actions',
        title = ('#%d · %s'):format(b.id, b.name),
        menu = 'rm_custom_blips_main',
        options = {
            { title = 'Edit', icon = 'pen', onSelect = function() editBlip(b) end },
            { title = 'Move here', icon = 'location-crosshairs', description = 'Move the blip to where you stand',
                onSelect = function()
                    local p = GetEntityCoords(cache.ped)
                    local data = lib.table.deepclone(b)
                    data.x, data.y, data.z = p.x, p.y, p.z
                    data.streetName = streetAt(p.x, p.y, p.z)
                    lib.callback.await('rm-custom-blips:save', false, data)
                    openMenu()
                end },
            { title = 'Set waypoint', icon = 'map-pin', onSelect = function() SetNewWaypoint(b.x, b.y) end },
            { title = 'Teleport', icon = 'person-walking-arrow-right', onSelect = function()
                SetEntityCoords(cache.ped, b.x, b.y, b.z, false, false, false, false)
            end },
            { title = 'Delete', icon = 'trash', iconColor = '#fa5252', onSelect = function()
                local ok = lib.alertDialog({ header = 'Delete blip', content = ('Delete "%s"?'):format(b.name), centered = true, cancel = true })
                if ok == 'confirm' then lib.callback.await('rm-custom-blips:delete', false, b.id) end
                openMenu()
            end },
        },
    })
    lib.showContext('rm_custom_blips_actions')
end

openMenu = function()
    local list = lib.callback.await('rm-custom-blips:adminList', false)
    if not list then return end
    local options = {
        { title = 'Create blip here', icon = 'plus', onSelect = function() editBlip(nil) end },
    }
    for _, b in ipairs(list) do
        options[#options + 1] = {
            title = ('#%d · %s'):format(b.id, b.name),
            description = ('%s · sprite %d · colour %d%s'):format(b.streetName or '', b.sprite, b.color,
                b.identifier and ' · personal' or ''),
            icon = b.type == 'blip' and 'location-dot' or 'circle',
            arrow = true,
            onSelect = function() blipActions(b) end,
        }
    end
    lib.registerContext({ id = 'rm_custom_blips_main', title = ('Blips (%d)'):format(#list), options = options })
    lib.showContext('rm_custom_blips_main')
end

RegisterNetEvent('rm-custom-blips:menu', function()
    openMenu()
end)
