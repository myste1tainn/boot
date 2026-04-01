local api = vim.api
local win_specs = {
    run = {
        name = "Run",
        window_commands = {
            open_win = 'botright split new',
            others = {'set nornu nonu'}
        },
        functions = {{cmd = "termopen"}},
        size = {height = 10}
    }
}

local function open_win(spec)
    vim.cmd(spec.window_commands.open_win)
    for _, x in pairs(spec.window_commands.others) do vim.cmd(x) end
    if spec.size ~= nil then
        if spec.size.height ~= nil then
            api.nvim_win_set_height(0, spec.size.height)
            vim.cmd('setl winfixheight')
        end
        if spec.size.width ~= nil then
            api.nvim_win_set_width(0, spec.size.width)
            vim.cmd('setl winfixwidth')
        end
    end
    return {
        -- get the window handler
        win = api.nvim_tabpage_get_win(0),
        -- get the buffer handler
        buf = api.nvim_win_get_buf(0)
    }
end

local function create_window_command(spec, args)
    local win_handle = nil
    local command_main_name = spec.name .. 'Window'
    local command_toggle_name = 'Toggle' .. command_main_name
    -- TODO: Add autocommand on BufUnload or something to reset the win_handle to nil
    api.nvim_create_user_command(command_main_name, function()
        -- if the handles is already there, stop & delete it first then start anew
        if win_handle ~= nil and win_handle.job_ids ~= nil then
            for _, id in pairs(win_handle.job_ids) do
                -- stop the command running in the termopen window
                api.nvim_call_function("jobstop", {id})
            end

            -- delete the buf
            vim.cmd('bd! ' .. win_handle.buf)
        end

        win_handle = open_win(spec)
        if spec.functions ~= nil then
            win_handle.job_ids = {}
            for _, fn in pairs(spec.functions) do
                -- TODO: Take commands argument from outside, cuz it's subjected to languages
                win_handle.job_ids[#win_handle.job_ids + 1] =
                    api.nvim_call_function(fn.cmd, {args})
            end
        end
        win_handle.state = 'open'
        -- after running commands, this will help the term windows auto scrolls
        -- to last line as the content is printed onto it
        vim.cmd("norm G")
        -- go back to previous window
        vim.cmd('wincmd p')
    end, {nargs = 0, desc = "Open '" .. spec.name .. "' Window"})

    api.nvim_create_user_command(command_toggle_name, function()
        if win_handle == nil or win_handle.win == nil then
            vim.cmd(command_main_name .. " " .. args)
            return
        end

        if win_handle.state == 'open' then
            vim.cmd('q ' .. win_handle.buf)
            win_handle.state = 'close'
        else
            local new_win = open_win(spec)
            -- Bring RunWindow's buffer to this window
            vim.cmd('b ' .. win_handle.buf)
            -- Wipeout the recently opened buffer
            vim.cmd('bw ' .. new_win.buf)
            win_handle.state = 'open'
        end
    end, {
        nargs = 0,
        desc = "Toggle '" .. spec.name ..
            "' Window, if it's closed then open, other close"
    })
end

return function(opts)
    create_window_command(win_specs.run, opts.run)
    -- TODO: Add create_window_command(win_specs.debug, opts.run) (if needed, unless DAP helps you with all that)
end
