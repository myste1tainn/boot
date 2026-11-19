local karabiner = hs.loadSpoon("Karabiner")
local aerospace = hs.loadSpoon("Aerospace")

karabiner:run()
aerospace:run()
hs.keycodes.inputSourceChanged(function()
	karabiner:run()
	aerospace:run()
end)

-- Rift matches monitors only by exact name, so its config is generated with the
-- names of the monitors connected now (see ~/.boot/rift/build-config.sh).
-- Rebuild it when a monitor comes or goes, and when the template is edited.
local riftDir = os.getenv("HOME") .. "/.boot/rift"
local riftRebuild = hs.timer.delayed.new(1, function()
	local names = {}
	for _, screen in ipairs(hs.screen.allScreens()) do
		table.insert(names, screen:name())
	end
	hs.task.new("/bin/bash", nil, { riftDir .. "/build-config.sh", table.unpack(names) }):start()
end)
riftRebuild:start()
-- Globals, so they are not garbage-collected.
RiftScreenWatcher = hs.screen.watcher.new(function() riftRebuild:start() end):start()
RiftTemplateWatcher = hs.pathwatcher.new(riftDir .. "/files/.config/rift/", function() riftRebuild:start() end):start()
