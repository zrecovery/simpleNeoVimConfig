-- author: glepnr https://github.com/glepnir
-- date: 2022-07-02
-- License: MIT
-- recommend plugins key defines in this file

require('keymap.config')
local key = require('core.keymap')
local nmap, imap, xmap, tmap = key.nmap, key.imap, key.xmap, key.tmap
local silent, noremap, expr, remap = key.silent, key.noremap, key.expr, key.remap
local opts = key.new_opts
local cmd = key.cmd

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.smart_tab = function()
  local cmp = require('cmp')
  local ok, luasnip = pcall(require, 'luasnip')
  local luasnip_status = false
  if ok then
    luasnip_status = luasnip.expand_or_jumpable()
  end

  if cmp.visible() and not luasnip_status then
    return '<C-n>'
  elseif luasnip_status then
    return '<Plug>luasnip-expand-or-jump'
  elseif has_words_before() then
    return '<Tab>'
  else
    return '<Tab>'
  end
end

_G.smart_shift_tab = function()
  local cmp = require('cmp')
  local _, luasnip = pcall(require, 'luasnip')

  if cmp.visible() then
    return '<C-p>'
  elseif luasnip.jumpable(-1) then
    return "<cmd>lua require'luasnip'.jump(-1)<CR>"
  else
    return '<S-Tab>'
  end
end

imap({
  -- tab key
  { '<TAB>', _G.smart_tab, opts(expr, silent, remap) },
  { '<S-TAB>', _G.smart_shift_tab, opts(expr, silent, remap) },
})

-- usage of plugins
nmap({
  -- packer
  { '<Leader>pu', cmd('PackerUpdate'), opts(noremap, silent) },
  { '<Leader>pi', cmd('PackerInstall'), opts(noremap, silent) },
  { '<Leader>pc', cmd('PackerCompile'), opts(noremap, silent) },
  -- dashboard
  { '<Leader>n', cmd('DashboardNewFile'), opts(noremap, silent) },
  { '<Leader>ss', cmd('SessionSave'), opts(noremap, silent) },
  { '<Leader>sl', cmd('SessionLoad'), opts(noremap, silent) },
  -- nvimtree
  { '<Leader>e', cmd('NvimTreeToggle'), opts(noremap, silent) },
  -- Telescope
  { '<Leader>b', cmd('Telescope buffers'), opts(noremap, silent) },
  { '<Leader>fa', cmd('Telescope live_grep'), opts(noremap, silent) },
  { '<Leader>ff', cmd('Telescope find_files'), opts(noremap, silent) },
})
