--- @since 25.5.28

-- For development
--[[ local function notify(message) ]]
--[[     ya.notify({ title = "Starship", content = message, timeout = 3 }) ]]
--[[ end ]]

local save = ya.sync(function(st, _cwd, output)
    st.output = output
    ya.render()
end)

-- Helper function for accessing the `config_file` state variable
---@return string
local get_config_file = ya.sync(function(st)
    return st.config_file
end)

return {
    ---User arguments for setup method
    ---@class Setuparg
    ---@field config_file string Absolute path to a starship config file
    ---@field hide_flags boolean Whether to hide all flags (such as filter and search). Recommended for themes which are intended to take the full width of the terminal.
    ---@field flags_after_prompt boolean Whether to place flags (such as filter and search) after the starship prompt. By default this is true.

    --- Setup plugin
    --- @param st table State
    --- @param arg Setuparg|nil
    setup = function(st, arg)
        local hide_flags = false
        local flags_after_prompt = true

        -- Check setup arg
        if arg ~= nil then
            if arg.config_file ~= nil then
                local url = Url(arg.config_file)
                if url.is_regular then
                    local config_file = arg.config_file

                    -- Manually replace '~' and '$HOME' at the start of the path with the OS environment variable
                    local home = os.getenv("HOME")
                    if home then
                        home = tostring(home)
                        config_file = config_file:gsub("^~", home):gsub("^$HOME", home)
                    end

                    st.config_file = config_file
                end
            end

            if arg.hide_flags ~= nil then
                hide_flags = arg.hide_flags
            end

            if arg.flags_after_prompt ~= nil then
                flags_after_prompt = arg.flags_after_prompt
            end
        end

        -- Replace default header widget
        Header:children_remove(1, Header.LEFT)
        Header:children_add(function(self)
            local max = self._area.w - self._right_width
            if max <= 0 then
                return ""
            end

            if hide_flags or not st.output then
                return ui.Align.parse(st.output or "")
            end

            -- Split `st.output` at the first line break (or keep as is if none was found)
            local output = st.output:match("([^\n]*)\n?") or st.output

            local flags = self:flags()
            if flags_after_prompt then
                output = output .. " " .. flags
            else
                output = flags .. " " .. output
            end

            return ui.Align.parse(output)
        end, 1000, Header.LEFT)

        -- Pass current working directory and custom config path (if specified) to the plugin's entry point
        ---Callback for subscribers to update the prompt
        local callback = function()
            local cwd = cx.active.current.cwd
            if st.cwd ~= cwd then
                st.cwd = cwd

                ya.emit("plugin", {
                    st._id,
                    ya.quote(tostring(cwd), true),
                })
            end
        end

        -- Subscribe to events
        ps.sub("cd", callback)
        ps.sub("tab", callback)
    end,

    entry = function(_, job)
        local arg = job.arg
        local command = Command("starship")
            :arg("prompt")
            :stdin(Command.INHERIT)
            :cwd(arg[1])
            :env("STARSHIP_SHELL", "")

        -- Point to custom starship config
        local config_file = get_config_file()
        if config_file then
            command = command:env("STARSHIP_CONFIG", config_file)
        end

        local output = command:output()
        if output then
            save(arg[1], output.stdout:gsub("^%s+", ""))
        end
    end,
}
