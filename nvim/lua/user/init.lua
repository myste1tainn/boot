local config = {
    colorscheme = "sonokai"
    -- plugins = {
    -- TODO: This some how doesn't work, so comment out for now use the above `refactoring`
    -- {
    --     "kkharji/lspsaga.nvim",
    --     cmd = "Lspsaga",
    --     config = function()
    --         local lspsaga = require 'lspsaga'
    --         lspsaga.setup { -- defaults ...
    --             debug = false,
    --             use_saga_diagnostic_sign = true,
    --             -- diagnostic sign
    --             error_sign = "",
    --             warn_sign = "",
    --             hint_sign = "",
    --             infor_sign = "",
    --             diagnostic_header_icon = "   ",
    --             -- code action title icon
    --             code_action_icon = " ",
    --             code_action_prompt = {
    --                 enable = true,
    --                 sign = true,
    --                 sign_priority = 40,
    --                 virtual_text = true
    --             },
    --             finder_definition_icon = "  ",
    --             finder_reference_icon = "  ",
    --             max_preview_lines = 10,
    --             finder_action_keys = {
    --                 open = "o",
    --                 vsplit = "s",
    --                 split = "i",
    --                 quit = "q",
    --                 scroll_down = "<C-f>",
    --                 scroll_up = "<C-b>"
    --             },
    --             code_action_keys = {quit = "q", exec = "<CR>"},
    --             rename_action_keys = {quit = "<C-c>", exec = "<CR>"},
    --             definition_preview_icon = "  ",
    --             border_style = "single",
    --             rename_prompt_prefix = "➤",
    --             rename_output_qflist = {
    --                 enable = false,
    --                 auto_open_qflist = false
    --             },
    --             server_filetype_map = {},
    --             diagnostic_prefix_format = "%d. ",
    --             diagnostic_message_format = "%m %c",
    --             highlight_prefix = false
    --         }
    --     end
    -- }

    -- }
}

-- local parser_config = require'nvim-treesitter.parsers'.get_parser_configs()
-- parser_config.gotmpl = {
--     install_info = {
--         url = "https://github.com/ngalaiko/tree-sitter-go-template",
--         files = {"src/parser.c"}
--     },
--     filetype = "gotmpl",
--     used_by = {"gohtmltmpl", "gotexttmpl", "gotmpl", "yaml"}
-- }

return config
