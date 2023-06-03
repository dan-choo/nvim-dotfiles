vim.g.mapleader = " "

require("config")
require("zenburn").setup()

if vim.env.VIM_PATH then
	vim.env.PATH = vim.env.VIM_PATH
end


