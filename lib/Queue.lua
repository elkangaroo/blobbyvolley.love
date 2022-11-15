-- based on "Programming in Lua - Queues and Double Queues" https://www.lua.org/pil/11.4.html
local Queue = {}

function Queue.new()
  return { first = 0, last = -1 }
end

function Queue.push(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end

function Queue.pop(list)
  if Queue.isEmpty(list) then error("list is empty") end

  local first = list.first
  local value = list[first]
  list[first] = nil  -- to allow garbage collection
  list.first = first + 1
  return value
end

function Queue.isEmpty(list)
  return list.first > list.last
end

return Queue
