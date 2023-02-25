require "parse_obj"
sin=math.sin
pow=math.pow
flr=math.floor
max=math.max
min=math.min
abs=math.abs
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
  x_scale = 28,
  y_scale = 60,
  text = "SiNeTeXt"
}

local t=0
local freez_plasma=false
local cam={
  pos={0,0,-1.8},
  spd=0.005,
  fov=250
}
local sun={
  pos={0,4,-1},
  exp=.4
}
local shift={x=600,y=280}

---------------------------------------
-- ### LOAD ###
--

function love.load()
  table.insert(app_fonts,love.graphics.newFont("FutilePro.ttf", 18))
  table.insert(app_fonts,love.graphics.newFont("FutilePro.ttf", 48))
  local vert, face = parseObjFile("P1X_logo.obj")
  table.insert(meshes, {vert=vert, face=face})
  dddSortZ(meshes[1])
  sine_text.text = "Hi there! Love2D and Lua offer a powerful and flexible platform for making demos in the demoscene, with a combination of fast prototyping, cross-platform support, lightweight and fast performance, extensibility, and community support."
  audioSource = love.audio.newSource(genMusic({ 0, 2, 4, 7, 9, 11, 12, 11, 9, 7, 4, 2 }), 44100, 16, 1)
  audioSource:play()

end

---------------------------------------
-- ### DRAW ###
--

function love.draw()
  love.graphics.setFont(app_fonts[1])
  if freez_plasma then
    love.graphics.draw(plasmaImage,0,0)
  else
    drawPlasma(1380,800,10)
  end
  local wx,wy = 25,25
  drawRoundedRectangle(wx,wy,190,160,12,{.1,.1,.1})
  drawWindowHeader("ENGINE LOG:",wx,wy,180)
  drawWindowText(engine_log,wx,wy)

  dddRaster(meshes[1])

  drawSineText(1280,700,{1,1,1})
end

---------------------------------------
-- ### UPDATE ###
--

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

  rotateYMesh(meshes[1],math.sin(t)*0.1)
  rotateZMesh(meshes[1],math.cos(t)*0.1)
  rotateXMesh(meshes[1],math.sin(t+10)*0.1)

  dddSortZ(meshes[1])
end


---------------------------------------
-- ### EVENTS ###
--

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "r" then
      plasmaImage = renderPlasmaFrame(1280,800)
      freez_plasma = not freez_plasma
  end
end

---------------------------------------
-- ### UI ###
--

function drawShadowedText(message,x,y,shadow)
  local color={1,1,1}
  local color2={0,0,0}
  love.graphics.setColor(color2)
  love.graphics.print(message, x+shadow[1], y+shadow[2])
  love.graphics.setColor(color)
  love.graphics.print(message, x, y)
end

function drawWindowText(message, x, y)
  local padding = 10
  local first_line = 30
  drawShadowedText(message,x+padding,y+first_line,{1,2})
end

function drawWindowHeader(title, x,y,w)
  local padding=10
  love.graphics.setColor(1,1,1)
  drawShadowedText(title, x+padding,y+padding,{1,2})
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

---------------------------------------
-- ### SINE TEXT ###
--

function drawSineText(x, y, color)
  love.graphics.setFont(app_fonts[2])

  for i = 1, #sine_text.text do
    local x_pos = x+sine_text.x + i * sine_text.x_scale
    local y_pos = y+sine_text.y + math.sin(sine_text.offset + i * -0.1) * sine_text.y_scale
    drawShadowedText(string.sub(sine_text.text, i,i),x_pos,y_pos,{4,4})
  end
end

function updateSineText(dt)
  sine_text.x = sine_text.x - sine_text.speed*dt
  if sine_text.x < sine_text.min_x - #sine_text.text*sine_text.x_scale then
    sine_text.x = sine_text.max_x
  end
  sine_text.offset = sine_text.offset + 0.05
end

---------------------------------------
-- ### PLASMA ###
--

function renderPlasmaFrame(width, height)
  local imageData = love.image.newImageData(width, height)
  local ratio=width/height
  local size=ratio*150
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

  local ratio=width/height
  local size=ratio*150


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





