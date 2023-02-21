function love.load()

 font=love.graphics.newFont("FutilePro.ttf", 70)
tunnel={
  px=0,
  py=0,
  maxx=640,
  maxy=100,
  shifter=4,
  speed=3
}
t=0
end

function love.update(dt)
  tunnel.px = math.sin(t)*1
  tunnel.py = math.sin(t*3)*3
  t=t+dt
--   if tunnel.shifter>0 then tunnel.shifter = tunnel.shifter - dt*10 end
 end

function love.draw()
for y=-tunnel.maxy+tunnel.py,tunnel.maxy+tunnel.py,3 do
		for x=-tunnel.maxx+tunnel.px,tunnel.maxx+tunnel.px do
			a=math.atan2(y,x)
			m=200
			d=m/math.sqrt(x*x+y*y)
			c=1-(a+d+t*tunnel.speed)%1
			love.graphics.setColor(c,.2,.2)
			love.graphics.points(640+x,400+y-tunnel.shifter-1)
			love.graphics.setColor(.2,c,.2)
			love.graphics.points(640+x,400+y)
			love.graphics.setColor(.2,.2,c)
			love.graphics.points(640+x,400+y+tunnel.shifter+1)
		end
	end
	love.graphics.setColor(1,1,1,0.8)
	love.graphics.setFont(font)
	love.graphics.print("WARNING! MATH FUNCTIONS AHEAD!", 50,360)
end
