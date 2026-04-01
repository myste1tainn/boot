-- local on_attach = function(_, bufnr)
--    vim.api.nvim_create_autocmd("BufWritePre", {
--        pattern = "*.go",
--        callback = function() vim.lsp.buf.format() end
--    })
-- end
return {
    -- on_attach = on_attach,
}
