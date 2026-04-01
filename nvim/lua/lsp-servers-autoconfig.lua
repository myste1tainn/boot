--require("lsp-auto-java")

-- local lsp = require("lspconfig")
-- local coq = require("coq")
-- local flutter_tools = require("flutter-tools")
-- 
-- lsp.dockerls.setup(coq.lsp_ensure_capabilities())
-- lsp.jdtls.setup(coq.lsp_ensure_capabilities())
-- lsp.yamlls.setup(coq.lsp_ensure_capabilities())
-- lsp.jsonls.setup(coq.lsp_ensure_capabilities())
-- lsp.html.setup(coq.lsp_ensure_capabilities())
-- -- lsp.angularls.setup(coq.lsp_ensure_capabilities())
-- lsp.cssls.setup(coq.lsp_ensure_capabilities())
-- lsp.cssmodules_ls.setup(coq.lsp_ensure_capabilities())
-- lsp.dotls.setup(coq.lsp_ensure_capabilities())
-- lsp.pyright.setup(coq.lsp_ensure_capabilities())
-- lsp.sourcekit.setup(coq.lsp_ensure_capabilities())
-- lsp.vimls.setup(coq.lsp_ensure_capabilities())
-- lsp.bashls.setup(coq.lsp_ensure_capabilities())
-- lsp.lua_ls.setup(coq.lsp_ensure_capabilities())
-- lsp.lemminx.setup(coq.lsp_ensure_capabilities())
-- flutter_tools.setup(coq.lsp_ensure_capabilities())
-- -- use flutter tools instead
-- -- lsp.dartls.setup(coq.lsp_ensure_capabilities()) 
-- lsp.sqlls.setup(coq.lsp_ensure_capabilities())
-- lsp.ccls.setup(coq.lsp_ensure_capabilities())
-- lsp.tsserver.setup(coq.lsp_ensure_capabilities({
--     on_attach = function(client, bufnr)
--         vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
--     end,
-- 
--     init_options = {
--         preferences = {
--             importModuleSpecifierPreference = "project-relative"
--         }
--     }
-- }))
--  -- lsp.eslint.setup(coq.lsp_ensure_capabilities())
-- 
-- local path = require 'nvim-lsp-installer.core.path'
-- local install_root_dir = path.concat {vim.fn.stdpath 'data', 'lsp_servers'}
-- 
-- local s = coq.lsp_ensure_capabilities({
--     go='go', -- go command, can be go[default] or go1.18beta1
--     goimport='gopls', -- goimport command, can be gopls[default] or goimport
--     fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
--     gofmt = 'gofumpt', --gofmt cmd,
--     max_line_len = 120, -- max line length in goline format
--     tag_transform = false, -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
--     gotests_template = "", -- sets gotests -template parameter (check gotests for details)
--     gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
--     comment_placeholder = '' ,  -- comment_placeholder your cool placeholder e.g. ﳑ       
--     icons = {breakpoint = '🧘', currentpos = '🏃'},  -- setup to `false` to disable icons setup
--     verbose = false,  -- output loginf in messages
--     lsp_cfg = false, -- true: use non-default gopls setup specified in go/lsp.lua
--     -- false: do nothing
--     -- if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
--     --   lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}}
--     lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
--     lsp_on_attach = nil, -- nil: use on_attach function defined in go/lsp.lua,
--     --      when lsp_cfg is true
--     -- if lsp_on_attach is a function: use this function as on_attach function for gopls
--     lsp_keymaps = true, -- set to false to disable gopls/lsp keymap
--     lsp_codelens = true, -- set to false to disable codelens, true by default, you can use a function
--     -- function(bufnr)
--     --    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", {noremap=true, silent=true})
--     -- end
--     -- to setup a table of codelens
--     lsp_diag_hdlr = true, -- hook lsp diag handler
--     -- virtual text setup
--     lsp_diag_virtual_text = { space =                     0, prefix = "" },
--     lsp_diag_signs = true,
--     lsp_diag_update_in_insert = false,
--     lsp_document_formatting = true,
--     -- set to true: use gopls to format
--     -- false if you want to use other formatter tool(e.g. efm, nulls)
--     gopls_cmd = {install_root_dir .. '/go/gopls'}, -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
--     gopls_remote_auto = true, -- add -remote=auto to gopls
--     dap_debug = true, -- set to false to disable dap
--     dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
--     -- false: do not use keymap in go/dap.lua.  you must define your own.
--     dap_debug_gui = true, -- set to true to enable dap gui, highly recommand
--     dap_debug_vt = true, -- set to true to enable dap virtual text
--     build_tags = "tag1,tag2", -- set default build tags
--     textobjects = true, -- enable default text jobects through treesittter-text-objects
--     test_runner = 'go', -- richgo, go test, richgo, dlv, ginkgo
--     verbose_tests = true, -- set to add ver                    bose flag to tests
--     run_in_floaterm = false, -- set to true to run in float window. :GoTermClose closes the floatterm
--     -- float term recommand if you use richgo/ginkgo with terminal color
-- })
-- 
-- require('go').setup(s)


