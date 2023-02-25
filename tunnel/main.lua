function love.load()

  font=love.graphics.newFont("FutilePro.ttf", 70)
  tunnel={
    px=0,
    py=0,
    maxx=640,
    maxy=100,
    shifter=4,
    speed=2,
    pixel_scale=4,
    fov=150
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
  tunnel.px = math.sin(t)*1
  tunnel.py = math.sin(t*3)*3
  updateSineText(dt)
  t=t+dt
 end

function love.draw()
  for y=-tunnel.maxy+tunnel.py,tunnel.maxy+tunnel.py,tunnel.pixel_scale+2 do
    for x=-tunnel.maxx+tunnel.px,tunnel.maxx+tunnel.px,tunnel.pixel_scale do
      a=math.atan2(y,x)
      m=tunnel.fov
      d=m/math.sqrt(x*x+y*y)
      c=(a+d+t*tunnel.speed)%1
      love.graphics.setPointSize(tunnel.pixel_scale)
      love.graphics.setColor(c,.8,.8,.4)
      love.graphics.points(640+x,400+y-tunnel.shifter)
      love.graphics.setColor(.8,c*.8,.8,.8)
      love.graphics.points(640+x,400+y)
      love.graphics.setColor(8,.8,c,.4)
      love.graphics.points(640+x,400+y+tunnel.shifter)
    end
  end
  drawFuzzyText(20,360)
  drawFuzzyText(20+1280,360)
end

function drawFuzzyText(x,y)
  for i = 1, #sine_text.text do
    local x_pos=x+sine_text.x+ i * sine_text.x_scale
    local y_pos=y+sine_text.y+ math.sin(sine_text.offset + i * -sine_text.pack) * sine_text.y_scale
    letter=string.sub(sine_text.text, i,i)
    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(letter,x_pos+sine_text.sx*.5,y_pos+sine_text.sy*.5)
    love.graphics.setColor(math.abs(1-sine_text.sx*.75),.8,math.abs(sine_text.sx*.5),0.8)
    love.graphics.print(letter,x_pos+4,y_pos+1)
    love.graphics.setColor(.1,.1,.25,0.4)
    love.graphics.print(letter,x_pos+1+sine_text.sx,y_pos+4+sine_text.sy)
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

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
