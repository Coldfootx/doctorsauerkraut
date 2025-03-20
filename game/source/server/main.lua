choices = {}
table.insert(choices, "Name of the Server")
table.insert(choices, "Short Description of the Server")
for i, name in ipairs(choices) do
  print(i..". "..name)
end

choice = io.read("*n")