local M = {}
local dap = require("dap")
local dapui = require("dapui")
local ui_float = require("ui.float")

function M.BreakHabitsWindow()
    -- Define the size of the floating window
    local width = 50
    local height = 10

    -- Create the scratch buffer displayed in the floating window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Get the current UI
    local ui = vim.api.nvim_list_uis()[1]

    -- Create the floating window
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = (ui.width/2) - (width/2),
        row = (ui.height/2) - (height/2),
        anchor = 'NW',
        style = 'minimal',
    }

    -- local win = ui_float.percentage_range_window(1, 65536, {})

    -- vim.api.nvim_win_call(win.win_id, ':terminal')

    -- return vim.api.nvim_open_win(buf, 1, opts)
end

function M.setup()
    dap.adapters.java = function(callback)
        local address = '127.0.0.1'
        local port = 5005
        local full = address .. ':' .. port
        local job = require('plenary.job')
        local args = {
            'spring-boot:run',
            '-P local',
            '-Dmaven.wagon.http.ssl.insecure=true',
            '-Dmaven.wagon.http.ssl.allowall=true',
            '-Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=' .. port ..  '"' ,
        }
        print('running with args =', table.concat(args, ' '))
        -- local jobId = job:new({
        --     command = 'mvn',
        --     args = { args },
        --     cwd = vim.fn.getcwd(),
        --     on_exit = function(j, return_val)
        --         print('return_val =', return_val)
        --         print('j:result() =', j:result())
        --     end,
        -- }):start()
        -- local job_id = vim.api.nvim_call_function('termopen', {"$SHELL"});

        job_id = BreakHabitsWindow()
        vim.api.nvim_chan_send(job_id, "mvn " .. table.concat(args, ' ') .. "\n")

        -- FIXME:
        -- Here a function needs to trigger the `vscode.java.startDebugSession` LSP command
        -- The response to the command must be the `port` used below
        callback({
            type = 'server';
            host = address;
            port = port;
        })
    end

    local main_class = "th.co.ktb.next.mobile.openaccount.MobileOpenAccountApplication"
    local main_class_name = "MobileOpenAccountApplication"

    dap.set_log_level('trace')

    dap.configurations.java = {

        -- For remote debugging
        {
            type = 'java';
            request = 'attach';
            name = "Debug (Attach) - Remote";
            hostName = "127.0.0.1";
            port = 5005;
        },

        -- Spefic project setup
        -- {
        --     -- You need to extend the classPath to list your dependencies.
        --     -- `nvim-jdtls` would automatically add the `classPaths` property if it is missing
        --     -- classPaths = {},

        --     -- If using the JDK9+ module system, this needs to be extended
        --     -- `nvim-jdtls` would automatically populate this property
        --     -- modulePaths = {},

        --     -- If using multi-module projects, remove otherwise.
        --     -- projectName = main_class_name,

        --     -- javaExec = vim.env.HOME .. "/.sdkman/candidates/java/current/bin/java",
        --     mainClass = main_class,
        --     name = main_class_name,
        --     vmArgs = "-Dspring.profiles.active=local",

        --     -- request = "launch",
        --     type = "java",
        --     command = "/opt/homebrew/bin/mvn",
        --     args = {"-P", "local"}
        -- }
    }
end

function M.start_debug()
    -- local result = handle:read("*a")
    -- vim.api.nvim_echo({{result}}, true, {})
    dapui.toggle()

    -- dap.continue will
    dap.continue()

end


return M