--require("lsp-auto-java")

local lsp = require("lspconfig")
local flutter_tools = require("flutter-tools")

lsp.dockerls.setup({})
--lsp.jdtls.setup({
--  cmd = { 'jdtls' }
--})
lsp.yamlls.setup({})
lsp.jsonls.setup({})
lsp.html.setup({})
-- lsp.gopls.setup({})
-- lsp.angularls.setup({})
lsp.cssls.setup({})
lsp.cssmodules_ls.setup({})
lsp.dotls.setup({})
lsp.pyright.setup({})
lsp.sourcekit.setup({})
lsp.vimls.setup({})
lsp.bashls.setup({})
lsp.lua_ls.setup({})
lsp.lemminx.setup({})
flutter_tools.setup({})
-- use flutter tools instead
-- lsp.dartls.setup({})
lsp.sqlls.setup({})
lsp.ccls.setup({})

local tsserver_opts = {
    inlayHints = {
        includeInlayEnumMemberValueHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = true,
    },
}
lsp.tsserver.setup({
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        require("lsp-inlayhints").on_attach(client, bufnr, false)
    end,

    init_options = {
        preferences = {
            importModuleSpecifierPreference = "project-relative"
        }
    },

    settings = {
        importModuleSpecifierPreference = "project-relative",
        javascript = tsserver_opts,
        typescript = tsserver_opts
    }
})
            -- lsp.eslint.setup({})

local path = require 'nvim-lsp-installer.core.path' local install_root_dir = path.concat {vim.fn.stdpath 'data', 'lsp_servers'}

local s = {
    go='go', -- go command, can be go[default] or go1.18beta1
    goimport='gopls', -- goimport command, can be gopls[default] or goimport
    fillstruct = 'gopls', -- can be nil (use fillstruct, slower) and gopls
    gofmt = 'gofumpt', --gofmt cmd,
    max_line_len = 120, -- max line length in goline format
    tag_transform = false, -- can be transform option("snakecase", "camelcase", etc) check gomodifytags for details and more options
    gotests_template = "", -- sets gotests -template parameter (check gotests for details)
    gotests_template_dir = "", -- sets gotests -template_dir parameter (check gotests for details)
    comment_placeholder = '' ,  -- comment_placeholder your cool placeholder e.g. ﳑ       
    icons = {breakpoint = '🧘', currentpos = '🏃'},  -- setup to `false` to disable icons setup
    verbose = false,  -- output loginf in messages
    lsp_cfg = false, -- true: use non-default gopls setup specified in go/lsp.lua
    -- false: do nothing
    -- if lsp_cfg is a table, merge table with with non-default gopls setup in go/lsp.lua, e.g.
    --   lsp_cfg = {settings={gopls={matcher='CaseInsensitive', ['local'] = 'your_local_module_path', gofumpt = true }}}
    lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
    lsp_on_attach = nil, -- nil: use on_attach function defined in go/lsp.lua,
    --      when lsp_cfg is true
    -- if lsp_on_attach is a function: use this function as on_attach function for gopls
    lsp_keymaps = true, -- set to false to disable gopls/lsp keymap
    lsp_codelens = true, -- set to false to disable codelens, true by default, you can use a function
    -- function(bufnr)
    --    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", {noremap=true, silent=true})
    -- end
    -- to setup a table of codelens
    lsp_diag_hdlr = true, -- hook lsp diag handler
    -- virtual text setup
    lsp_diag_virtual_text = { space =                     0, prefix = "" },
    lsp_diag_signs = true,
    lsp_diag_update_in_insert = false,
    lsp_document_formatting = true,
    -- set to true: use gopls to format
    -- false if you want to use other formatter tool(e.g. efm, nulls)
    gopls_cmd = {install_root_dir .. '/go/gopls'}, -- if you need to specify gopls path and cmd, e.g {"/home/user/lsp/gopls", "-logfile","/var/log/gopls.log" }
    gopls_remote_auto = true, -- add -remote=auto to gopls
    dap_debug = true, -- set to false to disable dap
    dap_debug_keymap = false, -- true: use keymap for debugger defined in go/dap.lua
    -- false: do not use keymap in go/dap.lua.  you must define your own.
    dap_debug_gui = true, -- set to true to enable dap gui, highly recommand
    dap_debug_vt = true, -- set to true to enable dap virtual text
    build_tags = "tag1,tag2", -- set default build tags
    textobjects = true, -- enable default text jobects through treesittter-text-objects
    test_runner = 'go', -- richgo, go test, richgo, dlv, ginkgo
    verbose_tests = true, -- set to add ver                    bose flag to tests
    run_in_floaterm = false, -- set to true to run in float window. :GoTermClose closes the floatterm
    -- float term recommand if you use richgo/ginkgo with terminal color
}

require('go').setup(s)
