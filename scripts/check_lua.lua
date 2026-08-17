-- Syntax-check every Lua file in the config. Run with:
--   nvim --clean -l scripts/check_lua.lua
local root = vim.env.GITHUB_WORKSPACE or vim.fn.getcwd()

local files = vim.fs.find(function(name)
  return name:sub(-4) == ".lua"
end, { type = "file", limit = math.huge, path = root })

-- vim.fs.find skips dot-directories; pick up workflow helpers if they live there.
vim.list_extend(
  files,
  vim.fs.find(function(name)
    return name:sub(-4) == ".lua"
  end, { type = "file", limit = math.huge, path = root .. "/.github" })
)

table.sort(files)

local errors = {}
for _, file in ipairs(files) do
  local chunk, err = loadfile(file)
  if not chunk then
    errors[#errors + 1] = err
  end
end

if #errors > 0 then
  for _, err in ipairs(errors) do
    io.stderr:write(err .. "\n")
  end
  io.stderr:write(string.format("lua syntax: %d file(s) failed\n", #errors))
  os.exit(1)
end

print(string.format("lua syntax: %d file(s) ok", #files))
