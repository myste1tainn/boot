-- vim.lsp.set_log_level("trace")
require("telescope").setup()
require("telescope").load_extension("fzf")
require("telescope").load_extension("live_grep_args")

require("terminal").setup()

require("treesitter")
require("statusbar")
require("completion")
require("go-setup")
require("lsp-keybind")
require("dapui").setup()
require("dap-react").setup()
require("dap-lua").setup()
require("dap-java").setup()
require("ultisnips_config")
require("theme")
require("nvim-ts-autotag").setup()
require("nvim-autopairs").setup()
require("lsp-inlayhints").setup()
require('plenary.reload').reload_module("dap-java", true)

require('formatter').setup {
  filetype = {
    sh = {
      require('formatter.filetypes.sh').shfmt
    }
  }
}

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.completion.spell,
    },
})

-- NOTE: Please find mason and the mason-lspconfig in teh plugins.lua file as it has to be lazy loaded after certain plugins
