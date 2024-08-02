local save = ya.sync(function(st, cwd, output)
    if cx.active.current.cwd == Url(cwd) then
        st.output = output
        ya.render()
    end
end)

return {
    ---User arguments for setup method
    ---@class SetupArgs
    ---@field config_file string Absolute path to a starship config file

    --- Setup plugin
    --- @param st table State
    --- @param args SetupArgs|nil
    setup = function(st, args)
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
        if output then
            save(args[1], output.stdout:gsub("^%s+", ""))
        end
    end,
}
