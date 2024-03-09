local save = ya.sync(function(st, cwd, output)
	if cx.active.current.cwd == Url(cwd) then
		st.output = output
		ya.render()
	end
end)

return {
	setup = function(st)
		Header.cwd = function()
			local cwd = cx.active.current.cwd
			if st.cwd ~= cwd then
				st.cwd = cwd
				ya.manager_emit("plugin", { st._name, args = ya.quote(tostring(cwd)) })
			end

			return ui.Line.parse(st.output or "")
		end
	end,

	entry = function(_, args)
		local output = Command("starship"):arg("prompt"):cwd(args[1]):env("STARSHIP_SHELL", ""):output()
		if output then
			save(args[1], output.stdout:gsub("^%s+", ""))
		end
	end,
}
