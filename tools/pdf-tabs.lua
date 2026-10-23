-- pdf-tabs.lua: in PDF output, print the MATLAB and Python versions one after
-- the other, under small bold labels instead of numbered section headings.
if not FORMAT:match("latex") then
  return {}
end

function Div(div)
  if not div.classes:includes("panel-tabset") then
    return nil
  end
  local out = {}
  for _, block in ipairs(div.content) do
    if block.t == "Header" then
      table.insert(out, pandoc.Para({ pandoc.Strong(block.content) }))
    else
      table.insert(out, block)
    end
  end
  return out
end
