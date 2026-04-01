vim.api.nvim_exec('autocmd FileType typescript,typescriptreact,javascript,javascriptreact lua require("lsp-keybind").keybind_ts()', false)
vim.api.nvim_exec('autocmd FileType go,gotmpl lua require("lsp-keybind").keybind_go()', false)
vim.api.nvim_exec('autocmd FileType java lua require("lsp-keybind").keybind_java()', false)
vim.api.nvim_exec('autocmd FileType lua lua require("lsp-keybind").keybind_lua()', false)
vim.api.nvim_exec('autocmd FileType dart lua require("lsp-keybind").keybind_lua()', false)

local M = {}

local bind = require("go.keybind")
local map_cr = bind.map_cr
local utils = require("go.utils")
local log = utils.log
local sep = "." .. utils.sep()
local getopt = require("go.alt_getopt")

local function keybind_common()
        -- DAP --
        -- run
        local keys = {
            ["n|<F6>"] = map_cr('<cmd>lua require"dap".step_over()<CR>'):with_noremap():with_silent(),
            ["n|<F7>"] = map_cr('<cmd>lua require"dap".step_into()<CR>'):with_noremap():with_silent(),
            ["n|<F8>"] = map_cr('<cmd>lua require"dap".step_out()<CR>'):with_noremap():with_silent(),
            ["n|<F9>"] = map_cr('<cmd>lua require"dap".continue()<CR>'):with_noremap():with_silent(),
            ["n|<A-.>"] = map_cr('<cmd>lua require"go.dap".stop()<CR>'):with_noremap():with_silent(),
            -- ["n|u"] = map_cr('<cmd>lua require"dap".up()<CR>'):with_noremap():with_silent(),
            -- ["n|D"] = map_cr('<cmd>lua require"dap".down()<CR>'):with_noremap():with_silent(),
            -- ["n|C"] = map_cr('<cmd>lua require"dap".run_to_cursor()<CR>'):with_noremap():with_silent(),
            ["n|<A-\\>"] = map_cr('<cmd>lua require"dap".toggle_breakpoint()<CR>'):with_noremap():with_silent(),
            --["n|P"] = map_cr('<cmd>lua require"dap".pause()<CR>'):with_noremap():with_silent(),
        }
        bind.nvim_load_mapping(keys)
end

function M.keybind_go()
    keybind_common()

    local keys = {
        ["n|<F4>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoRun . -F<CR>'):with_noremap():with_silent(),
        ["n|<F16>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | lua require"go.dap".run()<CR>'):with_noremap():with_silent(),

        ["n|<F5>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoTest ./...<CR>'):with_noremap():with_silent(),
        ["n|<F17>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoDebug -t<CR>'):with_noremap():with_silent(),
        ["n|<F53>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoDebug -t -n<CR>'):with_noremap():with_silent(),

        ["n|<F12>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoTest -b %<CR>'):with_noremap():with_silent(),
        ["n|<F24>"] = map_cr('<cmd>lua require"go.dap".stop()<CR> :let $pwd = getcwd() | let $local = "true" | :GoDebug -t -b<CR>'):with_noremap():with_silent(),

        -- Alt + <F9>
        ["n|<F57>"] = map_cr(':let $pwd = getcwd() | let $local = "true" | GoBuild ./...<CR>'):with_noremap():with_silent(),
    }

    print(keys)
    bind.nvim_load_mapping(keys)
end


function M.keybind_ts()
    keybind_common()

    local keys = {
        ["n|<F4>"] = map_cr('lua require("dap-react").start_debug()'):with_noremap():with_silent(),
        ["n|<F16>"] = map_cr('lua require("dap-react").start_debug()'):with_noremap():with_silent(),
        ["n|<F5>"] = map_cr('lua require("dap-react").start_debug()'):with_noremap():with_silent(),
        ["n|<F17>"] = map_cr('lua require("dap-react").start_debug()'):with_noremap():with_silent(),

        -- Shift + <F9>
        -- TODO: Find a way to compile typescript
        ["n|<F57>"] = map_cr(':let $pwd = getcwd() | let $local = "true" | :GoBuild .<CR>'):with_noremap():with_silent(),
    }
    bind.nvim_load_mapping(keys)

    vim.api.nvim_command('set indentexpr=GetTsxIndent()')
end

function M.keybind_java()
    keybind_common()

    local keys = {
        -- F$ & Shift
        ["n|<F4>"] = map_cr('lua require("dap-java").start_debug()'):with_noremap():with_silent(),
        ["n|<F16>"] = map_cr('lua require("dap-java").start_debug()'):with_noremap():with_silent(),

        -- F5 & Shift
        ["n|<F5>"] = map_cr('lua require("jdtls").test_class()'):with_noremap():with_silent(),
        ["n|<F17>"] = map_cr('lua require("jdtls").test_nearest_method()'):with_noremap():with_silent(),

        -- Shift + <F9>
        ["n|<F57>"] = map_cr(':JdtCompile<CR>'):with_noremap():with_silent(),
    }
    bind.nvim_load_mapping(keys)
end

function M.keybind_lua()
    keybind_common()

    local keys = {
        -- F$ & Shift
        ["n|<F4>"] = map_cr('lua require("dap-lua").start_debug()'):with_noremap():with_silent(),
        ["n|<F16>"] = map_cr('lua require("dap-lua").start_debug()'):with_noremap():with_silent(),

        -- F5 & Shift
        ["n|<F5>"] = map_cr('lua require("jdtls").test_class()'):with_noremap():with_silent(),
        ["n|<F17>"] = map_cr('lua require("jdtls").test_nearest_method()'):with_noremap():with_silent(),

        -- Shift + <F9>
        -- ["n|<F57>"] = map_cr(':JdtCompile<CR>'):with_noremap():with_silent(),
    }
    bind.nvim_load_mapping(keys)
end

function M.keybind_flutter()
    keybind_common()

    local keys = {
        ["n|<F4>"] = map_cr(':FlutterRun<CR>'):with_noremap():with_silent(),
        ["n|<F16>"] = map_cr('lua require("dap-lua").start_debug()'):with_noremap():with_silent(),

        ["n|<F5>"] = map_cr('FlutterTest<CR>'):with_noremap():with_silent(),
        ["n|<F17>"] = map_cr('lua require("dap-lua").start_debug()'):with_noremap():with_silent(),

        -- Alt + <F9>
        ["n|<F57>"] = map_cr(':FlutterBuild<CR>'):with_noremap():with_silent(),
    }

    bind.nvim_load_mapping(keys)
end

return M

