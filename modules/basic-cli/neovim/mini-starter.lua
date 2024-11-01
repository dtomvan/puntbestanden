local starter = require 'mini.starter'
local logo_width = 0

-- Removes the "Sessions" sections if there are none
local remove_empty_sessions = function(content)
    local coords = MiniStarter.content_coords(content, 'item')
    local found
    for _, c in ipairs(coords) do
        if content[c.line][c.unit].item.name == "There are no detected sessions in 'mini.sessions'" and not found then
            found = c.line
        end
    end
    if found then
        for i = 1, 3, 1 do
            table.remove(content, found - 1)
        end
    end
    return content
end

-- Shortens recent file paths to at most 80 characters, adds visual aid when
-- doing so and right-aligns the paths to the file afterwards.
local clean_recent_files = function(content)
    local coords = MiniStarter.content_coords(content, 'item')
    local longest = 0
    local cols = vim.o.columns

    for _, c in ipairs(coords) do
        local item = content[c.line][c.unit].item
        if item.section ~= 'Recent files' then
            goto continue
        end

        local name = item.action:sub(6)
        local filename = vim.fn.fnamemodify(name, ':~:.:t')
        local path = vim.fn.fnamemodify(name, ':~:.:h')
        local split = vim.split(filename, '.', { plain = true })
        local icon, hl = require('nvim-web-devicons').get_icon(filename, split[#split],
            { default = true })
        local do_path = path ~= '.' and path ~= '~'

        if #icon ~= 0 then
            icon = icon .. ' '
        end

        local len = #filename
        if do_path then
            len = len + 3 + #path
        end

        item._icon = icon
        item._hl = hl

        local new_line
        if len > math.min(cols, 80) then
            path = vim.fn.pathshorten(path, 4)
            -- minus 2 for icons or bullets
            local max_width = math.min(cols / 2 - 2, 40)
            local flen = #filename
            local plen = #path

            local filename_ellipsis = flen - max_width - 3 > 2
            local path_ellipsis = plen - max_width - 3 > 2

            filename = filename:sub(1, math.min(flen, max_width))
            path = path:sub(plen - math.min(plen, max_width), plen)
            local path_c = string.format(' (%s%s)', path_ellipsis and '...' or '', path)

            name = ('%s%s%s'):format(
                filename,
                filename_ellipsis and '...' or '',
                do_path and path_c or ''
            )
            new_line = { { string = filename, type = 'item', item = item } }
            if filename_ellipsis then
                table.insert(new_line, { string = '...', hl = 'Comment' })
            end
            if do_path then
                table.insert(new_line, { string = ' (', hl = 'Comment' })
                if path_ellipsis then
                    table.insert(new_line, { string = '...', hl = 'Comment' })
                end
                table.insert(new_line, { string = path, hl = 'Italic' })
                table.insert(new_line, { string = ')', hl = 'Comment' })
            end
        else
            new_line = {
                { string = filename, type = 'item', item = item },
            }
            if do_path then
                table.insert(new_line, { string = ' (', hl = 'Comment' })
                table.insert(new_line, { string = path })
                table.insert(new_line, { string = ')', hl = 'Comment' })
            end
        end
        content[c.line] = new_line
        item._len = #MiniStarter.content_to_lines { new_line }[1]
        if item._len > longest then
            longest = item._len
        end
        ::continue::
    end
    for _, c in ipairs(coords) do
        local unit = content[c.line][1]
        local item = unit.item
        local len = item._len
        if item.section ~= 'Recent files' then
            goto continue
        end
        local pad = string.rep(
            ' ',
            math.min(
                math.max(
                    logo_width - len - 2,
                    longest - len
                ),
                cols - len
            )
        )

        table.insert(content[c.line], 2, { string = pad })
        ::continue::
    end
    local header = MiniStarter.content_coords(content, 'header')
    for _, c in ipairs(header) do
        local unit = content[c.line][1]
        local lines = vim.split(unit.string, '\n')

        for i, line in ipairs(lines) do
            lines[i] = string.rep(
                    ' ',
                    math.min(
                        math.max(
                            logo_width - #line - 2,
                            longest - #line
                        ),
                        cols - #line
                    ) / 2
                ) ..
                line
        end
        content[c.line][1].string = table.concat(lines, '\n')
    end
    return content
end

-- modified version of MiniStarter.gen_hook.adding_bullet to add a filetype icon
-- on recent files
local function adding_bullet(place_cursor)
    place_cursor = place_cursor == nil and true or place_cursor
    return function(content)
        local coords = MiniStarter.content_coords(content, 'item')
        -- Go backwards to avoid conflict when inserting units
        for i = #coords, 1, -1 do
            local l_num, u_num = coords[i].line, coords[i].unit
            local item = content[l_num][u_num].item
            local bullet = item._icon or '░ '
            local bullet_unit = {
                string = bullet,
                type = 'item_bullet',
                hl = item._hl or 'MiniStarterItemBullet',
                item = item,
                _place_cursor = place_cursor,
            }
            table.insert(content[l_num], u_num, bullet_unit)
        end

        return content
    end
end

local function nothing_if_too_small(content)
    if vim.o.columns < 30 then
        return { { {
            type = 'item',
            string = 'Window too small',
            item = { name = '', action = 'enew', section = '' }
        } } }
    end
    return content
end

local function options(content)
    vim.opt_local.cursorline = true
    return content
end

starter.setup {
    header = function()
        local hour = tonumber(os.date '%H')
        -- [04:00, 12:00) - morning, [12:00, 20:00) - day, [20:00, 04:00) - evening
        local part_id = math.floor((hour + 4) / 8) + 1
        local day_part = ({ 'evening', 'morning', 'afternoon', 'evening' })[part_id]
        local username = vim.loop.os_get_passwd()['username'] or 'dtomvan'
        local header = ('Good %s, %s'):format(day_part, username)

        return header
    end,
    footer = function()
        return vim.fn.system('shuf -n1 ~/.config/nvim/inspirational_quotes.txt'):gsub('\\n', '\n'):gsub('\n$', '')
    end,
    items = {
        starter.sections.sessions(),
        starter.sections.recent_files(10),
    },
    content_hooks = {
        options,
        nothing_if_too_small,
        remove_empty_sessions,
        clean_recent_files,
        adding_bullet(false),
        starter.gen_hook.aligning('center', 'center'),
    },
    silent = true,
}

vim.api.nvim_set_hl(0, 'MiniStarterCurrent', { link = 'CursorLine' })
vim.api.nvim_set_hl(0, 'MiniStarterFooter', { link = 'MiniStarterSection' })
