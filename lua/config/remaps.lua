-- Some remaps/nice defaults

vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.wrap = false


options = { 
	noremap = true,
	silent = true,
}

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "jk", "<ESC>")

-- Makes Tab and Shift- Tab buffer controls: 
-- Tab for next and Shift-Tab for previous
vim.keymap.set("n", "<Tab>", ":if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>", options)
vim.keymap.set("n", "<S-Tab>", ":if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>", options)

-- Lets you move stuff that's highlighted :) -- Credit: ThePrimeagen
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Lets you copy stuff -- ThePrimeagen
vim.keymap.set("v", "<leader>y", "\"+y")


-- Telescope remaps
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)


