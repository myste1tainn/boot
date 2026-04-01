local result = vim.api.nvim_exec('autocmd VimEnter * lua TryAutoStartLspJava()', true)

function TryAutoStartLspJava()
    -- NOTE: This lines means that this script only works for *nix with `find` commands in shell
    -- local p = io.popen('find "' .. vim.env.PWD .. '" -type f -maxdepth 1')  --Open directory look for files, save data in p. By giving '-type f' as parameter, it returns all files.

    -- if p == nil then
    --     return
    -- end

    -- local hasPomFile = false

    -- for file in p:lines() do
    --     if string.find(file, "pom.xml") then
    --         hasPomFile = true
    --         break
    --     end
    -- end

    -- if hasPomFile then
    --     require("lsp-java").setup()
    -- end
end

print(result)
