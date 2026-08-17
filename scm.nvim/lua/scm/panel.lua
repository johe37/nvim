-- The source control panel: a sidebar listing changed files grouped into
-- Conflicts / Staged Changes / Changes / Untracked, like VS Code's SCM view.
local git = require("scm.git")
local state = require("scm.state")
local config = require("scm.config")
local diff = require("scm.diff")

local M = {}

local ns = vim.api.nvim_create_namespace("scm.panel")

local SECTIONS = {
  { key = "conflicted", title = "Merge Conflicts" },
  { key = "staged", title = "Staged Changes" },
  { key = "unstaged", title = "Changes" },
  { key = "untracked", title = "Untracked" },
}

local CODE_HL = {
  M = "ScmModified",
  A = "ScmAdded",
  D = "ScmDeleted",
  R = "ScmRenamed",
  C = "ScmRenamed",
  T = "ScmModified",
  U = "ScmConflict",
  ["?"] = "ScmUntracked",
}

local function win_valid(win)
  return win and vim.api.nvim_win_is_valid(win)
end

function M.is_open()
  return state.panel.win ~= nil and vim.api.nvim_win_is_valid(state.panel.win)
end

--- Entry under the cursor, or nil on a header/blank line.
function M.current_entry()
  if not M.is_open() then
    return nil
  end
  local lnum = vim.api.nvim_win_get_cursor(state.panel.win)[1]
  return state.panel.entries[lnum]
end

local function current_section()
  if not M.is_open() then
    return nil
  end
  local lnum = vim.api.nvim_win_get_cursor(state.panel.win)[1]
  return state.panel.sections[lnum] or (state.panel.entries[lnum] or {}).kind
end

