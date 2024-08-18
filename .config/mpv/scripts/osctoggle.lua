local osc_always_on = false

local function toggle_osc_always_never()
    osc_always_on = not osc_always_on
    mp.commandv('script-message', 'osc-visibility', osc_always_on and 'always' or 'never', "")
end

mp.add_key_binding(nil, 'toggle-osc-auto-always', toggle_osc_always_never)