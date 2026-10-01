local Config = {}

--- Master switch for every blip this resource draws (static + database).
Config.blipsShow = true

--- Blips from the database only show on the minimap when the player is close
--- (they always show on the pause map).
Config.shortRange = true

--- ACE needed for /blips and for saving/deleting blips. lib.addCommand grants
--- `command.blips` to the group below, so admins get it automatically.
Config.commandGroup = 'group.admin'

--- Static blips, defined here instead of in-game. Use any vanilla sprite id or one of
--- the custom ids below (the id is the vanilla sprite whose icon was replaced).
--- color: https://docs.fivem.net/docs/game-references/blips/#blip-colors
Config.Locations = {
    -- { coords = vec3(750.27, -1298.06, 36.16), sprite = 432, scale = 1.0, color = 50, label = 'Bowling' },
}

--- Icons baked into sheets/blips_texturesheet_ng.png. Every blip that uses one of these
--- sprite ids - from this resource or from ANY other script - shows the custom icon.
--- The list is only used for the "Custom icon" dropdown in /blips; editing it does not
--- change the texture.
Config.CustomSprites = {
    { id = 381, label = 'Bank' },
    { id = 382, label = 'Store' },
    { id = 383, label = 'Jobs' },
    { id = 384, label = 'Barber' },
    { id = 385, label = 'Prospecting' },
    { id = 386, label = 'Windmills' },
    { id = 387, label = 'Smelting' },
    { id = 389, label = 'Car wash' },
    { id = 104, label = 'Casino' },
    { id = 105, label = 'City hall' },
    { id = 107, label = 'Gas station' },
    { id = 113, label = 'Recycling' },
    { id = 181, label = 'Vehicle rental' },
    { id = 182, label = 'Impound' },
    { id = 210, label = 'Vehicle dealer' },
    { id = 211, label = 'Mechanic' },
    { id = 289, label = 'Police' },
    { id = 290, label = 'Tattoo' },
    { id = 291, label = 'Hospital' },
    { id = 420, label = 'Clothing' },
    { id = 429, label = 'Jewelry' },
    { id = 430, label = 'Golf' },
    { id = 432, label = 'Bowling' },
    { id = 433, label = 'Marketplace' },
    { id = 388, label = 'Security / vault' },
    { id = 118, label = 'Treasure' },
    { id = 183, label = 'Pawnshop / vendor' },
    { id = 208, label = 'Tennis' },
    { id = 209, label = 'DMV / licenses' },
    { id = 237, label = 'Pharmacy' },
    { id = 238, label = 'Hardware store' },
    { id = 293, label = 'Gun store' },
    { id = 78, label = 'Housing' },
    { id = 79, label = 'Hunting' },
    { id = 473, label = 'Warehouse' },
}

--- Texture sheets in sheets/ that replace the game's own (minimap.ytd).
Config.sheets = { 'blips_texturesheet_ng' }

return Config
