local dap = require("dap")
local dapui = require("dapui")
local M = {}

dap.set_log_level('TRACE')

function M.setup()
  dap.configurations.lua = {
    {
      type = 'nlua',

      request = 'attach',
      name = "Attach to running Neovim instance",
      -- host = function()
      --     local value = vim.fn.input('Host [127.0.0.1]: ')
      --     if value ~= "" then
      --         return value
      --     end
      --     return '127.0.0.1'
      -- end,
      -- port = function ()
      --     local val = tonumber(vim.fn.input('Port: '))
      --     assert(val, "Please provide a port number")
      --     return val
      -- end,
      host = '127.0.0.1',
      port = 4040,
      -- host = function ()
      --     print("dap.configurations.lua -> host config called attach")
      --     return '127.0.0.1'
      -- end,
      -- port = function ()
      --     print("dap.configurations.lua -> port config called attach")
      --     return 4040
      -- end
    }
  }

  dap.adapters.nlua = function(callback, config)
    print("dap.adapters.nlua -> called")
    -- require("osv").launch({ host = '127.0.0.1', port = 4040, log = true })
    callback({ type = 'server', host = config.host, port = config.port })
  end
end

function M.start_debug()
  print("start_debug")
  require("osv").launch({ host = '127.0.0.1', port = 4040, log = true })

  print("toggle_ui")
  dapui.toggle()

  -- print("continue to attach")
  -- dap.continue()
end

return M
