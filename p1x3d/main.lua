require "parse_obj"

local meshes = {}
local app_fonts = {}
local engine_log = ""
local sine_text = {
  offset = 0,
  x = 0,
  y = 0,
  speed = 100,
  min_x = 0,
  max_x = 200,
  x_scale = 20,
  y_scale = 60,
  text = "SiNeTeXt"
}
local t=0
local freez_plasma=false
function love.load()
  table.insert(app_fonts,love.graphics.newFont("MatchupPro.ttf", 18))
  table.insert(app_fonts,love.graphics.newFont("MatchupPro.ttf", 48))
  local vert, face = parseObjFile("p1x-logo.obj")
  table.insert(meshes, {vert=vert, face=face})
  sine_text.text = "Hi there! Love2D and Lua offer a powerful and flexible platform for making demos in the demoscene, with a combination of fast prototyping, cross-platform support, lightweight and fast performance, extensibility, and community support."
end

function love.draw()
  love.graphics.setFont(app_fonts[1])
  if freez_plasma then
    love.graphics.draw(plasmaImage,0,0)
  else
    drawPlasma(720,480,4)
  end
  local wx,wy = 25,25
  drawRoundedRectangle(wx,wy,180,200,12,{.1,.1,1.0})
  drawWindowHeader("ENGINE LOG:",wx,wy,180)
  drawWindowText(engine_log,wx,wy)

  local w2x,w2y = 225,25
  drawRoundedRectangle(w2x,w2y,480,440,12,{.2,.2,.2})

  drawSineText(720,350,{1,1,1})
end

function love.update(dt)
  engine_log = "LOADED P1X LOGO\n"..
  "VERT="..#meshes[1].vert..
  "\nFACE="..#meshes[1].face..
  "\n...\n"..
  "FPS="..love.timer.getFPS()..
  "\nMEM="..math.floor(collectgarbage('count')).."KB"

  updateSineText(dt)
  if not freez_plasma then
    t=t+dt
  end
end





function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
      plasmaImage = renderPlasmaFrame(720,480)
      freez_plasma = not freez_plasma
  end
end





function drawWindowText(message, x, y)
  local padding = 10
  local first_line = 30
  love.graphics.print(message,x+padding,y+first_line)
end

function drawWindowHeader(title, x,y,w)
  local padding=10
  love.graphics.setColor(1,1,1)
  love.graphics.print(title, x+padding,y+padding)
  love.graphics.line(x+padding,y+padding+18,w-padding,y+padding+18)
end

function drawRoundedRectangle(x, y, w, h, radius, color)
  local mode = "fill"
  local x1, y1 = x+radius, y+radius
  local x2, y2 = x+w-radius, y+h-radius
  love.graphics.setColor(color)
  love.graphics.rectangle(mode, x+radius, y, w-2*radius, h)
  love.graphics.rectangle(mode, x, y+radius, w, h-2*radius)
  love.graphics.circle(mode, x+radius, y+radius, radius)
  love.graphics.circle(mode, x+w-radius, y+radius, radius)
  love.graphics.circle(mode, x+radius, y+h-radius, radius)
  love.graphics.circle(mode, x+w-radius, y+h-radius, radius)
end

function drawOldSchoolPattern(colors)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setLineWidth(1)

  for i = 0, love.graphics.getWidth() / 20 do
    for j = 0, love.graphics.getHeight() / 20 do
      love.graphics.setColor(colors[1])
      love.graphics.rectangle("line", i * 20, j * 20, 20, 20)
      love.graphics.setColor(colors[2])
      love.graphics.rectangle("fill", i * 20 + 1, j * 20 + 1, 18, 18)
      love.graphics.setColor(colors[3])
      love.graphics.line(i * 20 + 20, j * 20, i * 20, j * 20 + 20)
    end
  end
end


function drawSineText(x, y, color)
  love.graphics.setFont(app_fonts[2])
  local color2={0,0,0}
  local shadow_x=4
  local shadow_y=4
  for i = 1, #sine_text.text do
    local x_pos = x+sine_text.x + i * sine_text.x_scale
    local y_pos = y+sine_text.y + math.sin(sine_text.offset + i * -0.1) * sine_text.y_scale
    love.graphics.setColor(color2)
    love.graphics.print(string.sub(sine_text.text, i,i), x_pos+shadow_x, y_pos+shadow_y)
    love.graphics.setColor(color)
    love.graphics.print(string.sub(sine_text.text, i,i), x_pos, y_pos)
  end
end

function updateSineText(dt)
  sine_text.x = sine_text.x - sine_text.speed*dt
  if sine_text.x < sine_text.min_x - #sine_text.text*sine_text.x_scale then
    sine_text.x = sine_text.max_x
  end
  sine_text.offset = sine_text.offset + 0.05
end



function renderPlasmaFrame(width, height)
  local imageData = love.image.newImageData(width, height)
  local size=100
  local ratio=width/height
  for x = 0, width-1 do
    for y = 0, height-1 do
      local xx=x
      local yy=y
      local v=math.sin((xx*ratio)/size+t)+math.sin((yy*ratio)/size+t)+math.sin((xx+yy)/size*4.0)
      local c=(v*2)
      local tc=t*.05
      local r=math.max(0.2,math.min(c*math.sin(3+c*.025-tc),1.0))
      local g=math.max(0.2,math.min(c*math.cos(2+c*.05),.5))
      local b=math.max(0.2,math.min(c*math.sin(3+c*.05+tc),.75))
       imageData:setPixel(x, y, r, g, b, 255)
    end
  end

  return love.graphics.newImage(imageData)
end

function drawPlasma(width,height,pixel_scale)
  local size=100
  local ratio=width/height

  for x = 0, width,pixel_scale do
    for y = 0, height,pixel_scale do
      local xx=x
      local yy=y
      local v=math.sin((xx*ratio)/size+t)+math.sin((yy*ratio)/size+t)+math.sin((xx+yy)/size*4.0)
      local c=(v*2)
      local tc=t*.05
      local r=math.max(0.2,math.min(c*math.sin(3+c*.025-tc),1.0))
      local g=math.max(0.2,math.min(c*math.cos(2+c*.05),.5))
      local b=math.max(0.2,math.min(c*math.sin(3+c*.05+tc),.75))
      love.graphics.setColor(r,g,b)
      love.graphics.setPointSize(pixel_scale)
      love.graphics.points(x,y)
    end
  end
end

