-- Per-project configs. Like `:h exrc`.

local group = vim.api.nvim_create_augroup("LocalConfig", { clear = true })

vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, {
    callback = function()
        local cwd = vim.fn.getcwd(0)
        for _, rc_name in ipairs { ".nvimrc.lua", ".nvimrc.vim", ".nvimrc", ".vimrc" } do
            local rc_path = vim.fs.joinpath(cwd, rc_name)
            ---@diagnostic disable-next-line: undefined-field
            if vim.uv.fs_stat(rc_path) then
                vim.ui.select(
                    { 'source', 'edit', 'skip' }, {
                        prompt = ("%s found in %s! What to do?"):format(rc_name, cwd),
                    },
                    function(choice)
                        if choice == nil or choice == 'skip' then return end
                        (vim.cmd[choice] or function(_) end)(rc_path)
                    end)
                break
            end
        end
    end,
    group = group,
    desc = "Load .nvimrc.lua, if applicable"
})
