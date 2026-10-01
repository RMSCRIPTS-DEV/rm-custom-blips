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
--- the slot ids below.
--- color: https://docs.fivem.net/docs/game-references/blips/#blip-colors
Config.Locations = {
    -- { coords = vec3(750.27, -1298.06, 36.16), sprite = 432, scale = 1.0, color = 50, label = 'Bowling' },
}

--- The blip sheet the slots live on (sheets/<name>.png, a copy of the game's own).
Config.sheet = { name = 'blips_texturesheet_ng', width = 1024, height = 1024 }

--- Replaceable slots. Drop `blips/<id>.png` into the resource and that sprite id shows
--- your image - for this resource's blips and for every other script using that id.
--- A slot without a PNG keeps the vanilla icon. Any size works (square, transparent
--- background); it is scaled into the slot. x/y/w/h = where the slot sits on the sheet.
Config.Slots = {
    { id = 381, x = 640, y = 640, w = 64, h = 64, label = 'Bank' },
    { id = 382, x = 704, y = 640, w = 64, h = 64, label = 'Store' },
    { id = 383, x = 768, y = 640, w = 64, h = 64, label = 'Jobs' },
    { id = 384, x = 832, y = 640, w = 64, h = 64, label = 'Barber' },
    { id = 385, x = 896, y = 640, w = 64, h = 64, label = 'Prospecting' },
    { id = 386, x = 960, y = 640, w = 64, h = 64, label = 'Windmills' },
    { id = 387, x = 0, y = 704, w = 64, h = 64, label = 'Smelting' },
    { id = 389, x = 128, y = 704, w = 64, h = 64, label = 'Car wash' },
    { id = 104, x = 448, y = 128, w = 64, h = 64, label = 'Casino' },
    { id = 105, x = 512, y = 128, w = 64, h = 64, label = 'City hall' },
    { id = 107, x = 640, y = 128, w = 64, h = 64, label = 'Gas station' },
    { id = 113, x = 960, y = 128, w = 64, h = 64, label = 'Recycling' },
    { id = 181, x = 256, y = 320, w = 64, h = 64, label = 'Vehicle rental' },
    { id = 182, x = 320, y = 320, w = 64, h = 64, label = 'Impound' },
    { id = 210, x = 192, y = 384, w = 64, h = 64, label = 'Vehicle dealer' },
    { id = 211, x = 256, y = 384, w = 64, h = 64, label = 'Mechanic' },
    { id = 289, x = 640, y = 448, w = 64, h = 64, label = 'Police' },
    { id = 290, x = 704, y = 448, w = 64, h = 64, label = 'Tattoo' },
    { id = 291, x = 768, y = 448, w = 64, h = 64, label = 'Hospital' },
    { id = 420, x = 0, y = 768, w = 64, h = 64, label = 'Clothing' },
    { id = 429, x = 320, y = 768, w = 64, h = 64, label = 'Jewelry' },
    { id = 430, x = 384, y = 768, w = 64, h = 64, label = 'Golf' },
    { id = 432, x = 512, y = 768, w = 64, h = 64, label = 'Bowling' },
    { id = 433, x = 576, y = 768, w = 64, h = 64, label = 'Marketplace' },
    { id = 388, x = 64, y = 704, w = 64, h = 64, label = 'Security / vault' },
    { id = 118, x = 0, y = 192, w = 64, h = 64, label = 'Treasure' },
    { id = 183, x = 384, y = 320, w = 64, h = 64, label = 'Pawnshop / vendor' },
    { id = 208, x = 64, y = 384, w = 64, h = 64, label = 'Tennis' },
    { id = 209, x = 128, y = 384, w = 64, h = 64, label = 'DMV / licenses' },
    { id = 237, x = 576, y = 384, w = 64, h = 64, label = 'Pharmacy' },
    { id = 238, x = 640, y = 384, w = 64, h = 64, label = 'Hardware store' },
    { id = 293, x = 832, y = 448, w = 64, h = 64, label = 'Gun store' },
    { id = 78, x = 512, y = 64, w = 64, h = 64, label = 'Housing' },
    { id = 79, x = 576, y = 64, w = 64, h = 64, label = 'Hunting' },
    { id = 473, x = 320, y = 896, w = 64, h = 64, label = 'Warehouse' },

    -- Empty slots: no PNG shipped. Add blips/<id>.png and rename the label.
    { id = 431, x = 448, y = 768, w = 64, h = 64, label = 'Slot 431' },
    { id = 434, x = 640, y = 768, w = 64, h = 64, label = 'Slot 434' },
    { id = 400, x = 192, y = 704, w = 64, h = 64, label = 'Slot 400' },
    { id = 405, x = 512, y = 704, w = 64, h = 64, label = 'Slot 405' },
    { id = 495, x = 960, y = 960, w = 64, h = 64, label = 'Slot 495' },
    { id = 76, x = 384, y = 64, w = 64, h = 64, label = 'Slot 76' },
    { id = 77, x = 448, y = 64, w = 64, h = 64, label = 'Slot 77' },
    { id = 89, x = 960, y = 64, w = 64, h = 64, label = 'Slot 89' },
    { id = 120, x = 128, y = 192, w = 64, h = 64, label = 'Slot 120' },
    { id = 352, x = 0, y = 576, w = 64, h = 64, label = 'Slot 352' },
    { id = 355, x = 128, y = 576, w = 64, h = 64, label = 'Slot 355' },
    { id = 205, x = 896, y = 320, w = 64, h = 64, label = 'Slot 205' },
    { id = 206, x = 960, y = 320, w = 64, h = 64, label = 'Slot 206' },
    { id = 269, x = 64, y = 448, w = 64, h = 64, label = 'Slot 269' },
    { id = 149, x = 64, y = 256, w = 64, h = 64, label = 'Slot 149' },
}

return Config
