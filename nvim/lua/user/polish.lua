return function()
    -- local set = vim.opt
    ---- Set options
    -- set.relativenumber = true

    ---- Set autocommands
    -- vim.cmd [[
    --  augroup packer_conf
    --    autocmd!
    --    autocmd bufwritepost plugins.lua source <afile> | PackerSync
    --  augroup end
    -- ]]
    require "user.my-terminal-controls"
    require "user.my-autocmds"
    require "user.my-lsp-keymaps"
end
