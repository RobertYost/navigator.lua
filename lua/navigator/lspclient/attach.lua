local vim, api = vim, vim.api
local lsp = require("vim.lsp")

local util = require "navigator.util"
local log = util.log

if not packer_plugins["nvim-lua/lsp-status.nvim"] or not packer_plugins["lsp-status.nvim"].loaded then
  vim.cmd [[packadd lsp-status.nvim]]
end
local lsp_status = require("lsp-status")

local diagnostic_map = function(bufnr)
  local opts = {noremap = true, silent = true}
  api.nvim_buf_set_keymap(bufnr, "n", "]O", ":lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
end
local M = {}
local function documentHighlight()
  api.nvim_exec(
    [[
      hi LspReferenceRead cterm=bold gui=Bold ctermbg=yellow guibg=DarkOrchid3
      hi LspReferenceText cterm=bold gui=Bold ctermbg=red guibg=gray27
      hi LspReferenceWrite cterm=bold gui=Bold,Italic ctermbg=red guibg=MistyRose
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
    false
  )
  vim.lsp.handlers["textDocument/documentHighlight"] = function(_, _, result, _)
    if not result then
      return
    end
    bufnr = api.nvim_get_current_buf()
    vim.lsp.util.buf_clear_references(bufnr)
    vim.lsp.util.buf_highlight_references(bufnr, result)
  end
end

M.on_attach = function(client, bufnr)
  log("attaching")
  if lsp_status ~= nil then
    lsp_status.on_attach(client, bufnr)
  end
  require "lsp_signature".on_attach()
  diagnostic_map(bufnr)
  -- lspsaga
  require "utils.highlight".add_highlight()

  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- https://github.com/fsouza
  if client.resolved_capabilities.document_highlight then
    documentHighlight()
  end

  require("navigator.lspclient.mapping").setup({client = client, bufnr = bufnr, cap = client.resolved_capabilities})

  vim.cmd [[packadd vim-illuminate]]
  require "illuminate".on_attach(client)
  require "utils.lspkind".init()

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
end



M.setup = function(cfg)
  return M
end

return M