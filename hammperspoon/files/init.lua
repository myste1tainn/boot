local karabiner = hs.loadSpoon("Karabiner")
local aerospace = hs.loadSpoon("Aerospace")

karabiner:run()
aerospace:run()
hs.keycodes.inputSourceChanged(function()
	karabiner:run()
	aerospace:run()
end)
