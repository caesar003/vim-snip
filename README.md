# vim-snip

A minimal, no-nonsense snippet manager for Vim and Neovim.

## Why Another Snippet Plugin?

There are plenty of well-crafted snippet plugins out there, like LuaSnip or UltiSnips. But if you’re like me, you don’t want to install a massive system filled with things you don’t understand (or need) just to insert a few common code patterns.

**vim-snip** is about:

-   Keeping things **simple** and **lightweight**.
-   **Understanding** what goes into your Vim/Neovim configuration.
-   **Curating** only the snippets **you** actually use.
-   Learning Vimscript and Lua instead of blindly copying configurations.

This is not meant to replace more powerful snippet plugins. It’s meant for those who prefer **hand-crafted**, minimal setups without unnecessary complexity.

## Features

-   Define your own snippet templates as simple text files.
-   Trigger snippets using **custom key mappings** (e.g., `!<Tab>` for an HTML boilerplate).
-   Works in both **Vim (Vimscript)** and **Neovim (Lua)**.
-   No dependencies, just native Vim/Neovim functionality.
-   Easily extendable with more snippets.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'caesar003/vim-snip'
```

For Lazy:

```lua
return {
    'caesar003/vim-snip'
}
```

## Usage

### 1. Snippet Files

Snippets are stored in the `plugin/templates/` directory, grouped by language.

Example structure:

```
plugin/templates/
├── html/
│   ├── boilerplate.txt
│   ├── unordered-list.txt
│   └── ordered-list.txt
├── javascript/
│   ├── console-log.txt
│   ├── async-await.txt
│   ├── switch.txt
│   ├── arrow-component.txt
│   └── function-expression-component.txt
```

### 2. Triggering Snippets

You can trigger snippets in **insert mode** with mappings like:

#### Vimscript (for Vim users)

```vim
inoremap !<Tab> <Cmd>Snip html boilerplate<CR>
inoremap img<Tab> <Cmd>Snip html img<CR>
inoremap clg<Tab> <Cmd>Snip javascript console-log<CR>
```

#### Lua (for Neovim users)

```lua
vim.api.nvim_set_keymap("i", "!<Tab>", "<Cmd>Snip html boilerplate<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "clg<Tab>", "<Cmd>Snip javascript console-log<CR>", { noremap = true, silent = true })
```

### 3. Adding Your Own Snippets

Just drop a new text file in `plugin/templates/<language>/` and map it using your preferred keybinding.

## Philosophy

I respect the work of the many brilliant Vim/Neovim contributors. Their tools are incredibly powerful. But Vim is also about **learning, improving, and making your setup truly yours**. If you enjoy understanding what goes into your config instead of blindly copying, this plugin is for you.

## Contributing

Feel free to submit PRs with additional **well-curated** snippets, but keep the spirit of minimalism in mind.

## License

MIT
