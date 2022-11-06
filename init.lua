-- TODO: Split this all up into multiple files?


local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options
local map = vim.keymap.set -- mappings


-- Sane defaults
cmd 'filetype plugin indent on'
cmd 'syntax enable'
cmd 'colorscheme zenburn'
vim.wo.colorcolumn = "80"
opt.expandtab = true
opt.hidden = true
opt.ignorecase = true
opt.number = true
opt.relativenumber = true
opt.smartindent = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartcase = true
opt.termguicolors = true
opt.wrap = false


-- Some nice remappings
vim.g.mapleader = " "
options = { 
    noremap = true,
    silent = true,
}
map("i", "jk", "<ESC>", options)
map("v", "<C-c>", "<ESC>", options)

-- Makes Tab and Shift- Tab buffer controls: 
-- Tab for next and Shift-Tab for previous
map("n", "<Tab>", ":if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>", options)
map("n", "<S-Tab>", ":if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>", options)

-- Open up terminal
map({'n', 'v', 'o'}, "<Leader>t", ":terminal <CR>", options)
-- Close terminal
map("t", "jk", "<C-W> N", options)

-- Reload init file
map("n", "<Leader>s", ":source ~/.config/nvim/init.lua <CR>", { noremap = true })


-- Packages
require "paq" {
    -- Let Paq manage itself
    "savq/paq-nvim"; 

    -- Colorschemes!
    "folke/tokyonight.nvim";
    "phha/zenburn.nvim";


    -- Fancy IDE stuff
    {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    };

    "neovim/nvim-lspconfig";
    "hrsh7th/cmp-nvim-lsp";
    "hrsh7th/nvim-cmp";


    -- LateX Stuff
    {
        "lervag/vimtex"
    };      -- Use braces when passing options
    {
        "L3MON4D3/LuaSnip",
        tag = "v<CurrentMajor>.*"
    };

    -- Nice status bar
    {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    };

}


local ts = require('nvim-treesitter.configs')
local cmp = require('cmp')
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

local luasnip = require('luasnip')

local lualine = require('lualine')

-- Treesitter Stuff
ts.setup {
    ensure_installed = { 
        "c",
        "cpp",
        "lua",
        "rust",
        "javascript",
        "typescript",
    },
    
    sync_install = false,

    highlight = {
        enable = true,

        disable = { "latex" },
    },
}

-- LSP Stuff and autocompletion stuff

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Mappings.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
end

-- Add additional capabilities supported by nvim-cmp

lspconfig['clangd'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
lspconfig['rust_analyzer'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
}
lspconfig['tsserver'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
        npmLocation = "/opt/homebrew/lib/node_modules/typescript-language-server/lib"
    }
}
lspconfig['pyright'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-f>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({
            select = true,
        }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),

    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }),
}

-- Snippets
luasnip.config.set_config({ -- Setting LuaSnip config
  -- Enable autotriggered snippets
  enable_autosnippets = true,

  -- Use Tab (or some other key if you prefer) to trigger visual selection
  store_selection_keys = "<Tab>",

  update_events = 'TextChanged,TextChangedI',
})

cmd[[
" Expand snippets in insert mode with Tab
imap <silent><expr> <Tab> luasnip#expandable() ? '<Plug>luasnip-expand-snippet' : '<Tab>'

" Jump forward in through tabstops in insert and visual mode with Control-n
imap <silent><expr> <C-n> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<C-n>'
smap <silent><expr> <C-n> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<C-n>'

" Jump backward through snippet tabstops with Shift-Tab (for example)
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]

-- Lazy-load snippets, i.e. only load when required, e.g. for a given filetype
require("luasnip.loaders.from_lua").lazy_load({paths = "~/.config/nvim/LuaSnip/"})


-- Lualine Stuff
lualine.setup {
    options = {
        icons_enabled = false,
        theme = 'zenburn',
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_c = {
            {
                'buffers',
                show_filename_only = true,
                show_modified_status = true,

                mode = 0,
            }
        },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}


-- Latex stuff
opt.conceallevel=2
cmd[[
let g:vimtex_view_method = 'skim'
let g:vimtex_quickfix_mode=0
let g:tex_conceal='abdmg'
:hi clear Conceal
]]


