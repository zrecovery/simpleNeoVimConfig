local api = vim.api
local lspconfig = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()

if not packer_plugins['cmp-nvim-lsp'].loaded then
  vim.cmd([[packadd cmp-nvim-lsp]])
end
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local signs = {
  Error = ' ',
  Warn = ' ',
  Info = ' ',
  Hint = ' ',
}
for type, icon in pairs(signs) do
  local hl = 'DiagnosticSign' .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  virtual_text = {
    source = true,
  },
})

local on_attach = function(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    api.nvim_create_autocmd('BufWritePre', {
      pattern = client.config.filetypes,
      callback = function()
        vim.lsp.buf.format({
          bufnr = bufnr,
          async = true,
        })
      end,
    })
  end
end

lspconfig.gopls.setup({
  on_attach = on_attach,
  cmd = { 'gopls', '--remote=auto' },
  capabilities = capabilities,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
  },
})

lspconfig.sumneko_lua.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        enable = true,
        globals = { 'vim', 'packer_plugins' },
      },
      runtime = { version = 'LuaJIT' },
      workspace = {
        library = vim.list_extend({ [vim.fn.expand('$VIMRUNTIME/lua')] = true }, {}),
      },
    },
  },
})

local servers = {
  'pyright',
  'bashls',
}

lspconfig.tsserver.setup({
  on_attach = on_attach,
})

for _, server in ipairs(servers) do
  lspconfig[server].setup({
    on_attach = on_attach,
  })
end
