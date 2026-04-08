-- Per-project configs. Like `:h exrc`.

local group = vim.api.nvim_create_augroup("LocalConfig", { clear = true })

vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, {
    callback = function()
        local cwd = vim.fn.getcwd(0)
        local rc_path = vim.fs.joinpath(cwd, ".nvimrc.lua")
        ---@diagnostic disable-next-line: undefined-field
        if vim.uv.fs_stat(rc_path) then
            vim.ui.select(
                { 'source', 'edit', 'skip' }, {
                    prompt = (".nvimrc.lua found in %s! What to do?"):format(cwd),
                },
                function(choice)
                    if choice == nil or choice == 'skip' then return end
                    (vim.cmd[choice] or function() end)(rc_path)
                end)
        end
    end,
    group = group,
    desc = "Load .nvimrc.lua, if applicable"
})
