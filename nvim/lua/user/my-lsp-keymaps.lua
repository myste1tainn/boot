-- Set key bindings
local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap
local c = require("user.my-terminal-controls")

-- Common Keymaps
---- Run & Debug mappings
vim.api.nvim_create_autocmd('FileType', {
    desc = 'Key mapping specifc to go file types',
    group = vim.api.nvim_create_augroup('lsp_key_map', { clear = true }),
    callback = function(_)
        local file_type = vim.api.nvim_buf_get_option(0, "filetype")

        if file_type == 'go' then
            c({ run = "go run main.go" })
        elseif string.match(file_type, "typescript") or
            string.match(file_type, "javascript") then
            c({ run = "npm start" })
        end
    end

})

map("", "<F1>", ":lua vim.lsp.buf.hover()<CR>", opts)
map("", "<F2>", ":lua vim.diagnostic.goto_next()<CR>", opts)
map("", "<F14>", ":lua vim.diagnostic.goto_prev()<CR>", opts)
map("", "<F4>", ":RunWindow<CR>", opts)
-- TODO: Map <F16> for debug run
-- TODO: Map <F5> for test
-- TODO: Map <F17> for test debug
-- TODO: Checkout Stepover, in, out control if you have the need for additional setup
map("", "<leader><F4>", ":ToggleRunWindow<CR>", opts)
------ Refactor -> rename
map("n", "<F18>", ":lua vim.lsp.buf.rename()<CR>", opts)
-- Buffer & Window mappings
------ close buffer
map("", "<S-x>", ":bd bufnr('%')", opts)
map("", "<A-CR>", ":lua vim.lsp.buf.code_action()<CR>", opts)
