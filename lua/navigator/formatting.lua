-- https://github.com/wention/dotfiles/blob/master/.config/nvim/lua/config/lsp.lua
-- https://github.com/lukas-reineke/dotfiles/blob/master/vim/lua/lsp/handlers.lua
return {
  format_hdl = function(err, result, ctx, _) -- FIXME: bufnr is nil
    if err ~= nil or result == nil then
      return
    end

    local util = require('navigator.util')
    local log = util.log

    local offset_encoding = util.encoding(vim.lsp.get_client_by_id(ctx.client_id))

    -- If the buffer hasn't been modified before the formatting has finished,
    -- update the buffer
    -- if not vim.api.nvim_buf_get_option(ctx.bufnr, 'modified') then
    vim.defer_fn(function()
      log('fmt callback')

      if ctx.bufnr == vim.api.nvim_get_current_buf() or not vim.api.nvim_buf_get_option(ctx.bufnr, 'modified') then
        local view = vim.fn.winsaveview()
        vim.lsp.util.apply_text_edits(result, ctx.bufnr, offset_encoding)
        vim.fn.winrestview(view)
        -- FIXME: commented out as a workaround
        -- if bufnr == vim.api.nvim_get_current_buf() then
        vim.api.nvim_command('noautocmd :update')

        -- Trigger post-formatting autocommand which can be used to refresh gitgutter
        vim.api.nvim_command('silent doautocmd <nomodeline> User FormatterPost')
        -- end
      end
    end, 100)
  end,
}
