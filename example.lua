local Non = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/NonUI/main/NonUI.lua"))() or NonUI

local Window = Non:CreateWindow({
    Title = "NonUI",
    Folder = "NonUI",
    Theme = "Dark",
    Size = { 680, 540 },
    OpenButton = { Title = "Open", Draggable = true },
})

local function say(title, body, icon)
    Non:Notify({ Title = title, Content = body, Icon = icon or "circle-check", Duration = 4 })
end

local Show = Window:Section({ Title = "Showcase" })
local Look = Window:Section({ Title = "Look" })

local Controls = Show:Tab({
    Title = "Controls",
    Icon = "sliders-horizontal",
    IconShape = "Squircle",
    IconColor = Color3.fromRGB(120, 190, 255),
})
local Pickers = Show:Tab({ Title = "Pickers", Icon = "chevrons-up-down" })
local Panels = Show:Tab({ Title = "Panels", Icon = "table-of-contents" })
local Popups = Show:Tab({ Title = "Popups", Icon = "bell" })
local Themes = Look:Tab({ Title = "Themes", Icon = "palette" })

do
    Controls:Section("Buttons")
    Controls:Button({ Title = "Plain button" })
    Controls:Button({ Title = "With a description", Desc = "and an icon", Icon = "play" })
    Controls:Button({ Title = "Locked", Desc = "cannot be pressed", Locked = true })
    Controls:Button({ Title = "Icon on the left", Icon = "star", IconAlign = "Left" })

    Controls:Section("Toggles")
    Controls:Toggle({ Title = "Switch", Default = true })
    Controls:Toggle({ Title = "Checkbox", Desc = "the square variant", Type = "Checkbox" })
    Controls:Toggle({ Title = "Locked switch", Locked = true })

    Controls:Section("Sliders")
    Controls:Slider({ Title = "Plain", Min = 0, Max = 100, Default = 40 })
    Controls:Slider({
        Title = "With icons",
        Desc = "click the number to type one",
        Min = 0,
        Max = 100,
        Default = 65,
        Suffix = "%",
        Icons = { From = "moon", To = "sun" },
    })
    Controls:Slider({ Title = "Steps of five", Min = 0, Max = 100, Default = 25, Step = 5 })
    Controls:Slider({ Title = "Two decimals", Min = 0, Max = 1, Default = 0.35, Rounding = 2 })

    Controls:Section("Short forms")
    Controls:Toggle("Just a title")
    Controls:Slider("Positional slider", 0, 100, 55)
    local watched = Controls:Toggle({ Title = "Watched flag", Flag = "demo_watch" })
    Controls:Button({
        Title = "Flip it from code",
        Desc = "Non:Set(\"demo_watch\", ...)",
        Icon = "refresh-cw",
        Callback = function() Non:Set("demo_watch", not Non:Get("demo_watch")) end,
    })
    Non:Watch("demo_watch", function(value)
        say("Flag changed", tostring(value), "check")
    end)

    local hidden = Controls:Button({ Title = "I can be hidden" })
    Controls:Toggle({
        Title = "Show the button above",
        Default = true,
        Callback = function(on) hidden:SetVisible(on) end,
    })
    Controls:Toggle({
        Title = "Lock the button above",
        Callback = function(on) hidden:SetLocked(on) end,
    })

    Controls:Section("Keys")
    Controls:Keybind({ Title = "Right click for the mode", Default = "g" })
    Controls:Keybind({ Title = "Hold only", Default = "h", Mode = "Hold" })
    Controls:Keybind({ Title = "Cannot be changed", Default = "j", CanChange = false })
end

do
    Pickers:Section("Dropdowns")
    local list = Pickers:Dropdown({
        Title = "Single choice",
        Values = { "First", "Second", "Third" },
        Default = "First",
    })
    Pickers:Dropdown({
        Title = "Multiple choice",
        Desc = "tick as many as you like",
        Values = { "Head", "Torso", "Arms", "Legs" },
        Multi = true,
    })
    Pickers:Dropdown({
        Title = "With a search",
        Desc = "type to filter the list",
        Values = { "Alder", "Birch", "Cedar", "Elm", "Fir", "Maple", "Oak", "Pine", "Willow" },
        SearchBarEnabled = true,
        AllowNone = true,
    })
    Pickers:Dropdown({ Title = "Empty", Values = { }, Placeholder = "nothing here" })
    Pickers:Button({
        Title = "Refill the first one",
        Icon = "refresh-cw",
        Callback = function() list:Refresh({ "Fresh", "List", "Of", "Options" }) end,
    })

    Pickers:Section("Colours")
    Pickers:Colorpicker({ Title = "Pick a colour" })
    Pickers:Colorpicker({ Title = "Starts red", Default = Color3.fromRGB(230, 70, 70) })
    Pickers:Colorpicker({
        Title = "With transparency",
        Desc = "an alpha strip appears",
        Default = Color3.fromRGB(120, 200, 255),
        Transparency = 0.3,
    })

    Pickers:Section("Text")
    Pickers:Input({ Title = "Empty", Placeholder = "type here" })
    Pickers:Input({ Title = "Filled", Default = "already typed" })
    Pickers:Input({ Title = "Clears on focus", Default = "click me", ClearTextOnFocus = true })
