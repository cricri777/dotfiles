-- Terminal splits get a tinted background and the window separators get brighter,
-- so the terminal stands out from the transparent editor. Colours follow the colorscheme.
local function blend(base, top, ratio)
  local out = 0
  for _, shift in ipairs({ 16, 8, 0 }) do
    local b = bit.band(bit.rshift(base, shift), 255)
    local t = bit.band(bit.rshift(top, shift), 255)
    out = out + bit.lshift(math.floor(b + (t - b) * ratio + 0.5), shift)
  end
  return out
end

local function hl(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false })
end

-- The real terminal background comes from the Omarchy theme, since the editor itself is transparent.
local function terminal_bg()
  local file = io.open(vim.fn.expand("~/.local/state/omarchy/current/theme/ghostty.conf"))
  if not file then
    return nil
  end
  local hex = ("\n" .. file:read("*a")):match("\nbackground%s*=%s*#(%x%x%x%x%x%x)")
  file:close()
  return hex and tonumber(hex, 16)
end

local function define_highlights()
  local fg = hl("Normal").fg
  local base = terminal_bg() or hl("ColorColumn").bg or hl("Visual").bg
  if not (fg and base) then
    return
  end
  local bg = base + 0x030303 -- three levels lighter per channel
  vim.api.nvim_set_hl(0, "TerminalNormal", { bg = bg })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = blend(bg, fg, 0.25), bold = true })
end

local TERM_WINHL = "Normal:TerminalNormal,NormalNC:TerminalNormal,EndOfBuffer:TerminalNormal"

local group = vim.api.nvim_create_augroup("terminal_style", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlights })

vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter", "WinEnter" }, {
  group = group,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      return
    end
    if vim.bo.buftype == "terminal" then
      vim.wo[win].winhighlight = TERM_WINHL
    elseif vim.wo[win].winhighlight == TERM_WINHL then
      vim.wo[win].winhighlight = ""
    end
  end,
})

define_highlights()
