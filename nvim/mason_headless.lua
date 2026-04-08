-- Headless LSP server installer via mason.nvim
-- Called from nvim/install.sh:
--   nvim --headless -c "Lazy! load mason.nvim" -c "luafile /path/to/mason_headless.lua"
--
-- Languages covered: go, groovy, java, javascript, python, ruby, rust, xml
-- dart   → dartls ships with the Flutter SDK (brew install --cask flutter)
-- lua    → lua-language-server installed via Homebrew
-- starlark → no mason package; no widely-adopted LSP available

local SERVERS = {
	"gopls", -- go
	"pyright", -- python
	"typescript-language-server", -- javascript / typescript
	"rust-analyzer", -- rust (also available via rustup)
	"jdtls", -- java (requires JDK — installed via SDKMan)
	"groovy-language-server", -- groovy
	"ruby-lsp", -- ruby
	"lemminx", -- xml
	"black",
	"buildifier",
	"gofumpt",
	"google-java-format",
	"prettier",
	"tilt",
	"starlark-rust",
	"rubocop",
	"rustfmt",
	"shfmt",
	"stylua",
}

local function log(msg)
	print("[mason-headless] " .. msg)
end

local function quit()
	vim.schedule(function()
		vim.cmd("qa")
	end)
end

-- Force-load mason in case it's lazy-loaded
local lazy_ok, lazy = pcall(require, "lazy")
if lazy_ok then
	lazy.load({ plugins = { "mason.nvim" } })
end

local ok, registry = pcall(require, "mason-registry")
if not ok then
	log("mason-registry not available — skipping LSP install")
	quit()
	return
end

registry.refresh(function()
	local pending = 0

	local function on_done(name)
		return function()
			log("done: " .. name)
			pending = pending - 1
			if pending <= 0 then
				quit()
			end
		end
	end

	for _, name in ipairs(SERVERS) do
		local pkg_ok, pkg = pcall(registry.get_package, name)
		if pkg_ok then
			if pkg:is_installed() then
				log("already installed: " .. name)
			else
				log("installing: " .. name)
				pending = pending + 1
				pkg:install():on("closed", on_done(name))
			end
		else
			log("not found in registry: " .. name)
		end
	end

	if pending <= 0 then
		quit()
	end
end)
