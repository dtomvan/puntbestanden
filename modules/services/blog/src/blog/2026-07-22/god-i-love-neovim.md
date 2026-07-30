---
title: God I love Neovim
replies_url: https://toot.cat/@dtomvan/116965713389345949
date: 2026-07-22T22:36:38+02:00
layout: post
lang: en
tags:
  - neovim
  - tricks
  - dx
draft: false
aliases:
    - /2026-07-22-god-i-love-neovim
---

If I had a nickel for every time this happened to me, I'd be rich, but
I haven't been posting for the better part of 2 weeks now, so I guess this is
my little epiphany of the week!

I love Neovim, it's my favourite customizable text editor. Well, I've used Emacs in the past, and in a way it's more customizable than Neovim, but I guess it's just a bit too easy to become [bankrupt](https://jakebox.github.io/posts/2025-08-31-bankruptcy.html) [^1] there... So, why am I writing this? Well, I've just smashed this into existence over the past 5 minutes:

```lua
local function f(bufnr)
    vim.keymap.set('n', '<leader>e', '<cmd>term sops %<cr>', { buf = bufnr })
    vim.notify("This seems like a sops secret. Press `<leader>e' to edit in-place")
end

vim.filetype.add {
    extension = {
        secret = function(_, bufnr)
            local content = vim.api.nvim_buf_get_lines(bufnr, 2, 3, false)[1] or ''
            if vim.regex([[^\s*"sops": {$]]):match_str(content) ~= nil then
                return "json", f
            end
        end,
        yaml = function(_, bufnr)
            local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) or {}
            for _, line in ipairs(content) do
                if vim.regex([[^sops:$]]):match_str(line) ~= nil then
                    return "yaml", f
                end
            end

            return "yaml"
        end,
    },
}
```

What does it do? Well, it's simple, really. When I open a file, it checks if the file I just opened is a [SOPS](https://getsops.io/) secret; that is, it can be a file ending in either `.secret` (which is a personal convention but oh well), or in `.yaml`, and in both cases it looks for a top-level `sops` attribute in respectively the JSON or YAML document. If the current file is indeed a SOPS secret, it will add a single simple keybinding: when I press space and then e, a quick keychord, it will open the decrypted secret contents for in-place editing. Then I can make some changes, save and quit, and SOPS will re-encrypt the file for me automatically!

Sops already has the `sops edit` command, which does exactly that, but this little bit of integration makes it that tiny bit more seamless, compared to manually writing `:term sops %` every time, or `sops edit secrets/path/to/some/secret` every time on the commandline...

Now the beauty of all this is that with Neovim, once you get used to the APIs it provides (like in this case [`:h vim.filetype.add`](<https://neovim.io/doc/user/lua/#vim.filetype.add()>)), you can just pump out these handy little snippets like they're nothing! And it worked first try too! Isn't that just neat.

[^1]: If I had a nickel for every time I linked that article about Emacs bankruptcy so far on this blog, I'd have two nickels. Which isn't a lot, but it's weird that it happened twice!
