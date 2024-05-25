std = "min+love"
allow_defined_top = true
unused_args = false
-- max_line_length 160

files["api/**"] = {
  global = false,
  unused = false,
  max_line_length = false,
  -- https://luacheck.readthedocs.io/en/stable/warnings.html
  ignore = {
    "611", -- A line consists of nothing but whitespace.
    "612", -- A line contains trailing whitespace.
    "613", -- Trailing whitespace in a string.
    "614", -- Trailing whitespace in a comment.
  },
}

exclude_files = {
  "lib/ext",
}
