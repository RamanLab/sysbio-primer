-- missing-output.lua: if an example's output figure has not been generated yet
-- (typically a MATLAB figure when previewing on a machine without MATLAB),
-- show a short note instead of a broken image.

local function exists(path)
  local f = io.open(path, "r")
  if f then f:close() return true end
  return false
end

function Image(img)
  if not img.src:match("/out/") then
    return nil
  end
  local path
  if img.src:sub(1, 1) == "/" then  -- relative to the project root
    path = pandoc.path.join({ quarto.project.directory, img.src:sub(2) })
  else
    path = pandoc.path.join({ pandoc.path.directory(quarto.doc.input_file), img.src })
  end
  if exists(path) then
    return nil
  end
  local lang = img.src:match("/out/(%a+)/") or "this"
  io.stderr:write("[missing-output] " .. img.src .. "\n")
  return pandoc.Emph({ pandoc.Str("(The " .. lang .. " figure has not been generated yet; it is produced by the CI run.)") })
end
