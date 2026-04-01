-- This file can be loaded by calling `lua require('plugins')` from your init.vim
-- Only required if you have packer configured as `opt`
--

local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    --vim.cmd [[packadd packer.nvim]]
    packer_bootstrap = fn.system({'git',
        'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
    use { 'wbthomason/packer.nvim' }
    use { 'shougo/deoplete.nvim' }

    -- LSP setup for flutter
    use {'akinsho/flutter-tools.nvim', requires = 'nvim-lua/plenary.nvim'}

    -- LspSasga, using the one from tami5 cuz it's maintain and has more functions
    --use { 'glepnir/lspsaga.nvim' }
    use { 'tami5/lspsaga.nvim' }

    use { 'nvim-lua/plenary.nvim' }
    use { 'nvim-lua/popup.nvim' }

    -- Files navigation
    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            { "nvim-telescope/telescope-live-grep-args.nvim" },
            { "nvim-telescope/telescope-dap.nvim" }
        }
    }

    -- Mason for LSP & DAP mgt.
    use {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "williamboman/nvim-lsp-installer",
      {
        "neovim/nvim-lspconfig",
        after = "nvim-lsp-installer",
        config = function()
          require("nvim-lsp-installer").setup {}
          -- mason and the mason-lspconfig setup order (strict order, don't swap)
          require("mason").setup()
          require("mason-lspconfig").setup {
            -- NOTE: sourcekit server is not available in mason
            ensure_installed = {
              "lua_ls",
              "angularls",
              "bashls",
              "shfmt",
              "cssls",
              "cssmodules_ls",
              "dockerls",
              "dotls",
              "eslint",
              "gopls",
              "groovyls",
              "html",
              "jdtls",
              "jsonls",
              "lemminx",
              "tsserver",
              "vimls",
              "yamlls"
            }
          }
          require("lsp")
          require("lsp-servers-autoconfig") -- This is where i've stored most of the `require("lspconfig").{lang_ls_name}.setup{}`
        end
      },
      run = ":MasonUpdate" -- :MasonUpdate updates registry contents
    }

    -- Formatter
    use {
      'mhartington/formatter.nvim',
      'jose-elias-alvarez/null-ls.nvim'
    }

    -- Formerly used this for completion
    -- use { 'hrsh7th/nvim-compe' }

    -- main
    use { 'neoclide/coc.nvim', branch = 'release' }
    -- snippets packages for coc.nvim, alongside usage, not dependencies
    use { 'SirVer/ultisnips' }
    use { 'honza/vim-snippets' }
    use { 'neoclide/coc-snippets' }


    -- main
    -- use { 'ms-jpq/coq_nvim', branch = 'coq' }
    -- 9000+ snippets
    -- use { 'ms-jpq/coq.artifacts', branch = 'artifacts' }
    -- Utils
    -- - shell repl
    -- - nvim lua api
    -- - scientific calculator
    -- - comment banner
    -- - etc
    -- use { 'ms-jpq/coq.thirdparty', branch = '3p' }

    use { 'nvim-treesitter/nvim-treesitter', run = ":TSUpdate" }
    use { 'nvim-treesitter/nvim-treesitter-textobjects' }
    use { 'kyazdani42/nvim-web-devicons' }

    use { 'norcalli/nvim-terminal.lua' }

    -- DAP for deebugging
    use 'jbyuki/one-small-step-for-vimkind'
    use 'mfussenegger/nvim-dap'
    use 'rcarriga/nvim-dap-ui'
    use 'theHamsta/nvim-dap-virtual-text'

    -- Go IDE
    use 'ray-x/go.nvim'
    use 'ray-x/guihua.lua'

    -- Java IDE
    use 'mfussenegger/nvim-jdtls'
    -- Status line
    use {
        'glepnir/galaxyline.nvim',
        branch = 'main',
        -- your statusline
        -- some optional icons
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }

    -- Util
    use 'famiu/nvim-reload'

    -- UI for nvim
    use 'mjlbach/neovim-ui'
    use 'mfussenegger/nvim-lua-debugger'

    -- Auto tagging for HTML & TSX
    use 'windwp/nvim-ts-autotag'
    -- Auto pairings for multiple char e.g. Single Quote
    use 'windwp/nvim-autopairs'

    -- inlay hints
    use 'lvimuser/lsp-inlayhints.nvim'

    if packer_bootstrap then
        require('packer').sync()
    end
end)
