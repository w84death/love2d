function love.load()
  -- Set up the dimensions of the fire
  fireWidth = 100
  fireHeight = 100

  -- Set up the colors of the fire
  fireColors = {
    {255, 255, 255, 255},
    {255, 128, 0, 255},
    {255, 0, 0, 255},
    {0, 0, 0, 255},
  }

  -- Set up the base intensity of the fire
  fireIntensity = 50

  -- Set up the cooling amount of the fire
  fireCooling = 1

  -- Create the fire canvas
  fireCanvas = love.graphics.newImage(fireWidth, fireHeight)

  -- Set up the position of the fire
  fireX = (love.graphics.getWidth() - fireWidth) / 2
  fireY = (love.graphics.getHeight() - fireHeight) / 2
end

function love.update(dt)
  -- Update the fire canvas
  love.graphics.setCanvas(fireCanvas)
  for y = fireHeight - 1, 1, -1 do
    for x = 1, fireWidth do
      -- Get the sum of the surrounding pixels
      local sum = (
        fireCanvas:getPixel(math.min(x + 1, fireWidth - 1), y)
        + fireCanvas:getPixel(math.max(x - 1, 0), y)
        + fireCanvas:getPixel(x, math.min(y + 1, fireHeight - 1))
        + fireCanvas:getPixel(x, math.max(y - 1, 0))
      )

      -- Calculate the new intensity of the current pixel
      local intensity = math.max((sum / 4) - fireCooling, 0)

      -- Set the new color of the pixel
      local r, g, b, a = unpack(fireColors[math.floor(intensity / (255 / #fireColors)) + 1])
      love.graphics.setColor(r, g, b, a)
      love.graphics.rectangle("fill", x - 1, y - 1, 1, 1)
    end
  end
  love.graphics.setCanvas()

  -- Set up the position of the fire
  fireX = (love.graphics.getWidth() - fireWidth) / 2
  fireY = (love.graphics.getHeight() - fireHeight) / 2
end

function love.draw()
  -- Draw the fire
  love.graphics.draw(fireCanvas, fireX, fireY)
end
