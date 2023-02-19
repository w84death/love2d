function parseObjFile(filename)
  -- Read input from file
  local input = {}
  for line in io.lines(filename) do
    table.insert(input, line)
  end
  input = table.concat(input, "\n")

  -- Regular expressions to match vertex and face data
  local vertexRegex = "^v%s+([-0-9.]+)%s+([-0-9.]+)%s+([-0-9.]+)"
  local faceRegex = "^f%s+([0-9]+)%s+([0-9]+)%s+([0-9]+)"

  -- Extract vertex data
  local vert = {}
  for line in input:gmatch("[^\n]+") do
    local x, y, z = line:match(vertexRegex)
    if x then
      table.insert(vert, {tonumber(x), tonumber(y), tonumber(z)})
    end
  end

  -- Extract face data
  local face = {}
  for line in input:gmatch("[^\n]+") do
    local v1, v2, v3 = line:match(faceRegex)
    if v1 then
      table.insert(face, {tonumber(v1), tonumber(v2), tonumber(v3)})
    end
  end

  -- Return vertex and face tables
  return vert, face
end

