-- Thin wrapper around the `git` CLI. Everything is synchronous: the commands we
-- run (status, show, add, reset) are cheap enough that a blocking call keeps the
-- rest of the plugin free of callback plumbing.
local M = {}

---@param args string[]
---@param opts? { cwd?: string, stdin?: string }
function M.run(args, opts)
  opts = opts or {}
  local cmd = { "git", "--no-pager", "--literal-pathspecs" }
  for _, a in ipairs(args) do
    cmd[#cmd + 1] = a
  end
  local ok, res = pcall(function()
    return vim.system(cmd, { text = true, cwd = opts.cwd, stdin = opts.stdin }):wait()
  end)
  if not ok then
    return { code = 1, stdout = "", stderr = tostring(res) }
  end
  res.stdout = res.stdout or ""
  res.stderr = res.stderr or ""
  return res
end

--- Run git and report failures to the user.
---@return boolean ok
function M.exec(args, opts)
  local res = M.run(args, opts)
  if res.code ~= 0 then
    local msg = vim.trim(res.stderr ~= "" and res.stderr or res.stdout)
    vim.notify("scm: git " .. table.concat(args, " ") .. "\n" .. msg, vim.log.levels.ERROR)
    return false
  end
  return true
end

--- Repository root containing `path` (a file or directory), or nil.
---@param path? string
---@return string|nil
function M.root(path)
  path = path or vim.uv.cwd()
  if path == "" or vim.fn.isdirectory(path) == 0 then
    path = vim.fs.dirname(path)
  end
  if not path or path == "" or vim.fn.isdirectory(path) == 0 then
    return nil
  end
  local res = M.run({ "rev-parse", "--show-toplevel" }, { cwd = path })
  if res.code ~= 0 then
    return nil
  end
  local root = vim.trim(res.stdout)
  return root ~= "" and root or nil
end

--- True when HEAD points at a commit (false in a repo with no commits yet).
function M.has_head(root)
  return M.run({ "rev-parse", "--verify", "--quiet", "HEAD" }, { cwd = root }).code == 0
end

function M.branch(root)
  local res = M.run({ "symbolic-ref", "--short", "HEAD" }, { cwd = root })
  if res.code == 0 then
    return vim.trim(res.stdout)
  end
  local sha = M.run({ "rev-parse", "--short", "HEAD" }, { cwd = root })
  if sha.code == 0 then
    return "detached " .. vim.trim(sha.stdout)
  end
  return "no commits yet"
end

--- How far the current branch is ahead/behind its upstream.
---@return { ahead: integer, behind: integer }|nil
function M.upstream(root)
  local res = M.run({ "rev-list", "--left-right", "--count", "HEAD...@{upstream}" }, { cwd = root })
  if res.code ~= 0 then
    return nil
  end
  local ahead, behind = vim.trim(res.stdout):match("^(%d+)%s+(%d+)$")
  if not ahead then
    return nil
  end
  return { ahead = tonumber(ahead), behind = tonumber(behind) }
end

local STATUS_LABEL = {
  M = "modified",
  A = "added",
  D = "deleted",
  R = "renamed",
  C = "copied",
  T = "typechange",
  U = "conflict",
  ["?"] = "untracked",
}

--- Working tree status, split into the three sections the panel renders.
---@return { staged: table[], unstaged: table[], untracked: table[], conflicted: table[] }
function M.status(root)
  local out = { staged = {}, unstaged = {}, untracked = {}, conflicted = {} }
  local res = M.run({ "status", "--porcelain=v1", "-z", "--untracked-files=all" }, { cwd = root })
  if res.code ~= 0 then
    return out
  end

  -- With -z each record is NUL terminated; rename/copy records are followed by a
  -- second NUL terminated field holding the original path.
  local fields = vim.split(res.stdout, "\0", { plain = true })
  local i = 1
  while fields[i] and fields[i] ~= "" do
    local record = fields[i]
    local x, y, path = record:sub(1, 1), record:sub(2, 2), record:sub(4)
    local orig = nil
    if x == "R" or x == "C" or y == "R" or y == "C" then
      orig = fields[i + 1]
      i = i + 1
    end
    i = i + 1

    local function entry(code, kind)
      return {
        path = path,
        orig = orig,
        code = code,
        kind = kind,
        label = STATUS_LABEL[code] or code,
        x = x,
        y = y,
      }
    end

    if x == "U" or y == "U" or (x == "A" and y == "A") or (x == "D" and y == "D") then
      out.conflicted[#out.conflicted + 1] = entry("U", "conflicted")
    elseif x == "?" then
      out.untracked[#out.untracked + 1] = entry("?", "untracked")
    else
      if x ~= " " then
        out.staged[#out.staged + 1] = entry(x, "staged")
      end
      if y ~= " " then
        out.unstaged[#out.unstaged + 1] = entry(y, "unstaged")
      end
    end
  end

  local function by_path(a, b)
    return a.path < b.path
  end
  for _, list in pairs(out) do
    table.sort(list, by_path)
  end
  return out
end

--- Contents of a blob, e.g. spec = "HEAD:lua/init.lua" or ":0:lua/init.lua".
---@return string[]|nil lines, string|nil err
function M.blob(root, spec)
  local res = M.run({ "show", spec }, { cwd = root })
  if res.code ~= 0 then
    return nil, vim.trim(res.stderr)
  end
  if res.stdout:find("\0", 1, true) then
    return nil, "binary file"
  end
  local lines = vim.split(res.stdout, "\n", { plain = true })
  -- git emits a trailing newline; don't turn it into a phantom last line.
  if lines[#lines] == "" then
    table.remove(lines)
  end
  return lines
end

--- Escape a path so `git show` treats it literally even if it starts with `-`.
function M.spec(rev, path)
  return string.format("%s:%s", rev, path)
end

function M.stage(root, entry)
  return M.exec({ "add", "--", entry.orig or entry.path, entry.path }, { cwd = root })
end

function M.unstage(root, entry)
  local paths = { "reset", "--quiet", "HEAD", "--", entry.path }
  if entry.orig then
    paths[#paths + 1] = entry.orig
  end
  if not M.has_head(root) then
    paths = { "rm", "--cached", "--quiet", "--", entry.path }
  end
  return M.exec(paths, { cwd = root })
end

function M.discard(root, entry)
  if entry.kind == "untracked" then
    return vim.fn.delete(root .. "/" .. entry.path) == 0
  end
  return M.exec({ "checkout", "--", entry.path }, { cwd = root })
end

function M.commit(root, message, amend)
  local args = { "commit", "--file=-", "--cleanup=strip" }
  if amend then
    args[#args + 1] = "--amend"
  end
  local res = M.run(args, { cwd = root, stdin = message })
  if res.code ~= 0 then
    vim.notify("scm: commit failed\n" .. vim.trim(res.stderr .. res.stdout), vim.log.levels.ERROR)
    return false
  end
  vim.notify("scm: " .. vim.trim(vim.split(res.stdout, "\n")[1] or "committed"))
  return true
end

function M.last_message(root)
  local res = M.run({ "log", "-1", "--pretty=%B" }, { cwd = root })
  if res.code ~= 0 then
    return ""
  end
  return vim.trim(res.stdout)
end

return M
