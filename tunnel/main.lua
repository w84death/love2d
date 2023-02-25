function love.load()
   music = love.audio.newSource("antytol.it", "stream")
  font=love.graphics.newFont("FutilePro.ttf", 70)
  font_small=love.graphics.newFont("FutilePro.ttf", 14)
  width, height = love.window.getMode()
  tunnel={
    px=0,
    py=0,
    maxx=600,
    maxy=220,
    width=1200,
    height=440,
    shifter=1.5,
    speed=3.33,
    pixel_scale=18,
    fov=125
  }
  sine_text = {
    offset = 0,
    x=0,
    y=0,
    sx=0,
    sy=0,
    loop_x=1280,
    sine_speed = 8,
    move_speed = 100,
    x_scale = 40,
    y_scale = 60,
    pack=0.333,
    text = "WARNING! MATH FUNCTIONS AHEAD!"
  }
  t=0
end

function love.update(dt)
  updateSineText(dt)
  t=t+dt
  if not music:isPlaying() then
      music:play()
  end
 end

function love.draw()
  drawTunnel()
  drawFuzzyText(20,360)
  drawFuzzyText(20+1280,360)
  drawCopyrights(30,height-25)

  drawStats(width-30,height-25)
end

function drawTunnelX()
  for y=0,tunnel.height do
    for x=0,tunnel.width do
      --local xx=x+math.sin(t*1.2)*400
      --local yy=y+math.sin(t*1.3)*200
      local fx=x-tunnel.width*.5
      local fy=y-tunnel.height*.5
      local radius = math.sqrt(fx*fx+fy*fy)
      local distance = 500.0/radius
      local u = math.abs((distance+t*10)%2)
      local v = math.atan2(fx,fy)*(512/math.pi/2)*t
      local color = (u^v)
      love.graphics.setColor(color,color,color)
      love.graphics.circle("fill",width*.5-fx,height*.5-fy, 2, 4)
    end
  end
end

function drawTunnel()
  for y=-tunnel.maxy,tunnel.maxy,tunnel.pixel_scale*.5 do
    for x=-tunnel.maxx,tunnel.maxx,tunnel.pixel_scale do
      local xx=x+math.sin(t*1.2)*400
      local yy=y+math.sin(t*1.3)*200
      local a=math.atan2(xx,yy)
      local m=tunnel.fov
      local d=m/math.sqrt(xx*xx*.05+yy*yy)
      local c=(a+d+t*tunnel.speed)%1

      local ts=0
      if y%2==0 then
        ts=tunnel.pixel_scale*.5
      end
      local dist=(1.5-d^.25)
      local alpha=math.max(0,(1+math.cos(t*7)*.25)*dist)
      local color=c*math.abs(math.sin(t))
      love.graphics.setColor(color,color*.2,c*.75, alpha)
      love.graphics.circle("fill",640+x+ts,400+y, 14, 12)

      if y%4==0 then
        ts=0
        if y%8==0 then
          ts=tunnel.pixel_scale*.5
        end
       love.graphics.setColor(c*.1,c*.2,c*.3, dist)
       love.graphics.circle("fill",640+x+ts,700-y*.5/2+math.sin(x+y+t*4)*4,14,6)
       love.graphics.setColor(c*.4,c*.3,c*.1, dist)
       love.graphics.circle("fill",640+x+ts,90-y*.5/2+math.sin(x+y+t*4)*4,14,6)
      end
    end
  end
end

function drawFuzzyText(x,y)
  for i = 1, #sine_text.text do
    local x_pos=x+sine_text.x+ i * sine_text.x_scale
    local y_pos=y+sine_text.y+ math.sin(sine_text.offset + i * -sine_text.pack) * sine_text.y_scale
    local y_pos2=y+sine_text.y+ math.sin(sine_text.offset + i * -sine_text.pack) * sine_text.y_scale*.25
    letter=string.sub(sine_text.text, i,i)
    love.graphics.setFont(font)

    love.graphics.setColor(.1,.1,.1,0.6)
    love.graphics.print(letter,x_pos+12,y_pos+2)

    love.graphics.setColor(1,1,1,1)
    love.graphics.print(letter,x_pos+sine_text.sx*.5,y_pos+sine_text.sy*.5)
    love.graphics.setColor(math.abs(1-sine_text.sx*.75),.8,math.abs(sine_text.sx*.5),0.8)
    love.graphics.print(letter,x_pos+4,y_pos+1)
    love.graphics.setColor(.1,.1,.25,0.4)
    love.graphics.print(letter,x_pos+1+sine_text.sx,y_pos+4+sine_text.sy)

    love.graphics.setColor(1,1,1,0.3)
    love.graphics.print(letter,x_pos-8,y_pos-2)

--     love.graphics.setColor(.2,.4,.4,0.1)
--     love.graphics.circle("fill",x_pos-8,y_pos2+320, 14, 12)
--     love.graphics.circle("fill",x_pos+8,y_pos2+320, 14, 12)
  end
end

function updateSineText(dt)
  sine_text.sx = math.sin(5+t*12)*dt*25
  sine_text.sy = math.sin(t*13)*dt*25
  sine_text.x = sine_text.x - sine_text.move_speed*dt
  if sine_text.x < -sine_text.loop_x then
    sine_text.x = 0
  end
  sine_text.offset = sine_text.offset + dt*sine_text.sine_speed
end

function drawCopyrights(x,y)
  love.graphics.setFont(font_small)
  love.graphics.setColor(1,1,1)
  love.graphics.print("CODE: w84death^P1X",x,y-10)
  love.graphics.print("MUSIC: antytol by YeKM19",x,y)
end

function drawStats(x,y)
  love.graphics.setFont(font_small)
  love.graphics.setColor(1,1,1)
  love.graphics.print("STATS: "..love.timer.getFPS().."FPS / "..math.floor(collectgarbage('count')).."KB",x-160,y)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
