-- Shared mutable state. Kept in its own module so panel/diff/commit can all see
-- the same windows without requiring each other in a cycle.
return {
  root = nil, ---@type string|nil

  panel = {
    buf = nil, ---@type integer|nil
    win = nil, ---@type integer|nil
    entries = {}, ---@type table<integer, table> line number -> status entry
    sections = {}, ---@type table<integer, string> line number -> section key
    collapsed = {}, ---@type table<string, boolean>
    status = nil,
  },

  diff = {
    left_win = nil, ---@type integer|nil
    right_win = nil, ---@type integer|nil
    left_buf = nil, ---@type integer|nil
    right_buf = nil, ---@type integer|nil
    entry = nil, ---@type table|nil
    saved = {}, ---@type table window id -> options captured before diff mode
  },
}