---------------------------------------
-- ### TUNES ###
--

function genMusic(melody)
  local rate = 44100
  local length = 30
  local tempo = 128 -- beats per minute
  local beatDuration = 60 / tempo
  local speed = 5
  local tone = 400
  local soundData=love.sound.newSoundData(flr(length*rate),rate,16,1)
  local accu=0
  local tt=0


  for ss=0,soundData:getSampleCount()-1 do
      local u=tt/rate
      for j=1,2 do
          for i=1,4 do
              local r=u*j/6
              local v=r%1
              local e=2^(-(9*v*i+.01/v))
              local f=tone*melody[1+flr(r%#melody)]
              local o=sin(f*i*u*j/4)
              accu=accu+sin(i)*e*o
          end

      end
      tt=tt+speed
      soundData:setSample(ss,math.min(math.max(-1, accu), 1))
  end
  return soundData
end





---------------------------------------
-- ### 3D ENGINE ###
--

function dddRaster(m)
  _p=1
  for i,f in pairs(m.face) do
    local p={m.vert[f[1]],m.vert[f[2]],m.vert[f[3]]}

    local n=dddNormal(p[1],p[2],p[3])
    if
			(n[1]*(p[1][1]-cam.pos[1]))+
			(n[2]*(p[1][2]-cam.pos[2]))+
			(n[3]*(p[1][3]-cam.pos[3]))<0
		then
			local dot=dddDotProd(n,sun.pos)*sun.exp

			local sp={
				dddProject(p[1]),
				dddProject(p[2]),
				dddProject(p[3])}
			local min_x,max_x,min_y,max_y = dddGetBounds(sp)

			local a01=sp[1][2]-sp[2][2]
			local a12=sp[2][2]-sp[3][2]
			local a20=sp[3][2]-sp[1][2]
			local b01=sp[2][1]-sp[1][1]
      local b12=sp[3][1]-sp[2][1]
			local b20=sp[1][1]-sp[3][1]

			local w0_=dddO2d(sp[2],sp[3],{min_x,min_y})
			local w1_=dddO2d(sp[3],sp[1],{min_x,min_y})
			local w2_=dddO2d(sp[1],sp[2],{min_x,min_y})
			local c=0
			local scan=false
			local sl={0,0,0,0}
			for y=min_y,max_y do
				w0,w1,w2=w0_,w1_,w2_
				for x=min_x,max_x do
					if bit.bor(bit.bor(w0,w1),w2)>0 then
					 if not scan then
					  scan = true
					  sl[1],sl[2]=x,y
					 end
					 if scan then
						 sl[3],sl[4]=x,y
           end
		   else
					scan=false
					end
					w0=w0+a12
					w1=w1+a20
					w2=w2+a01
				end
				w0_=w0_+b12
				w1_=w1_+b20
				w2_=w2_+b01
				c=dddShade(sl[1],sl[2],dot)
				love.graphics.setColor(c,.1,.25)
				love.graphics.line(sl[1]+shift.x,sl[2]+shift.y,sl[3]+shift.x,sl[4]+shift.y)
			end

--love.graphics.setColor(1,1,1,.25)
	--love.graphics.line(sp[1][1]+shift[1],sp[1][2]+shift[2],sp[2][1]+shift[1],sp[2][2]+shift[2])
		--love.graphics.line(sp[2][1]+shift[1],sp[2][2]+shift[2],sp[3][1]+shift[1],sp[3][2]+shift[2])
			--love.graphics.line(sp[3][1]+shift[1],sp[3][2]+shift[2],sp[1][1]+shift[1],sp[1][2]+shift[2])
	 end
	 _p=_p+1
	end
end

function dddProject(p)
  local cp=cam.pos
  local f=cam.fov
  return {
     (p[1]-cp[1])*f/(p[3]-cp[3])+63.5,
    -(p[2]-cp[2])*f/(p[3]-cp[3])+63.5}
end

function dddShade(x,y,dot)
	local luma=dot*sun.exp
  return luma
end

function dddDotProd(a,b)
  return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function dddNormal(p1,p2,p3)
  local n=dddCrossProd(
  {
    p2[1]-p1[1],
    p2[2]-p1[2],
    p2[3]-p1[3]
  },{
    p3[1]-p1[1],
    p3[2]-p1[2],
    p3[3]-p1[3]
  })
  local l=math.sqrt(n[1]*n[1]+n[2]*n[2]+n[3]*n[3])
  return {n[1]/l,n[2]/l,n[3]/l}
end

function dddGetBounds(p)
  local min_x=math.min(p[1][1],math.min(p[2][1],p[3][1]))
  local min_y=math.min(p[1][2],math.min(p[2][2],p[3][2]))
  local max_x=math.max(p[1][1],math.max(p[2][1],p[3][1]))
  local max_y=math.max(p[1][2],math.max(p[2][2],p[3][2]))

  return min_x,max_x,min_y,max_y
end

function dddO2d(a,b,c)
  return (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])
end

function dddCrossProd(v1,v2)
  return {
    v1[2]*v2[3]-v1[3]*v2[2],
    v1[3]*v2[1]-v1[1]*v2[3],
    v1[1]*v2[2]-v1[2]*v2[1]
  }
end

function dddRotMesh(m,a,r)
  local _m = {vert={},face=m.face}
  for i,v in pairs(m.vert) do
      table.insert(_m.vert,dddRotPoint(v,a,r))
  end
  return _m
end

function dddRotPoint(p,a,r)
  if a=="x" then
    _x=p[1]
    _y=math.cos(r)*p[2]-math.sin(r)*p[3]
    _z=math.sin(r)*p[2]+math.cos(r)*p[3]
  end
  if a=="y" then
    _x=math.sin(r)*p[3]+math.cos(r)*p[1]
    _y=p[2]
    _z=math.cos(r)*p[3]-math.sin(r)*p[1]
  end
  if a=="z" then
    _x=math.cos(r)*p[1]-math.sin(r)*p[2]
    _y=math.sin(r)*p[1]+math.cos(r)*p[2]
    _z=p[3]
  end
  return {_x,_y,_z}
end

function dddTranslateMesh(mesh, tx, ty, tz)
  for _, vertex in ipairs(mesh.vert) do
    vertex[1] = vertex[1] + tx
    vertex[2] = vertex[3] + ty
    vertex[3] = vertex[3] + tz
  end
end

function dddSortZ(mesh)
  sortFaces3D(mesh.face,mesh.vert)
end

local function averageZ(face, vertices)
  local sumZ = 0
  for i = 1, #face do
    sumZ = sumZ + vertices[face[i]][3]
  end
  return sumZ / #face
end

local function compareFaces(face1, face2, vertices)
  return averageZ(face1, vertices) < averageZ(face2, vertices)
end

function sortFaces3D(faces, vertices)
  table.sort(faces, function(a, b) return compareFaces(b, a, vertices) end)
end

-- rotation function for a 3D mesh around the x-axis
function rotateXMesh(mesh, angle)
  local sinAngle = math.sin(angle)
  local cosAngle = math.cos(angle)

  for _, vertex in ipairs(mesh.vert) do
    local y = vertex[2] * cosAngle - vertex[3] * sinAngle
    local z = vertex[2] * sinAngle + vertex[3] * cosAngle
    vertex[2] = y
    vertex[3] = z
  end
end

-- rotation function for a 3D mesh around the y-axis
function rotateYMesh(mesh, angle)
  local sinAngle = math.sin(angle)
  local cosAngle = math.cos(angle)

  for _, vertex in ipairs(mesh.vert) do
    local x = vertex[1] * cosAngle + vertex[3] * sinAngle
    local z = -vertex[1] * sinAngle + vertex[3] * cosAngle
    vertex[1] = x
    vertex[3] = z
  end
end

-- rotation function for a 3D mesh around the z-axis
function rotateZMesh(mesh, angle)
  local sinAngle = math.sin(angle)
  local cosAngle = math.cos(angle)

  for _, vertex in ipairs(mesh.vert) do
    local x = vertex[1] * cosAngle - vertex[2] * sinAngle
    local y = vertex[1] * sinAngle + vertex[2] * cosAngle
    vertex[1] = x
    vertex[2] = y
  end
end



