local M = {}
local jdtls = require('jdtls')
local jdtls_dap = require('jdtls.dap')
local jdtls_setup = require('jdtls.setup')

function M.setup()
    -- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

    -- vim.env.PWD already contains "/" in the front since it's an absolute path
    local workspace_dir = '/tmp' .. vim.env.PWD

    -- This bundles definition is the same as in the previous section (java-debug installation)
    local bundles = {
        vim.fn.glob(vim.env.HOME .. "/.local/share/nvim/java-debug/com.microsoft.java.debug.plugin-*.jar"),
    };
    -- extend java-debug bundles with vscode-java-test
    vim.list_extend(bundles, vim.split(vim.fn.glob(vim.env.HOME .. "/.local/share/nvim/vscode-java-test/*.jar"), "\n"))

    local lombok_path = vim.env.HOME .. '/.m2/repository/org/projectlombok/lombok/1.18.22/lombok-1.18.22.jar'

    -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
    local config = {
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {

            -- 💀
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms2g',
            '-Xmx4g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            -- so it recognizes lombok annotation
            '-javaagent:' .. lombok_path,
            -- '-Xbootclasspath/a:' .. lombok_path,

            -- 💀
            '-jar', vim.env.HOME .. '/.local/share/nvim/lsp_servers/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
            -- '-configuration', vim.env.HOME .. '/.local/share/nvim/lsp_servers/jdtls/config_linux',
            '-configuration', vim.env.HOME .. '/.local/share/nvim/lsp_servers/jdtls/config_mac',
            -- '-data', vim.env.PWD -- this means that vim should be running in the parent direcory containing java src
            '-data', workspace_dir
        },

        -- 💀
        -- This is the default  if not provided, you can remove it. Or adjust as needed.
        -- One dedicated LSP server & client will be started per unique root_dir
        root_dir = jdtls_setup.find_root({'.git', 'mvnw', 'gradlew', 'pom.xml'}),

        -- Here you can configure eclipse.jdt.ls specific settings
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- for a list of options
        settings = {
            java = {
            }
        },

        -- SETTING UP FOR DEBUGGING WITH NVIM-DAP
        init_options = {
            bundles = bundles;
        },

        on_attach = function(client, bufnr)
            -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
            -- you make during a debug session immediately.
            -- Remove the option if you do not want that.
            jdtls.setup_dap({ hotcodereplace = 'auto' })
            jdtls_setup.add_commands()
            jdtls_dap.setup_dap_main_class_configs()
        end,


    }
    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    jdtls.start_or_attach(config)
end

return M