---@param buf integer
local function render(buf, status)
  local lines, marks, entries, sections = {}, {}, {}, {}

  local function add(text, hls, meta)
    lines[#lines + 1] = text
    local lnum = #lines
    for _, hl in ipairs(hls or {}) do
      marks[#marks + 1] = { lnum - 1, hl[1], hl[2], hl[3] }
    end
    if meta then
      if meta.entry then
        entries[lnum] = meta.entry
      end
      if meta.section then
        sections[lnum] = meta.section
      end
    end
  end

  local name = vim.fs.basename(state.root or "")
  add(" Source Control", { { 0, -1, "ScmTitle" } })

  local head = git.branch(state.root)
  local upstream = git.upstream(state.root)
  local branch_line = " " .. head
  if upstream and (upstream.ahead > 0 or upstream.behind > 0) then
    branch_line = branch_line .. string.format("  ^%d v%d", upstream.ahead, upstream.behind)
  end
  add(branch_line, { { 0, -1, "ScmBranch" } })
  add(" " .. name, { { 0, -1, "ScmDim" } })

  local total = 0
  for _, section in ipairs(SECTIONS) do
    local list = status[section.key] or {}
    total = total + #list
    if #list > 0 then
      add("")
      local collapsed = state.panel.collapsed[section.key]
      local marker = collapsed and ">" or "v"
      add(
        string.format(" %s %s (%d)", marker, section.title, #list),
        { { 0, -1, "ScmSection" } },
        { section = section.key }
      )
      if not collapsed then
        for _, entry in ipairs(list) do
          local base = vim.fs.basename(entry.path)
          local dir = vim.fs.dirname(entry.path)
          dir = (dir == "." or dir == "") and "" or dir
          local prefix = string.format("   %s  ", entry.code)
          local text = prefix .. base
          local hls = {
            { 3, 4, CODE_HL[entry.code] or "ScmModified" },
            { #prefix, #prefix + #base, entry.code == "D" and "ScmDeleted" or "ScmPath" },
          }
          if dir ~= "" then
            text = text .. "  " .. dir
            hls[#hls + 1] = { #prefix + #base, -1, "ScmDim" }
          end
          add(text, hls, { entry = entry, section = section.key })
        end
      end
    end
  end

  if total == 0 then
    add("")
    add("  No changes", { { 0, -1, "ScmDim" } })
  end

  add("")
  add("  g? for help", { { 0, -1, "ScmDim" } })

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, mark in ipairs(marks) do
    local lnum, col_start, col_end, hl = mark[1], mark[2], mark[3], mark[4]
    local len = #(lines[lnum + 1] or "")
    if col_end == -1 or col_end > len then
      col_end = len
    end
    if col_start < col_end then
      vim.api.nvim_buf_set_extmark(buf, ns, lnum, col_start, { end_col = col_end, hl_group = hl })
    end
  end

  state.panel.entries = entries
  state.panel.sections = sections
  state.panel.status = status
end

--- Redraw the panel, keeping the cursor on the same file when possible.
function M.refresh()
  if not (state.panel.buf and vim.api.nvim_buf_is_valid(state.panel.buf)) then
    return
  end
  if not state.root then
    return
  end
  local keep = M.current_entry()
  render(state.panel.buf, git.status(state.root))
  if keep and M.is_open() then
    for lnum, entry in pairs(state.panel.entries) do
      if entry.path == keep.path and entry.kind == keep.kind then
        pcall(vim.api.nvim_win_set_cursor, state.panel.win, { lnum, 0 })
        return
      end
    end
    -- The entry moved sections (e.g. it was just staged); settle on the first file.
    local first = math.huge
    for lnum, entry in pairs(state.panel.entries) do
      if entry.path == keep.path then
        first = math.min(first, lnum)
      end
    end
    if first ~= math.huge then
      pcall(vim.api.nvim_win_set_cursor, state.panel.win, { first, 0 })
    end
  end
end

local function act(fn)
  return function()
    local entry = M.current_entry()
    if not entry then
      return
    end
    fn(entry)
  end
end

local function each_in_section(kind, fn)
  local list = (state.panel.status or {})[kind] or {}
  for _, entry in ipairs(list) do
    fn(entry)
  end
end

local function after_index_change()
  M.refresh()
  diff.refresh()
end

local HELP = {
  "SCM panel",
  "",
  "  <CR> / o   open side-by-side diff (focus the diff)",
  "  p          open diff, keep focus in the panel",
  "  s / u / -  stage / unstage / toggle the file",
  "  S / U      stage / unstage everything in the section",
  "  X          discard changes (untracked files are deleted)",
  "  cc / ca    commit / amend the last commit",
  "  <Tab>      collapse or expand a section",
  "  J / K      next / previous file",
  "  r          refresh",
  "  q          close the panel and any diff",
  "",
  "In the diff: ]c / [c jump between changes, q closes it,",
  "<leader>gS stages the file you are looking at.",
}

local function attach_keymaps(buf)
  local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, nowait = true, desc = "SCM: " .. desc })
  end

  map("<CR>", act(function(entry)
    diff.open(entry)
  end), "Open diff")
  map("o", act(function(entry)
    diff.open(entry)
  end), "Open diff")
  map("<2-LeftMouse>", act(function(entry)
    diff.open(entry)
  end), "Open diff")
  map("p", act(function(entry)
    diff.open(entry, { focus = false })
  end), "Preview diff")

  map("s", act(function(entry)
    if git.stage(state.root, entry) then
      after_index_change()
    end
  end), "Stage file")
  map("u", act(function(entry)
    if git.unstage(state.root, entry) then
      after_index_change()
    end
  end), "Unstage file")
  map("-", act(function(entry)
    local ok = entry.kind == "staged" and git.unstage(state.root, entry) or git.stage(state.root, entry)
    if ok then
      after_index_change()
    end
  end), "Toggle staged")

  map("S", function()
    local kind = current_section() or "unstaged"
    if kind == "staged" then
      return
    end
    each_in_section(kind, function(entry)
      git.stage(state.root, entry)
    end)
    after_index_change()
  end, "Stage all in section")
  map("U", function()
    each_in_section("staged", function(entry)
      git.unstage(state.root, entry)
    end)
    after_index_change()
  end, "Unstage all")

  map("X", act(function(entry)
    if config.confirm_discard then
      local what = entry.kind == "untracked" and ("Delete untracked " .. entry.path .. "?")
        or ("Discard changes in " .. entry.path .. "?")
      if vim.fn.confirm(what, "&Yes\n&No", 2) ~= 1 then
        return
      end
    end
    if git.discard(state.root, entry) then
      -- Reload the buffer so the window shows the reverted file.
      local bufnr = vim.fn.bufnr(state.root .. "/" .. entry.path)
      if bufnr ~= -1 and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          pcall(vim.cmd, "silent! edit!")
        end)
      end
      after_index_change()
    end
  end), "Discard changes")

  map("cc", function()
    require("scm.commit").open()
  end, "Commit")
  map("ca", function()
    require("scm.commit").open({ amend = true })
  end, "Commit --amend")

  map("<Tab>", function()
    local kind = current_section()
    if kind then
      state.panel.collapsed[kind] = not state.panel.collapsed[kind]
      M.refresh()
    end
  end, "Toggle section")

  local function jump(step)
    return function()
      local lnum = vim.api.nvim_win_get_cursor(0)[1]
      local last = vim.api.nvim_buf_line_count(buf)
      for i = lnum + step, step > 0 and last or 1, step do
        if state.panel.entries[i] then
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          return
        end
      end
    end
  end
  map("J", jump(1), "Next file")
  map("K", jump(-1), "Previous file")

  map("r", M.refresh, "Refresh")
  map("R", M.refresh, "Refresh")
  map("q", M.close, "Close panel")
  map("g?", function()
    vim.notify(table.concat(HELP, "\n"), vim.log.levels.INFO, { title = "scm.nvim" })
  end, "Help")
end

local function create_buf()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "scm"
  pcall(vim.api.nvim_buf_set_name, buf, "scm://status")
  attach_keymaps(buf)
  return buf
end

local function setup_win(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.cursorline = true
  wo.wrap = false
  wo.list = false
  wo.winfixwidth = true
  wo.spell = false
  wo.statuscolumn = ""
end

function M.open()
  local root = git.root(vim.api.nvim_buf_get_name(0)) or git.root(vim.uv.cwd())
  if not root then
    vim.notify("scm: not inside a git repository", vim.log.levels.WARN)
    return
  end
  if state.root and state.root ~= root then
    state.panel.collapsed = {}
  end
  state.root = root

  if not (state.panel.buf and vim.api.nvim_buf_is_valid(state.panel.buf)) then
    state.panel.buf = create_buf()
  end

  if not M.is_open() then
    local previous = vim.api.nvim_get_current_win()
    vim.cmd(config.position == "left" and "topleft vsplit" or "botright vsplit")
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, state.panel.buf)
    vim.api.nvim_win_set_width(win, config.width)
    setup_win(win)
    state.panel.win = win
    M.refresh()
    if win_valid(previous) then
      vim.api.nvim_set_current_win(win)
    end
  else
    M.refresh()
    vim.api.nvim_set_current_win(state.panel.win)
  end
end

function M.close()
  diff.close()
  if M.is_open() and #vim.api.nvim_tabpage_list_wins(0) > 1 then
    pcall(vim.api.nvim_win_close, state.panel.win, true)
  end
  state.panel.win = nil
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

--- Diff the file in the current buffer against the index (or HEAD).
---@param opts? { rev?: string }
function M.diff_current(opts)
  opts = opts or {}
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("scm: no file in this buffer", vim.log.levels.WARN)
    return
  end
  local root = git.root(path)
  if not root then
    vim.notify("scm: not inside a git repository", vim.log.levels.WARN)
    return
  end
  state.root = root
  local rel = vim.fs.relpath(root, path) or path
  diff.open({
    path = rel,
    code = "M",
    kind = "unstaged",
    label = "modified",
    force_left = opts.rev and git.spec(opts.rev, rel) or nil,
  })
end

return M
