function love.load()
  -- get the window width and height
  width, height = love.graphics.getDimensions()

  -- set up variables for the tunnel effect
  zoom = 80
  rot = 0
  speed = 2
end

function love.update(dt)
  -- update the rotation angle
  rot = rot - speed * dt
end

function love.draw()
  for x = 0, width-1 do
    for y = 0, height-1 do
      local angle = math.atan2(y - height / 2, x - width / 2) + rot
      local dist = math.sqrt((x - width / 2)^2 + (y - height / 2)^2) / zoom
      local color = (math.sin(dist + angle) + 1) / 2
      love.graphics.setColor(color, color, color)
      love.graphics.points(x, y)
    end
  end
end