end

do
    Panels:Paragraph({
        Title = "Paragraph",
        Desc = "Text wraps across as many lines as it needs and the card grows to fit it.",
    })

    local group = Panels:Group({ Title = "A group" })
    group:Toggle({ Title = "Inside a group", Default = true })
    group:Slider({ Title = "Also inside", Min = 0, Max = 100, Default = 30 })
    group:Button({ Title = "And a button" })

    Panels:Group({ Title = "Starts closed", Closed = true }):Toggle({ Title = "Hidden until opened" })

    Panels:Section({ Title = "Boxed section", Box = true })
    Panels:Button({
        Title = "Tagged",
        Desc = "tags sit before the title",
        Tags = { { Title = "new", Color = Color3.fromRGB(150, 220, 160) } },
    })
    Panels:Button({ Title = "Small", Size = "Small" })
    Panels:Button({ Title = "Large", Size = "Large" })

    Panels:Section("Progress")
    Panels:Progressbar({ Title = "With a value", Value = 0.62 })
    Panels:Progressbar({ Title = "Custom format", Value = 0.4, Format = "%d of 100" })
    Panels:Progressbar({ Title = "No number", Value = 0.8, ShowValue = false })
    Panels:Progressbar({ Title = "Endless", Desc = "no value to show", Indeterminate = true })

    Panels:Section("Static")
    Panels:Divider()
    Panels:Code({
        Title = "Code",
        CanCopied = true,
        Code = "local Window = Non:CreateWindow({\n    Title = \"my hub\",\n    Topbar = { ButtonsType = \"Mac\" },\n})",
    })
    Panels:Space({ Height = 16 })
end

do
    Popups:Section("Notifications")
    Popups:Button({
        Title = "Plain",
        Icon = "bell",
        Callback = function() say("Hello", "a short line of content") end,
    })
    Popups:Button({
        Title = "Long content",
        Icon = "info",
        Callback = function()
            say("Heads up", "This one carries enough text to wrap onto a second line inside the card.", "info")
        end,
    })

    Popups:Section("Dialogs")
    Popups:Button({
        Title = "Two answers",
        Icon = "triangle-alert",
        Callback = function()
            Window:Popup({
                Title = "Close the menu?",
                Icon = "circle-alert",
                Content = "The floating button brings it back.",
                Buttons = {
                    { Title = "Stay" },
                    { Title = "Close", Variant = "Primary", Callback = function() Window:Close() end },
                },
            })
        end,
    })
    Popups:Button({
        Title = "One answer",
        Icon = "circle-check",
        Callback = function()
            Window:Popup({
                Title = "Saved",
                Icon = "check",
                Content = "Nothing to decide, just a message.",
                Buttons = { { Title = "Fine", Variant = "Primary" } },
            })
        end,
    })
end

do
    Themes:Dropdown({
        Title = "Palette",
        Desc = "sixteen of them",
        Values = Non:GetThemes(),
        Default = "Dark",
        Callback = function(name)
            Non:SetTheme(name)
            say("Theme", name, "palette")
        end,
    })
    Themes:Slider({
        Title = "Scale",
        Min = 70,
        Max = 130,
        Default = 100,
        Suffix = "%",
        Callback = function(v) Window:SetUIScale(v / 100) end,
    })
    Themes:Slider({
        Title = "Transparency",
        Desc = "fades the whole window",
        Min = 0,
        Max = 60,
        Default = 0,
        Suffix = "%",
        Callback = function(v) Non:SetTransparency(v / 100) end,
    })
    Themes:Toggle({
        Title = "Panel background",
        Default = true,
        Callback = function(on) Window:SetPanelBackground(on) end,
    })
    Themes:Button({
        Title = "Roll up",
        Desc = "same as the minimise button",
        Icon = "minimize",
        Callback = function() Window:Minimise() end,
    })
    Themes:Keybind({
        Title = "Toggle key",
        Default = "rshift",
        Callback = function(key) Window:SetToggleKey(key) end,
    })
end

Controls:Select()

say("NonUI", "ready", "check")
