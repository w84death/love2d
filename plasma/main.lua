function love.load()
  p1x = love.graphics.newImage("p1x.png")
  love.window.setMode(512,512, {resizable=false, vsync=1})
  width, height = love.graphics.getDimensions()
  ratio = width/height

end
psize=0
psize_base=125
offset={x=0,y=0}
speed=0.01333
t=0
pixel_scale=2
function love.draw()
  plasma_draw()
end

function love.update()
  t=t+speed
end

function love.keypressed(key, scancode, isrepeat)
  if key == "f11" then
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen, "exclusive")
  end
  if key == "escape" then
    love.event.quit()
  end
end

function plasma_draw()
  for x = 0, width-1,pixel_scale do
    for y = 0, height-1,pixel_scale do
      xx=x+offset.x
      yy=y+offset.y
      v=math.sin((xx*ratio)/psize+t)+math.sin((yy*ratio)/psize+t)+math.sin((xx+yy)/psize*4.0)
      c=(v*2)
      tt=t*.25
      r=math.max(0.2,math.min(c*math.sin(3+c*.025-tt),1.0))
      g=math.max(0.2,math.min(c*math.cos(2+c*.05),.5))
      b=math.max(0.2,math.min(c*math.sin(3+c*.05+tt),.75))
      love.graphics.setColor(r,g,b)
      love.graphics.setPointSize(pixel_scale)
      love.graphics.points(x,y)
    end
  end
  psize=psize_base+math.sin(t*.3)*15
  offset.x=math.sin(t*.13)*width
  offset.y=math.cos(t*.12)*height
--love.graphics.setColor(1.0,1.0,1.0,1.0)
  love.graphics.draw(p1x, width-16-72, 16)
end
