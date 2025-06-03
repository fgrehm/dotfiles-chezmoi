-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- vim + tmux goodies
-- https://github.com/alexghergh/nvim-tmux-navigation
local nvim_tmux_nav = require("nvim-tmux-navigation")
vim.keymap.set("n", "<A-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
vim.keymap.set("n", "<A-Left>", nvim_tmux_nav.NvimTmuxNavigateLeft)
vim.keymap.set("n", "<A-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
vim.keymap.set("n", "<A-Down>", nvim_tmux_nav.NvimTmuxNavigateDown)
vim.keymap.set("n", "<A-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
vim.keymap.set("n", "<A-Up>", nvim_tmux_nav.NvimTmuxNavigateUp)
vim.keymap.set("n", "<A-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
vim.keymap.set("n", "<A-Right>", nvim_tmux_nav.NvimTmuxNavigateRight)
vim.keymap.set("n", "<A-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
vim.keymap.set("n", "<A-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
