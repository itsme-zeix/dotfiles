--[[
  Neovim Configuration
  Plugins are in lua/custom/plugins/init.lua
--]]

-- Leader key (must be set before plugins load)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- [[ Options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 15
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.colorcolumn = '100'
vim.opt.confirm = true
-- vim.o.autochdir = true
vim.o.clipboard = 'unnamedplus'

-- [[ Autocommands ]]
local yank_group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = yank_group,
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Enable yanking over ssh on OSC52-compatible terminal client',
  group = yank_group,
  callback = function()
    local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy '+'
    copy_to_unnamedplus(vim.v.event.regcontents)
    local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy '*'
    copy_to_unnamed(vim.v.event.regcontents)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Use syntax highlighting for Markdown until Tree-sitter Markdown is stable',
  pattern = { 'markdown' },
  callback = function(event)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) then
        pcall(vim.treesitter.stop, event.buf)
      end
    end)
  end,
})

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Split navigation
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Install lazy.nvim ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Setup lazy.nvim ]]
require('lazy').setup({
  { import = 'custom.plugins' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
