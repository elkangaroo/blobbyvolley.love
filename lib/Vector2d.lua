local Vector2d = {}
Vector2d.__index = Vector2d

do
  local meta = {
    _metatable = "Private metatable",
    _DESCRIPTION = "Vector in 2D",
  }

  meta.__index = meta

  function meta:__add(v)
    if type(v) == "number" then
      return Vector2d(self.x + v, self.y + v)
    end

    return Vector2d(self.x + v.x, self.y + v.y)
  end

  function meta:__sub(v)
    if type(v) == "number" then
      return Vector2d(self.x - v, self.y - v)
    end

    return Vector2d(self.x - v.x, self.y - v.y)
  end

  function meta:__mul(v)
    if type(v) == "number" then
      return Vector2d(self.x * v, self.y * v)
    end

    return Vector2d(self.x * v.x, self.y * v.y)
  end

  function meta:__div(v)
    if type(v) == "number" then
      return Vector2d(self.x / v, self.y / v)
    end

    return Vector2d(self.x / v.x, self.y / v.y)
  end

  function meta:__unm()
    return Vector2d(-self.x, -self.y)
  end

  function meta:__eq(v)
    return self.x == v.x and self.y == v.y
  end

  function meta:__tostring()
    return ("<%g, %g>"):format(self.x, self.y)
  end

  -- get the cross product
  function meta:cross(v)
    return self.x * v.y - self.y * v.x
  end

  -- get the dot product
  function meta:dot(v)
    return self.x * v.x + self.y * v.y
  end

  -- get the length / magnitude
  function meta:length()
    return math.sqrt(self:lengthSq())
  end

  -- get the length / magnitude squared
  function meta:lengthSq()
    return self.x^2 + self.y^2
  end

  function meta:normalise()
    return self / self:length()
  end

  -- reflect: r = d − 2(d⋅n)n
  function meta:reflect(normal)
    return self - (normal * 2 * self:dot(normal))
  end

  function meta:reflectX()
    return Vector2d(- self.x, self.y)
  end

  function meta:reflectY()
    return Vector2d(self.x, - self.y)
  end

  function meta:clone()
    return Vector2d(self.x, self.y)
  end

  setmetatable(Vector2d, {
    __call = function(V, x, y)
      return setmetatable({x = x or 0, y = y or 0}, meta)
    end
  })
end

return Vector2d
