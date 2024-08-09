local save = ya.sync(function(st, cwd, output)
    if cx.active.current.cwd == Url(cwd) then
        st.output = output
        ya.render()
    end
end)

-- Helper function for accessing `try_cut_character` state
---@return boolean
local try_cut_character = ya.sync(function(st)
    return st.try_cut_character
end)

return {
    ---User arguments for setup method
    ---@class SetupArgs
    ---@field config_file string Absolute path to a starship config file
    ---@field try_cut_character boolean Whether the plugin should attempt to cut the character/prompt icon from the end of the prompt. Only useful for single line prompts.

    --- Setup plugin
    --- @param st table State
    --- @param args SetupArgs|nil
    setup = function(st, args)
        --- Pass args to state
        st.try_cut_character = args and args.try_cut_character or false

        -- Replace default header widget
        Header:children_remove(1, Header.LEFT)
        Header:children_add(function()
            return ui.Line.parse(st.output or "")
        end, 1000, Header.LEFT)

        -- Check for custom starship config file
        local config_file = nil
        if args ~= nil and args.config_file ~= nil then
            local url = Url(args.config_file)
            if url.is_regular then
                config_file = ya.quote(tostring(url), true)
            end
        end

        -- Pass current working directory and custom config path (if specified) to the plugin's entry point
        ps.sub("cd", function()
            local cwd = cx.active.current.cwd
            if st.cwd ~= cwd then
                st.cwd = cwd
                local args = ya.quote(tostring(cwd), true)
                if config_file ~= nil then
                    args = string.format("%s %s", args, config_file)
                end

                ya.manager_emit("plugin", {
                    st._id,
                    args = args,
                })
            end
        end)
    end,

    entry = function(_, args)
        local command = Command("starship"):arg("prompt"):cwd(args[1]):env("STARSHIP_SHELL", "")

        -- Point to custom starship config
        if args[2] ~= nil then
            command = command:env("STARSHIP_CONFIG", args[2])
        end

        local output = command:output()
        if not output then
            return
        end

        local cut = 0
        if try_cut_character() then
            local character = Command("starship")
                :arg("module")
                :arg("character")
                :cwd(args[1])
                :env("STARSHIP_SHELL", "")
                :output()
            if character ~= nil then
                cut = string.len(character.stdout)
            end
        end

        local line = output.stdout:gsub("^%s+", "")
        save(args[1], ya.truncate(line, { max = string.len(line) - cut }))
    end,
}
