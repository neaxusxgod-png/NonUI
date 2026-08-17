local Non = (function()

local floor, ceil, abs, min, max = math.floor, math.ceil, math.abs, math.min, math.max
local cos, sin, pi = math.cos, math.sin, math.pi
local sub, upper, lower, rep, byte, char = string.sub, string.upper, string.lower, string.rep, string.byte, string.char
local format, gsub, find, match = string.format, string.gsub, string.find, string.match
local concat, insert, remove, sort = table.concat, table.insert, table.remove, table.sort
local rgb, v2 = Color3.fromRGB, Vector2.new
local now = tick or os.clock

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function lerp(a, b, t) return a + (b - a) * t end

local function to255(v) return floor(clamp(v, 0, 1) * 255 + 0.5) end

local function hex(s)
    local n = tonumber(s, 16) or 0
    return rgb(floor(n / 65536) % 256, floor(n / 256) % 256, n % 256)
end

local function mix(a, b, t)
    if t <= 0 then return a end
    if t >= 1 then return b end
    return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function hsv(h, s, v) return Color3.fromHSV(clamp(h, 0, 1), clamp(s, 0, 1), clamp(v, 0, 1)) end

local function tohsv(c)
    local r, g, b = c.R, c.G, c.B
    local high, low = max(r, g, b), min(r, g, b)
    local span = high - low
    local h = 0
    if span > 0 then
        if high == r then h = ((g - b) / span) % 6
        elseif high == g then h = (b - r) / span + 2
        else h = (r - g) / span + 4 end
        h = h / 6
    end
    return h, high > 0 and span / high or 0, high
end

local function hexOf(c) return format("%02X%02X%02X", to255(c.R), to255(c.G), to255(c.B)) end

local Palette = {
    Dark = {
        Accent = hex("18181B"),
        Dialog = hex("1A1A1A"),
        Outline = hex("FFFFFF"),
        Text = hex("FFFFFF"),
        Placeholder = hex("A1A1A1"),
        Background = hex("101010"),
        Button = hex("52525B"),
        Icon = hex("A1A1AA"),
        Toggle = hex("33C759"),
        Slider = hex("0091FF"),
        Checkbox = hex("0091FF"),
        PanelBackground = hex("FFFFFF"),
        PanelBackgroundTransparency = 0.95,
        SliderIcon = hex("908F95"),
        Primary = hex("0091FF"),
        LabelBackground = hex("000000"),
        LabelBackgroundTransparency = 0.83,
        ElementBackground = hex("2A2A2C"),
        ElementBackgroundTransparency = 0,
    },
    Light = {
        Accent = hex("EFEFEF"),
        Dialog = hex("F4F4F5"),
        Outline = hex("FFFFFF"),
        Text = hex("000000"),
        Placeholder = hex("555555"),
        Background = hex("FFFFFF"),
        Button = hex("18181B"),
        Icon = hex("52525B"),
        Toggle = hex("33C759"),
        Slider = hex("0091FF"),
        Checkbox = hex("0091FF"),
        DropdownTabBackground = hex("BEBEBE"),
        DropdownBackground = hex("FFFFFF"),
        TabBackground = hex("FFFFFF"),
        TabBackgroundHover = hex("F3F3F3"),
        TabBackgroundHoverTransparency = 0,
        TabBackgroundActive = hex("EFEFEF"),
        TabBackgroundActiveTransparency = 0,
        PanelBackground = hex("EFEFEF"),
        PanelBackgroundTransparency = 0,
        LabelBackground = hex("EFEFEF"),
        LabelBackgroundTransparency = 0,
        ElementBackground = hex("FFFFFF"),
        ElementBackgroundTransparency = 0,
    },
    Rose = {
        Accent = hex("BE185D"),
        Dialog = hex("4C0519"),
        Text = hex("FDF2F8"),
        Placeholder = hex("D67AA6"),
        Background = hex("1F0308"),
        Button = hex("E95F74"),
        Icon = hex("FB7185"),
        ElementBackground = hex("381E23"),
        ElementBackgroundTransparency = 0,
    },
    Plant = {
        Accent = hex("166534"),
        Dialog = hex("052E16"),
        Text = hex("F0FDF4"),
        Placeholder = hex("4FBF7A"),
        Background = hex("0A1B0F"),
        Button = hex("16A34A"),
        Icon = hex("4ADE80"),
        ElementBackground = hex("28342A"),
        ElementBackgroundTransparency = 0,
    },
    Red = {
        Accent = hex("991B1B"),
        Dialog = hex("450A0A"),
        Text = hex("FEF2F2"),
        Placeholder = hex("D95353"),
        Background = hex("1C0606"),
        Button = hex("DC2626"),
        Icon = hex("EF4444"),
        ElementBackground = hex("322221"),
        ElementBackgroundTransparency = 0,
    },
    Indigo = {
        Accent = hex("3730A3"),
        Dialog = hex("1E1B4B"),
        Text = hex("F1F5F9"),
        Placeholder = hex("7078D9"),
        Background = hex("0F0A2E"),
        Button = hex("4F46E5"),
        Icon = hex("6366F1"),
        ElementBackground = hex("282543"),
        ElementBackgroundTransparency = 0,
    },
    Sky = {
        Accent = hex("00D4FF"),
        Dialog = hex("0A4D66"),
        Text = hex("E6F7FF"),
        Placeholder = hex("66B3CC"),
        Background = hex("051A26"),
        Button = hex("00A8CC"),
        Icon = hex("2DB8D9"),
        Toggle = hex("00D9D9"),
        Slider = hex("00D4FF"),
        Checkbox = hex("00D4FF"),
        PanelBackground = hex("0D3A47"),
        PanelBackgroundTransparency = 0.8,
        ElementBackground = hex("172E3B"),
        ElementBackgroundTransparency = 0,
    },
    Violet = {
        Accent = hex("6D28D9"),
        Dialog = hex("3C1361"),
        Text = hex("FAF5FF"),
        Placeholder = hex("8F7EE0"),
        Background = hex("1E0A3E"),
        Button = hex("7C3AED"),
        Icon = hex("8B5CF6"),
        ElementBackground = hex("342650"),
        ElementBackgroundTransparency = 0,
    },
    Amber = {
        Icon = hex("F59E0B"),
        Slider = hex("D97706"),
        PanelBackground = hex("FFFFFF"),
        PanelBackgroundTransparency = 0.95,
        ElementBackground = hex("3A2E22"),
        ElementBackgroundTransparency = 0,
    },
    Emerald = {
        Accent = hex("047857"),
        Dialog = hex("022C22"),
        Text = hex("ECFDF5"),
        Placeholder = hex("3FBF8F"),
        Background = hex("011411"),
        Button = hex("059669"),
        Icon = hex("10B981"),
        ElementBackground = hex("202E2A"),
        ElementBackgroundTransparency = 0,
    },
    Midnight = {
        Accent = hex("1E3A8A"),
        Dialog = hex("0C1E42"),
        Text = hex("DBEAFE"),
        Placeholder = hex("2F74D1"),
        Background = hex("0A0F1E"),
        Button = hex("2563EB"),
        Primary = hex("2563EB"),
        Icon = hex("5591F4"),
        ElementBackground = hex("242836"),
        ElementBackgroundTransparency = 0,
    },
    Crimson = {
        Accent = hex("B91C1C"),
        Dialog = hex("450A0A"),
        Text = hex("FEF2F2"),
        Placeholder = hex("6F757B"),
        Background = hex("0C0404"),
        Button = hex("991B1B"),
        Icon = hex("DC2626"),
        ElementBackground = hex("251F1F"),
        ElementBackgroundTransparency = 0,
    },
    MonokaiPro = {
        Accent = hex("FC9867"),
        Dialog = hex("1E1E1E"),
        Text = hex("FCFCFA"),
        Placeholder = hex("AFAFAF"),
        Background = hex("191622"),
        Button = hex("AB9DF2"),
        Icon = hex("A9DC76"),
        ElementBackground = hex("323039"),
        ElementBackgroundTransparency = 0,
    },
    CottonCandy = {
        Accent = hex("EC4899"),
        Dialog = hex("2D1B3D"),
        Text = hex("FDF2F8"),
        Placeholder = hex("8A5FD3"),
        Background = hex("1A0B2E"),
        Button = hex("D946EF"),
        Slider = hex("D946EF"),
        Icon = hex("06B6D4"),
        ElementBackground = hex("312643"),
        ElementBackgroundTransparency = 0,
    },
    Mellowsi = {
        Accent = hex("342A1E"),
        Dialog = hex("291C13"),
        Text = hex("F5EBDD"),
        Placeholder = hex("9C8A73"),
        Background = hex("1C1002"),
        Button = hex("342A1E"),
        Icon = hex("C9B79C"),
        Toggle = hex("A9873F"),
        Slider = hex("C9A24D"),
        Checkbox = hex("C9A24D"),
        ElementBackground = hex("33291E"),
        ElementBackgroundTransparency = 0,
    },
    Rainbow = {
        Text = hex("FFFFFF"),
        Placeholder = hex("00FF80"),
        Icon = hex("FFFFFF"),
    },
}

local Skin, raw
local Resolved = { }
do
    local blended
    local Blend = { }

    function blended(base, toward, amount)
        Blend[#Blend + 1] = { base = base, toward = hex(toward), amount = amount }
        return Blend[#Blend]
    end

    local Fallback = {
        Primary = "Icon",
        White = Color3.new(1, 1, 1),
        Black = Color3.new(0, 0, 0),
        Dialog = "Accent",
        Background = "Accent",
        BackgroundTransparency = 0,
        Hover = "Text",
        PanelBackground = "White",
        PanelBackgroundTransparency = 0.95,
        WindowBackground = "Background",
        WindowShadow = "Black",
        WindowTopbarTitle = "Text",
        WindowTopbarAuthor = "Text",
        WindowTopbarIcon = "Icon",
        WindowTopbarButtonIcon = "Icon",
        WindowSearchBarBackground = "Dialog",
        TabBackground = "Hover",
        TabBackgroundHover = "Hover",
        TabBackgroundHoverTransparency = 0.97,
        TabBackgroundActive = "Hover",
        TabBackgroundActiveTransparency = 0.93,
        TabText = "Text",
        TabTextTransparency = 0.3,
        TabTextTransparencyActive = 0,
        TabTitle = "Text",
        TabIcon = "Icon",
        TabIconTransparency = 0.4,
        TabIconTransparencyActive = 0.1,
    TabIconActiveTransparency = 0.1,
        TabBorderTransparency = 1,
        TabBorderTransparencyActive = 0.75,
        TabBorder = "White",
        ElementBackground = "Text",
        ElementBackgroundTransparency = 0.93,
        ElementBackgroundHover = blended("ElementBackground", "FFFFFF", 0.1),
        ElementTitle = "Text",
        ElementDesc = "Text",
        ElementIcon = "Icon",
        PopupBackground = "Background",
        PopupBackgroundTransparency = "BackgroundTransparency",
        PopupTitle = "Text",
        PopupContent = "Text",
        PopupIcon = "Icon",
        DialogBackground = "Dialog",
        DialogBackgroundTransparency = "BackgroundTransparency",
        DialogTitle = "Text",
        DialogContent = "Text",
        DialogIcon = "Icon",
        Toggle = "Button",
        ToggleBar = "White",
        Checkbox = "Primary",
        CheckboxIcon = "White",
        CheckboxBorder = "White",
        CheckboxBorderTransparency = 0.75,
        SliderIcon = "Icon",
        Slider = "Primary",
        SliderThumb = "White",
        SliderIconFrom = "SliderIcon",
        SliderIconTo = "SliderIcon",
        ProgressBar = "Primary",
        ProgressBarTrack = "Text",
        ProgressBarTrackTransparency = 0.9,
        ProgressBarText = "Text",
        Tooltip = hex("4C4C4C"),
        TooltipText = "White",
        TooltipSecondary = "Primary",
        TooltipSecondaryText = "White",
        TabSectionIcon = "Icon",
        SectionIcon = "Icon",
        SectionExpandIcon = "Icon",
        SectionExpandIconTransparency = 0.4,
        SectionBox = "Text",
        SectionBoxTransparency = 0.95,
        SectionBoxBorder = "White",
        SectionBoxBorderTransparency = 0.75,
        SectionBoxBackground = "Text",
        SectionBoxBackgroundTransparency = 0.97,
        SearchBarBorder = "White",
        SearchBarBorderTransparency = 0.75,
        Notification = "Background",
        Notification2 = "White",
        Notification2Transparency = 0.92,
        NotificationTitle = "Text",
        NotificationTitleTransparency = 0,
        NotificationContent = "Text",
        NotificationContentTransparency = 0.4,
        NotificationDuration = "White",
        NotificationDurationTransparency = 0.95,
        NotificationBorder = "White",
        NotificationBorderTransparency = 0.75,
        DropdownTabBorder = "White",
        DropdownTabBackground = "ElementBackground",
        DropdownBackground = "Background",
        LabelBackground = "White",
        LabelBackgroundTransparency = 0.95,
        ViewportBackground = "ElementBackground",
        ViewportBackgroundTransparency = "ElementBackgroundTransparency",
    }

    Skin = Palette.Dark

    function raw(key, depth)
        if depth > 8 then return nil end
        local got = Skin[key]
        if got == nil then got = Fallback[key] end
        if got == nil then return nil end
        if type(got) == "string" then return raw(got, depth + 1) end
        if type(got) == "table" and got.base then
            local base = raw(got.base, depth + 1)
            if base == nil then return nil end
            return mix(base, got.toward, got.amount)
        end
        return got
    end
end

local function paint(key)
    local got = Resolved[key]
    if got == nil then
        got = raw(key, 0)
        if got == nil or type(got) == "number" or type(got) == "string" then
            got = Color3.new(1, 1, 1)
        end
        Resolved[key] = got
    end
    return got
end

local function veil(key)
    local got = Resolved[key .. "!"]
    if got == nil then
        got = raw(key .. "Transparency", 0)
        if type(got) ~= "number" then got = 0 end
        Resolved[key .. "!"] = got
    end
    return got
end

local function wear(name)
    if not Palette[name] then return false end
    Skin = Palette[name]
    for slot in pairs(Resolved) do Resolved[slot] = nil end
    return true
end

local png, unbase64
do
    local bxor, band, rshift
    if bit32 then
        bxor, band, rshift = bit32.bxor, bit32.band, bit32.rshift
    else
        bxor = function(a, b)
            local out, bit = 0, 1
            for _ = 1, 32 do
                local x, y = a % 2, b % 2
                if x ~= y then out = out + bit end
                a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
            end
            return out
        end
        band = function(a, b)
            local out, bit = 0, 1
            for _ = 1, 32 do
                local x, y = a % 2, b % 2
                if x == 1 and y == 1 then out = out + bit end
                a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
            end
            return out
        end
        rshift = function(a, n) return floor(a / 2 ^ n) end
    end

    local CrcTable = { }
    for i = 0, 255 do
        local c = i
        for _ = 1, 8 do
            if band(c, 1) == 1 then c = bxor(0xEDB88320, rshift(c, 1)) else c = rshift(c, 1) end
        end
        CrcTable[i] = c
    end

    local function crc32(s)
        local c = 0xFFFFFFFF
        for i = 1, #s do c = bxor(rshift(c, 8), CrcTable[band(bxor(c, byte(s, i)), 255)]) end
        return bxor(c, 0xFFFFFFFF)
    end

    local function adler32(s)
        local a, b = 1, 0
        for i = 1, #s do
            a = (a + byte(s, i)) % 65521
            b = (b + a) % 65521
        end
        return b * 65536 + a
    end

    local function be32(n)
        return char(floor(n / 16777216) % 256, floor(n / 65536) % 256, floor(n / 256) % 256, n % 256)
    end

    local function le16(n) return char(n % 256, floor(n / 256) % 256) end

    local function deflate(raw)
        local out, at, n = { char(120, 1) }, 1, #raw
        while at <= n do
            local size = min(n - at + 1, 65535)
            local last = (at + size - 1 >= n) and 1 or 0
            out[#out + 1] = char(last) .. le16(size) .. le16(65535 - size) .. sub(raw, at, at + size - 1)
            at = at + size
        end
        out[#out + 1] = be32(adler32(raw))
        return concat(out)
    end

    local function chunk(tag, data) return be32(#data) .. tag .. data .. be32(crc32(tag .. data)) end

    function png(w, h, pixels)
        return char(137, 80, 78, 71, 13, 10, 26, 10)
            .. chunk("IHDR", be32(w) .. be32(h) .. char(8, 6, 0, 0, 0))
            .. chunk("IDAT", deflate(pixels))
            .. chunk("IEND", "")
    end

    local B64 = { }
    for i = 1, 64 do
        B64[byte("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", i)] = i - 1
    end

    function unbase64(s)
        if base64decode then
            local ok, out = pcall(base64decode, s)
            if ok and type(out) == "string" and #out > 0 then return out end
        end
        local out, n, hold, bits = { }, 0, 0, 0
        for i = 1, #s do
            local v = B64[byte(s, i)]
            if v then
                hold = hold * 64 + v
                bits = bits + 6
                if bits >= 8 then
                    bits = bits - 8
                    local place = 2 ^ bits
                    local b = floor(hold / place)
                    hold = hold - b * place
                    n = n + 1
                    out[n] = char(b)
                end
            end
        end
        return concat(out)
    end
end

local function paintMask(mask, w, h, colour)
    local head = char(to255(colour.R), to255(colour.G), to255(colour.B))
    local rows, at = { }, 0
    for _ = 1, h do
        rows[#rows + 1] = char(0)
        local line = { }
        for i = 1, w do
            at = at + 1
            line[i] = head .. char(byte(mask, at) or 0)
        end
        rows[#rows + 1] = concat(line)
    end
    return png(w, h, concat(rows))
end

local Masks = { }
local cornerSheet
do
    local SQUIRCLE = 4.2
    local STEPS = 4

    local function cornerCoverage(size, dx, dy, radius, power)
        local inside = 0
        for sy = 0, STEPS - 1 do
            for sx = 0, STEPS - 1 do
                local px = (dx + (sx + 0.5) / STEPS) / radius
                local py = (dy + (sy + 0.5) / STEPS) / radius
                if px ^ power + py ^ power <= 1 then inside = inside + 1 end
            end
        end
        return inside / (STEPS * STEPS)
    end

    local Corners = { }

    local function cornerMask(radius, spot)
        local key = radius .. "/" .. spot
        local built = Corners[key]
        if built then return built end

        local bytes, at = { }, 0
        for y = 0, radius - 1 do
            for x = 0, radius - 1 do
                local dx = (spot == 0 or spot == 2) and (radius - 1 - x) or x
                local dy = (spot == 0 or spot == 1) and (radius - 1 - y) or y
                at = at + 1
                bytes[at] = char(floor(cornerCoverage(radius, dx, dy, radius, SQUIRCLE) * 255 + 0.5))
            end
        end
        built = concat(bytes)
        Corners[key] = built
        return built
    end

    local Sheets, SheetCount = { }, 0

    function cornerSheet(radius, spot, colour)
        if radius < 1 then return nil end
        local key = radius .. "/" .. spot .. "/" .. hexOf(colour)
        local sheet = Sheets[key]
        if sheet == nil then
            local ok, made = pcall(paintMask, cornerMask(radius, spot), radius, radius, colour)
            sheet = ok and made or false
            if SheetCount > 160 then
                Sheets, SheetCount = { }, 0
            end
            Sheets[key] = sheet
            SheetCount = SheetCount + 1
        end
        return sheet or nil
    end
end

local Arcs = { }
local arcSheet
do
    local Painted = { }

    local function arcMask(side, pad, radius, thick)
        local half = thick / 2
        local endAx, endAy = radius, 0
        local endBx, endBy = 0, radius
        local bytes, at = { }, 0
        for y = 0, side - 1 do
            for x = 0, side - 1 do
                local ink = 0
                for sy = 0, 3 do
                    for sx = 0, 3 do
                        local ox = x + (sx + 0.5) / 4 - pad
                        local oy = y + (sy + 0.5) / 4 - pad
                        local near
                        if ox >= 0 and oy >= 0 then
                            near = abs((ox * ox + oy * oy) ^ 0.5 - radius)
                        else
                            local da = ((ox - endAx) ^ 2 + (oy - endAy) ^ 2) ^ 0.5
                            local db = ((ox - endBx) ^ 2 + (oy - endBy) ^ 2) ^ 0.5
                            near = min(da, db)
                        end
                        if near <= half then ink = ink + 1 end
                    end
                end
                at = at + 1
                bytes[at] = char(floor(ink / 16 * 255 + 0.5))
            end
        end
        return concat(bytes)
    end

    function arcSheet(radius, thick, colour)
        radius, thick = floor(radius), max(1, floor(thick))
        local pad = ceil(thick / 2) + 1
        local side = pad + radius + ceil(thick / 2) + 1
        local shape = radius .. "/" .. thick
        local mask = Arcs[shape]
        if not mask then
            mask = arcMask(side, pad, radius, thick)
            Arcs[shape] = mask
        end
        local key = shape .. "/" .. hexOf(colour)
        local sheet = Painted[key]
        if sheet == nil then
            local ok, made = pcall(paintMask, mask, side, side, colour)
            sheet = ok and made or false
            Painted[key] = sheet
        end
        return sheet or nil, side, pad
    end
end

local Fonts = (Drawing and Drawing.Fonts) or { }
local FONT = Fonts.System or Fonts.SystemBold or 0

local Can = { center = false, font = false, sides = false, fontsize = false, corner = false }
if Drawing then
    local function probe(kind, fn)
        local ok, obj = pcall(Drawing.new, kind)
        if not ok or not obj then return false end
        pcall(function() obj.Visible = false end)
        local good = pcall(fn, obj)
        pcall(function() obj:Remove() end)
        return good
    end
    pcall(function()
        Can.corner = probe("Square", function(o) o.Corner = 4 end)
        Can.center = probe("Text", function(o) o.Center = true end)
        Can.font = probe("Text", function(o) o.Font = FONT end)
        Can.sides = probe("Circle", function(o) o.NumSides = 24 end)
        Can.fontsize = probe("Text", function(o) o.FontSize = 12 end)
    end)
end

local take, newFrame, hideRest, wipe
do
    local Pool = { sq = { }, tx = { }, ln = { }, ci = { }, im = { }, tr = { } }
    local Cache = { sq = { }, tx = { }, ln = { }, ci = { }, im = { }, tr = { } }
    local Used = { sq = 0, tx = 0, ln = 0, ci = 0, im = 0, tr = 0 }
    local Class = {
        sq = "Square", tx = "Text", ln = "Line", ci = "Circle", im = "Image", tr = "Triangle",
    }

    function take(kind)
        local i = Used[kind] + 1
        Used[kind] = i
        local obj = Pool[kind][i]
        if not obj then
            local ok, made = pcall(Drawing.new, Class[kind])
            if not ok or not made then return nil end
            obj = made
            Pool[kind][i] = obj
            Cache[kind][i] = { }
            if kind == "tx" then
                pcall(function() obj.Outline = false end)
                if Can.center then pcall(function() obj.Center = false end) end
            end
        end
        return obj, Cache[kind][i]
    end

    function newFrame()
        for kind in pairs(Pool) do Used[kind] = 0 end
    end

    function hideRest()
        for kind, list in pairs(Pool) do
            for i = Used[kind] + 1, #list do
                local obj, c = list[i], Cache[kind][i]
                if obj and c and c.vis ~= false then
                    c.vis = false
                    obj.Visible = false
                end
            end
        end
    end

    function wipe()
        for kind, list in pairs(Pool) do
            for i = 1, #list do
                local obj = list[i]
                if obj then pcall(function() obj.Visible = false; obj:Remove() end) end
                list[i], Cache[kind][i] = nil, nil
            end
            Used[kind] = 0
        end
    end
end

local Sheer = 1

local function sheerness(value)
    Sheer = clamp(value, 0.05, 1)
    return Sheer
end

local Clip = nil

local function clipTo(x, y, w, h)
    Clip = { x, y, w, h }
end

local function unclip()
    Clip = nil
end

local function boxed(x, y, w, h)
    if not Clip then return true end
    return x >= Clip[1] - 0.5 and y >= Clip[2] - 0.5
        and x + w <= Clip[1] + Clip[3] + 0.5 and y + h <= Clip[2] + Clip[4] + 0.5
end

local function rect(x, y, w, h, colour, z, alpha, radius)
    alpha = (alpha or 1) * Sheer
    if w <= 0.2 or h <= 0.2 or alpha <= 0.004 then return end
    if Clip then
        local right = min(x + w, Clip[1] + Clip[3])
        local foot = min(y + h, Clip[2] + Clip[4])
        x, y = max(x, Clip[1]), max(y, Clip[2])
        w, h = right - x, foot - y
        if w <= 0.2 or h <= 0.2 then return end
    end
    local o, c = take("sq")
    if not o then return end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.w ~= w or c.h ~= h then c.w, c.h = w, h; o.Size = v2(w, h) end
    if c.colour ~= colour then c.colour = colour; o.Color = colour end
    if c.fill ~= true then c.fill = true; o.Filled = true end
    if Can.corner then
        local bend = min(radius or 0, w / 2, h / 2)
        if c.bend ~= bend then c.bend = bend; o.Corner = bend end
    end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function img(sheet, x, y, w, h, z, alpha)
    alpha = (alpha or 1) * Sheer
    if not sheet or w <= 0.2 or h <= 0.2 or alpha <= 0.004 then return end
    if not boxed(x, y, w, h) then return end
    local o, c = take("im")
    if not o then return end
    if c.sheet ~= sheet then c.sheet = sheet; o.Data = sheet end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.w ~= w or c.h ~= h then c.w, c.h = w, h; o.Size = v2(w, h) end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function line(x1, y1, x2, y2, colour, z, thick, alpha)
    alpha = (alpha or 1) * Sheer
    if alpha <= 0.004 then return end
    if not boxed(min(x1, x2), min(y1, y2), abs(x2 - x1), abs(y2 - y1)) then return end
    local o, c = take("ln")
    if not o then return end
    if c.x1 ~= x1 or c.y1 ~= y1 then c.x1, c.y1 = x1, y1; o.From = v2(x1, y1) end
    if c.x2 ~= x2 or c.y2 ~= y2 then c.x2, c.y2 = x2, y2; o.To = v2(x2, y2) end
    if c.colour ~= colour then c.colour = colour; o.Color = colour end
    if c.thick ~= thick then c.thick = thick; o.Thickness = thick or 1 end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function circ(x, y, radius, colour, z, filled, thick, alpha)
    alpha = (alpha or 1) * Sheer
    if radius <= 0.2 or alpha <= 0.004 then return end
    if not boxed(x - radius, y - radius, radius * 2, radius * 2) then return end
    local o, c = take("ci")
    if not o then return end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.radius ~= radius then c.radius = radius; o.Radius = radius end
    if c.colour ~= colour then c.colour = colour; o.Color = colour end
    if c.filled ~= filled then c.filled = filled; o.Filled = filled and true or false end
    if c.thick ~= thick then c.thick = thick; o.Thickness = thick or 1 end
    if Can.sides and c.sides ~= 48 then c.sides = 48; o.NumSides = 48 end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function text(s, x, y, colour, size, z, alpha)
    s = tostring(s)
    alpha = alpha or 1
    if alpha <= 0.004 or s == "" then return end
    if not boxed(x, y, 0, size) then return end
    local o, c = take("tx")
    if not o then return end
    if c.text ~= s then c.text = s; o.Text = s end
    if c.size ~= size then
        c.size = size
        o.Size = size
        if Can.fontsize then o.FontSize = size end
    end
    if Can.font and c.font ~= FONT then c.font = FONT; o.Font = FONT end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.colour ~= colour then c.colour = colour; o.Color = colour end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function squircle(x, y, w, h, radius, colour, z, alpha)
    alpha = alpha or 1
    if w <= 0.2 or h <= 0.2 or alpha <= 0.004 then return end
    radius = floor(min(radius, w / 2, h / 2))

    if Can.corner or radius < 1 then
        rect(x, y, w, h, colour, z, alpha, radius)
        return
    end

    x, y = floor(x + 0.5), floor(y + 0.5)
    w, h = floor(w + 0.5), floor(h + 0.5)
    local right, bottom = x + w - radius, y + h - radius
    img(cornerSheet(radius, 0, colour), x, y, radius, radius, z, alpha)
    img(cornerSheet(radius, 1, colour), right, y, radius, radius, z, alpha)
    img(cornerSheet(radius, 2, colour), x, bottom, radius, radius, z, alpha)
    img(cornerSheet(radius, 3, colour), right, bottom, radius, radius, z, alpha)

    local span = w - radius * 2
    if span > 0 then
        rect(x + radius, y, span, radius + 1, colour, z, alpha)
        rect(x + radius, bottom - 1, span, radius + 1, colour, z, alpha)
    end
    rect(x, y + radius - 1, w, h - radius * 2 + 2, colour, z, alpha)
end

local function squircleEdge(x, y, w, h, radius, colour, z, alpha, thick)
    alpha = (alpha or 1) * Sheer
    if w <= 0.2 or h <= 0.2 or alpha <= 0.004 then return end
    thick = thick or 1
    radius = floor(min(radius, w / 2, h / 2))

    local o, c = take("sq")
    if not o then return end
    if c.x ~= x or c.y ~= y then c.x, c.y = x, y; o.Position = v2(x, y) end
    if c.w ~= w or c.h ~= h then c.w, c.h = w, h; o.Size = v2(w, h) end
    if c.colour ~= colour then c.colour = colour; o.Color = colour end
    if c.fill ~= false then c.fill = false; o.Filled = false end
    if c.thick ~= thick then c.thick = thick; o.Thickness = thick end
    if Can.corner and c.bend ~= radius then c.bend = radius; o.Corner = radius end
    local zi = floor(z or 1)
    if c.z ~= zi then c.z = zi; o.ZIndex = zi end
    if c.alpha ~= alpha then c.alpha = alpha; o.Transparency = alpha end
    if c.vis ~= true then c.vis = true; o.Visible = true end
end

local function shadow(x, y, w, h, radius, z, alpha, spread)
    spread = spread or 8
    for i = spread, 1, -1 do
        local soft = alpha * 0.1 * (1 - i / (spread + 1))
        squircle(x - i, y - i + 1, w + i * 2, h + i * 2, radius + i, paint("WindowShadow"),
            z + spread - i, soft)
    end
end

local Glyph = { }
do
    Glyph.other = 0.55
    local function set(chars, w)
        for i = 1, #chars do Glyph[byte(chars, i)] = w end
    end
    set(",.:;", 0.21) set("'", 0.23) set("ijl|", 0.24) set("I`", 0.27) set(" !", 0.28)
    set("()[]{}", 0.30) set("f", 0.32) set("t", 0.34) set("Jr", 0.35) set("\\", 0.38)
    set("/\"", 0.39) set("-", 0.40) set("*_", 0.41) set("s", 0.42) set("?z", 0.45)
    set("cx", 0.46) set("L", 0.47) set("vy", 0.48) set("Fk", 0.49) set("Ea", 0.51)
    set("STe", 0.53) set("$0123456789", 0.54) set("PYhnu", 0.56) set("BZ", 0.57)
    set("Ko", 0.58) set("#Xbdgpq", 0.59) set("R", 0.60) set("CV", 0.62) set("A", 0.65)
    set("+<=>GU^~", 0.69) set("D", 0.70) set("H", 0.71) set("w", 0.72) set("N", 0.75)
    set("OQ", 0.76) set("&", 0.80) set("%", 0.82) set("m", 0.86) set("M", 0.90)
    set("W", 0.94) set("@", 0.95)
end

local width
do
    local Widths, WidthCount = { }, 0

    function width(s, size)
        s = tostring(s)
        if s == "" then return 0 end
        local key = s .. "\1" .. size
        local known = Widths[key]
        if known then return known end
        local run, i, n = 0, 1, #s
        while i <= n do
            local b = byte(s, i)
            if b < 128 then
                run = run + (Glyph[b] or Glyph.other)
                i = i + 1
            else
                run = run + Glyph.other
                i = i + 1
                while i <= n and byte(s, i) >= 128 and byte(s, i) <= 191 do i = i + 1 end
            end
        end
        run = run * size
        if WidthCount >= 4096 then Widths, WidthCount = { }, 0 end
        Widths[key] = run
        WidthCount = WidthCount + 1
        return run
    end
end

local CAPHEIGHT = 0.72
local capTop
do
    local CAPTOP = 0.21

    function capTop(cap, size) return cap - size * CAPTOP end
end

local function label(s, x, cap, colour, size, z, alpha)
    text(s, x, capTop(cap, size), colour, size, z, alpha)
end

local function labelmid(s, cx, cap, colour, size, z, alpha)
    text(s, cx - width(s, size) / 2, capTop(cap, size), colour, size, z, alpha)
end

local function labelright(s, right, cap, colour, size, z, alpha)
    text(s, right - width(s, size), capTop(cap, size), colour, size, z, alpha)
end

local function middle(s, x, y, h, colour, size, z, alpha)
    label(s, x, y + (h - size * CAPHEIGHT) / 2, colour, size, z, alpha)
end

local function fit(s, room, size, tail)
    s = tostring(s)
    if room <= 4 then return "" end
    if width(s, size) <= room then return s end
    tail = tail or ""
    local lo, hi = 0, #s
    while lo < hi do
        local mid = floor((lo + hi + 1) / 2)
        if width(sub(s, 1, mid) .. tail, size) <= room then lo = mid else hi = mid - 1 end
    end
    if lo == 0 then return "" end
    return sub(s, 1, lo) .. tail
end

local function runText(s, x, top, colour, size, z, alpha)
    s = tostring(s)
    local pen = x
    for i = 1, #s do
        local b = byte(s, i)
        if b ~= 32 then text(sub(s, i, i), pen, top, colour, size, z, alpha) end
        pen = pen + (Glyph[b] or Glyph.other) * size
    end
    return pen
end

local function wrap(s, room, size)
    local lines, line = { }, ""
    for word in string.gmatch(tostring(s), "[^ ]+") do
        local try = line == "" and word or (line .. " " .. word)
        if width(try, size) <= room or line == "" then
            line = try
        else
            lines[#lines + 1] = line
            line = word
        end
    end
    if line ~= "" then lines[#lines + 1] = line end
    return lines
end

local dt = 1 / 60

local function glide(from, to, seconds)
    if from == nil then return to end
    if not seconds or seconds <= 0 then return to end
    local moved = lerp(from, to, 1 - 0.5 ^ (dt / (seconds * 0.33)))
    if abs(to - moved) < 0.0015 then return to end
    return moved
end

local function fade(owner, key, to, seconds)
    local v = glide(owner[key], to, seconds or 0.15)
    owner[key] = v
    return v
end

local function ease(t)
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    return t * t * (3 - 2 * t)
end

local function drift(owner, key, to, seconds)
    return ease(fade(owner, key, to, seconds))
end

local function shove(owner)
    owner.aPunch = 1
end

local function punch(owner)
    local at = owner.aPunch
    if not at or at <= 0.004 then
        owner.aPunch = 0
        return 0
    end
    owner.aPunch = glide(at, 0, 0.11)
    return ease(at)
end

local keyDown, m1Down, m2Down, focused, grabInput, toClip, fromClip
do
    local function host(name, fallback)
        local f = _G[name]
        if type(f) == "function" then return f end
        return fallback
    end

    keyDown   = host("iskeypressed", function() return false end)
    m1Down    = host("ismouse1pressed", function() return false end)
    m2Down    = host("ismouse2pressed", function() return false end)
    focused   = host("isrbxactive", function() return true end)
    grabInput = host("setrobloxinput", function() end)
    toClip    = host("setclipboard", function() end)
    fromClip  = host("getclipboard", nil)
end

local Key, Order, Named = { }, { }, { }

local function bindKey(name, id, ch, shifted)
    if not Key[name] then Order[#Order + 1] = name end
    Key[name] = { id = id, down = false, hit = false, up = false, ch = ch, shifted = shifted }
    Named[id] = upper(sub(name, 1, 1)) .. sub(name, 2)
end

bindKey("m1", 0x01) bindKey("m2", 0x02)
bindKey("mouse3", 0x04) bindKey("mouse4", 0x05) bindKey("mouse5", 0x06)
bindKey("wheelup", 0x101) bindKey("wheeldown", 0x102)
bindKey("backspace", 0x08) bindKey("tab", 0x09) bindKey("enter", 0x0D)
bindKey("shift", 0x10) bindKey("ctrl", 0x11) bindKey("alt", 0x12)
bindKey("esc", 0x1B) bindKey("space", 0x20, " ", " ")
bindKey("pageup", 0x21) bindKey("pagedown", 0x22) bindKey("end", 0x23) bindKey("home", 0x24)
bindKey("left", 0x25) bindKey("up", 0x26) bindKey("right", 0x27) bindKey("down", 0x28)
bindKey("insert", 0x2D) bindKey("delete", 0x2E)
do
    local shifted = { ")", "!", "@", "#", "$", "%", "^", "&", "*", "(" }
    for i = 0, 9 do bindKey(tostring(i), 0x30 + i, tostring(i), shifted[i + 1]) end
end
for i = 0, 25 do
    local ch = char(97 + i)
    bindKey(ch, 0x41 + i, ch, upper(ch))
end
for i = 1, 12 do bindKey("f" .. i, 0x6F + i) end
bindKey("lshift", 0xA0) bindKey("rshift", 0xA1) bindKey("lctrl", 0xA2) bindKey("rctrl", 0xA3)
bindKey("semicolon", 0xBA, ";", ":") bindKey("plus", 0xBB, "=", "+")
bindKey("comma", 0xBC, ",", "<") bindKey("minus", 0xBD, "-", "_")
bindKey("period", 0xBE, ".", ">") bindKey("slash", 0xBF, "/", "?")
bindKey("tilde", 0xC0, "`", "~") bindKey("lbracket", 0xDB, "[", "{")
bindKey("backslash", 0xDC, "\\", "|") bindKey("rbracket", 0xDD, "]", "}")
bindKey("quote", 0xDE, "'", "\"")
Named[0xA0], Named[0xA1] = "LShift", "RShift"
Named[0xA2], Named[0xA3] = "LCtrl", "RCtrl"
Named[0x20], Named[0x0D], Named[0x1B] = "Space", "Enter", "Esc"
Named[0x04], Named[0x05], Named[0x06] = "MMB", "MB4", "MB5"
Named[0x101], Named[0x102] = "WheelUp", "WheelDn"

local S = {
    open = true, show = 0, alive = true,
    x = 0, y = 0, w = 580, h = 460,
    mx = 0, my = 0, hasMouse = false,
    scale = 1, frames = 0, lastError = nil,
    layer = 0, floor = 0,
    tookClick = false, tookRight = false, locked = false,
    focus = nil, grab = nil, caret = nil, drag = nil, sizing = nil,
    slide = nil, bar = nil, pick = nil,
    tip = nil, tipAt = 0,
    windows = { }, notes = { }, popups = { }, binds = { },
    key = "rightshift", holder = nil,
}

local Mouse, lastTick, clipMirror = nil, nil, ""
local spin, wheel = 0, 0

pcall(function()
    local input = game:GetService("UserInputService")
    input.InputChanged:Connect(function(what)
        if what.UserInputType == Enum.UserInputType.MouseWheel then
            spin = what.Position.Z
        end
    end)
end)

local repeatKey, repeatAt = nil, 0

local function pollKeys()
    local live = focused() ~= false
    for _, name in ipairs(Order) do
        local k = Key[name]
        if name ~= "m1" and name ~= "m2" then
            local down
            if k.id > 0xFF then
                down = (k.id == 0x101 and wheel > 0) or (k.id == 0x102 and wheel < 0)
            else
                down = live and keyDown(k.id) == true or false
            end
            k.hit = down and not k.down
            k.up = (not down) and k.down
            k.down = down
        end
    end
end

local function screen()
    local w, h = 1920, 1080
    if Drawing and Drawing.Viewport then
        local ok = pcall(function() w, h = Drawing.Viewport.X, Drawing.Viewport.Y end)
        if not ok then w, h = 1920, 1080 end
    end
    if workspace and workspace.CurrentCamera then
        local ok, size = pcall(function() return workspace.CurrentCamera.ViewportSize end)
        if ok and size and size.X > 0 then w, h = size.X, size.Y end
    end
    return w, h
end

local function readInput()
    wheel, spin = spin, 0

    local t = now()
    dt = clamp(t - (lastTick or t), 1 / 1000, 1 / 15)
    lastTick = t

    for _, name in ipairs(Order) do
        local k = Key[name]
        k.hit, k.up = false, false
    end

    local live = focused() ~= false
    if not Mouse then
        pcall(function() Mouse = game:GetService("Players").LocalPlayer:GetMouse() end)
    end
    if Mouse then
        local ok = pcall(function() S.mx, S.my = Mouse.X, Mouse.Y end)
        S.hasMouse = ok
    end

    local down1 = live and m1Down() == true
    Key.m1.hit = down1 and not Key.m1.down
    Key.m1.up = (not down1) and Key.m1.down
    Key.m1.down = down1

    local down2 = live and m2Down() == true
    Key.m2.hit = down2 and not Key.m2.down
    Key.m2.up = (not down2) and Key.m2.down
    Key.m2.down = down2

    pollKeys()

    S.tookClick, S.tookRight = false, false
    S.layer, S.floor = 0, 0
end

local function inside(x, y, w, h)
    if not S.hasMouse then return false end
    return S.mx >= x and S.mx <= x + w and S.my >= y and S.my <= y + h
end

local function over(x, y, w, h)
    if S.locked or S.layer < S.floor then return false end
    return inside(x, y, w, h)
end

local function hit(x, y, w, h)
    if S.locked or S.tookClick or not Key.m1.hit or S.layer < S.floor then return false end
    if not inside(x, y, w, h) then return false end
    S.tookClick = true
    return true
end

local function rightHit(x, y, w, h)
    if S.locked or S.tookRight or not Key.m2.hit or S.layer < S.floor then return false end
    if not inside(x, y, w, h) then return false end
    S.tookRight = true
    return true
end

local function held(name)
    local k = Key[name]
    if not k or not k.down then return false end
    if k.hit then
        repeatKey, repeatAt = name, now() + 0.4
        return true
    end
    if repeatKey == name and now() >= repeatAt then
        repeatAt = now() + 0.035
        return true
    end
    return false
end

local function shiftHeld() return Key.shift.down or Key.lshift.down or Key.rshift.down end
local function ctrlHeld() return Key.ctrl.down or Key.lctrl.down or Key.rctrl.down end

local function scrollBox(box, x, y, w, h, content)
    box.scroll = box.scroll or 0
    box.reach = max(0, content - h)

    if over(x, y, w, h) then
        if Key.wheelup.hit then box.scroll = box.scroll - 48 end
        if Key.wheeldown.hit then box.scroll = box.scroll + 48 end
    end

    box.scroll = clamp(box.scroll, 0, box.reach)
    box.eased = glide(box.eased or box.scroll, box.scroll, 0.12)
    return box.eased
end

local function scrollGrab(box, x, y, w, h)
    if box.reach <= 0 then
        box.hold = nil
        return
    end

    if Key.m1.hit and not S.tookClick and inside(x, y, w, h) then
        box.hold = { S.my, box.scroll }
    end
    if not box.hold then return end

    if not Key.m1.down then
        box.hold = nil
        return
    end

    local moved = box.hold[1] - S.my
    if abs(moved) > 6 then
        S.tookClick = true
        box.scroll = clamp(box.hold[2] + moved, 0, box.reach)
    end
end

local Metric = {
    corner = 16,
    pad = 14,
    gap = 5,
    topbar = 52,
    sidebar = 200,
    tabHeight = 34,
    tabGap = 9,
    tabIcon = 18,
    buttonSize = 36,
    buttonGap = 9,
    buttonIcon = 16,
    elementCorner = 16,
    elementPad = 13,
    dragWidth = 160,
    fTitle = 16,
    fAuthor = 13,
    fTab = 15,
    fElement = 17,
    fDesc = 15,
    fLocked = 18,
}

local Z = {
    shadow = 1000000,
    body = 2000000,
    panel = 3000000,
    side = 3200000,
    search = 3900000,
    row = 4000000,
    chrome = 8000000,
    popup = 20000000,
    note = 40000000,
    tip = 45000000,
}

local Span = {
    tab = 64,
    row = 8000,
    kid = 300,
}

local function apart(a, b)
    return abs(a.R - b.R) + abs(a.G - b.G) + abs(a.B - b.B)
end

local function ground()
    local card = paint("ElementBackground")
    local back = paint("WindowBackground")
    if apart(back, card) < 0.16 then
        return mix(card, paint("Text"), 0.19)
    end
    return back
end

local function deck()
    local card = paint("ElementBackground")
    local back = ground()
    if apart(paint("PanelBackground"), card) < 0.16 then
        return mix(card, back, 0.55)
    end
    return mix(back, paint("PanelBackground"), 1 - veil("PanelBackground"))
end

local function anchor(win)
    return floor(win.x + 0.5), floor(win.y + 0.5)
end

local Art = {
    mousepointerclick = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAcbANAAEAAQEBAAAAAAAAAAAAAAAAAAMAwv9QAAMCAAAAAAAAAAAAAAAAAAAAAAQAdPqSAAUADrOuBQEBAAAAAAAAAAICBAUBNv/cBwEUw//aBwEBAAAAAAAAAAAAAAAAB9PUCQfL/9MgAAIAAAAAAAAAAHG5czYDAA4QAAnHyRoAAgAAAAAAAAAAALP////REQAADgAAAAAEAAAAAAAAAAAAAQ1SlNjUEwOL6bBMBgAAAwMBAAAAAAAAAAAAAAUDAA32////13khAAAABAEAAAAAAAEDBQAABAGz/cHF///3pUYCAAADAgAAAAABABTIxwJK/8YDRqX3///OcRsAAAAAAAEBDsT/zQMF2v9EAAAhfNz//+2fKQACAAIBtf/UGQMAeP+pAQUAAABLx/7/3QgBAAEBrtMeAAQAHfX2HwAAP4u27P//3AgBAAAAAAQAAgADAKb/fQA+/f//9cOKKAACAAAAAAACAAADAEH/3wCN/6pDGAAAAAAAAAAAAAEAAAAAAQTR/0a0/zoAAAEEAgAAAAAAAAAAAAAABABu/8vr9BYDAwAAAAAAAAAAAAAAAAAAAgAX8P//wwABAAAAAAAAAAAAAAAAAAAAAAMAoP//jQAEAAAAAAAAAAAAAAAAAAAAAAIBKNnZKQECAAAAAAAAAAAAAAAAAAAAAAAAAAUFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAQAAAAAAAAAA",
    lock = "AAAAAAAAAAIAAAAPDwAAAAIAAAAAAAAAAAAAAAAAAQAJb8Hq6sFuCQABAAAAAAAAAAAAAAACAB/M///4+P//zB4AAgAAAAAAAAAAAAECC8//zk4XF0/O/84KAgEAAAAAAAAAAAQAcP/OEAAAAAARzv9vAAQAAAAAAAAAAAEByP5KAAcBAQcAS/7IAQEAAAAAAAAAAQAM7vgVAQEAAAEBFfjtDAABAAAAAAAAAQEQ8/IQAQIBAQIBEPLzEAEBAAAAAAABBAAL8/MLAAAAAAAAC/PzCwAEAQAAAAAAAAgd8vMdDxAPDxAPHfPyHQcAAAAAAQEHjeHy///08/Pz8/Pz9P//8t+CAwEBAwCO///y7+/z8/Pz8/Pz8+/v8v//gQADAAjp+UMPEhAPDw8PDw8PDxASD0365ggAABD08wYAAAAAAAAAAAAAAAAAAAbz9BAAAA/08xEBAgEBAQEBAQEBAQECARHz8w8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/z8xEBAgEBAQEBAQEBAQECARHz9A8AABD08wYAAAAAAAAAAAAAAAAAAAbz9BAAAAjm+k0PEQ8PDw8PDw8PDw8RD0T56QgAAwCB///09PT09PT09PT09PT09P//jgADAQECgNvt7u/v7+/v7+/v7+/u7d2KBgIBAAAAAAgQEBAQEBAQEBAQEBAQEAkAAAAA",
    chevrondown = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAAABAQACAAAAAAAAAgABAQAAAAAAAAABAQbDyBYAAwAAAAADABbIwwYBAQAAAAABAQbL/8wXAAMAAAMAFsz/zAYBAQAAAAAAAQAVy//NFwACAgAWzP/MFgABAAAAAAAAAAIAFsv/zRcAABbM/80WAAIAAAAAAAAAAAADABbM/80RD83/zRYAAwAAAAAAAAAAAAAAAwAWzP/Hxv/NFgADAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAAADABbGxxYAAwAAAAAAAAAAAAAAAAAAAAAAAgABAQACAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    chevronup = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgABAQACAAAAAAAAAAAAAAAAAAAAAAADABbGxxcAAwAAAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAwAWzP/Hxv/NFwADAAAAAAAAAAAAAAADABbM/80RD8z/zRcAAwAAAAAAAAAAAAIAFsz/zRYAABbM/80XAAIAAAAAAAAAAQAWy//NFgACAgAWzP/NFgABAAAAAAABAQbL/8wXAAMAAAMAFsz/zAYBAQAAAAABAQbDyBYAAwAAAAADABbIwwYBAQAAAAAAAAABAQACAAAAAAAAAgABAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    chevronleft = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgABAQAAAAAAAAAAAAAAAAAAAAAAAAADABbIwwYBAQAAAAAAAAAAAAAAAAAAAAMAFsz/zAYBAQAAAAAAAAAAAAAAAAAAAwAWzP/MFgABAAAAAAAAAAAAAAAAAAADABbM/80WAAIAAAAAAAAAAAAAAAAAAAIAFsz/zRYAAwAAAAAAAAAAAAAAAAAAAQAWzv/OFgADAAAAAAAAAAAAAAAAAAABAQfJ/8UTAAIAAAAAAAAAAAAAAAAAAAABAQfI/8UTAAIAAAAAAAAAAAAAAAAAAAAAAQAWzf/OFwADAAAAAAAAAAAAAAAAAAAAAAIAFsz/zRcAAwAAAAAAAAAAAAAAAAAAAAADABbM/80XAAIAAAAAAAAAAAAAAAAAAAAAAwAWzP/NFgABAAAAAAAAAAAAAAAAAAAAAAMAFsz/zAYBAQAAAAAAAAAAAAAAAAAAAAADABbIwwYBAQAAAAAAAAAAAAAAAAAAAAAAAgABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    chevronright = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQACAAAAAAAAAAAAAAAAAAAAAAABAQbDyBYAAwAAAAAAAAAAAAAAAAAAAAABAQbL/8wXAAMAAAAAAAAAAAAAAAAAAAAAAQAVy//NFwADAAAAAAAAAAAAAAAAAAAAAAIAFsv/zRcAAwAAAAAAAAAAAAAAAAAAAAADABbM/80XAAIAAAAAAAAAAAAAAAAAAAAAAwAWzf/PFwABAAAAAAAAAAAAAAAAAAAAAAIAEsX/yQcBAQAAAAAAAAAAAAAAAAAAAAIAEsX/yQcBAQAAAAAAAAAAAAAAAAAAAwAWzf/PFgABAAAAAAAAAAAAAAAAAAADABbM/80WAAIAAAAAAAAAAAAAAAAAAAIAFsz/zRYAAwAAAAAAAAAAAAAAAAAAAQAWy//NFgADAAAAAAAAAAAAAAAAAAABAQbL/8wXAAMAAAAAAAAAAAAAAAAAAAABAQbDyBYAAwAAAAAAAAAAAAAAAAAAAAAAAAABAQACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    chevronsupdown = "AAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgABAQACAAAAAAAAAAAAAAAAAAAAAAADABbGxhcAAwAAAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAwAWzP/Hxv/NFwADAAAAAAAAAAAAAAACABbM/80RD8z/zRcAAgAAAAAAAAAAAAEAFsv/zRYAABbM/80WAAEAAAAAAAAAAQEGy//MFwACAgAWzP/MBgEBAAAAAAAAAQEGw8gWAAMAAAMAFsjDBgEBAAAAAAAAAAAAAQEAAgAAAAACAAEBAAAAAAAAAAAAAAAAAAABAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAQAAAAAAAAAAAAAAAAAAAQEAAgAAAAACAAEBAAAAAAAAAAAAAQEGw8gWAAMAAAMAFsjDBgEBAAAAAAAAAQEGy//MFwACAgAWzP/MBgEBAAAAAAAAAAEAFcv/zRcAABbM/8wWAAEAAAAAAAAAAAACABbL/80RD83/zRYAAgAAAAAAAAAAAAAAAwAWzP/Hxv/NFgADAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAAADABbGxxYAAwAAAAAAAAAAAAAAAAAAAAAAAgABAQACAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAA",
    search = "AAAAAAAAAAMEAAAAAAQDAAAAAAAAAAAAAAAAAAACAAAAAA0NAAAAAAIAAAAAAAAAAAAAAAMAAEqe0+/v055KAAADAAAAAAAAAAAAAwAtvf////b2////vi0AAwAAAAAAAAADAETv/911MRQUMXXd/+9EAAMAAAAAAAIAKvH/nxAAAAAAAAAQoP/xKQACAAAAAAICwv+hAAAEAgEBAgQAAKH/wQICAAAAAwBI/94MAQMAAAAAAAADAQze/0cAAwAABACg/nMABAAAAAAAAAAABAB0/p8ABAAAAALW/y4BAwAAAAAAAAAAAwEu/9UCAAEAAA3v9xQAAQAAAAAAAAAAAQAU9+4NAAEAAA3v9xQAAQAAAAAAAAAAAQAU9+4NAAEAAALW/y4BAwAAAAAAAAAAAwEu/9UCAAEABACg/nMABAAAAAAAAAAABAB0/p8ABAAAAwBH/98MAQMAAAAAAAADAQzg/0cAAwAAAAICwv+hAAAEAgEBAgQAAKT/vQQCAAAAAAIAKvH/oBEAAAAAAAARov/6PQAFAAAAAAADAETu/952MRQUMXbf////yBcAAwAAAAAAAwAsvP////b2////vEfK/80XAAEAAAAAAAMAAEmc0u7u0pxKAAAXzP/NFgACAAAAAAACAQAAAA0NAAAAAAQAFsz/zQYBAAAAAAAAAAMDAAAAAAMDAAADABbJxQYBAAAAAAAAAAAAAQEBAQAAAAAAAgABAQABAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAA",
    x = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAAABAQACAAAAAAAAAgABAQAAAAAAAAABAQbDyBYAAwAAAAADABbIwwYBAQAAAAABAQbL/8wXAAMAAAMAFsz/zAYBAQAAAAAAAQAVy//NFwACAgAWzP/MFgABAAAAAAAAAAIAFsv/zRcAABbM/80WAAIAAAAAAAAAAAADABbM/80RD83/zRYAAwAAAAAAAAAAAAAAAwAWzf/KyP/OFgADAAAAAAAAAAAAAAAAAAIAEsb//8cTAAIAAAAAAAAAAAAAAAAAAAIAEsb//8cTAAIAAAAAAAAAAAAAAAAAAwAWzf/JyP/OFwADAAAAAAAAAAAAAAADABbM/80RD8z/zRcAAwAAAAAAAAAAAAIAFsz/zRYAABbM/80XAAIAAAAAAAAAAQAWy//NFgACAgAWzP/NFgABAAAAAAABAQbL/8wXAAMAAAMAFsz/zAYBAQAAAAABAQbDyBYAAwAAAAADABbIwwYBAQAAAAAAAAABAQACAAAAAAAAAgABAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAEAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    minus = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAPDw8PDw8PDw8PDw8PDwAAAQAAAAEBB8Hz8fPz8/Pz8/Pz8/Px88EHAQEAAAEBB8Hz8fPz8/Pz8/Pz8/Px88EHAQEAAAABAAAPDw8PDw8PDw8PDw8PDwAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    maximize = "AAABAwAAAAAAAAAAAAAAAAAAAAADAQAAAAAAAAkPDw8AAAAAAAAAAA8PDwkAAAAAAQEHkeTy8fTDBwEBAQEHw/Tx8uSQBwEBAwCR///z8fPCBwEBAQEHwvPx8///kAADAArr+EIPEQ8AAAEAAAEAAA8RD0P46woAABD08gYAAAAAAAAAAAAAAAAAAAby9RAAAA/y8REBAgEBAAAAAAAAAQECARHx8g8AABD8+xAAAQAAAAAAAAAAAAABABD7/BAAAQXCwQUBAQAAAAAAAAAAAAABAQXBwgUBAAADAwAAAAAAAAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAABAQAAAAABAQAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAADAwAAAQXCwQUBAQAAAAAAAAAAAAABAQXBwgUBABD8+xAAAQAAAAAAAAAAAAABABD7/BAAAA/y8REBAgEBAAAAAAAAAQECARHx8g8AABD08gYAAAAAAAAAAAAAAAAAAAby9BAAAArr+EMPEQ8AAAEAAAEAAA8RD0P46wkAAwCQ///z8fPCBwEBAQEHwvPx8///jwADAQEHj+Ty8fTDBwEBAQEHw/Tx8uSPBwEBAAAAAAkPDw8AAAAAAAAAAA8PDwkAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    minimize = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMDAAAAAAAAAwMAAAAAAAAAAAAAAAEBBcLCBQEBAQEFwsIFAQEAAAAAAAAAAAEAEPv7EAABAQAQ+/sQAAEAAAAAAAABAQIBEfHxDwABAQAP8fERAQIBAQAAAAAAAAAABvL0EAABAQAQ9PIGAAAAAAAAAQAADxEPQ/jqCQABAQAK6vhDDxEPAAABAQfD8/Hz//+PAAMAAAMAj///8/HzwwcBAQfD8/Dx448HAQEAAAEBB4/j8fDzwwcBAQAADw8PCQAAAAAAAAAAAAAJDw8PAAABAAAAAAAAAAMBAAAAAAAAAQMAAAAAAAAAAAABAQEBAQAAAAAAAAAAAAABAQEBAQAAAAABAQEBAQAAAAAAAAAAAAABAQEBAQAAAAAAAAAAAAMBAAAAAAAAAQMAAAAAAAAAAQAADw8PCQAAAAAAAAAAAAAJDw8PAAABAQfD8/Dx448HAQEAAAEBB5Dj8fDzwwcBAQfD8/Hz//+PAAMAAAMAkP//8/HzwwcBAQAADxEPQ/jqCgABAQAK6vhCDxEPAAABAAAAAAAABvL0EAABAQAQ8/IGAAAAAAAAAAABAQIBEfHxDwABAQAP8fERAQIBAQAAAAAAAAEAEPv7EAABAQAQ+/sQAAEAAAAAAAAAAAEBBcLCBQEBAQEFwsIFAQEAAAAAAAAAAAAAAAMDAAAAAAAAAwMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    expand = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADEBAQDw8AAAEAAAEAAA8PEBAQAwAAAQfE8O3z8/TCBwEBAQEHwvTz8+3wxAcBABH4///17fXABwEBAQEHwPXt9f//+BEAABDu///UJgwBAAEAAAEAAQwl0///7hAAAA/z8tf/yRMAAwAAAAADABLI/9jy8w8AAA/06yDJ/84XAAIAAAIAFs3/yiHr9A8AABD8/gcTzP/NFgABAQAWy//OFAf+/BAAAQXBwAkAF8z/zAYBAQbL/8wXAAnAwQUBAAACAgADABbIwwYBAQbDyBYAAwACAgAAAAAAAAAAAgABAQAAAAABAQACAAAAAAAAAAABAQAAAAEAAAAAAAAAAAEAAAABAQAAAAABAQAAAAEAAAAAAAAAAAEAAAABAQAAAAAAAAAAAgABAQAAAAABAQACAAAAAAAAAAACAgADABbIwwYBAQbDyBYAAwACAgAAAQXBwAkAF8z/zAYBAQbL/8wXAAnAwQUBABD8/gcTzf/MFgABAQAVy//OFAf+/BAAAA/06yDJ/84XAAIAAAIAFs3/yiHr9A8AAA/z8tj/yRIAAwAAAAADABHI/9ny8w8AABDu///UJgwBAAEAAAEAAQwl0///7hAAABH4///17fXABwEBAQEHwPXt9f//+BEAAQfE8O3z8/TCBwEBAQEHwvTz8+3wxAcBAAADEBAQDw8AAAEAAAEAAA8PEBAQAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    move = "AAAAAAAAAAAAAgAFBQACAAAAAAAAAAAAAAAAAAAAAAADABbMzRcAAwAAAAAAAAAAAAAAAAAAAAIAFs7//88XAAIAAAAAAAAAAAAAAAAAAQAWzf/9/f/NFgABAAAAAAAAAAAAAAABAQbM/9b09Nb/zAYBAQAAAAAAAAAAAAEBAQbExSHu7iHFxAYBAQEAAAAAAAAAAQAAAQACAQn09AkBAgABAAABAAAAAAACAAEBAAEAABHz8xEAAAEAAQEAAgAAAAMAFsnEBwIDAhDz8xACAwIHxMkWAAMAAgAXzv/HAgAAAAvz8wsAAAACxv/OFwACABbO/9MmDxEQDx309B0PEBEPJdL/zxcACc//+/Tw8/Pz8/T+/vTz8/Pz8PT7/88JCc//+/Tw8/Pz8/T+/vTz8/Pz8PT7/88JABbO/9MmDxEQDx309B0PEBEPJdL/zxcAAgAWzv/HAgAAAAvz8wsAAAACx//OFwACAAMAFsnEBwIDAhDz8xACAwIHxMkWAAMAAAACAAEBAAEAABHz8xEAAAEAAQEAAgAAAAAAAQAAAQACAQn09AkBAgABAAABAAAAAAAAAAEBAQbExSHu7iHFxAYBAQEAAAAAAAAAAAABAQbM/9b09Nb/zAYBAQAAAAAAAAAAAAAAAQAVzf/9/f/NFgABAAAAAAAAAAAAAAAAAAIAFs7//88XAAIAAAAAAAAAAAAAAAAAAAADABbMzRcAAwAAAAAAAAAAAAAAAAAAAAAAAgAFBQACAAAAAAAAAAAA",
    copy = "AAAACRAQEBAQEBAQEBAJAAAAAAAAAAAAAgaK3e3u7+/v7+/v7u3diwYCAQAAAAAAAIv///T09PT09PT09PT//4sAAwAAAAAACeT5RA8RDw8PDw8PEg9F//AJAAEAAAAAEe/0BgAAAAAAAAAAAAAAwcIHAgIBAAAAEO/0EQECAQIEAAAAAAAAAAAAAAAAAwAAEO/0DwABAAAACA8PDw8QDg4QDw8HAAAAEO/0DwACAQeN4fHy8/Pz8/Pz8vHfgwMCEO/0DwAEAI3///Pz8/Pz8/Pz8/P//34AEO/0DwAACej5Qw8RDw8PDw8PEQ9N+uEJEO/0DwAAEPPzBgAAAAAAAAAAAAAG9O8REO/0DwAAD/PzEQECAQEBAQEBAgER9O8QEO/0EQEAD/PzDwABAAAAAAAAAQAP9O8QEe/0BgAAD/PzDwABAAAAAAAAAQAP9O8QCeT5RQAAEPPzDwABAAAAAAAAAQAP9O8QAIr//8EEDvTzDwABAAAAAAAAAQAP9O8QAgaK5MIEDvTzDwABAAAAAAAAAQAP9O8QAAAACgEAEPPzDwABAAAAAAAAAQAP9O8QAAEDAAAAD/PzEQECAQEBAQEBAgER9O8QAAAAAQIAEPPzBgAAAAAAAAAAAAAG9O8RAAAAAAEACOX6TQ8RDw8PDw8PEQ9E+eQJAAAAAAADAIH///T09PT09PT09PT//4sAAAAAAAAAAQKA2+3u7+/v7+/v7u3digYCAAAAAAAAAAAACBAQEBAQEBAQEBAJAAAA",
    check = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAEBAAAAAAAAAAAAAAAAAAAAAAAAAAMAFsjDBwEBAAAAAAAAAAAAAAAAAAAAAwAWzP/MBgEBAAAAAAAAAAAAAAAAAAADABbM/8wWAAEAAAAAAQEAAAAAAAAAAAMAFsz/zRYAAgAAAAAAAAABAAAAAAAAAwAWzP/NFgADAAAAAAAAAQEAAgAAAAADABbM/80WAAMAAAAAAQEHw8gWAAMAAAMAF83/zRYAAwAAAAAAAQEGy//MFwACAgAWzf/NFwADAAAAAAAAAAEAFcv/zRcAABbM/80XAAMAAAAAAAAAAAACABbL/80RD83/zRYAAwAAAAAAAAAAAAAAAwAWzP/Hxv/NFgADAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAAADABbGxhYAAwAAAAAAAAAAAAAAAAAAAAAAAgABAQACAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    key = "AAAAAAAAAAAAAAAAAAAAAAAAAgACAQABAAAAAAAAAAAAAAAAAAAAAAADABbFwQYBAAAAAAAAAAAAAAAAAAAAAAMAGM//zwYCAAAAAAAAAAAAAAAAAAAAAwAW0f/GEgEBAAAAAAAAAAAAAAAAAAADABbN///HEwABAAAAAAAAAAAAAAAAAAMAFs7/yMv/0RQBAAAAAAAAAQEBAAAAAwAaz//JEwzE/38AAAAAAAMDAAAAAwMDABbP//QvABbD/34AAAAAAgAABg8GAAAAFs3/+v/IOcv/zxQBAAAAAEWm3fHdpUAYzv/LOc7//v/OFwACAQIDlv////P////l/84ZABi787sXAAIAAwCX//N4KBIoePX/4xUABAAAGwAAAgAAAEH/7jwAAAAAAD7w9j0CAwEAAAABAAAAAKf/eAAHAgECBwB5/6oAAwAAAgAAAAAAB9z9IwICAAAAAgIj/eAGAAEAAAAAAAAAEO32EAABAAAAAQAR9fEPAAEAAAAAAAAAB9z9IwICAAAAAgIj/d8GAAEAAAAAAAAAAKb+eQAHAgECBwB5/6kAAwAAAAAAAAAAAEH/7zwAAAAAADzv/0EAAwAAAAAAAAAAAwCX//N5KBIoefT/lQADAAAAAAAAAAAAAQIDlf////P///+VAwIBAAAAAAAAAAAAAAABAEWl3fLdpUUAAQAAAAAAAAAAAAAAAAAAAgAABg8GAAACAAAAAAAAAAAAAAAAAAAAAAMDAAAAAwMAAAAAAAAAAAAAAAAA",
    keyboard = "AAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAEDAAAAAAAAAAAAAAAAAAAAAAAAAwAAAAAACA8PDw8PDw8PDw8PDw8PDw8HAAAAAQeO4fHy8/Pz8/Pz8/Pz8/Pz8vHfgwMCAIv///P08/Pz8/Pz8/Pz8/Pz9PP//34ACeT5QxAQDhAQDg4QEA4OEBAOEBBN+uEJEe/0BwAAAAAAAAAAAAAAAAAAAAAH9O8REO/1EATLzQYFy80GBcvNBgXLzQUQ9e8QEO/1DgPKzAUEycwFBMnMBQTJzAQO9e8QEO/0EAABAQAAAQEAAAEBAAABAQAQ9O8QEO/0DwABAAEBAAABAQAAAQEAAQAP9O8QEO/0DwACBsnMBQTJzAUEycsHAgAP9O8QEO/0DwABBsrNBgXLzQYFy8wHAQAP9O8QEO/0DwACAAAAAAAAAAAAAAAAAgAP9O8QEO/0DwAAAA4OEBAODhAQDg4AAAAP9O8QEO/0EAAHwfPx8/Pz8/Pz8fPBBwAQ9O8QEO/0EgEIwvTy9PT09PT08vTCCAES9O8QEe/0BgAAAAsLCwsLCwsLCwsAAAAG9O8RCeH6TQ8SDwsLCwsLCwsLCwsPEg9E+eQJAH7///Pz8/T09PT09PT09PTz8/P//4oAAgKC3/Hy8/Pz8/Pz8/Pz8/Pz8vHhjQYCAAAABw8PDw8PDw8PDw8PDw8PDw8IAAAAAAADAAAAAAAAAAAAAAAAAAAAAAAAAwEAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAA",
    type = "AAAAAAEBAQEBAQEBAQEBAQEBAQEAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAcQDw8PDxARERAPDw8PEAYAAAAAAAIAUt3x8vPz8/Pv7/Pz8/Py8d1SAAIAAQEI5v/y8/Pz8/T///Tz8/Pz8v/lCAEBAQAQ8fAdDxAQDx3z8x0PEBAPHfDxEAABAQAQ+/sMAAAAAAvz8wsAAAAADPv7EAABAQEFwcIGAgICARDz8xABAgICBsLBBQEBAAAAAwMAAAABAA/z8w8AAQAAAAMDAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAQEAAAABAA/z8w8AAQAAAAEBAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAACARDz8xABAgAAAAAAAAAAAAAAAAAAAAAAAAvz8wsAAAAAAAAAAAAAAAAAAAAAAQAADx3z8x0PAAABAAAAAAAAAAAAAAABAQfB8/L///LzwQcBAQAAAAAAAAAAAAABAQfB8/Hv7/HzwQcBAQAAAAAAAAAAAAAAAQAADw8REQ8PAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQAAAAAAAAAA",
    textcursorinput = "AAAAAAABAQEAAAEBAQAAAAAAAAAAAAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAAAAQAADwkAAAkPAAABAAAAAAAAAAAAAAABAQfB8+OLjOPzwQcBAQAAAAAAAAAAAAABAgjD8//////zwwgCAgEBAQEBAAAAAAEDAAABEET390MQAQAAAAAAAAAAAwEAAAAACRAAAAfy8gcAABAPDw8PDw8JAAAAAQeR4/PDBhD09BAGw/Px8/Pz8vHjkAcBAI7///PDBA709A4Ew/Px8/Pz8/P//40ACub5Qg8CABDz8xAAAA8PDw8PEQ9D+eYKEe/0BgABAA/z8w8AAAAAAAAAAAAG9PAREO/0EQEDAA/z8w8AAgEBAQEBAgER9O4QEO/0EQEDAA/z8w8AAgEBAQEBAgER9O4QEe/0BgABAA/z8w8AAAAAAAAAAAAG9PARCub5Qw8CABDz8xAAAA8PDw8PEQ9D+eYKAI3///PDBA709A4Ew/Px8/Pz8/P//4wAAQeQ4vPDBhD09BAGw/Px8/Pz8vHjjwcBAAAACRAAAAfy8gcAABAPDw8PDw8JAAAAAAEDAAABEET390MQAQAAAAAAAAAAAwEAAAABAgjD8//////zwwgCAgEBAQEBAAAAAAABAQfB8+KLi+LzwQcBAQAAAAAAAAAAAAAAAQAADwkAAAkPAAABAAAAAAAAAAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAAAAAABAQEAAAEBAQAAAAAAAAAAAAAA",
    toggleright = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQAAAAAAAAAAAAAAAAACBAAAAAAAAAAAAAAEAgAAAAAAAAAAAQIAAAANDw8PDw8PDQAAAAMAAAAAAAABAAA3k8/u8/Pz8/Pz7MmBHwACAAAAAAEAB5X////28/Pz8/P0+f//7mkAAwAAAQIIuv/1iTcVEBAPERINFEWp//+EAAMAAwCW/90zAAAAAAAAAAAGBQAAYPj/XwADADL+8S8ABgIBAQMALKnn56stAGP/7RcBAJL/igAGAAAAAgEp7P/9/f/tLwC0/3cAAs7/MwIDAAAAAgCs/6kfH6n/rwBH/8QBDur4FAABAAABAArp+RkAABn56gUU+ugNDej5FgABAAABAArp+RkAABn56QUS+eoOAcT/RAEDAAAAAwCs/6kgIKn/rgE2/84CAHj/sgAFAQAAAgEp7P/9/f/sLgCN/5EAARjt/2IABQMBAQMAK6nn56ouADHx/jEAAwBg//hfAAAAAAAAAAAGBQAANd3/lQADAAMAhP//p0MYEBAPERINEzqM9v+5CAIBAAADAGju///48/Pz8/P0+P///5QHAAEAAAAAAwAfgMns8/Pz8/Pz7c6SNgAAAQAAAAAAAAMAAAANDw8PDw8PDQAAAAIBAAAAAAAAAAACBAAAAAAAAAAAAAAEAgAAAAAAAAAAAAAAAAABAQEBAQEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    slidershorizontal = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQAAAAICAAEBAQEBAQAAAAAAAAAAAAAAAAABBcLBAQAAAAAAAAAAAQAADw8PDw8PDwAAEfv8Hg8QDw8PAAABAQbC8/Hz8/Px88IED+788vPz8/HzwgYBAQbC8/Hz8/Px88IED+788vPz8/HzwgYBAQAADw8PDxAQDwAAEfv8Hg8QDw8PAAABAAAAAAAAAAAAAAABBcHAAQAAAAAAAAAAAAABAgIDAQQEAAEBAAQEAQMCAgICAQAAAAAAAAAAAcDBBQEAAAAAAAAAAAAAAAAAAQAADxAPHvz7EQAADxAQDw8PDw8PAAABAQbC8/Hz8vzuDwTC8/Hz8/Pz8/HzwgYBAQbC8/Hz8vzuDwTC8/Hz8/Pz8/HzwgYBAQAADxAPHvz7EQAADw8PEBAPDw8PAAABAAAAAAAAAcDBBQEAAAAAAAAAAAAAAAAAAAABAgIDAQQEAAECAgEABAQBAwICAQAAAAAAAAAAAAAAAAAAAAEFwcABAAAAAAAAAQAADw8PDxAQDw8PAAAR+/weDxAPAAABAQbC8/Hz8/Pz8/HzwgQP7vzy8/HzwgYBAQbC8/Hz8/Pz8/HzwgQP7vzy8/HzwgYBAQAADw8PDw8PDw8PAAAR+/weDxAPAAABAAAAAAAAAAAAAAAAAAEFwsEBAAAAAAAAAAABAQEBAQEBAQEBAAAAAgIAAQEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    trash2 = "AAAAAAAAAAAAChAQEBAKAAAAAAAAAAAAAAAAAAABAQeO3+3u7u3fjQcBAQAAAAAAAAABAQEEAJH///X19fX//5AABAEBAQAAAAAAAAAABur4PgsNDQs/+OkGAAAAAAAAAQAADxEQHvPyFQsMDAsV8vMeEBEPAAABAQbC8+3v8///9vT09PT2///z7+3zwgYBAQfC9P//9O/v8/Pz8/Pz7+/0///0wgcBAQAAHfLzHRAREBAPDxAQERAd8/IdAAABAAEAC/PzCwAAAAAAAAAAAAAL8/MLAAEAAAEBEPPzEAEBBAMAAAMEAQEQ8/MQAQEAAAEAD/PzEAAGwcEEBMHBBgAQ8/MPAAEAAAEAD/PzEQAS/P0MDP38EgAR8/MPAAEAAAEAD/PzEQAR8fILC/LxEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8fILC/LxEQAR8/MPAAEAAAEAD/PzEQAS/P0MDP38EgAR8/MPAAEAAAEAD/PzEAAGwcEEBMHBBgAQ8/MPAAEAAAEAD/PzEQEBBAMAAAMEAQER8/MPAAEAAAEAEPTyBgAAAAAAAAAAAAAG8vQQAAEAAAEACur4Qw8REBAPDxAQEQ9D+OoJAAEAAAADAJD///T09PT09PT09PT//5AAAwAAAAABAQeM3+3u7+/v7+/v7u3fjAcBAQAAAAAAAAAAChAQEBAQEBAQEBAKAAAAAAAA",
    trianglealert = "AAAAAAAAAAAAAQMAAAMBAAAAAAAAAAAAAAAAAAAAAAAAAAAMDAAAAAAAAAAAAAAAAAAAAAAAAAECCJTp6ZEHAgEAAAAAAAAAAAAAAAAAAAMAl//+//+SAAMAAAAAAAAAAAAAAAAAAwAz+/MzOPT6LwADAAAAAAAAAAAAAAAAAwC8/4gAAI3/uAADAAAAAAAAAAAAAAADAFL/5BECAhTn/04AAwAAAAAAAAAAAAECCdj/ZAAGBgBp/9UIAgEAAAAAAAAAAAMAdv/MBQjBwQcGz/9xAAQAAAAAAAAAAgEa7f5DABP7+xMAR//rGAECAAAAAAAAAwCa/6wAAA/x8Q8BALD/lgADAAAAAAADADP69SYBAA/x8Q8AASn2+TAAAwAAAAADALz/iAAFABD8/BAABACN/7gAAwAAAAMAUv/kEQICAQXBwQUBAgIT5/9OAAMAAQIJ2P9kAAMAAAABAQAAAAQAaP/VCAIBAwB2/8sEAgEAAAAAAAAAAAECBc//cgADABru/kIAAwABAQbJywYBAQADAEb/7BgBAJT/rQAEAQECAgfKzAgCAgEBBACy/5AADun5HwAAAAAAAAAAAAAAAAAAAAAk++QLDur2PRARDw8PDxAODhAPDw8PERBB+eYLAJH///Pz8/Pz8/Pz8/Pz8/Pz8/P//4sAAQiT5PLz9PT09PT09PT09PT08/LjkAcBAAAACQ8PDw8PDw8PDw8PDw8PDw8JAAAAAAEDAAAAAAAAAAAAAAAAAAAAAAAAAwEA",
    user = "AAAAAAAAAAAAAwIAAAIDAAAAAAAAAAAAAAAAAAAAAAACAAAMDAAAAgAAAAAAAAAAAAAAAAAAAAIAU7ns67lSAAIAAAAAAAAAAAAAAAAAAgCI///5+f//hAACAAAAAAAAAAAAAAADAFD/9WwaGm32/00AAwAAAAAAAAAAAAACAL7+bAAAAABu/r4AAgAAAAAAAAAAAAEADOz4FAMDAwMV+esMAAEAAAAAAAAAAAEADOz4FAMDAwMV+esMAAEAAAAAAAAAAAACAL7+bQAAAABu/r4AAgAAAAAAAAAAAAADAFD/9m8aGm72/08AAwAAAAAAAAAAAAAAAgCE///5+v//hAACAAAAAAAAAAAAAAAAAAIAULnr67lSAAIAAAAAAAAAAAAAAAAAAwIAAAAICAAAAAIDAAAAAAAAAAAAAAACAAANEhEMDBESDQAAAgAAAAAAAAAAAAIAU7nq8vP09PPy6rlTAAIAAAAAAAAAAgCJ///68/Pz8/Pz+v//iQACAAAAAAADAFH/9WwbERAPDxARG2z1/1EAAwAAAAACAL/+awAAAAAAAAAAAABr/r8AAgAAAAEAC+z5FAMDAQEBAQEBAwMV+ewLAAEAAAEAD/HwDwABAAAAAAAAAQAP8PEPAAEAAAEAEPv8EAABAAAAAAAAAQAQ/PsQAAEAAAEBBcLCBQEBAAAAAAAAAQEFwsIFAQEAAAAAAAMDAAAAAAAAAAAAAAAAAwMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    eyeoff = "AAICAAIAAAAAAAAAAAAAAAAAAAAAAAAAB73FFgADAAAAAAEBAQEAAAAAAAAAAAAAB8j/zRcAAwAAAQAAAAACBAIAAAAAAAAAABXM/80XAAMAAAAPDgUAAAADAgAAAAAAAgAWzP/PFwACJNTx8NuzcSQAAAMAAAAAAAMAGL//zxsAL/L08/////ibHwADAAAAAAAGAGP7/9AXABMUEShVovf/6FEAAwAAAAMAY/z/6f/OGAAAAAAAACir//9hAAMAAwBE/f94Hc3/zxkABAIDAwAAfP/8QwADARDh/4MAABbI/88XAAMAAAIDAIT/4A8BAHz/wQAEBQCo///OFwADAAABBADC/3wACt/8NgEEAA3v89b/zhcAAwAAAwE3/N4KCt78NwEEAAzt8im8/88XAAMAAwA4/N4JAHz/wgAEBACv/50r0//PFwAEAgTB/3sAAQ/g/4QABgMs7f/59v//zhcAAWn/3w8BAwBD/P98AAAAMKzq7arN/88XAETCPgADAAMAYf//rCkAAAAHCAAFvP/PGgAAAAEAAAAEAFDo//iiVysPDyxRsP//zxgABAAAAAAAAwAemvj////29v////Lf/84XAAMAAAAAAAMAACRxstrw8NqyciAXzP/NFwACAAAAAAABAwAAAAQODgQAAAAAFsv/zRYAAAAAAAAAAAIEAgAAAAACBAEDABbN/8kHAAAAAAAAAAAAAAEBAQEAAAAAAwAWxbwHAAAAAAAAAAAAAAAAAAAAAAAAAAIAAgIA",
    eye = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAQEAAAAAAAAAAAAAAAAAAAAAAAIEAgAAAAACBAIAAAAAAAAAAAAAAAACAwAAAAUODgUAAAADAgAAAAAAAAAAAAMAACRxs9vx8duzcSQAAAMAAAAAAAAAAwAfm/j////19f////iaHwADAAAAAAADAFHo//eiVyoPDypXovj/6FAABAAAAAMAYf//qygAAAAGBgAAACir//9hAAMAAwBE/f98AAAALqrn56ouAAAAfP/8QwADARDh/4MABgMp7P/9/f/sKgMGAIT/4A8BAH3/wQAEBACs/6kfH6n/rAAEBADC/3sACt/8NgEEAArp+RkAABn56AoABAE3/N4JCt78NwEEAArp+RkAABn56AoABAE4/N4JAHz/wgAEBACs/6kgIKn/rAAEBADD/3sAARDg/4QABgMp7P/9/f/sKQMGAIX/4A8BAwBD/P98AAAALarn56otAAAAff/8QgADAAMAYf//rCkAAAAFBQAAACms//9gAAMAAAAEAFDn//ijVysQECtXo/j/51AABAAAAAAAAwAemvj////29v////iaHgADAAAAAAAAAAMAACRwstvw8NqycCMAAAMAAAAAAAAAAAABAwAAAAQODgQAAAADAQAAAAAAAAAAAAAAAAIEAgAAAAACBAIAAAAAAAAAAAAAAAAAAAAAAAEBAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    terminal = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEAAgAAAAAAAAAAAAAAAAAAAAAAAQEHw8gWAAMAAAAAAAAAAAAAAAAAAAAAAQEGy//MFwADAAAAAAAAAAAAAAAAAAAAAAEAFcv/zRcAAwAAAAAAAAAAAAAAAAAAAAACABbL/80XAAMAAAAAAAAAAAAAAAAAAAAAAwAWzP/NFwACAAAAAAAAAAAAAAAAAAAAAAMAFs3/zxcAAQAAAAAAAAAAAAAAAAAAAAACABLF/8kHAQEAAAAAAAAAAAAAAAAAAAACABLF/8kHAQEAAAAAAAAAAAAAAAAAAAMAFs3/zxYAAQAAAAAAAAAAAAAAAAAAAwAWzP/NFgACAAAAAAAAAAAAAAAAAAACABbM/80WAAMAAAAAAAAAAAAAAAAAAAEAFsv/zRYAAwABAQEBAQEBAQEBAAAAAQEGy//MFwADAAAAAAAAAAAAAAAAAAAAAQEHw8gWAAMAAQAADw8PDw8PDw8AAAAAAAAAAQEAAgABAQfB8/Hz8/Pz8fPBBwEBAAAAAAABAAABAQfB8/Hz8/Pz8fPBBwEBAAAAAQEAAAAAAQAADw8PDw8PDw8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    palette = "AAAAAAABBAAAAAQPEAYAAAADAgAAAAAAAAAAAAIAABpnq9bs7dmycycAAAMAAAAAAAAAAgAKg+7////19f////2iJAADAAAAAAACACXM//+vWikSEyRUnvP/7FUAAwAAAAIAJeL/zT4AAAAAAAMAACOk//9eAAMAAQIL0P+2DAAPAAQCguaEBAAAev/5NgADAwCD/88MAIXkggEM9f/1CgIGAI//ygQCABjx+zkADvX/9QwBgeOAAQQABAja/0oAAGn/sQAGAoDjgAECAAwAAAAMAABw/p8AAK7+VgEGAAAMAAAAAgAEAYHkgwEv/9IDBdj/JwAADAAAAgAAAAIACvX/9gYR+OsPD+z2FACC5IECAgAAAAACAYDjggIX+ekND+z3Dwb2//UKAAEAAAABAQANAABM/sQBBdj/KACC44ABAgAAAQIAAAAAABHP/20AAK7+VwEADAAAAAAAAAANEBAaT8//zwoCAGn/sQAFAAIAAAEBFajr8vP4///KHgACABjx+zgABQAAAAIAqv/88/Psw28JAAEABACC/9AMAAQAAQAN8fcsDxENAAAAAgAAAQIKz/+2DQADBAMH3P5WAAAAAQQBAAAAAAIAJOL/zT0AAAAAVv7cBwICAAAAAAAAAAACACXM//+vWysQLffwDQABAAAAAAAAAAAAAgAKgu7////0/f+pAAIAAAAAAAAAAAAAAAIAABpmqtXs56QUAQEAAAAAAAAAAAAAAAABBAAAAAQQDgAAAAAAAAAAAAAA",
    settings = "AAAAAAAAAAABAAAKCgAAAQAAAAAAAAAAAAAAAAAAAAEAEJTf35QPAAEAAAAAAAAAAAAAAAECAQIFu/////+6BQIBAgEAAAAAAAAAAwAAAAE0/94sLN//MwEAAAADAAAAAAAAABcsDwB//JoAAJv8fwAPLBcAAAAAAQIDi/D/4b///0YDA0f//7/i/++KAwIABAB4//vY///wdAAAAAB18P//2Pv/eAADAQTb+00ELkAcAAALCwAAHEAtBE372wQBAAjm+xoAAAAALajm5qgtAAAAABr75ggAAwCp/8MVBAQr7P/9/f/sKwQEFsT/qAADAgEg2P+gAACs/6kfH6n/rAAAof/YHwECAAIAI/fuCgbq+RkAABn56QYK7/YiAAIAAAIAJPfuCgbq+RkAABn56QYK7/YjAAIAAgEh2f+fAACs/6kgIKn/qwAAoP/ZIAECAwCq/8MVBAQr7P/9/f/sKwQEFcT/qQADAAjn+xkAAAAALKjl5agsAAAAABn75ggAAQXc+00FLkEdAAAKCgAAHUEuBU772wQBAwB5//vZ///xdQAAAAB18f//2fz/eAADAAIDiu//4b/+/0cDA0j//r/h/++JAwIAAAAAABYrDgB+/JsAAJv8fgAOKxYAAAAAAAAAAwAAAAE0/98tLd//MwEAAAADAAAAAAAAAAECAQIFuv////+5BAIBAgEAAAAAAAAAAAAAAAEAD5Pe3pMPAAEAAAAAAAAAAAAAAAAAAAABAAAJCQAAAQAAAAAAAAAA",
    info = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////39////+2BCQACAAAAAAACACPK//+wWyoUFCtbsP//yiQAAgAAAAIAIuD/zj4AAAAAAAAAAD3O/+EjAAIAAQMKzf+4DgADAwIAAAIDAwAOuP/NCgMBAwCB/9AMAAQAAAABAQAAAAQADNH/gAADABfw+zkABAABAQbJywYBAQAEADn78BcAAGf/sgADAAABAQbJywYBAQAAAwCz/2cAAKz+WAEEAAAAAAAAAAAAAAAABAFZ/qwABNb/KAACAAAAAAABAQAAAAAAAgAo/9YEDur4EwABAAABAQXBwQUBAQAAAQAU+OoODur4EwABAAABABD8/BAAAQAAAQAU+OoOBNb/KAACAAABAA/x8Q8AAQAAAgAo/9YEAKz+WAEEAAABAA/x8Q8AAQAABAFZ/qwAAGf/swADAAABABD8/BAAAQAAAwCz/2YAABfw+zoABAABAQXBwQUBAQAEADr78BcAAwCA/9ENAAQAAAACAgAAAAQADdH/gAADAQMKzf+4DwADAwIAAAIDAwAOuP/NCQMBAAIAIuD/zz4AAAAAAAAAAD7O/+AiAAIAAAACACPK//+xXCsUFCtcsP//ySMAAgAAAAAAAgAJgOz////39////+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
    circlealert = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////39////+2BCQACAAAAAAACACPK//+wWyoUFCtbsP//yiQAAgAAAAIAIuD/zj4AAAAAAAAAAD3O/+EjAAIAAQMKzf+4DgADAwIAAAIDAwAOuP/NCgMBAwCB/9AMAAQAAAACAgAAAAQADNH/gAADABfw+zkABAABAQXBwQUBAQAEADn78BcAAGf/sgADAAABABD8/BAAAQAAAwCz/2cAAKz+WAEEAAABAA/x8Q8AAQAABAFZ/qwABNb/KAACAAABAA/x8Q8AAQAAAgAo/9YEDur4EwABAAABABD8/BAAAQAAAQAU+OoODur4EwABAAABAQXBwQUBAQAAAQAU+OoOBNb/KAACAAAAAAABAQAAAAAAAgAo/9YEAKz+WAEEAAAAAAAAAAAAAAAABAFZ/qwAAGf/swADAAABAQbJywYBAQAAAwCz/2YAABfw+zoABAABAQbJywYBAQAEADr78BcAAwCA/9ENAAQAAAABAQAAAAQADdH/gAADAQMKzf+4DwADAwIAAAIDAwAOuP/NCQMBAAIAIuD/zz4AAAAAAAAAAD7O/+AiAAIAAAACACPK//+xXCsUFCtcsP//ySMAAgAAAAAAAgAJgOz////39////+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
    circlecheck = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////39////+2BCQACAAAAAAACACPK//+wWyoUFCtbsP//yiQAAgAAAAIAIuD/zj4AAAAAAAAAAD3O/+EjAAIAAQMKzf+4DgADBAIBAQIEAwAOuP/NCgMBAwCB/9AMAAQAAAAAAAABAQQADNH/gAADABfw+zkABAAAAAAAAAEAAAAEADn78BcAAGf/sgADAAABAQAAAgABAQAAAwCz/2cAAKz+WAEEAAAAAAECABbIwwYBBAFZ/qwABNb/KAACAAABAQAAFsz/zAYBAwAo/9YEDur4EwACAQbDyBAQzf/MFgABAQAU+OoODur4EwACAQbL/8bH/80XAAIAAQAU+OoOBNb/KAACAQAWzf//zhcAAwAAAgAo/9YEAKz+WAEEAAIAFsbHFgADAAAABAFZ/qwAAGf/swADAAACAAEBAAIAAAAAAwCz/2YAABfw+zoABAAAAQAAAQAAAAAEADr78BcAAwCA/9ENAAQAAAEBAAAAAAQADdH/gAADAQMKzf+4DwADBAIBAQIEAwAOuP/NCQMBAAIAIuD/zz4AAAAAAAAAAD7O/+AiAAIAAAACACPK//+xXCsUFCtcsP//ySMAAgAAAAAAAgAJgOz////39////+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
    circlex = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////39////+2BCQACAAAAAAACACPK//+wWyoUFCtbsP//yiQAAgAAAAIAIuD/zj4AAAAAAAAAAD3O/+EjAAIAAQMKzf+4DgAEBAIBAQIEBAAOuP/NCgMBAwCB/9AMAAQAAAEAAAEAAAQADNH/gAADABfw+zkABAABAQABAQABAQAEADn78BcAAGf/sgAEAQbDyBYAABbIwwYBBACz/2cAAKz+WAEFAQbL/80QEM3/zAYBBQFZ/qwABNb/KAACAQAVzf/JyP/OFgABAgAo/9YEDur4EwABAAEAEsb//8cTAAEAAQAU+OoODur4EwABAAEAEsb//8cTAAEAAQAU+OoOBNb/KAACAQAWzf/JyP/OFgABAgAo/9YEAKz+WAEFAQbL/80QEM3/zAYBBQFZ/qwAAGf/swAEAQbDyBYAABbIwwYBBACz/2YAABfw+zoABAABAQABAQABAQAEADr78BcAAwCA/9ENAAQAAAEAAAEAAAQADdH/gAADAQMKzf+4DwAEBAIBAQIEBAAOuP/NCQMBAAIAIuD/zz4AAAAAAAAAAD7O/+AiAAIAAAACACPK//+xXCsUFCtcsP//ySMAAgAAAAAAAgAJgOz////39////+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
    plus = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAgAAAAAAAAAAAAAAAAAAAAAAAAABAQXBwQUBAQAAAAAAAAAAAAAAAAAAAAABABD8/BAAAQAAAAAAAAAAAAAAAAAAAAABAA/x8Q8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAEBAQECARDz8xABAgEBAQEAAAAAAAAAAAAAAAAAAAvz8wsAAAAAAAAAAAAAAAABAAAPDw8QDx309B0PEA8PDwAAAQAAAAEBB8Hz8fPz8/T+/vTz8/Px88EHAQEAAAEBB8Hz8fPz8/T+/vTz8/Px88EHAQEAAAABAAAPDw8QDx309B0PEA8PDwAAAQAAAAAAAAAAAAAAAAvz8wsAAAAAAAAAAAAAAAAAAAEBAQECARDz8xABAgEBAQEAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAAABAA/x8Q8AAQAAAAAAAAAAAAAAAAAAAAABABD8/BAAAQAAAAAAAAAAAAAAAAAAAAABAQXBwQUBAQAAAAAAAAAAAAAAAAAAAAAAAAACAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    pencil = "AAAAAAAAAAAAAAAAAAAAAgAACRAAAAIAAAAAAAAAAAAAAAAAAAADABCR3eq1OwACAAAAAAAAAAAAAAAAAAMAFcz///j/+zoAAAAAAAAAAAAAAAAAAwAWzf/PMBiX/7oAAAAAAAAAAAAAAAADABXQ/8gUAAAO+OsOAAAAAAAAAAAAAAMAFcz//8cSAgAt+uEJAAAAAAAAAAAAAwAVy//Jyf/PEBLO/5EAAAAAAAAAAAADABXK/9ASD87/ysr/zRICAAAAAAAAAAMAFMr/zxkAABLH///LFQABAAAAAAAAAwAUyf/PGQAGABTH/88VAAIAAAAAAAADABTJ/88ZAAYAGM//zBYAAwAAAAAAAAMAFMn/zxkABgAYzv/LFQADAAAAAAAAAwAUyf/PGQAGABjO/8wVAAMAAAAAAAACABTJ/88ZAAYAGM7/zBYAAwAAAAAAAAEAFMn/zxkABgAYzv/MFgADAAAAAAAAAQISy//PGQAGABjP/8sWAAMAAAAAAAAABACE/80ZAAYAGM//yxUAAwAAAAAAAAAAAQPV/zwACQAYz//MFQADAAAAAAAAAAAAACz+5g0AABjO/8wWAAMAAAAAAAAAAAAAAG//jwAMQc7/yxYAAwAAAAAAAAAAAAAAArv+lJXh///KFgADAAAAAAAAAAAAAAAADfH/////0oMPAAMAAAAAAAAAAAAAAAAAAYPluG4sAQAAAQAAAAAAAAAAAAAAAAAAAAAOAAAAAAQBAAAAAAAAAAAAAAAAAAAA",
    folder = "AAEDAAAAAAAAAwEAAAAAAAAAAAAAAAAAAAAACQ8PDw8IAAAAAAAAAAAAAAAAAAAAAQeR5PLz8/LhhQIDAgEBAQEBAQEBAAAAAI7///Pz8/P//4YAAAAAAAAAAAAAAwEACub5Qg8REQ9K+flMDxEPDw8PDw8JAAAAEe/0BgAAAAAAhP//8/Pz8/Pz8vHjkAcBEO/0EQECAQIDAoPf8fLz8/Pz8/P//40AEO/0DwABAAAAAAAHDw8PDw8PEQ9D+eYKEO/0DwABAAAAAQMAAAAAAAAAAAAG9PAREO/0DwABAAAAAAABAQEBAQEBAgER9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0DwABAAAAAAAAAAAAAAAAAQAP9O8QEO/0EQECAQEBAQEBAQEBAQEBAgER9O8QEe/0BgAAAAAAAAAAAAAAAAAAAAAG9PARCub5Qw8RDw8PDw8PDw8PDw8PEQ9D+eYKAI3///Pz8/Pz8/Pz8/Pz8/Pz8/P//4wAAQeQ4/Hy8/Pz8/Pz8/Pz8/Pz8vHjjwcBAAAACQ8PDw8PDw8PDw8PDw8PDw8JAAAAAAEDAAAAAAAAAAAAAAAAAAAAAAAAAwEAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAA",
    star = "AAAAAAAAAAAAAAAGBgAAAAAAAAAAAAAAAAAAAAAAAAACASnU1CkBAgAAAAAAAAAAAAAAAAAAAAADALL//7IAAwAAAAAAAAAAAAAAAAAAAAMBMvzy8vwyAQMAAAAAAAAAAAAAAAAAAAMAqv97e/+qAAMAAAAAAAAAAAACAwQEBQAu+vIUFPL7LgAFBAQDAgAAAAAAAAAAAAWs/40AAI3/rAUAAAAAAAEAAAApR2mLsdf/8xwBARz0/9exi2lHKAAAA5j8///////XRwACAgBH1////////JcDDfX+44pzTC4GAAIAAAIABy5Mc4rj/vQNAH3/7UoAAAAAAgAAAAACAAAAAEnt/30AAgCD//9kAAYBAAAAAAAAAQYAY///hQACAQMAfP//ZAACAAAAAAAAAgBj//9+AAMBAAEEAHf+/TAAAgAAAAACADH9/ncABAEAAAAABQCW/34ABAAAAAAEAH//lQAFAAAAAAAABAJ//nkABAMDAwMEAHn+fwIEAAAAAAAAAwCy/04DBQAAAAAFA07/sgADAAAAAAABAAPZ/y0AAEiYmEgAAC3/2QMAAQAAAAACABn56AI+t/////+3PgLo+RkAAQAAAAADAD3+2qj//+R0dOT//6fa/j0AAwAAAAAEAGD////sfhQAABR+7P///18ABAAAAAACASDV7IkbAAAEBAAAG4ns1R8BAgAAAAAAAQAIFAAABAEAAAEEAAAUCAABAAAAAAAAAAEAAAQCAAAAAAAAAgQAAAEAAAAA",
    heart = "AAAAAAAAAQEBAAAAAAAAAQEBAAAAAAAAAAAAAAMDAAAAAwMAAAMDAAAAAwMAAAAAAAABAgAABw8HAAACAgAACBEJAAACAQAAAAAAAEam3vHepkYAAEip4fPiq0oAAAEAAQIDl/////P///+Qkf////H///+cBAIBAwCY//N3KBIoePT///N1JREkc/D/nAACAEL/7jsAAAAAADrW1jkAAAAAADjt/0QAAKj+dwAHAgECBAAGBgAEAgECBwB1/qkAB939IgICAAAAAAIAAAIAAAAAAgIi/d4HEe/1EAABAAAAAAABAQAAAAAAAQAQ9e4RB9z9JQICAAAAAAAAAAAAAAAAAgIl/dwHAKT/fQAFAAAAAAAAAAAAAAAABQB+/6IAADz/7ysABAAAAAAAAAAAAAAEACzw/zwAAwCc/9UYAAMAAAAAAAAAAAMAGNb/mwADAQILxf/NGQADAAAAAAAAAwAZzf/FCgIBAAEAFcz/0h0AAwAAAAADABzS/8wVAAEAAAACABTH/9ciAAQAAAQAINb/yBUAAgAAAAAAAwARwv/cJwAEBAAm2//DEQADAAAAAAAAAAMADbz/4SwAACvg/70OAAMAAAAAAAAAAAACAAq3/+Q1NeP/twsAAwAAAAAAAAAAAAAAAgAHsf////+yBwACAAAAAAAAAAAAAAAAAAIABI7l5Y0EAAIAAAAAAAAAAAAAAAAAAAABAAAKCgAAAQAAAAAAAAAAAAAAAAAAAAAAAQMAAAMBAAAAAAAAAAAA",
    bell = "AAAAAAAAAAMAAAAPDwAAAAMAAAAAAAAAAAAAAAAAAwAfgsjr68iBHwADAAAAAAAAAAAAAAADAF/v///39///714AAwAAAAAAAAAAAAIAXf//p0AVFUGn//9bAAIAAAAAAAAAAgAe8f9zAAAAAAAAdP/xHgACAAAAAAAABACG/6gABAMBAQMEAKn/hQAEAAAAAAABAQLO/joCBAAAAAAEAjv/zgIBAQAAAAABAA3u+BQAAQAAAAABABX47gwAAQAAAAABABH08A4AAQAAAAABAA/x9BEAAQAAAAACABz85gkAAQAAAAABAAnn/BsAAgAAAAACADT/zQABAQAAAAABAQHN/zMAAgAAAAAEAGr+nwAEAAAAAAAAAwCg/mkABAAAAAEDAMv/VQAEAAAAAAAABABW/8oAAwEAAAMAdf/dCwICAQEBAQEBAgIM3v90AAMAAwBX/vxIAAAAAAAAAAAAAAAASP39VgADAAnk/YUKEg8PDw8PDw8PDw8TCob95AkAAAnn/+r08/Pz8/Pz8/Pz8/Pz9On/5wkAAgBR3fLy8/Pz8/Tz8/Tz8/Pz8vLcUQACAAAABhAPDw8PEA0SEg0QDw8PDxAGAAAAAAACAAAAAAAAAAQAAAQAAAAAAAAAAgAAAAAAAQEBAQQBi942Nt6LAQQBAQEBAAAAAAAAAAAAAAQAlf////+UAAQAAAAAAAAAAAAAAAAAAAEBBovh4YoGAQEAAAAAAAAAAAAAAAAAAAAAAAALCwAAAAAAAAAAAAAA",
    menu = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQICAgICAgICAgICAgICAgIBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQICAgICAgICAgICAgICAgIBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAQEHwfPx8/Pz8/Pz8/Pz8/Pz8fPBBwEBAAAAAA8PDw8PDw8PDw8PDw8PDw8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQEBAQEBAQEBAQEBAQEBAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    list = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAECAgICAgICAgICAgICAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAECAgICAgICAgICAgICAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQbKywcCB8Hz8fPz8/Pz8/Pz8/HzwgYBAQABAQABAAAPDw8PDw8PDw8PDw8PAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQAAAAEBAQEBAQEBAQEBAQEBAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    grid2x2 = "AAABAwAAAAAAAAAAAAAAAAAAAAADAQAAAAAAAAgPDw8PDw8QEA8PDw8PDwcAAAAAAQEHjuLy8/T09PTw8PT09PTz8uCDAwEBAwCO///z8/Pz8/T///Tz8/Pz8///gQADAAjp+UMPEQ8QDx3z8x0PEA8RD0365ggAABD08wYAAAAAAAvz8wsAAAAAAAbz9BAAAA/08xEBAgECARDz8xABAgECARHz8w8AAA/08w8AAQABAA/z8w8AAQABAA/z9A8AAA/08xABAgECARDz8xABAgECARDz9A8AAA/08wsAAAAAAAvz8wsAAAAAAAvz9A8AAA/09B0PEA8QDx309B0PEA8QDx309A8AABDw/vPz8/Pz8/T+/vTz8/Pz8/P+8BAAABDw/vPz8/Pz8/T+/vTz8/Pz8/P+8BAAAA/09B0PEA8QDx309B0PEA8QDx309A8AAA/08wsAAAAAAAvz8wsAAAAAAAvz9A8AAA/08xABAgECARDz8xABAgECARDz9A8AAA/08w8AAQABAA/z8w8AAQABAA/z9A8AAA/z8xEBAgECARDz8xABAgECARHz9A8AABD08wYAAAAAAAvz8wsAAAAAAAbz9BAAAAjm+k0PEQ8QDx3z8x0PEA8RD0T56QgAAwCA///z8/Pz8/T///Tz8/Pz8///jQADAQEDguDy8/T09PTw8PT09PTz8uKMBgIBAAAAAAcPDw8PDw8QEA8PDw8PDwgAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    squaremousepointer = "AAABAwAAAAAAAAAAAAAAAAAAAAADAQAAAAAAAAkPDw8PDw8PDw8PDw8PDwkAAAAAAQEHkeTy8/T09PT09PT09PTz8uSQBwEBAwCR///z8/Pz8/Pz8/Pz8/Pz8///kAADAArr+EIPEQ8PDw8PDw8PDw8RD0P46woAABD08gYAAAAAAAAAAAAAAAAAAAby9RAAAA/08xEBAgEBAQEBAQEBAQECARHz9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAQAAAAABAA/z9A8AAA/08w8AAQAAAAACAAIDAQABAA/x8g8AAA/08w8AAQAAAAAADQAAAAMDABD7/BAAAA/08w8AAQAAAgGI6bFUDQAAAgnDwwUBAA/08w8AAQABAAz2////4IkxAAAABgEAAA/08w8AAQAAAgG0/bi9////vWQWAAAAAA/08w8AAQAABABS/70AOJHp///qnCcAAA/08w8AAQAAAQAL4/82AAAITL///9gIAA/08w8AAQAAAAQAif+TAgM3htP//9cIAA/08xEBAgEBAQQBLf3rBTX+///VkicAABD08gYAAAAAAAABAMD/SYb/pTQFAAAAAArr+EMPEQ8PDw8DAGH/w9X+LAACBAIAAwCQ///z8/Pz8fPDBhPt///YBgMBAAAAAQEHj+Ty8/T08vTDCACe//+UAAQAAAAAAAAAAAkPDw8PDw8AAAEn09QnAQIAAAAAAAABAwAAAAAAAAAAAAAABQUAAAAAAAAA",
    tableofcontents = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgICAgICAgICAgICAgEAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAgICAgICAgICAgICAgEAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQbC8/Hz8/Pz8/Pz8/Px88EHAgbJzAYBAQAADw8PDw8PDw8PDw8PDwAAAQABAQABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAQEBAQEBAQEBAQEBAQEAAAABAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
    image = "AAABAwAAAAAAAAAAAAAAAAAAAAADAQAAAAAAAAgPDw8PDw8PDw8PDw8PDwcAAAAAAQEHjuLy8/T09PT09PT09PTz8uCDAwEBAwCO///z8/P09PPz8/Pz8/Pz8///gQADAAjp+UMPEhMNDRIQDw8PDw8RD0365ggAABD08wYAAAAFBQAAAAAAAAAAAAbz9BAAAA/08xIBCI7k5I8IAgIBAQECARHz8w8AAA/08xMAjv////+MAAMAAAABAA/z9A8AAA/09A0G6vkyM/noCQACBAMFAQ/z9A8AAA/09A0G6fkzM/noCQIAAAAAABHz9A8AAA/08xMAjf////+MAAAOeKN5DAf19A8AAA/08xAAB4vj44wJABbL////xyLt9g8AAA/08w8AAAAJCQAAFs3/zF/N/9by8w8AAA/08w8AAgMAAAAXzP/NGAAXzP//8BAAAA/08w8AAQADABfN/80WAAcAFsz/7hAAAA/08w8AAQMAFs3/zRcAAwADAB748Q8AAA/08w8ABAAWzP/NFwADAAABAQzy9A8AAA/z8xECABbN/84YAAQBAQECARLz8w8AABD08wgAF87/yBIAAAAAAAAAAAbz9BAAAAjm+koezv/TJgwSDw8PDw8RD0T56QgAAwCA///6///17/Xz8/Pz8/Pz8///jQADAQEDguDx7fDz9fT09PT09PTz8uKMBgIBAAAAAAcPEBAQDw8PDw8PDw8PDwgAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    play = "AAAAAAEDAAADAgAAAAAAAAAAAAAAAAAAAAAAAAAACgoAAAMBAAAAAAAAAAAAAAAAAAABAQeQ5+aQGgAAAwAAAAAAAAAAAAAAAAADAJD/////6G4GAAICAAAAAAAAAAAAAAEACur4Pyyw///JSAAAAwEAAAAAAAAAAAEAEPPyCAAAT8///6gpAAADAAAAAAAAAAEAD/PzEQIDAAl07P/zghAAAQIAAAAAAAEAD/PzDwABAwAAH5v//9pcAAADAQAAAAEAD/PzDwABAAEEAAA9v///ujkAAAAAAAEAD/PzDwABAAAAAQMAAGLf//+UCAEBAAEAD/PzDwABAAAAAAADAQATifj/jwADAAEAD/PzDwABAAAAAAAAAAMAADj46woAAAEAD/PzDwABAAAAAAAAAAMAADj46woAAAEAD/PzDwABAAAAAAADAQATifj/jgADAAEAD/PzDwABAAAAAQMAAGLf//+TBwEBAAEAD/PzDwABAAEEAAA+v///ujkAAAAAAAEAD/PzDwABAwAAH5v//9pcAAADAQAAAAEAD/PzEQIDAAl17P/zghAAAQIAAAAAAAEAEPPyBwAAT8///6gpAAADAAAAAAAAAAEACur4QCyw///JSAAAAwEAAAAAAAAAAAADAJD/////6G4GAAICAAAAAAAAAAAAAAABAQeP5uWQGgAAAwAAAAAAAAAAAAAAAAAAAAAACgoAAAMBAAAAAAAAAAAAAAAAAAAAAAEDAAADAgAAAAAAAAAAAAAAAAAA",
    pause = "AAAAAAIAAAAAAAIAAAIAAAAAAAIAAAAAAAAAAAAFEA8QBQAAAAAFEA8QBQAAAAAAAAACAEzb8vPy20kAAEzb8vPy20kAAgAAAAEBCOP/8vPy/+AFBuT/8vPy/+AHAQEAAAEAEPTyHw8f8vUMDPXyHw8f8vQQAAEAAAEAD/LzDQAN8/MLC/PzDQAN8/IPAAEAAAEAD/PzEgES8/QLC/TzEgES8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEQAR8/QLC/TzEQAR8/MPAAEAAAEAD/PzEgES8/QLC/TzEgES8/MPAAEAAAEAD/LzDQAN8/MLC/PzDQAN8/IPAAEAAAEAEPTyHw8f8vUMC/XyHw8f8vQQAAEAAAEBBt3/8vPy/+MGA97/8vPy/+IIAQEAAAACAEbZ8vLy20wAAEbZ8vLy20wAAgAAAAAAAAAFEA8QBQAAAAAFEA8QBQAAAAAAAAAAAAIAAAAAAAIAAAIAAAAAAAIAAAAA",
    volume2 = "AAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAACAAAAAAAAAAAAAAAAAAAAAAAAAAIAAA0AAAAAAAAAAQMAAAAAAAAAAAAAAwAXuuhwAAIAAAAAAAAAAAAAAAABAQEDABfO///xDAABAAEAF08AAQEAAAIAAAAAFs3/1vHxEQABAQUAmP+PAAMAAAAHERAky//JIe30DwABAAIBP/L/VwADAFHe8fL7/88VBvbzDwAAAgIBAGX/4AsBCeL/8fLtrhcAE/PzEAAHxMcKAgDI/1kAEe/zHQ8QAAABD/PzEAAH0f9uAABj/qYAEO70CwAAAgIAD/PzDwAASv7IAQAr/9UEEO/0EAECAAEAD/PzDwAAFPjtDgAU9+wPEO/0EAECAAEAD/PzDwAAFfjtDgAU9+wPEO70CwAAAgIAD/PzDwAAS/7HAQAr/9UEEe/zHQ8QAAABD/PzEAAH0v9uAABj/qYACeL/8fLurxcAE/PzEAAHxcYKAgDI/1kAAFHd8fL7/88VBvbzDwAAAgIBAGX/3wsBAAAGERAkyv/JIe30DwABAAIBQPL/VgADAAIAAAAAFs3/1vHxEQABAQUAmP+OAAMAAAABAQEDABfO///wDAABAAEAF08AAQEAAAAAAAAAAwAXuuhwAAIAAAAAAAAAAAAAAAAAAAAAAAIAAA0AAAAAAAAAAQMAAAAAAAAAAAAAAAABAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAA",
    sun = "AAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAEBAAAAAQW9vQUBAAAAAQEAAAAAAAAAAAAAAQABABD7+xAAAQABAAAAAAAAAAABAAsGAAIBABD6+hAAAQIABgsAAQAAAAEADtzLFgACAQXCwgUBAgAWy9wOAAEAAAEBC87/zBkCBQEAAAEFAhnM/84LAQEAAAABABbM/0cBAAAMDAAAAUf/zBYAAQAAAAAAAQATRgQAUrjr67hSAARGEwABAAAAAAEBAQIAAACI///5+f//hAAAAAIBAQEAAAAAAAAFA1H/9WwaGm32/00DBQAAAAAAAAAPDwABAb7+bAAAAABu/r4BAQAPDwAAB73z88IEC+34FAMDAwMV+ewLBMLz870HB73z88IEC+34FAMDAwMV+ewLBMLz870HAAAPDwABAb7+bQAAAABu/r4BAQAPDwAAAAAAAAAFA1D/9m8aGm72/08DBQAAAAAAAAEBAQIAAACE///5+v//hQAAAAIBAQEAAAAAAQATRgQAT7jr67hRAARGEwABAAAAAAABABbM/0cBAAAMDAAAAUf/zBYAAQAAAAEBC87/zBkCBQEAAAEFAhnM/84LAQEAAAEADtzLFgACAQXCwgUBAgAWy9wOAAEAAAABAAsGAAIBABD6+hAAAQIABgsAAQAAAAAAAAAAAQABABD7+xAAAQABAAAAAAAAAAAAAAEBAAAAAQW9vQUBAAAAAQEAAAAAAAAAAAAAAAAAAAADAwAAAAAAAAAAAAAA",
    moon = "AAAAAAAAAAEEAwAAAgAAAAAAAAAAAAAAAAAAAAAAAwAAAAQNAAAAAAAAAAAAAAAAAAAAAAACAAxcp9fqhwECAAAAAAAAAAAAAAAAAQEAXNr/////9wwAAQAAAAAAAAAAAAABAwCT///FXKD+pQEDAAAAAAAAAAAAAAADAJP/9GUAAMj/OwADAAAAAAAAAAAAAAMAWP/xQQAAEfD3FAABAAAAAAAAAAAAAQEM4P9jAAcADe73FAABAAAAAAAAAAAABABc/8cABAEBAc7/OwIEAAAAAAABAAAAAwCr/mIABAAEAIX/qgAEAwEBAwIAAgAAAATb/ykAAgACAB7x/3UAAAAAAAAOAAAAAA7x9RIAAQAAAgBb//+oQhYXQqbqhwECAA7y9RIAAQAAAAMAXO3///f3////8wwAAATb/ykAAgAAAAADAB6Cyu3uxp/+2AQAAwCr/mEABAAAAAAAAwAAAA0RAFT+qQADBABc/8cABAEAAAAAAAIEAAAAAcz/WgAEAQEM4P9kAAYAAAAAAAAAAQcAZv/fCwEBAAMAV//xQgACBAIBAQIEAgBD8v9WAAMAAAADAJP/9WUAAAAAAAAAAGb1/5EAAwAAAAABAwCS///DZS0TEy1lxP//kQADAQAAAAAAAQEAW9r////19f///9laAAIBAAAAAAAAAAACAAxbptfx8demWwwAAgAAAAAAAAAAAAAAAwAAAAIODgIAAAADAAAAAAAAAAAAAAAAAAEEAwAAAAADBAEAAAAAAAAA",
    clock = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////39////+2BCQACAAAAAAACACPK//+wWysTEytbsP//yiQAAgAAAAIAIuD/zj4AAAAAAAAAAD3O/+EjAAIAAQMKzf+4DgADBQfCwgcFBAAOuP/NCgMBAwCB/9AMAAQBABD8/BAAAQQADNH/gAADABfw+zkABAABAA/x8Q8AAQAEADn78BcAAGf/sgADAAABAA/z8w8AAQAAAwCz/2cAAKz+WAEEAAABAA/z8xIBAQAABAFZ/qwABNb/KAACAAABAA/x8gEABAEAAgAo/9YEDur4EwABAAABABH3+GUGAAAAAQAU+OoODur4EwABAAABAQa6///PXgQAAgAU+OoOBNb/KAACAAAAAQAGYM7//8MHAgAo/9YEAKz+WAEEAAAAAAAAAAZd0sMGAwFZ/qwAAGf/swADAAAAAAABAwAAAwEABACz/2YAABfw+zoABAAAAAAAAAEDAAAEADr78BcAAwCA/9ENAAQAAAAAAAAAAQUADdH/gAADAQMKzf+4DwADBAIBAQIEAwAOuP/NCQMBAAIAIuD/zz4AAAAAAAAAAD7O/+AiAAIAAAACACPK//+xXCsUFCtcsP//ySMAAgAAAAAAAgAJgOz////39////+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
    calendar = "AAABAwAAAAICAAAAAAAAAgIAAAADAQAAAAAAAAkQE76+ExAQEBATvr4TEAcAAAAAAQEHjuLy9f//9fT09PT1///18uCDAwEBAwCO///z9Pr68/Pz8/Pz+vr08///gQADAAjp+UUPIfz8Hg8QEA8e/PwhD0765ggAABD08wgAA8LCAgAAAAACwsIDAAjz9BAAAA/08w0AAAAAAAAAAAAAAAAAAA3z9A8AAA/09B0PEQ4OEA8PDw8QDg4RDx309A8AABDw/vPz8/Pz8/Pz8/Pz8/Pz8/P+8BAAABDw/vPz8/Pz8/Pz8/Pz8/Pz8/P+8BAAAA/09B0PEA8PDw8PDw8PDw8QDx309A8AAA/08wsAAAAAAAAAAAAAAAAAAAvz9A8AAA/08xABAgEBAQEBAQEBAQECARDz9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/08w8AAQAAAAAAAAAAAAABAA/z9A8AAA/z8xEBAgEBAQEBAQEBAQECARHz9A8AABD08wYAAAAAAAAAAAAAAAAAAAbz9BAAAAjm+k0PEQ8PDw8PDw8PDw8RD0T56QgAAwCA///z8/Pz8/Pz8/Pz8/Pz8///jQADAQEDguDy8/T09PT09PT09PTz8uKMBgIBAAAAAAcPDw8PDw8PDw8PDw8PDwgAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    download = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAgAAAAAAAAAAAAAAAAAAAAAAAAABAQXBwQUBAQAAAAAAAAAAAAAAAAAAAAABABD8/BAAAQAAAAAAAAAAAAAAAAAAAAABAA/x8Q8AAQAAAAAAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAAAAAAAAQEBAA/z8w8AAQEBAAAAAAAAAAAAAAAAAAACAA/z8w8AAgAAAAAAAAAAAAAAAAAAAQEAAQ/z8w8BAAEBAAAAAAAAAAAAAQEGw8gXABPz8xMAF8jDBgEBAAAAAAAAAQEGy//NFQb19QYUzf/MBgEBAAAAAAABAQEAFcv/ySHv7yDI/8wWAAEBAQAAAAAAAAABABbM/9f089b/zRYAAQAAAAAAAAADAwAAAwAWzf/9/f/OFgADAAADAwAAAQXCwQUBAAMAFs3//84XAAMAAQXBwgUBABD8+xAAAQADABbQ0BcAAwABABD7/BAAAA/y8Q8AAQAAAgAFBAACAAABAA/x8g8AAA/z8xEBAgEBAQIAAAIBAQECARHz8w8AABD18gYAAAAAAAAAAAAAAAAAAAby9RAAAArr+EMPEQ8PDw8PDw8PDw8RD0P46wkAAwCQ///z8/Pz8/Pz8/Pz8/Pz8///jwADAQEHj+Ty8/T09PT09PT09PTz8uSPBwEBAAAAAAkPDw8PDw8PDw8PDw8PDwkAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    upload = "AAAAAAAAAAAAAAEAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAEBAACAAAAAAAAAAAAAAAAAAAAAAADABbR0RcAAwAAAAAAAAAAAAAAAAAAAAMAFs3//84XAAMAAAAAAAAAAAAAAAAAAwAWzf/9/f/OFwADAAAAAAAAAAAAAAACABbM/9f089b/zRcAAgAAAAAAAAAAAAEAFsv/ySHv7yDI/80WAAEAAAAAAAAAAQEGy//NFQb19QYUzf/MBgEBAAAAAAAAAQEGw8gXABPz8xMAF8jDBgEBAAAAAAAAAAAAAQEAAQ/z8w8BAAEBAAAAAAAAAAAAAAAAAAACAA/z8w8AAgAAAAAAAAAAAAABAQAAAQEBAA/z8w8AAQEBAAABAQAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAADAwAAAAABAA/x8Q8AAQAAAAADAwAAAQXCwQUBAQABABD8/BAAAQABAQXBwgUBABD8+xAAAQABAQXBwQUBAQABABD7/BAAAA/y8Q8AAQAAAAACAgAAAAABAA/x8g8AAA/z8xEBAgEBAQEAAAEBAQECARHz8w8AABD18gYAAAAAAAAAAAAAAAAAAAby9RAAAArr+EMPEQ8PDw8PDw8PDw8RD0P46wkAAwCQ///z8/Pz8/Pz8/Pz8/Pz8///jwADAQEHj+Ty8/T09PT09PT09PTz8uSPBwEBAAAAAAkPDw8PDw8PDw8PDw8PDwkAAAAAAAABAwAAAAAAAAAAAAAAAAAAAAADAQAA",
    refreshcw = "AAAAAAAAAAEEAwAAAAADBAEAAAAAAAAAAAAAAAAAAwAAAAMODgMAAAADAQACAgAAAAAAAAACAA1cp9jx8dmrYxUAAQfBwgUBAAAAAQEAXNr////09f///+Z0AAr+/BAAAAABAwCS///DZCwSEytet///tx/s9A8AAAADAJP/9WQAAAAAAAAAAEfY/9jy8w8AAAMAWP/xQgACBAIBAQMCAQQr0///7hAAAQEM4P9kAAYAAAAAAQEHwfbs9f//+BEABABc/8cABAEAAAAAAQEHwfPy8uzvxAgBAwCr/mIABAAAAAAAAAEAAA8PEBAQAwAAAAPZ/SkAAgAAAAAAAAAAAAAAAAAAAQAAAA/6/hMAAQAAAAAAAAAAAQECAgbCwwUBAQXDwgYCAgEBAAAAAAAAAAABABT/+Q4AAAABAAAAAAAAAAAAAAAAAAACACr92AMAAAADEBAQDw8AAAEAAAAAAAAEAGP+qQADAQjE7+zy8vPBBwEBAAAAAAEEAMj/WgAEABH4///17PbBBwEBAAAAAQYAZf/eDAEBABDu///TKwQBAgMBAQIEAgBD8v9WAAMAAA/z8tj/2EcAAAAAAAAAAGb1/5EAAwAAAA/07B+3//+4XiwTEy1mxP//kQADAQAAABD8/goAdOb////19f///9laAAIBAAAAAQXCwQcBABRiqtjw8demWgwAAgAAAAAAAAACAgABAwAAAAMODgIAAAADAAAAAAAAAAAAAAAAAAEEAwAAAAADBAEAAAAAAAAA",
    power = "AAAAAAAAAAAAAAADAwAAAAAAAAAAAAAAAAAAAAAAAAAAAQW9vQUBAAAAAAAAAAAAAAAAAAAAAAABABD9/RAAAQAAAAAAAAAAAAAAAAADAQABAA/x8Q8AAQABBAEAAAAAAAAAAAAAAAABAA/z8w8AAQAAAAAAAAAAAAABAQBOFgACAA/z8w8AAgAYWAIAAQAAAAADAI//lgAFAA/z8w8ABQCP/54AAwAAAAMAVv/xPwADAA/z8w8AAwE16/9kAAMAAQEL3f9mAAMBAA/z8w8AAQMAVv/oEgABBABX/8oAAwEBAA/z8w8AAQAEALz/ZgAEAwCl/mcABAABAA/x8Q8AAQAEAVj+tAACAALU/y8AAwABABD8/BAAAQACACL+4gYAAArq+hkAAQABAQXBwQUBAQABAA7v9xMAAArp+xoAAQAAAAACAgAAAAABAA7v9xMAAAHR/zIBAwAAAAAAAAAAAAACACT+4AUABACf/m4ABAAAAAABAQAAAAAEAF7+sAADBABQ/9IDAwEAAAAAAAAAAAEEAMX/XwAEAQEI1v9zAAYBAAAAAAAAAQYAY//hDgEBAAMASf/3UAABBAICAgIEAQBE8v9YAAMAAAADAIP/+3QGAAAAAAAAAmn2/5IAAwAAAAABAwCD///QcjQaGjJsyf//jwADAQAAAAAAAAIATs/////8+////9ZXAAEBAAAAAAAAAAADAAVOmcnj5MydVAkAAgAAAAAAAAAAAAAAAwAAAAALCwAAAAADAAAAAAAA",
    shield = "AAAAAAAAAAACAgAJCQACAgAAAAAAAAAAAAAAAAEBAwQAAGbb22UAAAQDAQEAAAAAAAAAAgAAAAAfoP////+fHgAAAAACAAAAAAAAAAcXPo/u/+9XV/D/7o4+FwcAAAAAAAIAU971////pygAACip////9d1SAAIAAQEI5v/sy4kzAAADAwAANIrL7P/lCAEBAQAQ8/IbAAAAAgIAAAICAAAAG/LzEAABAQAP8vMLAAUCAAAAAAAAAgUAC/PyDwABAQAP8/MQAAEAAAAAAAAAAAEAEPPzDwABAQAP8/MPAAEAAAAAAAAAAAEAD/PzDwABAQAP8/MPAAEAAAAAAAAAAAEAD/PzDwABAQAP8/MPAAEAAAAAAAAAAAEAD/PzDwABAQAP8/MPAAEAAAAAAAAAAAEAD/PzDwABAQAO8PYSAAEAAAAAAAAAAAEAE/bwDgABAQAF3P8mAAIAAAAAAAAAAAIAJ//bBAABAAMAr/5dAAQAAAAAAAAAAAQAXv6uAAMAAAQAX//HAAQBAAAAAAAAAQQAyP9eAAQAAAEBDN7/dgAFAgAAAAACBQB3/90LAQEAAAADAEv//m4AAAQCAgQAAG7+/0sAAwAAAAAAAwBx//+jIwAAAAAiov//cQADAAAAAAAAAAMAXe7/8pIyMJHx/+5dAAMAAAAAAAAAAAADACWj////////oyUAAwAAAAAAAAAAAAAAAwAAL4vb3Y0wAAADAAAAAAAAAAAAAAAAAAICAAAICQAAAgIAAAAAAAAA",
    zap = "AAAAAAAAAAAAAAACAAARAAAAAAAAAAAAAAAAAAAAAAAAAAMAJbnquiMAAgAAAAAAAAAAAAAAAAAABAAn4f/8/8ICAgAAAAAAAAAAAAAAAAAEACff/68v+PMNAAEAAAAAAAAAAAAAAAQAJ9//vAZF/8QCAQAAAAAAAAAAAAAABAAn3/+6DACs/24ABAAAAAAAAAAAAAAEACff/7kKABfx+SEBAwAAAAAAAAAAAAQAJ9//uQoCAV7/tQAAAAECAAAAAAAAAwAn3/+5CgAFAbb9aRATEAAAAAAAAAACACff/7kKAAMADPT/8vPy8b4kAAIAAAIBJuH/ugsBAwACAYfr8PP09P/BAgIAAAICwP+xBgAAAAIAAAAPEBINK/byDgABAQAO8/YrDRIQDwAAAAIAAAAGsf++AgIAAAICwv/09PPw7IgBAgADAQu6/+EmAQIAAAIAJL3x8vPy//UMAAMACrn/3ycAAgAAAAAAAAAQExBo/bYBBQAJuP/gKAADAAAAAAAAAgEAAAC0/14BAgm4/+AoAAQAAAAAAAAAAAADASH58RcACbj/4CgABAAAAAAAAAAAAAAEAG3/rAALuP/gKAAEAAAAAAAAAAAAAAABAsT/RAa7/98oAAQAAAAAAAAAAAAAAAEADvP3L6//3ycABAAAAAAAAAAAAAAAAAACAsL//P/hJwAEAAAAAAAAAAAAAAAAAAACACO66bckAAMAAAAAAAAAAAAAAAAAAAAAAAAAEQAAAgAAAAAAAAAAAAAA",
    flame = "AAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgACAwAAAAAAAAAAAAAAAAAAAAAAAAACACHOvwUBAAAAAAAAAAAAAAAAAAAAAAIBG93//zIBAwAAAAAAAAAAAAAAAAAAAAIBuP/0/ooABAAAAAAAAAAAAAAAAAAAAwA7/9tU/+sUAgIAAAAAAAAAAAAAAAAABAB1/osAuP+aAAUBAAAAAAAAAAAAAAAABAB2/ogBLfX/ZgAEAAAAAAAAAAAAAAABBABD/9YHAGT//WgAAwAAAAAAAAAAAAEAAAEG0v9aAQB5//95AAMAAAAAAAAAAAACAwMAX/+9AAUAZ/z/XgADAAAAAAABAQrHvwMFFfjsDAAFAGf/7xwBAgAAAAAEAHH//CgAJvjqCwABBQCs/4MABAAAAAABAcr//9SD0f+hAAMAAwE9/80BAQEAAAEADe300////8kYAQIAAQAU9+4NAAEAAAEADvDzGVN7VQcAAQAAAQAU9+8OAAEAAAAAAtL/MAAAAAABAAAAAwIz/9ICAAEAAAAEAJX/igAKAwEAAAAABgCL/5QABAAAAAADADT+8S8ABgIBAQIGAC/x/jMAAwAAAAAAAwCW/9wyAAAAAAAAM93/lgADAAAAAAAAAQIJu//1iTcUFDeK9v+6CQIBAAAAAAAAAAEACJf////29////5YIAAEAAAAAAAAAAAABAAA3kczr68yQNgAAAQAAAAAAAAAAAAAAAQIAAAAPDwAAAAIBAAAAAAAA",
    crosshair = "AAAAAAABBAAAAAMQEAMAAAAEAQAAAAAAAAAAAAIAABljqNTo6NSrZhkAAAIAAAAAAAAAAgAJgez//////////+2BCQACAAAAAAACACPK//+xWTXz8zVasP//yiQAAgAAAAIAIuD/zj4AAAfx8QYAAD3O/+EjAAIAAQMKzf+4DgAEAxL8/BIDBAAOuP/NCgMBAwCB/9AMAAQBAQXBwQUBAQQADNH/gAADABfw+zkABAAAAAACAgAAAAAEADn78BcAAGf/swAEAQAAAAAAAAAAAAABBAC0/2cAAKz+VAAAAAAAAAABAQAAAAAAAABV/qwABNb/NQ8RAAABAAAAAAAAAQAAEQ81/9YDEOj/8/HzwQcBAQAAAAABAQfB8/Hz/+gQEOj/8/HzwQcBAQAAAAABAQfB8/Hz/+gQBNb/NQ8RAAABAAAAAAAAAQAAEQ81/9YEAKz+VAAAAAAAAAABAQAAAAAAAABV/qwAAGf/tAAEAQAAAAAAAAAAAAABBAC0/2YAABfw+zoABAAAAAACAgAAAAAEADr78BcAAwCA/9ENAAQBAQXBwQUBAQQADdH/gAADAQMKzf+4DwAEAxL8/BIDBAAOuP/NCQMBAAIAIuD/zz4AAAbx8QYAAD7O/+AiAAIAAAACACPK//+xWjXz8zVasP//ySMAAgAAAAAAAgAJgOz//////////+2ACQACAAAAAAAAAAIAABljqNTo6NOqZhkAAAIAAAAAAAAAAAABBAAAAAMQEAMAAAAEAQAAAAAA",
    target = "AAAAAAABBAAAAAMODgMAAAAEAQAAAAAAAAAAAAIAABljqNTq6tSrZhkAAAIAAAAAAAAAAgAJgez////4+P///+2BCQACAAAAAAACACPK//+yXysQECtfsf//yiQAAgAAAAIAIuD/zkEAAAAICAAAAEDP/+EjAAIAAQMKzf+4EAAih83v782GIgAQuP/NCgMBAwCB/9EOAF/t///39///7WAADtD/gAADABfw+zwAXv//qEQTE0Sp//9eADz78BcAAGf/tAAh8f91AAAEBAAAdf/xIAC1/2cAAKz+XAGJ/6oACpDl5JEJAKv/iAFd/qwABNb/KADP/z4Bkf////+QAT//zwAp/9YEDur4EAfv+BIF6vkyM/npBRL57wcQ+eoODur4EAfv+BIF6fkzM/npBRL57wcQ+eoOBNb/KADP/z4BkP////+PAT//zwAp/9YEAKz+XAGI/6sACY/k5JAJAKv/iAFd/qwAAGf/tAAg8f91AAAEBAAAdf/wIAC1/2YAABfw+zwAXv//qUUUFEWp//9dADz78BcAAwCA/9EOAF7t///4+P//7V8ADtH/gAADAQMKzf+4EAAhhszv7syGIQAQuP/NCQMBAAIAIuD/z0EAAAAICAAAAEHP/+AiAAIAAAACACPK//+yXysQECtfsf//ySMAAgAAAAAAAgAJgOz////4+P///+2ACQACAAAAAAAAAAIAABljqNTq6tSqZhkAAAIAAAAAAAAAAAABBAAAAAMODgMAAAAEAQAAAAAA",
}

local Ink, InkCount = { }, 0

local function iconSheet(art, colour)
    if not art then return nil end
    local key = art .. "\1" .. hexOf(colour)
    local sheet = Ink[key]
    if sheet == nil then
        local bytes = Masks[art]
        if bytes == nil then
            local fine, got = pcall(unbase64, art)
            bytes = (fine and #got >= 576) and got or false
            Masks[art] = bytes
        end
        if not bytes then
            Ink[key] = false
            return nil
        end
        local ok, made = pcall(paintMask, bytes, 24, 24, colour)
        sheet = ok and made or false
        if InkCount > 120 then
            Ink, InkCount = { }, 0
        end
        Ink[key] = sheet
        InkCount = InkCount + 1
    end
    return sheet or nil
end

local artwork
do
    local Loaded = { }

    local function fetch(spec)
        if byte(spec, 1) == 137 and sub(spec, 2, 4) == "PNG" then return spec end

        if find(spec, "^https?://") then
            local ok, body = pcall(function() return game:HttpGet(spec, true) end)
            if not ok then
                local ask = _G.request or _G.http_request
                if type(ask) == "function" then
                    local fine, reply = pcall(ask, { Url = spec, Method = "GET" })
                    if fine and type(reply) == "table" and reply.Body then
                        body, ok = reply.Body, true
                    end
                end
            end
            if ok and type(body) == "string" and #body > 8 then return body end
            return nil
        end

        if isfile and readfile and isfile(spec) then
            local ok, body = pcall(readfile, spec)
            if ok and type(body) == "string" and #body > 8 then return body end
        end

        if #spec > 64 and not find(spec, "[^A-Za-z0-9+/=]") then
            local ok, body = pcall(unbase64, spec)
            if ok and type(body) == "string" and #body > 8 then return body end
        end
        return nil
    end

    function artwork(spec)
        if not spec then return nil, false end
        spec = tostring(spec)

        local named = Art[gsub(lower(spec), "[%-_ ]", "")]
        if named then return named, true end

        local held = Loaded[spec]
        if held == nil then
            held = fetch(spec) or false
            Loaded[spec] = held
        end
        return held or nil, false
    end
end

local function stamp(art, cx, cy, size, colour, z, alpha)
    if alpha <= 0.01 then return end
    local sheet = iconSheet(art, colour)
    if sheet then img(sheet, cx - size / 2, cy - size / 2, size, size, z, alpha) end
end

local function melt(art, cx, cy, size, cold, warm, t, z, alpha)
    if alpha <= 0.01 then return end
    if t < 0.996 then stamp(art, cx, cy, size, cold, z, alpha * (1 - t)) end
    if t > 0.004 then stamp(art, cx, cy, size, warm, z + 1, alpha * t) end
end

local function chevron(cx, cy, radius, turn, colour, z, alpha)
    local angle = turn * pi
    local cosA, sinA = cos(angle), sin(angle)
    local rise = radius * 0.55
    local function spin(ox, oy)
        return cx + ox * cosA - oy * sinA, cy + ox * sinA + oy * cosA
    end
    local lx, ly = spin(-radius, -rise)
    local tipX, tipY = spin(0, rise)
    local rx, ry = spin(radius, -rise)
    line(lx, ly, tipX, tipY, colour, z, 1.6, alpha)
    line(tipX, tipY, rx, ry, colour, z + 1, 1.6, alpha)
end

local function fire(fn, ...)
    if type(fn) ~= "function" then return end
    local args = { ... }
    local ok, err = pcall(function() return fn(unpack and unpack(args) or table.unpack(args)) end)
    if not ok then S.lastError = tostring(err) end
end

local function bindName(item)
    if not item.bind then return "None" end
    local k = Key[item.bind]
    return k and (Named[k.id] or item.bind) or item.bind
end

local function dropText(item)
    if item.many then
        local picked, n = { }, 0
        for _, value in ipairs(item.values) do
            if item.pick and item.pick[value] then
                n = n + 1
                picked[n] = tostring(value)
            end
        end
        if n == 0 then return item.empty or "None" end
        return concat(picked, ", ")
    end
    if item.pick == nil or item.pick == "" then return item.empty or "None" end
    return tostring(item.pick)
end

local function edit(obj, field, allow, cap)
    local value = obj[field] or ""
    obj.at = clamp(obj.at or #value, 0, #value)
    local at, anchorAt = obj.at, obj.mark
    local marked = anchorAt ~= nil and anchorAt ~= at
    local lo = marked and min(anchorAt, at) or at
    local hi = marked and max(anchorAt, at) or at
    local changed = false
    local extend = shiftHeld()

    local function cut()
        value = sub(value, 1, lo) .. sub(value, hi + 1)
        at, anchorAt, marked, changed = lo, nil, false, true
    end

    local function done()
        if cap and #value > cap then value = sub(value, 1, cap) end
        obj.at = clamp(at, 0, #value)
        obj.mark = anchorAt
        obj[field] = value
        return changed
    end

    if ctrlHeld() then
        if Key.a.hit then
            anchorAt, at, Key.a.hit = 0, #value, false
        elseif Key.c.hit then
            if marked then clipMirror = sub(value, lo + 1, hi); pcall(toClip, clipMirror) end
            Key.c.hit = false
        elseif Key.x.hit then
            if marked then clipMirror = sub(value, lo + 1, hi); pcall(toClip, clipMirror); cut() end
            Key.x.hit = false
        elseif Key.v.hit then
            Key.v.hit = false
            local paste = clipMirror
            if fromClip then
                local ok, got = pcall(fromClip)
                if ok and type(got) == "string" and got ~= "" then paste = got end
            end
            paste = gsub(paste, "[\r\n]", "")
            if allow then
                local kept, n = { }, 0
                for i = 1, #paste do
                    local ch = sub(paste, i, i)
                    if find(ch, allow) then
                        n = n + 1
                        kept[n] = ch
                    end
                end
                paste = concat(kept)
            end
            if paste ~= "" then
                if marked then cut() end
                value = sub(value, 1, at) .. paste .. sub(value, at + 1)
                at, changed = at + #paste, true
            end
        end
        return done()
    end

    if Key.left.hit or Key.right.hit or Key.home.hit or Key["end"].hit then
        local to = at
        if Key.left.hit then to = (marked and not extend) and lo or max(0, at - 1) end
        if Key.right.hit then to = (marked and not extend) and hi or min(#value, at + 1) end
        if Key.home.hit then to = 0 end
        if Key["end"].hit then to = #value end
        anchorAt = extend and (anchorAt or at) or nil
        at = to
        Key.left.hit, Key.right.hit, Key.home.hit, Key["end"].hit = false, false, false, false
        return done()
    end

    if Key.delete.hit then
        if marked then cut()
        elseif at < #value then
            value = sub(value, 1, at) .. sub(value, at + 2)
            anchorAt, changed = nil, true
        end
        Key.delete.hit = false
    end

    if held("backspace") then
        if marked then cut()
        elseif at > 0 then
            value = sub(value, 1, at - 1) .. sub(value, at + 1)
            at, anchorAt, changed = at - 1, nil, true
        end
    end

    if not changed then
        for _, name in ipairs(Order) do
            local k = Key[name]
            if k.ch then
                local typed = k.hit or (k.down and repeatKey == name and now() >= repeatAt)
                if typed then
                    local ch = (extend and k.shifted) or k.ch
                    if allow and not find(ch, allow) then
                        typed = false
                    elseif cap and not marked and #value >= cap then
                        typed = false
                    else
                        if marked then cut() end
                        value = sub(value, 1, at) .. ch .. sub(value, at + 1)
                        at, anchorAt, changed = at + 1, nil, true
                    end
                    if k.hit then
                        repeatKey, repeatAt, k.hit = name, now() + 0.4, false
                    else
                        repeatAt = now() + 0.035
                    end
                    if typed then break end
                end
            end
        end
    end
    return done()
end

local function caretAt(obj, value, mx)
    value = tostring(value or "")
    local size = obj.size or 14
    local edge, best, gap = obj.left or 0, 0, abs(mx - (obj.left or 0))
    for i = 1, #value do
        edge = edge + width(sub(value, i, i), size)
        local step = abs(mx - edge)
        if step < gap then gap, best = step, i end
    end
    return best
end

local function drawEdit(obj, value, x, top, size, colour, z, alpha, room, on)
    value = tostring(value or "")
    obj.left, obj.size = x, size
    local at = clamp(obj.at or #value, 0, #value)
    local first = 0
    while first < at and width(sub(value, first + 1, at), size) > room - 6 do
        first = first + 1
    end
    local last = first
    while last < #value and width(sub(value, first + 1, last + 1), size) <= room - 4 do
        last = last + 1
    end

    local anchorAt = on and obj.mark
    if anchorAt and anchorAt ~= at then
        local lo = clamp(min(anchorAt, at), first, last)
        local hi = clamp(max(anchorAt, at), first, last)
        if hi > lo then
            local a = x + width(sub(value, first + 1, lo), size)
            local b = x + width(sub(value, first + 1, hi), size)
            rect(a, top - 1, b - a, size + 3, paint("Primary"), z, 0.45 * alpha)
        end
    end

    runText(sub(value, first + 1, last), x, top, colour, size, z + 1, alpha)

    if on and (not anchorAt or anchorAt == at) and floor(now() * 2) % 2 == 0 then
        local cx = x + width(sub(value, first + 1, clamp(at, first, last)), size)
        line(cx, top - 1, cx, top + size + 1, colour, z + 2, 1, 0.9 * alpha)
    end
end

local function openPopup(kind, item, x, y, width_, stacked)
    while #S.popups > 0 and S.popups[#S.popups].dying do remove(S.popups) end
    local keep = stacked and #S.popups or 0
    for i = #S.popups, keep + 1, -1 do S.popups[i] = nil end
    S.popups[#S.popups + 1] = { kind = kind, item = item, x = x, y = y, w = width_, t = 0 }
end

local function shutPopup()
    local top = S.popups[#S.popups]
    if top then top.dying = true end
end

local function popupOpen(item, kind)
    for i = 1, #S.popups do
        local pop = S.popups[i]
        if pop.item == item and pop.kind == kind and not pop.dying then return true end
    end
    return false
end

local function anyPopup()
    for i = 1, #S.popups do
        if not S.popups[i].dying then return true end
    end
    return false
end

local Pop = { }

function Pop.list(pop, alpha, t, z)
    local item = pop.item
    local rowH = 32
    local huntH = item.hunt and 34 or 0
    local shown = item.values
    if item.hunt then
        item.seek = item.seek or { value = "", at = 0 }
        local needle = lower(item.seek.value)
        if needle ~= "" then
            shown = { }
            for _, value in ipairs(item.values) do
                if find(lower(tostring(value)), needle, 1, true) then
                    shown[#shown + 1] = value
                end
            end
        end
    end
    local count = #shown
    local full = min(count * rowH + 12 + huntH, 280)
    local w, h = screen()
    local x = clamp(pop.x, 6, max(6, w - pop.w - 6))
    local y = clamp(pop.y, 6, max(6, h - full - 6))
    local grown = floor(full * t)

    shadow(x, y, pop.w, grown, 12, z - 40, 0.5 * alpha, 8)
    squircle(x, y, pop.w, grown, 12, paint("DropdownBackground"), z, alpha)
    pop.box = { x, y, pop.w, grown }
    if grown < rowH then return end

    if item.hunt then
        local seek = item.seek
        local typing = S.focus == seek
        local hy = y + 6
        squircle(x + 6, hy, pop.w - 12, 26, 8, mix(paint("DropdownBackground"), paint("Text"),
            0.06), z + 6, alpha)
        stamp(Art.search, x + 20, hy + 13, 14, paint("Icon"), z + 8, 0.7 * alpha)
        local seekX = x + 34
        local seekTop = capTop(hy + (26 - Metric.fDesc * CAPHEIGHT) / 2 + 1, Metric.fDesc)
        if typing or seek.value ~= "" then
            drawEdit(seek, seek.value, seekX, seekTop, Metric.fDesc, paint("Text"), z + 10,
                alpha, pop.w - 52, typing)
        else
            text("Search", seekX, seekTop, paint("Placeholder"), Metric.fDesc, z + 10, 0.6 * alpha)
        end
        seek.box = { x + 6, hy, pop.w - 12, 26 }
        if hit(x + 6, hy, pop.w - 12, 26) then
            S.focus, S.grab = seek, nil
            seek.left, seek.size = seekX, Metric.fDesc
            seek.at, seek.mark = caretAt(seek, seek.value, S.mx), nil
        end
    end

    local viewTop = y + huntH + 4
    local viewFoot = y + grown - 4
    local span = viewFoot - viewTop
    local shift = scrollBox(item, x, viewTop, pop.w, span, count * rowH)
    local rail = (item.reach or 0) > 1
    local knob, rode = 0, viewTop
    if rail then
        knob = max(24, span * span / (span + item.reach))
        rode = viewTop + (span - knob) * clamp((item.eased or 0) / item.reach, 0, 1)
        local barX = x + pop.w - 11
        if Key.m1.hit and not S.tookClick and inside(barX, viewTop, 11, span) then
            S.tookClick = true
            item.riding = inside(barX, rode, 11, knob) and (S.my - rode) or knob / 2
        end
        if item.riding then
            if not Key.m1.down then
                item.riding = nil
            elseif span > knob then
                item.scroll = clamp((S.my - viewTop - item.riding) / (span - knob), 0, 1)
                    * item.reach
                item.eased = item.scroll
                shift = item.scroll
                rode = viewTop + (span - knob) * clamp(shift / item.reach, 0, 1)
            end
        end
    end
    local at = viewTop - shift
    local rowW = pop.w - 8 - (rail and 8 or 0)
    clipTo(x, viewTop, pop.w, span)

    for i = 1, count do
        local value = shown[i]
        if at + rowH > viewTop and at < viewFoot then
            local key = tostring(value)
            local chosen = item.many and (item.pick and item.pick[value] and true or false)
                or (item.pick == value)
            local whole = at >= viewTop - 1 and at + rowH <= viewFoot + 1
            local on = whole and over(x + 4, at, rowW, rowH)
            item.warm = item.warm or { }
            local glow = drift(item.warm, key, on and 1 or 0, 0.045)
            local rz = z + 10 + i * 6

            if glow > 0.01 then
                squircle(x + 4, at, rowW, rowH, 8, paint("Text"), rz, 0.06 * glow * alpha)
            end
            middle(fit(key, pop.w - 40, Metric.fDesc, "..."), x + 14, at + 1, rowH,
                chosen and paint("Primary") or paint("Text"), Metric.fDesc, rz + 2,
                (chosen and 1 or 0.8) * alpha)
            if chosen then
                stamp(Art.check, x + pop.w - 20, at + rowH / 2, 16, paint("Primary"),
                    rz + 4, alpha)
            end
            if whole and hit(x + 4, at, rowW, rowH) then
                if item.many then
                    item.pick = item.pick or { }
                    item.pick[value] = (not item.pick[value]) or nil
                    item:Set(item.pick)
                elseif item.none and item.pick == value then
                    item:Set(nil)
                    shutPopup()
                else
                    item:Set(value)
                    shutPopup()
                end
            end
        end
        at = at + rowH
    end
    unclip()

    if rail then
        local warm = (item.riding or over(x + pop.w - 11, viewTop, 11, span)) and 1 or 0
        squircle(x + pop.w - 7, viewTop, 3, span, 2, paint("Text"), z + 400, 0.06 * alpha)
        squircle(x + pop.w - 7, rode, 3, knob, 2, paint("Text"), z + 402,
            (0.24 + 0.2 * warm) * alpha)
    end
    scrollGrab(item, x, viewTop, rowW, span)
end

local svSheet, hueSheet, alphaSheet
do
    local SvSheets, SvCount = { }, 0
    local HueSheet = nil

    function svSheet(hue)
    local step = floor(hue * 47 + 0.5)
    local sheet = SvSheets[step]
    if sheet == nil then
        local tint = step / 47
        local rows, n = { }, 0
        for y = 0, 63 do
            n = n + 1
            rows[n] = char(0)
            local line = { }
            for x = 0, 63 do
                local c = hsv(tint, x / 63, 1 - y / 63)
                line[x + 1] = char(to255(c.R), to255(c.G), to255(c.B), 255)
            end
            n = n + 1
            rows[n] = concat(line)
        end
        local ok, made = pcall(png, 64, 64, concat(rows))
        sheet = ok and made or false
        if SvCount > 20 then
            SvSheets, SvCount = { }, 0
        end
        SvSheets[step] = sheet
        SvCount = SvCount + 1
    end
    return sheet or nil
    end

    local Ramps, RampCount = { }, 0

    function alphaSheet(colour)
        local key = hexOf(colour)
        local sheet = Ramps[key]
        if sheet == nil then
            local r, g, b = to255(colour.R), to255(colour.G), to255(colour.B)
            local head = char(r, g, b)
            local row, n = { }, 0
            for x = 0, 95 do
                n = n + 1
                row[n] = head .. char(floor(x / 95 * 255 + 0.5))
            end
            local line = concat(row)
            local ok, made = pcall(png, 96, 2, char(0) .. line .. char(0) .. line)
            sheet = ok and made or false
            if RampCount > 16 then
                Ramps, RampCount = { }, 0
            end
            Ramps[key] = sheet
            RampCount = RampCount + 1
        end
        return sheet or nil
    end

    function hueSheet()
        if HueSheet == nil then
        local rows, n = { }, 0
        for y = 0, 127 do
            local c = hsv(y / 127, 1, 1)
            local pixel = char(to255(c.R), to255(c.G), to255(c.B), 255)
            n = n + 1
            rows[n] = char(0)
            n = n + 1
            rows[n] = rep(pixel, 4)
        end
        local ok, made = pcall(png, 4, 128, concat(rows))
        HueSheet = ok and made or false
    end
    return HueSheet or nil
    end
end

function Pop.colour(pop, alpha, t, z)
    local item = pop.item
    local pad = 12
    local field = pop.w - pad * 2 - 26
    local full = field + pad * 3 + 26 + (item.clear and 24 or 0)
    local w, h = screen()
    local x = clamp(pop.x - pop.w, 6, max(6, w - pop.w - 6))
    local y = clamp(pop.y, 6, max(6, h - full - 6))

    shadow(x, y, pop.w, floor(full * t), 14, z - 40, 0.5 * alpha, 8)
    squircle(x, y, pop.w, floor(full * t), 14, paint("DialogBackground"), z, alpha)
    pop.box = { x, y, pop.w, floor(full * t) }
    if t < 0.9 then return end

    local fx, fy = x + pad, y + pad
    local hx = x + pop.w - pad - 18

    if not Key.m1.down then
        S.pick = nil
    elseif S.pick == nil and Key.m1.hit then
        if inside(fx, fy, field, field) then S.pick, S.tookClick = "sv", true
        elseif inside(hx - 4, fy, 26, field) then S.pick, S.tookClick = "hue", true end
    end
    if S.pick == "sv" then
        item.sat = clamp((S.mx - fx) / field, 0, 1)
        item.val = clamp(1 - (S.my - fy) / field, 0, 1)
        item:Push()
    elseif S.pick == "hue" then
        item.hue = clamp((S.my - fy) / field, 0, 1)
        item:Push()
    end

    local field_ = svSheet(item.hue)
    if field_ then
        img(field_, fx, fy, field, field, z + 4, alpha)
    else
        rect(fx, fy, field, field, hsv(item.hue, 1, 1), z + 4, alpha)
    end

    local dx, dy = fx + item.sat * field, fy + (1 - item.val) * field
    circ(dx, dy, 6, paint("Black"), z + 6, false, 2, 0.5 * alpha)
    circ(dx, dy, 5, paint("White"), z + 7, false, 1.6, alpha)

    local strip = hueSheet()
    if strip then
        img(strip, hx, fy, 18, field, z + 8, alpha)
    else
        rect(hx, fy, 18, field, hsv(item.hue, 1, 1), z + 8, alpha)
    end
    rect(hx - 3, fy + item.hue * field - 1, 24, 2, paint("White"), z + 10, alpha)

    local live = hsv(item.hue, item.sat, item.val)
    local barY = fy + field + pad
    if item.clear then
        local aw = field
        local ay = barY
        local strip = 12
        local tile = 6
        for i = 0, floor(aw / tile) do
            local shade = (i % 2 == 0) and 0.22 or 0.32
            rect(fx + i * tile, ay, min(tile, aw - i * tile), strip,
                mix(paint("Black"), paint("White"), shade), z + 10, alpha)
        end
        local ramp = alphaSheet(live)
        if ramp then
            img(ramp, fx, ay, aw, strip, z + 11, alpha)
        else
            rect(fx, ay, aw, strip, live, z + 11, alpha)
        end
        rect(fx + aw * item.alpha - 1, ay - 2, 2, strip + 4, paint("White"), z + 12, alpha)
        if Key.m1.down and S.pick == "alpha" then
            item.alpha = clamp((S.mx - fx) / aw, 0, 1)
            item:Push()
        elseif Key.m1.hit and not S.tookClick and inside(fx, ay - 4, aw, strip + 8) then
            S.pick, S.tookClick = "alpha", true
        end
        barY = barY + strip + pad
    end
    if item.clear then
        squircle(fx, barY, 26, 26, 8, mix(paint("Black"), paint("White"), 0.28), z + 11, alpha)
        squircle(fx, barY, 26, 26, 8, live, z + 12, item.alpha * alpha)
    else
        squircle(fx, barY, 26, 26, 8, live, z + 12, alpha)
    end
    middle("#" .. hexOf(live), fx + 34, barY, 26, paint("Text"), Metric.fDesc, z + 14, 0.9 * alpha)

    local copyX = x + pop.w - pad - 22
    local warm = drift(item, "aCopy", over(copyX, barY, 22, 26) and 1 or 0, 0.16)
    melt(Art.copy, copyX + 11, barY + 13, 18, paint("Icon"), paint("Primary"), warm, z + 16, alpha)
    if hit(copyX, barY, 22, 26) then pcall(toClip, "#" .. hexOf(live)) end
end

local function drawPopups()
    for i = #S.popups, 1, -1 do
        local pop = S.popups[i]
        pop.t = glide(pop.t, pop.dying and 0 or 1, 0.045)
        if pop.dying and pop.t < 0.02 then
            remove(S.popups, i)
        else
            S.layer = Z.popup + i * 10000
            S.floor = S.layer
            local paintPop = Pop[pop.kind]
            if paintPop then paintPop(pop, pop.t, pop.t, Z.popup + i * 100000) end
            if Key.m1.hit and not S.tookClick and pop.box and not pop.dying then
                local bx, by, bw, bh = pop.box[1], pop.box[2], pop.box[3], pop.box[4]
                if not inside(bx, by, bw, bh) then
                    S.tookClick = true
                    shutPopup()
                end
            end
        end
    end
    S.layer = 0
    S.floor = 0
end

local Row = { }

local CARD = 47
local CARD_DESC = 67
local cardBody, cardSkin, cardLock
do

    function cardHeight(item)
        if item.h then return item.h end
        if item.desc then return CARD_DESC end
        return CARD
    end

    function cardSkin(item, x, y, w, h, alpha, z, whole)
        local warm = drift(item, "aHover", (not item.locked) and over(x, y, w, h) and 1 or 0, 0.055)
        local base = item.locked and paint("Black") or paint("ElementBackground")
        local veiled = item.locked and 0.35 or veil("ElementBackground")
        local sink = whole and punch(item) * 2 or 0
        local tone = item.locked and base
            or mix(base, paint("Text"), 0.07 * max(warm, sink / 2))
        squircle(x + sink, y + sink, w - sink * 2, h - sink * 2, Metric.elementCorner, tone, z,
            (1 - veiled) * alpha)
        return warm
    end

    local function cardTags(item, x, y, alpha, z)
        if not item.tags then return 0 end
        local run = 0
        for i, tag in ipairs(item.tags) do
            local title = type(tag) == "table" and tag.Title or tostring(tag)
            local tone = type(tag) == "table" and tag.Color or paint("Primary")
            local wide = width(title, Metric.fDesc - 3) + 14
            squircle(x + run, y, wide, 18, 6, tone, z, 0.9 * alpha)
            middle(title, x + run + 7, y, 18, paint("Black"), Metric.fDesc - 3,
                z + 1 + i, alpha)
            run = run + wide + 6
        end
        return run
    end

    function cardText(item, x, y, w, h, room, alpha, z)
        local pad = Metric.elementPad
        local shade = item.locked and 0.35 or 1
        local mark = 0
        if item.tags then
            local seat = item.desc and (22 + Metric.fElement * CAPHEIGHT / 2 - 9)
                or ((h - 18) / 2)
            mark = cardTags(item, x + pad, y + seat, alpha, z + 20)
        end
        if item.desc then
            label(fit(item.title, room - mark, Metric.fElement, "..."), x + pad + mark, y + 22,
                paint("ElementTitle"), Metric.fElement, z + 4, shade * alpha)
            label(fit(item.desc, room, Metric.fDesc, "..."), x + pad, y + 44,
                paint("ElementDesc"), Metric.fDesc, z + 5, 0.55 * shade * alpha)
        else
            middle(fit(item.title, room - mark, Metric.fElement, "..."), x + pad + mark, y, h,
                paint("ElementTitle"), Metric.fElement, z + 4, shade * alpha)
        end
    end

    function cardLock(item, x, y, w, h, alpha, z)
        if not item.locked then return end
        local title = item.lockedTitle or "Locked"
        local size = Metric.fLocked
        local run = width(title, size)
        local mark = 18
        local block = mark + 8 + run
        local cx = x + w / 2 - block / 2

        stamp(Art.lock, cx + mark / 2, y + h / 2, mark, paint("Text"), z + 10, 0.9 * alpha)
        middle(title, cx + mark + 8, y, h, paint("Text"), size, z + 12, alpha)
    end

    function cardIcon(item, x, y, w, h, alpha, z)
        if not item.icon then return end
        local size = 22
        local shade = item.locked and 0.35 or 1
        if item.iconLeft then
            stamp(item.icon, x + Metric.elementPad + size / 2, y + h / 2, size,
                paint("ElementIcon"), z + 8, shade * alpha)
            return nil, size + 10
        end
        local cx = x + w - Metric.elementPad - size / 2
        stamp(item.icon, cx, y + h / 2, size, paint("ElementIcon"), z + 8, shade * alpha)
        return cx - size / 2 - 8
    end

    function cardBody(item, x, y, w, alpha, z, reserve, whole)
        local h = cardHeight(item)
        local warm = cardSkin(item, x, y, w, h, alpha, z, whole)
        local edge, lead = cardIcon(item, x, y, w, h, alpha, z)
        local right = edge or (x + w - Metric.elementPad)
        lead = lead or 0
        local room = max(20, right - (x + Metric.elementPad) - lead - (reserve or 0))
        cardText(item, x + lead, y, w - lead, h, room, alpha, z)
        cardLock(item, x, y, w, h, alpha, z)
        return h, warm, right
    end
end

local function well(x, y, w, h, radius, glow, alpha, z, sink)
    x, y = x + sink, y + sink
    w, h = w - sink * 2, h - sink * 2
    local face = mix(paint("DropdownTabBackground"), paint("Text"), 0.055 + 0.125 * glow)
    squircle(x, y, w, h, radius, face, z, alpha)
end

function Row.button(item, x, y, w, alpha, z)
    local h = cardBody(item, x, y, w, alpha, z, 0, true)
    if item.locked then return end
    if hit(x, y, w, h) then
        shove(item)
        fire(item.callback)
    end
end

function Row.paragraph(item, x, y, w, alpha, z)
    local pad = Metric.elementPad
    local room = w - pad * 2
    local lines = item.wrapped
    if not lines or item.room ~= room then
        lines = wrap(item.desc or "", room, Metric.fDesc)
        item.wrapped, item.room = lines, room
        item.h = 22 + 14 + #lines * 20 + pad
    end
    local h = item.h

    squircle(x, y, w, h, Metric.elementCorner, paint("ElementBackground"), z,
        (1 - veil("ElementBackground")) * alpha)
    label(item.title, x + pad, y + 24, paint("ElementTitle"), Metric.fElement, z + 4, alpha)
    for i, part in ipairs(lines) do
        label(part, x + pad, y + 44 + (i - 1) * 20, paint("ElementDesc"), Metric.fDesc,
            z + 5 + i, 0.55 * alpha)
    end
end

function Row.divider(item, x, y, w, alpha, z)
    rect(x + Metric.elementPad, y + item.h / 2, w - Metric.elementPad * 2, 1,
        paint("Text"), z, 0.1 * alpha)
end

function Row.section(item, x, y, w, alpha, z)
    if item.boxed then
        squircle(x, y, w, item.h, Metric.elementCorner, paint("SectionBox"), z,
            (1 - veil("SectionBox")) * alpha)
        middle(item.title, x + Metric.elementPad, y, item.h, paint("Text"),
            Metric.fDesc, z + 4, 0.85 * alpha)
        return
    end
    middle(item.title, x + Metric.elementPad, y, item.h, paint("SectionIcon"),
        Metric.fDesc, z + 2, 0.7 * alpha)
end

function Row.space(item, x, y, w, alpha, z)
end

function Row.toggle(item, x, y, w, alpha, z)
    local trackW, trackH = 44, 26
    local h, warm, right = cardBody(item, x, y, w, alpha, z, trackW + 10)
    if item.locked then return end
    local tx = right - trackW
    local ty = y + (h - trackH) / 2

    local lit = drift(item, "aOn", item.value and 1 or 0, item.box and 0.055 or 0.16)
    if item.box then
        local side = 26
        local bend = 9
        local bx = right - side
        local byy = y + (h - side) / 2
        squircle(bx, byy, side, side, bend, paint("Text"), z + 10, 0.15 * alpha)
        if lit > 0.004 then
            local grow = side * lit
            squircle(bx + (side - grow) / 2, byy + (side - grow) / 2, grow, grow,
                max(1, bend * lit), paint("Checkbox"), z + 12, alpha)
        end
        squircleEdge(bx, byy, side, side, bend, paint("CheckboxBorder"), z + 14,
            (1 - veil("CheckboxBorder")) * alpha, 1)
        if lit > 0.02 then
            local mark = (item.mark or 16) * (0.55 + 0.45 * lit)
            stamp(Art.check, bx + side / 2, byy + side / 2, mark, paint("CheckboxIcon"),
                z + 16, lit * alpha)
        end
    else
        squircle(tx, ty, trackW, trackH, trackH / 2, paint("Button"), z + 10, alpha)
        if lit > 0.004 then
            squircle(tx, ty, trackW, trackH, trackH / 2, paint("Toggle"), z + 12, lit * alpha)
        end
        local knob = trackH - 6
        local kx = tx + 3 + (trackW - knob - 6) * lit
        squircle(kx, ty + 3, knob, knob, knob / 2, paint("ToggleBar"), z + 14, alpha)
    end

    if hit(x, y, w, h) then item:Set(not item.value) end
end

function Row.slider(item, x, y, w, alpha, z)
    local barW = 150
    local lead = item.from and 26 or 0
    local tail = item.to and 26 or 0
    local h, warm, right = cardBody(item, x, y, w, alpha, z, barW + 60 + lead + tail)
    if item.locked then return end
    local tx = right - tail - barW
    local ty = y + h / 2 - 3

    local span = max(1e-6, item.max - item.min)
    local part = clamp((item.value - item.min) / span, 0, 1)
    local eased = fade(item, "aFill", part, 0.11)

    squircle(tx, ty, barW, 6, 3, paint("Button"), z + 10, alpha)
    if eased > 0.004 then
        squircle(tx, ty, max(6, barW * eased), 6, 3, paint("Slider"), z + 12, alpha)
    end

    local knob = 14
    local kx = tx + barW * eased - knob / 2
    squircle(kx, y + h / 2 - knob / 2, knob, knob, knob / 2, paint("SliderThumb"), z + 14, alpha)

    if item.from then
        stamp(item.from, tx - 13, y + h / 2, 16, paint("SliderIconFrom"), z + 16, 0.7 * alpha)
    end
    if item.to then
        stamp(item.to, tx + barW + 13, y + h / 2, 16, paint("SliderIconTo"), z + 17, 0.7 * alpha)
    end

    local shown = item.round > 0 and format("%." .. item.round .. "f", item.value)
        or tostring(floor(item.value + 0.5))
    shown = shown .. (item.suffix or "")
    local numX = tx - lead - 12 - width(shown, Metric.fDesc)
    local numY = y + (h - Metric.fDesc * CAPHEIGHT) / 2
    if item.typed and S.focus == item then
        item.left, item.size = numX, Metric.fDesc
        drawEdit(item, item.buf, numX, capTop(numY, Metric.fDesc), Metric.fDesc,
            paint("Text"), z + 18, alpha, 60, true)
    else
        label(shown, numX, numY, paint("ElementDesc"), Metric.fDesc, z + 16, 0.7 * alpha)
    end
    if item.typed and hit(numX - 6, y + h / 2 - 12, width(shown, Metric.fDesc) + 16, 24) then
        S.focus, S.grab = item, nil
        item.buf = shown
        item.at, item.mark = #item.buf, nil
        item.box = { numX - 6, y + h / 2 - 12, 70, 24 }
    end

    if Key.m1.hit and not S.tookClick and inside(tx - 8, ty - 10, barW + 16, 26) then
        S.tookClick, S.slide = true, item
    end
    if S.slide == item then
        if not Key.m1.down then S.slide = nil
        else item:Set(item.min + span * clamp((S.mx - tx) / barW, 0, 1)) end
    end
end

function Row.progress(item, x, y, w, alpha, z)
    local pad = Metric.elementPad
    local h = item.h
    cardSkin(item, x, y, w, h, alpha, z)

    local room = w - pad * 2
    label(fit(item.title, room, Metric.fElement, "..."), x + pad, y + 24,
        paint("ElementTitle"), Metric.fElement, z + 4, alpha)
    if item.desc then
        label(fit(item.desc, room, Metric.fDesc, "..."), x + pad, y + 46,
            paint("ElementDesc"), Metric.fDesc, z + 5, 0.55 * alpha)
    end
    if item.locked then
        cardLock(item, x, y, w, h, alpha, z)
        return
    end

    local barY = y + h - pad - 6
    local part = clamp(item.value, 0, 1)
    local eased = fade(item, "aFill", part, 0.09)

    if item.endless then
        item.roll = ((item.roll or 0) + dt * 0.8) % 1
        local runW = room * 0.3
        local at = x + pad + (room + runW) * item.roll - runW
        local left = max(x + pad, at)
        local right = min(x + pad + room, at + runW)
        squircle(x + pad, barY, room, 6, 3, paint("Button"), z + 10, alpha)
        if right > left then
            squircle(left, barY, right - left, 6, 3, paint("ProgressBar"), z + 12, alpha)
        end
        return
    end

    local bar = room
    if item.shows then
        local shown = format(item.shape, part * 100)
        bar = room - width(shown, Metric.fDesc) - 10
        label(shown, x + pad + bar + 10, barY - 3, paint("ProgressBarText"), Metric.fDesc,
            z + 16, 0.8 * alpha)
    end
    squircle(x + pad, barY, bar, 6, 3, paint("Button"), z + 10, alpha)
    if eased > 0.004 then
        squircle(x + pad, barY, max(6, bar * eased), 6, 3, paint("ProgressBar"), z + 12, alpha)
    end
end

function Row.input(item, x, y, w, alpha, z)
    local boxW = 150
    local h, warm, right = cardBody(item, x, y, w, alpha, z, boxW + 10)
    if item.locked then return end
    local boxH = 30
    local bx = right - boxW
    local by = y + (h - boxH) / 2

    local typing = S.focus == item
    local glow = drift(item, "aBox", (typing or over(bx, by, boxW, boxH)) and 1 or 0, 0.16)
    well(bx, by, boxW, boxH, 10, glow, alpha, z + 10, 0)

    local pad = 10
    local top = capTop(by + (boxH - Metric.fDesc * CAPHEIGHT) / 2 + 1, Metric.fDesc)
    if typing or item.value ~= "" then
        drawEdit(item, item.value, bx + pad, top, Metric.fDesc, paint("Text"), z + 12,
            alpha, boxW - pad * 2, typing)
    else
        text(item.ghost or "", bx + pad, top, paint("Placeholder"), Metric.fDesc, z + 12,
            0.7 * alpha)
    end

    item.box = { bx, by, boxW, boxH }
    if hit(bx, by, boxW, boxH) then
        S.focus, S.grab = item, nil
        item.left, item.size = bx + pad, Metric.fDesc
        if item.wipes and not typing then
            item.value, item.at, item.mark = "", 0, nil
        else
            item.at = caretAt(item, item.value, S.mx)
            item.mark = item.at
            S.caret = item
        end
    end
    if S.caret == item then
        if not Key.m1.down then S.caret = nil
        else item.at = caretAt(item, item.value, S.mx) end
    end
end

local modeList
do
    local Modes = { "Toggle", "Hold", "Always" }

    function modeList(item)
        local list = item.modes
        if not list then
            list = { values = Modes, empty = "Toggle" }
            function list:Set(picked)
                self.pick = picked
                item.mode = lower(picked)
                item.on = false
            end
            item.modes = list
        end
        list.pick = upper(sub(item.mode, 1, 1)) .. sub(item.mode, 2)
        return list
    end
end

function Row.keybind(item, x, y, w, alpha, z)
    local chipH = 28
    local name = S.grab == item and "..." or bindName(item)
    local chipW = max(44, width(name, Metric.fDesc) + 24)
    local h, warm, right = cardBody(item, x, y, w, alpha, z, chipW + 10)
    if item.locked then return end
    local bx = right - chipW
    local by = y + (h - chipH) / 2

    local glow = drift(item, "aChip", (S.grab == item or over(bx, by, chipW, chipH)) and 1 or 0, 0.16)
    well(bx, by, chipW, chipH, 9, glow, alpha, z + 10, 0)
    middle(name, bx + (chipW - width(name, Metric.fDesc)) / 2 + 0.5, by + 1, chipH,
        paint("Text"), Metric.fDesc, z + 12, alpha)

    if hit(bx, by, chipW, chipH) and not item.fixed then S.grab, S.focus = item, nil end
    if rightHit(bx, by, chipW, chipH) then
        local list = modeList(item)
        if popupOpen(list, "list") then
            shutPopup()
        else
            openPopup("list", list, bx + chipW - 112, by + chipH + 6, 112)
        end
    end
end

function Row.dropdown(item, x, y, w, alpha, z)
    local boxW = 160
    local shown = dropText(item)
    local h, warm, right = cardBody(item, x, y, w, alpha, z, boxW + 10)
    if item.locked then return end
    local boxH = 30
    local bx = right - boxW
    local by = y + (h - boxH) / 2

    local open = popupOpen(item, "list")
    local glow = drift(item, "aBox", (open or over(bx, by, boxW, boxH)) and 1 or 0, 0.16)
    well(bx, by, boxW, boxH, 10, glow, alpha, z + 10, 0)

    local pad = 10
    middle(fit(shown, boxW - pad * 2 - 18, Metric.fDesc, "..."), bx + pad, by + 1, boxH,
        paint("Text"), Metric.fDesc, z + 12, 0.85 * alpha)
    chevron(bx + boxW - pad - 5, by + boxH / 2, 5, drift(item, "aTurn", open and 1 or 0, 0.2),
        paint("Icon"), z + 14, 0.8 * alpha)

    if hit(bx, by, boxW, boxH) then
        if open then
            shutPopup()
        else
            openPopup("list", item, bx, by + boxH + 6, item.menuW or boxW)
        end
    end
end

function Row.colour(item, x, y, w, alpha, z)
    local chipW, chipH = 44, 28
    local h, warm, right = cardBody(item, x, y, w, alpha, z, chipW + 10)
    if item.locked then return end
    local bx = right - chipW
    local by = y + (h - chipH) / 2

    local live = hsv(item.hue, item.sat, item.val)
    local glow = drift(item, "aChip", over(bx, by, chipW, chipH) and 1 or 0, 0.16)
    well(bx, by, chipW, chipH, 9, glow, alpha, z + 10, 0)
    if item.clear then
        squircle(bx + 3, by + 3, chipW - 6, chipH - 6, 7,
            mix(paint("Black"), paint("White"), 0.28), z + 12, alpha)
        squircle(bx + 3, by + 3, chipW - 6, chipH - 6, 7, live, z + 14, item.alpha * alpha)
    else
        squircle(bx + 3, by + 3, chipW - 6, chipH - 6, 7, live, z + 14, alpha)
    end

    if hit(bx, by, chipW, chipH) then
        if popupOpen(item, "colour") then shutPopup()
        else openPopup("colour", item, bx + chipW, by + chipH + 6, 200) end
    end
end

local SEARCH_HEIGHT = 39

local function drawSearch(win, x, y, w, alpha, z)
    local h = SEARCH_HEIGHT
    win.hunt = win.hunt or { value = "", at = 0 }
    local box = win.hunt
    local typing = S.focus == box
    local glow = drift(win, "aHunt", (typing or over(x, y, w, h)) and 1 or 0, 0.16)

    squircle(x, y, w, h, 12, mix(paint("WindowSearchBarBackground"), paint("Text"),
        0.03 + 0.04 * glow), z, alpha)

    stamp(Art.search, x + 19, y + h / 2, 16, paint("Icon"), z + 16, 0.7 * alpha)

    local textX = x + 36
    local room = w - 48
    local top = capTop(y + (h - Metric.fDesc * CAPHEIGHT) / 2 + 1, Metric.fDesc)
    if typing or box.value ~= "" then
        drawEdit(box, box.value, textX, top, Metric.fDesc, paint("Text"), z + 18, alpha, room, typing)
    else
        text("Search", textX, top, paint("Placeholder"), Metric.fDesc, z + 18, 0.6 * alpha)
    end

    box.box = { x, y, w, h }
    if hit(x, y, w, h) then
        S.focus, S.grab = box, nil
        box.left, box.size = textX, Metric.fDesc
        box.at = caretAt(box, box.value, S.mx)
        box.mark = box.at
        S.caret = box
    end
    if S.caret == box then
        if not Key.m1.down then S.caret = nil
        else box.at = caretAt(box, box.value, S.mx) end
    end
    return box.value
end

local function matches(title, hunt)
    if hunt == "" then return true end
    return find(lower(tostring(title)), lower(hunt), 1, true) ~= nil
end

local function drawTag(tab, right, cy, alpha, z)
    if not tab.tags or #tab.tags == 0 then return right end
    for i = #tab.tags, 1, -1 do
        local tag = tab.tags[i]
        local run = width(tag.title, Metric.fDesc - 3)
        local wide = run + 14
        local tall = 18
        local tx = right - wide
        squircle(tx, cy - tall / 2, wide, tall, 6, tag.colour, z, 0.9 * alpha)
        middle(tag.title, tx + 7, cy - tall / 2, tall, paint("Black"), Metric.fDesc - 3,
            z + 2, alpha)
        right = tx - 6
    end
    return right
end

local function drawScrollBar(box, x, y, h, alpha, z)
    if not box.reach or box.reach <= 1 then return end
    local shown = h / (h + box.reach)
    local knob = max(24, h * shown)
    local room = h - knob
    local at = y + room * clamp((box.eased or 0) / box.reach, 0, 1)
    local warm = drift(box, "aBar", (box.riding or over(x - 6, y, 15, h)) and 1 or 0, 0.16)

    squircle(x, y, 3, h, 2, paint("Text"), z, 0.06 * alpha)
    squircle(x, at, 3, knob, 2, paint("Text"), z + 2, (0.22 + 0.2 * warm) * alpha)

    if Key.m1.hit and not S.tookClick and inside(x - 6, y, 15, h) then
        S.tookClick = true
        box.riding = inside(x - 6, at, 15, knob) and (S.my - at) or knob / 2
    end
    if box.riding then
        if not Key.m1.down then
            box.riding = nil
        elseif room > 0 then
            box.scroll = clamp((S.my - y - box.riding) / room, 0, 1) * box.reach
            box.eased = box.scroll
        end
    end
end

local function drawResize(win, alpha, z)
    if not win.sizeable then return end
    local x, y = anchor(win)
    local zone = 32
    local zx, zy = x + win.w - zone / 2, y + win.h - zone / 2
    local riding = S.sizing and S.sizing[1] == win
    local warm = drift(win, "aGrip", (riding or over(zx, zy, zone, zone)) and 1 or 0, 0.2)

    local bend = floor(Metric.corner)
    local sheet, side, pad = arcSheet(bend + 5, 3, paint("Text"))
    if sheet then
        img(sheet, x + win.w - bend - pad, y + win.h - bend - pad, side, side, z,
            (0.3 + 0.45 * warm) * alpha)
    end

    if Key.m1.hit and not S.tookClick and inside(zx, zy, zone, zone) then
        S.tookClick = true
        S.sizing = { win, S.mx - win.w, S.my - win.h }
    end
    if riding then
        if not Key.m1.down then
            S.sizing = nil
        else
            win.w = clamp(S.mx - S.sizing[2], win.least[1], win.most[1])
            win.h = clamp(S.my - S.sizing[3], win.least[2], win.most[2])
        end
    end
end

local function drawOpenButton(win)
    if win.open or not win.button then return end
    local button = win.button
    local title = button.title or "Open"
    local scale = button.scale or 1
    local tall = 40 * scale
    local wide = button.bare and tall or (width(title, Metric.fDesc) + 54) * scale
    local w, h = screen()

    button.x = clamp(button.x or (w - wide - 30), 6, max(6, w - wide - 6))
    button.y = clamp(button.y or (h - tall - 30), 6, max(6, h - tall - 6))
    local x, y = floor(button.x), floor(button.y)

    local bend = button.bend or tall / 2
    local warm = drift(button, "aHover", over(x, y, wide, tall) and 1 or 0, 0.16)
    shadow(x, y, wide, tall, bend, Z.note - 60, 0.45, 8)
    squircle(x, y, wide, tall, bend, paint("Background"), Z.note - 20, 1)
    if button.bare then
        stamp(Art.menu, x + wide / 2, y + tall / 2, 20 * scale, paint("Icon"), Z.note - 4, 0.9)
    else
        stamp(Art.menu, x + 24 * scale, y + tall / 2, 18 * scale, paint("Icon"), Z.note - 4, 0.9)
        middle(title, x + 44 * scale, y, tall, paint("Text"), Metric.fDesc, Z.note - 2, 1)
    end

    if Key.m1.hit and not S.tookClick and inside(x, y, wide, tall) then
        S.tookClick = true
        button.press = { S.mx - x, S.my - y }
        button.moved = false
    end
    if button.press then
        if Key.m1.down then
            local nx, ny = S.mx - button.press[1], S.my - button.press[2]
            if abs(nx - x) > 3 or abs(ny - y) > 3 then button.moved = true end
            if not button.still then button.x, button.y = nx, ny end
        else
            if not button.moved then win:Open() end
            button.press = nil
        end
    end
end

local function topbarButton(win, index, glyph, z)
    local x, y = anchor(win)
    local size = Metric.buttonSize
    local right = x + win.w - Metric.pad / 2
    local bx = right - size - (index - 1) * (size + Metric.buttonGap)
    local by = y + (win.barHeight - size) / 2

    local warm = drift(win, "aBtn" .. index, over(bx, by, size, size) and 1 or 0, 0.055)
    if warm > 0.01 then
        squircle(bx, by, size, size, 10, paint("Hover"), z, 0.06 * warm)
    end

    local ink = paint("WindowTopbarButtonIcon")
    local shade = 1 - 0.25 * warm
    local cx, cy = bx + size / 2, by + size / 2
    local reach = Metric.buttonIcon / 2

    if glyph == "close" then
        line(cx - reach + 2, cy - reach + 2, cx + reach - 2, cy + reach - 2, ink, z + 2, 1.6, shade)
        line(cx + reach - 2, cy - reach + 2, cx - reach + 2, cy + reach - 2, ink, z + 3, 1.6, shade)
    elseif glyph == "minimise" then
        line(cx - reach + 2, cy, cx + reach - 2, cy, ink, z + 2, 1.6, shade)
    else
        local arm = reach - 3
        local corner = 4
        line(cx - arm, cy - arm, cx - arm + corner, cy - arm, ink, z + 2, 1.6, shade)
        line(cx - arm, cy - arm, cx - arm, cy - arm + corner, ink, z + 3, 1.6, shade)
        line(cx + arm, cy - arm, cx + arm - corner, cy - arm, ink, z + 4, 1.6, shade)
        line(cx + arm, cy - arm, cx + arm, cy - arm + corner, ink, z + 5, 1.6, shade)
        line(cx - arm, cy + arm, cx - arm + corner, cy + arm, ink, z + 6, 1.6, shade)
        line(cx - arm, cy + arm, cx - arm, cy + arm - corner, ink, z + 7, 1.6, shade)
        line(cx + arm, cy + arm, cx + arm - corner, cy + arm, ink, z + 8, 1.6, shade)
        line(cx + arm, cy + arm, cx + arm, cy + arm - corner, ink, z + 9, 1.6, shade)
    end

    return hit(bx, by, size, size)
end

local function drawTopbar(win, alpha)
    local x, y = anchor(win)
    local z = Z.chrome

    local left = x + Metric.pad / 2 + 4
    if win.macTop then left = left + 3 * 12 + 2 * 8 + Metric.pad end
    if win.icon then
        local mark = 26
        if win.iconMask then
            stamp(win.icon, left + mark / 2, y + win.barHeight / 2, mark,
                paint("WindowTopbarIcon"), z + 1, alpha)
        else
            img(win.icon, left, y + (win.barHeight - mark) / 2, mark, mark, z + 1, alpha)
        end
        left = left + mark + 12
    end
    local titleInk = Metric.fTitle * CAPHEIGHT
    local authorInk = Metric.fAuthor * CAPHEIGHT
    local stack = win.author and (titleInk + 5 + authorInk) or titleInk
    local titleCap = y + (win.barHeight - stack) / 2
    label(win.title, left, titleCap, paint("WindowTopbarTitle"), Metric.fTitle, z + 2, alpha)
    if win.author then
        label(win.author, left, titleCap + titleInk + 5, paint("WindowTopbarAuthor"),
            Metric.fAuthor, z + 3, 0.65 * alpha)
    end

    if win.macTop then
        local dot = 12
        local gap = 8
        local cy = y + win.barHeight / 2
        local shades = { hex("FF5F57"), hex("FEBC2E"), hex("28C840") }
        for i = 1, 3 do
            local cx = x + Metric.pad + dot / 2 + (i - 1) * (dot + gap)
            local warm = drift(win, "aMac" .. i, over(cx - dot, cy - dot, dot * 2, dot * 2)
                and 1 or 0, 0.16)
            circ(cx, cy, dot / 2, shades[i], z + 10 + i * 2, true, 1, (0.85 + 0.15 * warm) * alpha)
            if hit(cx - dot / 2, cy - dot / 2, dot, dot) then
                if i == 1 then win:Close()
                elseif i == 2 then win:Minimise()
                else win:Fullscreen() end
            end
        end
    else
        if topbarButton(win, 1, "close", z + 10) then win:Close() end
        if topbarButton(win, 2, "fullscreen", z + 20) then win:Fullscreen() end
        if topbarButton(win, 3, "minimise", z + 30) then win:Minimise() end
    end

    if hit(x, y, win.w - Metric.buttonSize * 3 - 40, win.barHeight) then
        S.drag = { S.mx - win.x, S.my - win.y, win }
    end
end

local function drawTabRow(win, tab, x, y, width, alpha, z)
    local height = Metric.tabHeight * (tab.grown or 1)
    local live = tab == win.tab
    local warm = drift(tab, "aHover", over(x, y, width, height) and 1 or 0, 0.045)
    local lit = drift(tab, "aLive", live and 1 or 0, 0.045)

    local deep = 1 - veil("TabBackgroundActive")
    local soft = 1 - veil("TabBackgroundHover")
    local wash = max(warm * soft * 0.6, lit * deep)
    local tone = mix(ground(), paint("TabBackgroundActive"), wash)
    squircle(x, y, width, height, 10, tone, z, alpha)

    local ink = paint("TabIcon")
    local iconAlpha = lerp(1 - veil("TabIcon"), 1 - veil("TabIconActive"), lit)
    local mark = tab.showTitle == false and (x + width / 2) or (x + Metric.pad)
    if tab.icon then
        if tab.iconShape then
            local plate = 26
            local bend = tab.iconShape == "Square" and 8 or plate / 2
            local tone = tab.iconColour or paint("Primary")
            squircle(mark - plate / 2, y + (height - plate) / 2, plate, plate, bend, tone,
                z + 2, (0.75 + 0.25 * lit) * alpha)
            stamp(tab.icon, mark, y + height / 2, Metric.tabIcon - 3, paint("Black"),
                z + 4, alpha)
        else
            stamp(tab.icon, mark, y + height / 2, Metric.tabIcon, ink, z + 4, iconAlpha * alpha)
        end
    end

    if tab.showTitle ~= false then
        local textX = x + Metric.pad + Metric.tabIcon / 2 + Metric.tabGap + 4
        local edge = drawTag(tab, x + width - Metric.pad, y + height / 2, alpha, z + 20)
        local room = edge - textX - 4
        local shade = lerp(1 - veil("TabText"), 1, lit)
        middle(fit(tab.title, room, Metric.fTab, "..."), textX, y, height,
            paint("TabTitle"), Metric.fTab, z + 6, shade * alpha)
    end

    if hit(x, y, width, height) then win:Select(tab) end
end

local function drawUser(win, x, y, wide, alpha, z)
    local card = 46
    local face = 30
    squircle(x, y, wide, card, 12, mix(ground(), paint("Text"), 0.05), z, alpha)
    if win.user.Icon then
        local sheet, mask = artwork(win.user.Icon)
        if sheet and mask then
            stamp(sheet, x + 10 + face / 2, y + card / 2, face - 6, paint("Icon"), z + 4, alpha)
        elseif sheet then
            img(sheet, x + 10, y + (card - face) / 2, face, face, z + 4, alpha)
        end
    else
        squircle(x + 10, y + (card - face) / 2, face, face, 9, paint("Primary"), z + 4, alpha)
        labelmid(upper(sub(tostring(win.user.Title or "?"), 1, 1)), x + 10 + face / 2,
            y + card / 2 - 5, paint("Black"), Metric.fElement, z + 6, alpha)
    end
    local textX = x + 10 + face + 10
    local room = wide - (textX - x) - 10
    label(fit(tostring(win.user.Title or ""), room, Metric.fDesc, "..."), textX, y + 20,
        paint("Text"), Metric.fDesc, z + 8, alpha)
    if win.user.Desc then
        label(fit(tostring(win.user.Desc), room, Metric.fDesc - 2, "..."), textX, y + 34,
            paint("Placeholder"), Metric.fDesc - 2, z + 9, 0.8 * alpha)
    end
    return card
end

local function drawSidebar(win, alpha)
    local x, y = anchor(win)
    local inset = Metric.pad / 2
    local top = y + win.barHeight
    local wide = win.sidebar - inset * 2
    local z = Z.panel

    local hunt = ""
    local height = win.h - win.barHeight - inset
    if win.footer then height = height - 22 end
    if win.user then
        local card = drawUser(win, x + inset, top, wide, alpha, Z.search + 200)
        top = top + card + Metric.gap
        height = height - card - Metric.gap
    end
    if not win.hideSearch then
        height = height - SEARCH_HEIGHT - 6
        hunt = drawSearch(win, x + inset, top + height + 6, wide, alpha, Z.search)
    end

    local shown = { }
    for _, tab in ipairs(win.tabs) do
        if tab.section then
            tab.grown = 1
            shown[#shown + 1] = tab
        else
            local hidden = (tab.band and tab.band.shut) or not matches(tab.title, hunt)
            tab.grown = drift(tab, "aFold", hidden and 0 or 1, 0.09)
            if tab.grown > 0.004 then shown[#shown + 1] = tab end
        end
    end

    local content = 0
    for _, tab in ipairs(shown) do
        content = content + ((tab.section and 26 or Metric.tabHeight) + Metric.gap) * tab.grown
    end

    local shift = scrollBox(win.side, x + inset, top, wide, height, content)
    local at = top - shift

    clipTo(x, top, win.sidebar, height)
    for _, tab in ipairs(shown) do
        local rowH = (tab.section and 26 or Metric.tabHeight) * tab.grown
        if at + rowH > top and at < top + height and tab.grown > 0.02 then
            if tab.section then
                local warm = drift(tab, "aHover", over(x + inset, at, wide, rowH) and 1 or 0, 0.16)
                local seat = Z.side + tab.index * Span.tab
                middle(tab.title, x + inset + Metric.pad, at, rowH, paint("TabText"),
                    Metric.fTab - 2, seat + 4, (0.5 + 0.3 * warm) * alpha)
                chevron(x + inset + wide - Metric.pad, at + rowH / 2, 5,
                    drift(tab, "aFold", tab.shut and 0 or 1, 0.2), paint("SectionExpandIcon"),
                    seat + 6, (0.35 + 0.3 * warm) * alpha)
                if hit(x + inset, at, wide, rowH) then tab.shut = not tab.shut end
            else
                drawTabRow(win, tab, x + inset, at, wide, alpha * tab.grown,
                    Z.side + tab.index * Span.tab)
            end
        end
        at = at + rowH + Metric.gap * tab.grown
    end
    unclip()
    scrollGrab(win.side, x + inset, top, wide, height)

    drawScrollBar(win.side, x + win.sidebar - 5, top, height, alpha, Z.search + 100)

    if win.footer then
        middle(fit(tostring(win.footer), wide - 12, Metric.fDesc - 2, "..."), x + inset + 6,
            y + win.h - inset - 22, 22, paint("Placeholder"), Metric.fDesc - 2,
            Z.search + 300, 0.7 * alpha)
    end
end

local function drawPanel(win, alpha)
    local x, y = anchor(win)
    local inset = Metric.pad / 2
    local px0 = x + win.sidebar
    local py0 = y + win.barHeight
    local pw = win.w - win.sidebar - inset
    local ph = win.h - win.barHeight - inset

    if win.panel then
        squircle(px0, py0, pw, ph, Metric.corner - inset, deck(), Z.panel, alpha)
    end

    local tab = win.tab
    if not tab then return end

    local pad = Metric.elementPad
    local innerX = px0 + pad
    local innerW = pw - pad * 2
    local content = 0
    for _, item in ipairs(tab.items) do
        if item.shown ~= false then content = content + item.h + Metric.gap end
    end

    local enter = drift(tab, "aEnter", 1, 0.2)
    local shift = scrollBox(tab, px0, py0, pw, ph, content + pad * 2)
    local at = py0 + pad - shift + (1 - enter) * 14

    drawScrollBar(tab, px0 + pw - 6, py0 + pad, ph - pad * 2, alpha, Z.row - 200)

    local viewTop, viewBottom = py0 + pad, py0 + ph - pad
    clipTo(px0, viewTop, pw, viewBottom - viewTop)
    for index, item in ipairs(tab.items) do
        local paintRow = item.shown ~= false and Row[item.kind]
        if paintRow and at + item.h > viewTop and at < viewBottom then
            local edge = 1
            if at < viewTop then
                edge = clamp((at + item.h - viewTop) / max(1, item.h), 0, 1)
            elseif at + item.h > viewBottom then
                edge = clamp((viewBottom - at) / max(1, item.h), 0, 1)
            end
            paintRow(item, innerX, at, innerW, alpha * enter * edge * edge,
                Z.row + index * Span.row)
        end
        item.top = at
        if item.shown ~= false then at = at + item.h + Metric.gap end
    end
    unclip()
    scrollGrab(tab, px0, py0, pw, ph)

end

local function drawWindow(win)
    local shown = drift(win, "aShow", win.open and 1 or 0, 0.077)
    if shown <= 0.004 then return end

    local w, h = screen()
    win.x = clamp(win.x, -win.w + 60, w - 60)
    win.y = clamp(win.y, 0, h - win.barHeight)

    local x, y = anchor(win)
    local alpha = shown
    local roll = drift(win, "aRoll", win.rolled and 1 or 0, 0.09)
    local tall = lerp(win.h, win.barHeight, roll)

    shadow(x, y, win.w, tall, Metric.corner, Z.shadow, 0.6 * alpha, 10)
    squircle(x, y, win.w, tall, Metric.corner, ground(), Z.body, alpha)

    if roll < 0.995 then
        local inner = alpha * (1 - roll)
        clipTo(x, y, win.w, tall)
        drawSidebar(win, inner)
        drawPanel(win, inner)
        unclip()
    end
    drawTopbar(win, alpha)

    if S.drag and S.drag[3] == win then
        if not Key.m1.down then
            S.drag = nil
        else
            win.x, win.y = S.mx - S.drag[1], S.my - S.drag[2]
        end
    end

    if roll > 0.02 then
        if S.sizing and S.sizing[1] == win then S.sizing = nil end
        return
    end

    drawResize(win, alpha, Z.chrome + 200)

    local bar = 200
    local bx = x + (win.w - bar) / 2
    local by = y + win.h + 4
    local onBar = over(bx - 8, by - 8, bar + 16, 20)
    local pull = drift(win, "aPull", (S.drag and S.drag[3] == win or onBar) and 1 or 0, 0.2)
    squircle(bx, by, bar, 4, 2, paint("Text"), Z.chrome, (0.2 + 0.35 * pull) * alpha)

    if Key.m1.hit and not S.tookClick and inside(bx - 8, by - 8, bar + 16, 20) then
        S.tookClick = true
        S.drag = { S.mx - win.x, S.my - win.y, win }
    end
end

local Flags = { }
local Watchers = { }

local function setFlag(item, value)
    if not item.flag then return end
    Flags[item.flag] = value
    local list = Watchers[item.flag]
    if not list then return end
    for i = 1, #list do fire(list[i], value, item) end
end

local Piece = { }
Piece.__index = Piece

function Piece:SetTitle(text)
    self.title = tostring(text or "")
    self.wrapped = nil
    return self
end

function Piece:SetDesc(text)
    self.desc = text and tostring(text) or nil
    self.wrapped = nil
    return self
end

function Piece:SetVisible(on)
    self.shown = on ~= false
    return self
end

function Piece:SetLocked(on)
    self.locked = on and true or false
    return self
end

function Piece:SetIcon(spec)
    self.icon = artwork(spec)
    return self
end

function Piece:OnChanged(fn)
    if type(fn) ~= "function" then return self end
    if self.flag then
        Watchers[self.flag] = Watchers[self.flag] or { }
        insert(Watchers[self.flag], fn)
    else
        local before = self.callback
        self.callback = function(...)
            fire(before, ...)
            fn(...)
        end
    end
    return self
end

function Piece:Destroy()
    local list = self.tab and self.tab.items
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == self then remove(list, i) end
    end
end

local function spell(cfg, title)
    if type(cfg) == "string" or type(cfg) == "number" then
        return { Title = tostring(cfg) }
    end
    return cfg or { Title = title }
end

local function newItem(tab, kind, cfg, height)
    cfg = spell(cfg)
    local item = {
        kind = kind,
        tab = tab,
        title = cfg.Title or cfg.Name or "Element",
        desc = cfg.Desc or cfg.Description,
        icon = artwork(cfg.Icon),
        locked = cfg.Locked and true or false,
        lockedTitle = cfg.LockedTitle,
        callback = cfg.Callback,
        flag = cfg.Flag,
        tags = cfg.Tags,
        iconLeft = cfg.IconAlign == "Left",
        h = height + (cfg.Size == "Large" and 8 or cfg.Size == "Small" and -8 or 0),
        shown = true,
    }
    setmetatable(item, Piece)
    tab.items[#tab.items + 1] = item
    return item
end

local Tab = { }
Tab.__index = Tab

function Tab:Button(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "button", cfg, cfg.Desc and CARD_DESC or CARD)
    item.icon = item.icon or Art.mousepointerclick
    return item
end

function Tab:Paragraph(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "paragraph", cfg, CARD_DESC)
    return item
end

function Tab:Divider(cfg)
    local item = newItem(self, "divider", cfg or { }, 12)
    return item
end

function Tab:Section(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    local item = newItem(self, "section", cfg, cfg.Box and 40 or 28)
    item.boxed = cfg.Box and true or false
    return item
end

function Tab:Space(cfg)
    local item = newItem(self, "space", cfg or { }, (cfg and cfg.Height) or 10)
    return item
end

function Tab:Toggle(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "toggle", cfg, cfg.Desc and CARD_DESC or CARD)
    item.box = lower(tostring(cfg.Type or "")) == "checkbox"
    item.mark = cfg.IconSize or 16
    item.value = cfg.Value or cfg.Default or false
    setFlag(item, item.value)
    function item:Set(on)
        on = on and true or false
        if self.value == on then return end
        self.value = on
        setFlag(self, on)
        fire(self.callback, on)
    end
    function item:Get() return self.value end
    return item
end

function Tab:Slider(cfg)
    local item = newItem(self, "slider", cfg, cfg.Desc and CARD_DESC or CARD)
    local step = cfg.Step or cfg.Value and cfg.Value.Step
    item.min = cfg.Min or (cfg.Value and cfg.Value.Min) or 0
    item.max = cfg.Max or (cfg.Value and cfg.Value.Max) or 100
    item.round = cfg.Rounding or cfg.Round or 0
    item.suffix = cfg.Suffix or ""
    item.step = step
    item.typed = cfg.IsTextbox ~= false
    item.from = artwork(cfg.Icons and cfg.Icons.From)
    item.to = artwork(cfg.Icons and cfg.Icons.To)
    item.value = cfg.Default or (cfg.Value and cfg.Value.Default) or item.min
    setFlag(item, item.value)
    function item:Set(v)
        if self.step and self.step > 0 then
            v = self.min + floor((v - self.min) / self.step + 0.5) * self.step
        end
        local scale = 10 ^ self.round
        v = floor(clamp(v, self.min, self.max) * scale + 0.5) / scale
        if v == self.value then return end
        self.value = v
        setFlag(self, v)
        fire(self.callback, v)
    end
    function item:Get() return self.value end
    return item
end

function Tab:Dropdown(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "dropdown", cfg, cfg.Desc and CARD_DESC or CARD)
    item.values = cfg.Values or cfg.Options or { }
    item.many = cfg.Multi and true or false
    item.menuW = cfg.MenuWidth
    item.hunt = cfg.SearchBarEnabled and true or false
    item.none = cfg.AllowNone and true or false
    item.empty = cfg.Placeholder or "None"
    item.pick = cfg.Value or cfg.Default
    if item.many and type(item.pick) ~= "table" then item.pick = { } end
    setFlag(item, item.pick)
    function item:Set(value)
        self.pick = value
        setFlag(self, value)
        fire(self.callback, value)
    end
    function item:Get() return self.pick end
    function item:Refresh(list)
        self.values = list or { }
        if not self.many then self.pick = nil end
    end
    return item
end

function Tab:Input(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "input", cfg, cfg.Desc and CARD_DESC or CARD)
    item.value = cfg.Value or cfg.Default or ""
    item.ghost = cfg.Placeholder or ""
    item.wipes = cfg.ClearTextOnFocus and true or false
    setFlag(item, item.value)
    function item:Set(v)
        self.value = tostring(v or "")
        setFlag(self, self.value)
        fire(self.callback, self.value)
    end
    function item:Get() return self.value end
    return item
end

function Tab:Keybind(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "keybind", cfg, cfg.Desc and CARD_DESC or CARD)
    item.bind = cfg.Value and lower(tostring(cfg.Value)) or cfg.Default
        and lower(tostring(cfg.Default)) or nil
    item.mode = lower(tostring(cfg.Mode or "Toggle"))
    item.fixed = cfg.CanChange == false
    item.banned = cfg.Blacklist
    item.on = false
    setFlag(item, item.bind)
    function item:Set(key)
        self.bind = key and lower(tostring(key)) or nil
        setFlag(self, self.bind)
        fire(self.callback, self.bind)
    end
    function item:Get() return self.bind end
    S.binds[#S.binds + 1] = item
    return item
end

function Tab:Colorpicker(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "colour", cfg, cfg.Desc and CARD_DESC or CARD)
    local start = cfg.Default or cfg.Value or paint("Primary")
    item.hue, item.sat, item.val = tohsv(start)
    item.colour = start
    item.clear = cfg.Transparency ~= nil
    item.alpha = 1 - (cfg.Transparency or 0)
    setFlag(item, start)
    function item:Push()
        self.colour = hsv(self.hue, self.sat, self.val)
        setFlag(self, self.colour)
        fire(self.callback, self.colour, 1 - self.alpha)
    end
    function item:Set(c)
        self.hue, self.sat, self.val = tohsv(c)
        self:Push()
    end
    function item:Get() return self.colour end
    return item
end

function Tab:Progressbar(cfg)
    cfg = spell(cfg)
    local item = newItem(self, "progress", cfg, cfg.Desc and (CARD_DESC + 14) or (CARD + 20))
    item.value = cfg.Value or 0
    item.shows = cfg.ShowValue ~= false
    item.endless = cfg.Indeterminate and true or false
    item.shape = cfg.Format or "%d%%"
    function item:Set(v)
        self.value = clamp(v, 0, 1)
        fire(self.callback, self.value)
    end
    return item
end

local Window = { }
Window.__index = Window

function Window:Tab(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    local tab = setmetatable({
        title = cfg.Title or "Tab",
        icon = artwork(cfg.Icon),
        iconShape = cfg.IconShape,
        iconColour = cfg.IconColor,
        showTitle = cfg.ShowTabTitle ~= false,
        locked = cfg.Locked and true or false,
        window = self,
        items = { },
        index = #self.tabs + 1,
    }, Tab)
    self.tabs[#self.tabs + 1] = tab
    if not self.tab and not tab.section then self.tab = tab end
    return tab
end

local Band = { }
Band.__index = Band

function Band:Tab(cfg)
    local tab = self.window:Tab(cfg)
    local tabs = self.window.tabs
    remove(tabs)

    local at = 0
    for i = 1, #tabs do
        if tabs[i] == self.mark then at = i end
    end
    while at < #tabs and tabs[at + 1].band == self.mark do at = at + 1 end

    tab.band = self.mark
    insert(tabs, at + 1, tab)
    for i = 1, #tabs do tabs[i].index = i end
    return tab
end

function Window:Section(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    local mark = { title = cfg.Title or "Section", section = true, shut = false,
        index = #self.tabs + 1 }
    self.tabs[#self.tabs + 1] = mark
    return setmetatable({ window = self, mark = mark }, Band)
end

function Window:SetLogo(spec)
    self.icon, self.iconMask = artwork(spec)
    return self.icon ~= nil
end

function Window:Element(flag)
    for _, tab in ipairs(self.tabs) do
        if tab.items then
            for _, item in ipairs(tab.items) do
                if item.flag == flag then return item end
                if item.items then
                    for _, kid in ipairs(item.items) do
                        if kid.flag == flag then return kid end
                    end
                end
            end
        end
    end
end

function Window:Select(tab)
    if not tab or tab.section or tab.locked then return end
    if self.tab == tab then return end
    self.tab = tab
    tab.aEnter = 0
    tab.scroll, tab.eased = 0, 0
end

function Window:Close()
    self.open = false
    fire(self.onClose)
end

function Window:Open()
    self.open = true
    fire(self.onOpen)
end

function Window:Toggle()
    if self.open then self:Close() else self:Open() end
end

function Window:Minimise()
    self.rolled = not self.rolled
    return self.rolled
end

function Window:Fullscreen()
    local w, h = screen()
    if self.full then
        self.w, self.h, self.x, self.y = self.full[1], self.full[2], self.full[3], self.full[4]
        self.full = nil
    else
        self.full = { self.w, self.h, self.x, self.y }
        self.x, self.y = 20, 20
        self.w, self.h = w - 40, h - 40
    end
end

function Window:Destroy()
    for i = #S.windows, 1, -1 do
        if S.windows[i] == self then remove(S.windows, i) end
    end
end

local Base = { }
for slot, value in pairs(Metric) do Base[slot] = value end

local function rescale(factor)
    S.scale = clamp(tonumber(factor) or 1, 0.5, 2)
    for slot, value in pairs(Base) do Metric[slot] = value * S.scale end
    Metric.corner = floor(Base.corner * S.scale)
    Metric.elementCorner = floor(Base.elementCorner * S.scale)
end

local Config
do
    local Store = { }

    local function folderName(win)
        return "NonUI/" .. (win.folder or "Config")
    end

    local function configPath(win, name)
        return folderName(win) .. "/" .. name .. ".json"
    end

    local function walk(list, visit)
        if not list then return end
        for _, item in ipairs(list) do
            visit(item)
            if item.items then walk(item.items, visit) end
        end
    end

    local function collect(win)
        local out = { }
        for _, tab in ipairs(win.tabs) do
            walk(tab.items, function(item)
                if not item.flag or not item.Get then return end
                local ok, value = pcall(item.Get, item)
                if not ok then return end
                local slot
                if typeof and typeof(value) == "Color3" then
                    slot = { kind = "colour", hex = hexOf(value), alpha = item.alpha }
                else
                    slot = { kind = "plain", value = value }
                end
                if item.kind == "keybind" then slot.mode = item.mode end
                out[item.flag] = slot
            end)
        end
        return out
    end

    local function restore(win, blob)
        for _, tab in ipairs(win.tabs) do
            walk(tab.items, function(item)
                local saved = item.flag and blob[item.flag]
                if not saved or not item.Set then return end
                if saved.mode then item.mode = saved.mode end
                if saved.kind == "colour" then
                    if saved.alpha then item.alpha = saved.alpha end
                    pcall(item.Set, item, hex(saved.hex))
                else
                    pcall(item.Set, item, saved.value)
                end
            end)
        end
    end

    Config = { }
    Config.__index = Config

    function Config:Save(name)
        name = name or self.name
        if not name or name == "" then return false, "no name" end
        local blob = collect(self.window)
        Store[name] = blob
        if not writefile or not game then return true, "memory only" end

        local ok, text = pcall(function()
            return game:GetService("HttpService"):JSONEncode(blob)
        end)
        if not ok then return false, "cannot encode" end

        local wrote = pcall(function()
            if makefolder and isfolder and not isfolder(folderName(self.window)) then
                makefolder(folderName(self.window))
            end
            writefile(configPath(self.window, name), text)
        end)
        if not wrote then return false, "cannot write" end
        return true
    end

    function Config:Load(name)
        name = name or self.name
        local blob = Store[name]
        if not blob and readfile and isfile then
            local path = configPath(self.window, name)
            if isfile(path) then
                local ok, text = pcall(readfile, path)
                if ok then
                    local fine, parsed = pcall(function()
                        return game:GetService("HttpService"):JSONDecode(text)
                    end)
                    if fine then blob = parsed end
                end
            end
        end
        if type(blob) ~= "table" then return false end
        restore(self.window, blob)
        return true
    end

    function Config:Delete(name)
        name = name or self.name
        Store[name] = nil
        if delfile and isfile then
            local path = configPath(self.window, name)
            if isfile(path) then pcall(delfile, path) end
        end
        return true
    end

    function Config:AllConfigs()
        local names = { }
        for name in pairs(Store) do names[#names + 1] = name end
        if listfiles and isfolder and isfolder(folderName(self.window)) then
            local ok, files = pcall(listfiles, folderName(self.window))
            if ok then
                for _, path in ipairs(files) do
                    local found = match(path, "([^/\\]+)%.json$")
                    if found and not Store[found] then names[#names + 1] = found end
                end
            end
        end
        sort(names)
        return names
    end

    function Config:SetAutoLoad(name)
        self.auto = name or self.name
        if writefile then
            pcall(function()
                if makefolder and isfolder and not isfolder(folderName(self.window)) then
                    makefolder(folderName(self.window))
                end
                writefile(folderName(self.window) .. "/autoload.txt", self.auto)
            end)
        end
        return self.auto
    end

    function Config:ClearAutoLoad()
        self.auto = nil
        if delfile and isfile then
            local path = folderName(self.window) .. "/autoload.txt"
            if isfile(path) then pcall(delfile, path) end
        end
    end

    function Config:LoadAutoLoad()
        local name = self.auto
        if not name and readfile and isfile then
            local path = folderName(self.window) .. "/autoload.txt"
            if isfile(path) then
                local ok, text = pcall(readfile, path)
                if ok then name = gsub(tostring(text), "%s", "") end
            end
        end
        if not name or name == "" then return false end
        self.auto = name
        return self:Load(name)
    end

    function Config:GetAutoLoadConfig()
        return self.auto
    end
end

function Window:CreateConfig(name)
    local made = setmetatable({ window = self, name = name or "default" }, Config)
    self.configs = self.configs or { }
    self.configs[made.name] = made
    return made
end

function Window:GetConfig(name)
    self.configs = self.configs or { }
    return self.configs[name]
end

function Window:SetUIScale(factor)
    rescale(factor)
    return S.scale
end

function Window:SetToggleKey(key)
    S.key = lower(tostring(key or "rshift"))
    return S.key
end

function Window:SetPanelBackground(on)
    self.panel = on and true or false
    return self.panel
end

function Window:EditOpenButton(cfg)
    cfg = cfg or { }
    if cfg.Enabled == false then
        self.button = nil
        return self
    end
    self.button = self.button or { }
    self.button.title = cfg.Title or self.button.title or "Open"
    return self
end

function Tab:Select()
    self.window:Select(self)
    return self
end

function Tab:Tag(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    self.tags = self.tags or { }
    local tag = {
        title = cfg.Title or "Tag",
        colour = cfg.Color or paint("Primary"),
    }
    self.tags[#self.tags + 1] = tag
    return tag
end

function Tab:Group(cfg)
    if type(cfg) == "string" then cfg = { Title = cfg } end
    local group = newItem(self, "group", cfg, 44)
    group.items = { }
    group.shut = cfg.Closed and true or false

    local holder = setmetatable({
        window = self.window,
        items = group.items,
        parent = self,
    }, Tab)
    group.holder = holder

    function group:Set(open) self.shut = not open end
    return holder, group
end

function Tab:Image(cfg)
    local item = newItem(self, "picture", cfg, (cfg.Height or 120) + 20)
    item.art = cfg.Image and Art[gsub(lower(tostring(cfg.Image)), "%-", "")] or nil
    item.tall = cfg.Height or 120
    return item
end

function Tab:Code(cfg)
    local item = newItem(self, "code", cfg, 0)
    item.lines = { }
    for piece in string.gmatch(tostring(cfg.Code or ""), "[^\n]+") do
        item.lines[#item.lines + 1] = piece
    end
    item.h = 26 + #item.lines * 18 + 14
    return item
end

function Row.group(item, x, y, w, alpha, z)
    local pad = Metric.elementPad
    local headH = 40
    local open = item.shut and 0 or 1
    local grown = drift(item, "aOpen", open, item.shut and 0.118 or 0.15)

    local inner = 0
    for _, kid in ipairs(item.items) do inner = inner + kid.h + Metric.gap end
    if inner > 0 then inner = inner + pad - Metric.gap end
    local h = headH + inner * grown
    item.h = h

    squircle(x, y, w, h, Metric.elementCorner, paint("SectionBoxBackground"), z,
        (1 - veil("SectionBoxBackground")) * alpha)

    middle(item.title, x + pad, y, headH, paint("Text"), Metric.fElement, z + 4, alpha)
    chevron(x + w - pad - 6, y + headH / 2, 6, grown, paint("SectionExpandIcon"), z + 6,
        (1 - veil("SectionExpandIcon")) * alpha)

    if hit(x, y, w, headH) then item.shut = not item.shut end
    if grown <= 0.02 then return end

    local at = y + headH
    for index, kid in ipairs(item.items) do
        local paintRow = Row[kid.kind]
        if paintRow and at + kid.h < y + h + 2 then
            paintRow(kid, x + pad, at, w - pad * 2, grown * alpha, z + 200 + index * Span.kid)
        end
        at = at + kid.h + Metric.gap
    end
end

function Row.picture(item, x, y, w, alpha, z)
    squircle(x, y, w, item.h, Metric.elementCorner, paint("ElementBackground"), z,
        (1 - veil("ElementBackground")) * alpha)
    if item.art then
        stamp(item.art, x + w / 2, y + item.h / 2, min(item.tall, w - 20), paint("Icon"),
            z + 4, alpha)
    end
end

function Row.code(item, x, y, w, alpha, z)
    local pad = Metric.elementPad
    squircle(x, y, w, item.h, Metric.elementCorner, paint("Black"), z, 0.55 * alpha)
    for i, part in ipairs(item.lines) do
        runText(part, x + pad, y + 18 + (i - 1) * 18, paint("Placeholder"), Metric.fDesc - 1,
            z + 4 + i, 0.9 * alpha)
    end
    if not item.copies then return end

    local mark = 18
    local mx = x + w - pad - mark
    local my = y + pad - 4
    local warm = drift(item, "aCopy", over(mx, my, mark, mark) and 1 or 0, 0.16)
    melt(Art.copy, mx + mark / 2, my + mark / 2, mark, paint("Icon"), paint("Primary"),
        warm, z + 40, (0.55 + 0.4 * warm) * alpha)
    if hit(mx, my, mark, mark) then
        pcall(toClip, item.code)
        fire(item.onCopy, item.code)
    end
end

local Dialog = nil

function Window:Popup(cfg)
    Dialog = {
        title = cfg.Title or "",
        content = cfg.Content or "",
        icon = cfg.Icon and Art[gsub(lower(tostring(cfg.Icon)), "%-", "")] or nil,
        buttons = cfg.Buttons or { { Title = "OK" } },
        show = 0,
        window = self,
    }
    return Dialog
end

function Window:Dialog(cfg)
    return self:Popup(cfg)
end

local function dialogOpen()
    return Dialog ~= nil and not Dialog.dying
end

local function drawDialog()
    if not Dialog then return end
    local w, h = screen()
    Dialog.show = glide(Dialog.show, Dialog.dying and 0 or 1, 0.045)
    if Dialog.dying and Dialog.show < 0.02 then
        Dialog = nil
        return
    end

    local alpha = Dialog.show
    rect(0, 0, w, h, paint("Black"), Z.popup - 1000, 0.5 * alpha)

    local wide = 340
    local lines = wrap(Dialog.content, wide - 48, Metric.fDesc)
    local tall = 74 + #lines * 20 + 56
    local x = floor((w - wide) / 2)
    local y = floor((h - tall) / 2)

    S.layer, S.floor = Z.popup + 500000, Z.popup + 500000
    shadow(x, y, wide, tall, 18, Z.popup + 400000, 0.6 * alpha, 10)
    squircle(x, y, wide, tall, 18, paint("DialogBackground"), Z.popup + 500000, alpha)

    local titleCap = y + 36
    local textX = x + 24
    if Dialog.icon then
        stamp(Dialog.icon, x + 36, titleCap + Metric.fElement * CAPHEIGHT / 2, 22,
            paint("DialogIcon"), Z.popup + 500010, alpha)
        textX = x + 58
    end
    label(Dialog.title, textX, titleCap, paint("DialogTitle"), Metric.fElement,
        Z.popup + 500012, alpha)
    for i, part in ipairs(lines) do
        label(part, x + 24, y + 64 + (i - 1) * 20, paint("DialogContent"), Metric.fDesc,
            Z.popup + 500014 + i, 0.6 * alpha)
    end

    local count = #Dialog.buttons
    local gap = 8
    local room = wide - 48 - gap * (count - 1)
    local each = room / max(1, count)
    local by = y + tall - 56
    for i, button in ipairs(Dialog.buttons) do
        local bx = x + 24 + (i - 1) * (each + gap)
        local warm = drift(button, "aHover", over(bx, by, each, 36) and 1 or 0, 0.16)
        local sink = punch(button)
        local tone = button.Variant == "Primary" and paint("Primary") or paint("Text")
        squircle(bx + sink * 2, by + sink, each - sink * 4, 36 - sink * 2, 12, tone,
            Z.popup + 500030 + i * 10,
            (button.Variant == "Primary" and 1 or (0.08 + 0.05 * warm)) * alpha)
        local ink = button.Variant == "Primary" and paint("Black") or paint("Text")
        middle(button.Title or "OK", bx + (each - width(button.Title or "OK", Metric.fDesc)) / 2,
            by, 36, ink, Metric.fDesc, Z.popup + 500034 + i * 10, alpha)
        if hit(bx, by, each, 36) then
            shove(button)
            fire(button.Callback)
            Dialog.dying = true
        end
    end
    S.layer, S.floor = 0, 0
end

local function drawTip()
    if not S.tip then return end
    local body, mx, my = S.tip[1], S.tip[2], S.tip[3]
    local wide = width(body, Metric.fDesc - 1) + 20
    local tall = 28
    local w, h = screen()
    local x = clamp(mx + 16, 4, w - wide - 4)
    local y = clamp(my + 20, 4, h - tall - 4)
    shadow(x, y, wide, tall, 8, Z.tip - 40, 0.5, 6)
    squircle(x, y, wide, tall, 8, paint("Tooltip"), Z.tip, 1)
    middle(body, x + 10, y, tall, paint("TooltipText"), Metric.fDesc - 1, Z.tip + 4, 1)
end

local function tipAt(body)
    S.tip = { body, S.mx, S.my }
end

local function notify(cfg)
    S.notes[#S.notes + 1] = {
        title = tostring(cfg.Title or ""),
        content = cfg.Content and tostring(cfg.Content) or nil,
        icon = cfg.Icon and Art[gsub(lower(tostring(cfg.Icon)), "%-", "")] or nil,
        life = tonumber(cfg.Duration) or 5,
        shut = cfg.CanClose ~= false,
        born = now(),
        show = 0,
        slip = 1,
    }
end

local function drawNotes()
    local w, h = screen()
    local wide = 300
    local x = w - wide - 20
    local at = 20

    for i = #S.notes, 1, -1 do
        local note = S.notes[i]
        local age = now() - note.born
        local leaving = age > note.life
        note.show = glide(note.show, leaving and 0 or 1, leaving and 0.25 or 0.2)
        if leaving and note.show < 0.02 then
            remove(S.notes, i)
        else
            local lines = note.content and wrap(note.content, wide - 70, Metric.fDesc) or { }
            local tall = 30 + #lines * 20 + 18
            note.slip = glide(note.slip, 0, 0.2)
            local nx = x + note.slip * (wide + 30)
            local ny = at
            local alpha = note.show

            shadow(nx, ny, wide, tall, 14, Z.note - 40, 0.4 * alpha, 8)
            squircle(nx, ny, wide, tall, 14, paint("Notification"), Z.note + i * 200, alpha)

            local titleSize = Metric.fDesc + 1
            local titleCap = ny + 22
            local textX = nx + 16
            if note.icon then
                stamp(note.icon, nx + 28, titleCap + titleSize * CAPHEIGHT / 2, 20,
                    paint("Icon"), Z.note + i * 200 + 4, alpha)
                textX = nx + 48
            end
            label(note.title, textX, titleCap, paint("NotificationTitle"), titleSize,
                Z.note + i * 200 + 6, alpha)
            for n, part in ipairs(lines) do
                label(part, textX, ny + 44 + (n - 1) * 20, paint("NotificationContent"),
                    Metric.fDesc, Z.note + i * 200 + 8 + n, 0.6 * alpha)
            end

            if note.shut then
                local mark = 16
                local mx = nx + wide - 16 - mark
                local my = ny + 16
                local warm = drift(note, "aShut", over(mx, my, mark, mark) and 1 or 0, 0.16)
                melt(Art.x, mx + mark / 2, my + mark / 2, mark, paint("Icon"), paint("Text"),
                    warm, Z.note + i * 200 + 30, (0.5 + 0.4 * warm) * alpha)
                if hit(mx, my, mark, mark) then note.born = now() - note.life end
            end

            local left = clamp(1 - age / note.life, 0, 1)
            squircle(nx + 16, ny + tall - 8, (wide - 32) * left, 3, 2,
                paint("Primary"), Z.note + i * 200 + 40, 0.8 * alpha)

            at = at + tall + 10
        end
    end
end

local function runBinds()
    if S.grab or S.focus then return end
    for i = 1, #S.binds do
        local item = S.binds[i]
        if item.mode == "always" and not item.on then
            item.on = true
            fire(item.callback, item.bind, true)
        end
        local k = item.mode ~= "always" and item.bind and Key[item.bind]
        if k then
            if item.armed then
                if not k.down then item.armed = nil end
            elseif item.mode == "hold" then
                if item.on ~= k.down then
                    item.on = k.down
                    fire(item.callback, item.bind, item.on)
                end
            elseif k.hit then
                item.on = not item.on
                fire(item.callback, item.bind, item.on)
            end
        end
    end
end

local function grabKey()
    if not S.grab then return end
    local item = S.grab
    for _, name in ipairs(Order) do
        local k = Key[name]
        local banned = item.banned and find(concat(item.banned, ","), name, 1, true)
        if k.hit and name ~= "m1" and not banned then
            item:Set(name == "esc" and nil or name)
            item.armed = true
            S.grab, k.hit = nil, false
            Key.m1.hit, Key.m2.hit = false, false
            break
        end
    end
end

local function typing()
    if S.grab then return end
    local target = S.focus
    if type(target) ~= "table" then return end
    if target.buf then
        if Key.esc.hit or Key.enter.hit then
            if Key.enter.hit then target:Set(tonumber(target.buf) or target.value) end
            target.buf, S.focus = nil, nil
            Key.esc.hit, Key.enter.hit = false, false
            return
        end
        edit(target, "buf", "[%d%.%-]", 12)
        return
    end
    if Key.esc.hit or Key.enter.hit then
        S.focus = nil
        Key.esc.hit, Key.enter.hit = false, false
        fire(target.callback, target.value)
        return
    end
    if edit(target, "value") then
        setFlag(target, target.value)
    end
end

local function frame()
    S.frames = S.frames + 1
    readInput()

    local toggle = Key[S.key]
    if toggle and toggle.hit and not S.grab and not S.focus then
        for _, win in ipairs(S.windows) do win:Toggle() end
    end

    if Key.m1.hit and type(S.focus) == "table" then
        local seat = S.focus.box
        if not (seat and inside(seat[1], seat[2], seat[3], seat[4])) then
            S.tookClick = true
            S.focus = nil
        end
    end

    newFrame()
    S.tip = nil
    drawPopups()
    if anyPopup() or dialogOpen() then S.floor = Z.popup end
    for _, win in ipairs(S.windows) do
        drawWindow(win)
        drawOpenButton(win)
    end
    drawNotes()
    drawDialog()
    drawTip()

    runBinds()
    grabKey()
    typing()

    hideRest()
end

local function report(msg)
    msg = tostring(msg)
    if S.lastError == msg then return end
    S.lastError = msg
    local out = (type(warn) == "function") and warn or print
    pcall(out, "[non] " .. msg)
end

local function step()
    local ok, err = pcall(frame)
    if not ok then
        report(err)
        pcall(hideRest)
    end
end

local function kill()
    S.alive = false
    wipe()
    S.windows, S.notes, S.popups, S.binds = { }, { }, { }, { }
    S.focus, S.grab, S.caret = nil, nil, nil
    pcall(grabInput, true)
end

local NonUI = { }

function NonUI:CreateWindow(cfg)
    cfg = cfg or { }
    local w, h = screen()
    local size = cfg.Size or { 580, 460 }
    local bar = cfg.Topbar or { }
    local win = setmetatable({
        title = cfg.Title or "NonUI",
        author = cfg.Author,
        w = size[1] or 580,
        h = size[2] or 460,
        open = true,
        tabs = { },
        tab = nil,
        side = { },
        onOpen = cfg.OnOpen,
        onClose = cfg.OnClose,
        hideSearch = cfg.HideSearchBar and true or false,
        panel = cfg.HidePanelBackground ~= true,
        sizeable = cfg.Resizable ~= false,
        sidebar = cfg.SideBarWidth or 200,
        macTop = bar.ButtonsType == "Mac",
        barHeight = bar.Height or 52,
        least = cfg.MinSize or { 420, 320 },
        most = cfg.MaxSize or { 1600, 1000 },
        user = cfg.User,
        footer = cfg.Footer,
        button = (cfg.OpenButton and cfg.OpenButton.Enabled == false) and nil or {
            title = (cfg.OpenButton and cfg.OpenButton.Title) or "Open",
            bare = cfg.OpenButton and cfg.OpenButton.OnlyIcon or false,
            still = cfg.OpenButton and cfg.OpenButton.Draggable == false or false,
            bend = cfg.OpenButton and cfg.OpenButton.CornerRadius,
            scale = (cfg.OpenButton and cfg.OpenButton.Scale) or 1,
        },
    }, Window)
    win.icon, win.iconMask = artwork(cfg.Icon or cfg.Logo)
    win.x = floor((w - win.w) / 2)
    win.y = floor((h - win.h) / 2)
    S.windows[#S.windows + 1] = win
    if cfg.Theme then wear(cfg.Theme) end
    if cfg.Transparency then sheerness(1 - clamp(cfg.Transparency, 0, 0.95)) end
    if cfg.KeySystem or cfg.ToggleKey then S.key = lower(tostring(cfg.ToggleKey or "rshift")) end
    return win
end

function NonUI:Notify(cfg)
    notify(cfg or { })
end

function NonUI:SetTheme(name)
    return wear(name)
end

function NonUI:SetTransparency(value)
    return 1 - sheerness(1 - clamp(tonumber(value) or 0, 0, 0.95))
end

function NonUI:GetTransparency()
    return 1 - sheerness(1)
end

function NonUI:AddTheme(name, colours)
    if type(colours) ~= "table" then return false end
    Palette[name] = colours
    return true
end

function NonUI:GetThemes()
    local names = { }
    for name in pairs(Palette) do names[#names + 1] = name end
    sort(names)
    return names
end

function NonUI:Flags()
    return Flags
end

function NonUI:Get(flag)
    return Flags[flag]
end

function NonUI:Set(flag, value)
    for _, win in ipairs(S.windows) do
        local piece = win:Element(flag)
        if piece and piece.Set then
            piece:Set(value)
            return true
        end
    end
    Flags[flag] = value
    return false
end

function NonUI:Watch(flag, fn)
    if type(fn) ~= "function" then return end
    Watchers[flag] = Watchers[flag] or { }
    insert(Watchers[flag], fn)
end

function NonUI:Bind(key, fn)
    local hook = { bind = lower(tostring(key)), mode = "toggle", callback = fn, on = false }
    S.binds[#S.binds + 1] = hook
    return hook
end

function NonUI:Unload()
    kill()
end

NonUI.Themes = Palette
NonUI.Icons = Art
NonUI.Step = step

if _G.__nonui then pcall(_G.__nonui.stop) end
_G.__nonui = { stop = kill, state = S }

if task and task.spawn then
    task.spawn(function()
        while S.alive do
            step()
            if task.wait then task.wait() elseif wait then wait() else break end
        end
    end)
end

pcall(function()
    if type(getgenv) == "function" then
        getgenv().NonUI = NonUI
    end
end)
_G.NonUI = NonUI
NonUI.Version = "1.0.0"

return NonUI

end)();
