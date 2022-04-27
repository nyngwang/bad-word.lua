local M = {}

local fn = vim.fn
local api = vim.api
local max_len = 20
local disable_on_lines = 2000

function M.setup(opt)
  max_len = opt.max_len ~= nil and opt.max_len or max_len
  disable_on_lines = opt.disable_on_lines ~= nil and opt.disable_on_lines or disable_on_lines
end


function M.highlight()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > disable_on_lines then return end
  if fn.hlexists("BadWord") == 0 or api.nvim_exec("hi BadWord", true):find("cleared") then
    vim.cmd("hi! BadWord cterm=underline gui=underline")
  end
end

local function matchdelete(clear_word)
  if clear_word then
    vim.w.bad_word = nil
  end
  if vim.w.bad_word_match_id then
    pcall(fn.matchdelete, vim.w.bad_word_match_id)
    vim.w.bad_word_match_id = nil
  end
end

local function matchstr(...)
  local ok, ret = pcall(fn.matchstr, ...)
  if ok then
    return ret
  end
  return ""
end

function M.matchadd()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > disable_on_lines then return end
  if vim.tbl_contains(vim.g.bad_word_disable_filetypes or {}, vim.bo.filetype) then
    return
  end

  local column = api.nvim_win_get_cursor(0)[2]
  local line = api.nvim_get_current_line()

  local left = matchstr(line:sub(1, column + 1), [[\k*$]])
  local right = matchstr(line:sub(column + 1), [[^\k*]]):sub(2)

  local bad_word = left .. right

  if bad_word == vim.w.cursorwod then
    return
  end

  vim.w.bad_word = bad_word

  matchdelete()

  if #bad_word < 3 or #bad_word > max_len or bad_word:find("[\192-\255]+") then
    return
  end

  bad_word = fn.escape(bad_word, [[~"\.^$[]*]])
  vim.w.bad_word_match_id = fn.matchadd("BadWord", [[\<]] .. bad_word .. [[\>]], -1)
end

function M.matchdelete()
  if vim.fn.getbufinfo(vim.fn.bufnr())[1].linecount > disable_on_lines then return end
  matchdelete(true)
end

return M
