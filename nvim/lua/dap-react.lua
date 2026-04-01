local M = {}
local dap = require("dap")
local dapui = require("dapui")

function M.setup()
    dap.adapters.chrome = {
        type = "executable",
        command = "node",
        args = {os.getenv("HOME") .. "/Downloads/vscode-chrome-debug/out/src/chromeDebug.js"}
    }

    -- change this to javascript if needed
    dap.configurations.javascriptreact = {{
        type = "chrome",
        request = "attach",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${workspaceFolder}"
    }}

    -- change to typescript if needed
    dap.configurations.typescriptreact = {{
        type = "chrome",
        request = "attach",
        program = "${file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${workspaceFolder}"
    }}
end

function M.start_debug()
    local cmd = "/Applications/Brave\\ Browser.app/Contents/MacOS/Brave\\ Browser --user-data-dir=/tmp --remote-debugging-port=9222"
    -- Run the command in background since this command blocks, until browser is killed
    os.execute(cmd .. " > /tmp/nvim_lua_dap-react.lua.txt 2>&1 &")
    -- local handle = io.popen(cmd)
    -- if handle == nil then
    --     print("failed to start debugging cannot launch browser")
    --     return
    -- end

    -- local result = handle:read("*a")
    -- vim.api.nvim_echo({{result}}, true, {})
    dapui.toggle()

    -- dap.continue will
    dap.continue()
end


return M
