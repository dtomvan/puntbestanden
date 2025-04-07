local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local bufnr = vim.api.nvim_get_current_buf()
local filetypes = vim.fn.getcompletion('', 'filetype')

function PickFt()
    pickers.new(opts, {
        prompt_title = "filetypes",
        finder = finders.new_table {
            results = filetypes,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()[1]
                vim.schedule(function()
                    vim.api.nvim_set_option_value("filetype", selection, {
                        buf = bufnr,
                    })
                end)
            end)
            return true
        end,
    }):find()
end

vim.api.nvim_create_user_command("Ft", PickFt, {
    nargs = 0,
})
