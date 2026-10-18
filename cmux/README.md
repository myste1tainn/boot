# cmux

cmux is a Ghostty-based terminal, so its configuration is split across two
formats in two places. Only the files under `files/` are portable between
machines; everything else cmux keeps on disk is per-device state.

## What is linked (portable — tracked here)

| Repo file | Links to | What it holds |
|---|---|---|
| `files/.config/ghostty/config` | `~/.config/ghostty/config` | Terminal settings: font, font size, `macos-option-as-alt`. Ghostty's `key = value` format. |
| `files/.config/cmux/settings.json` | `~/.config/cmux/settings.json` | cmux app settings, JSONC. |
| `files/.config/cmux/cmux.json` | `~/.config/cmux/cmux.json` | cmux app settings, JSONC (newer schema name). |

`~/.config/cmux/settings.json` takes precedence over the Application Support
fallback. Both JSONC files are the templates cmux writes on first launch when
no settings file exists: every setting in them is commented out, which means
"fall back to whatever the Settings UI saved". Uncomment a key to make it
file-managed — and therefore versioned here and shared across machines, which
is the point of tracking them.

**Do not uncomment `automation.socketPassword` with a real value** — this repo
is not the place for it. Put it in `~/.config/boot/secrets.env` (which `zshrc`
sources and git ignores) or leave it to the Settings UI.

## What is deliberately not tracked (per-device state)

| Path | Why not |
|---|---|
| `~/Library/Preferences/com.cmuxterm.app.plist` | Settings-UI values, but mixed with install IDs, auth project ID, analytics timestamps and dismissed-notification IDs. Copying it to another machine carries that identity with it. To share a setting, uncomment it in the JSONC files above instead. |
| `~/Library/Application Support/cmux/` | Runtime state: control socket, session/scrollback history, `search.db`, agent-journal SQLite. |
| `~/.cmuxterm/` | Runtime state: event logs, sequence locks, CLI shims, per-session Claude settings. |
| `~/.cmux/ssh/` | Empty, created on demand (mode 700). |

## Editor support for the config format

Ghostty's config format is its own: "a custom, but very simplistic `key =
value` syntax" per its docs — not INI, TOML or YAML — so there is no existing
language environment to point an editor at. There is, however, a real
tree-sitter grammar for it, and that is what Neovim uses.

### Neovim — tree-sitter (the real grammar)

Handled in the **nvim config repo**, not here: `lua/plugins/tree-sitter-ghostty.lua`
pulls in [`bezhermoso/tree-sitter-ghostty`](https://github.com/bezhermoso/tree-sitter-ghostty),
which ships the parser, highlight queries, its own ftdetect and an ftplugin. It
builds `parser/ghostty.so` at install time with the tree-sitter CLI (needs
tree-sitter-cli >= 0.26 and GNU make — bootstrap installs both).

This understands the format properly rather than pattern-matching it: keys are
`@variable`, `=` is `@operator`, values resolve to `@number` / `@boolean` /
`@string`, and a `keybind` value is parsed structurally — modifiers as
`@constant.builtin`, the action as `@function.call`. Neovim itself has no
ghostty filetype (checked on 0.12.5) and nvim-treesitter does not carry the
parser, which is why it comes from the grammar's own repo.

### Plain vim — generated syntax file

Plain vim cannot load a tree-sitter grammar, so it keeps a vim syntax file —
which is also what Ghostty upstream ships for vim. Upstream generates those
files at build time from its compiled option list rather than publishing them,
so this repo does the same:

    ./cmux/gen-ghostty-vim-syntax.sh

It reads the option list from the `ghostty` binary cmux bundles, so the
recognised keys match the installed version exactly (204 config keys and 86
keybind actions as of ghostty 1.3.2). Output goes to `files/.vim/`, linked to
`~/.vim/` by `linkfiles.sh`:

| Repo file | Links to |
|---|---|
| `files/.vim/ftdetect/ghostty.vim` | `~/.vim/ftdetect/ghostty.vim` |
| `files/.vim/ftplugin/ghostty.vim` | `~/.vim/ftplugin/ghostty.vim` |
| `files/.vim/syntax/ghostty.vim` | `~/.vim/syntax/ghostty.vim` |

Re-run it after a cmux upgrade and commit the result.

No `~/.vimrc` is needed for this to take effect: with no user vimrc, vim loads
`$VIMRUNTIME/defaults.vim`, which runs `filetype plugin indent on`
unconditionally and `syntax on` whenever the terminal has colors. Note that
`vim` is aliased to `nvim` in `zshrc`, so plain vim is what you get from
`/usr/bin/vim` and from `EDITOR=vim` over SSH.

An unrecognised key is left unhighlighted rather than flagged as an error,
since cmux may accept keys a given ghostty build does not list.
