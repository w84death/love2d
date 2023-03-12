require "parse_obj"

local meshes={}
local tex={}
local app_fonts={}
local engine_log=""
local t=0
local cam={
  pos={0,0,-3.5},
  spd=0.005,
  fov=300
}
local sun={
  pos={-2,2,-3},
  exp=.6
}
local shift={x=250,y=200}
local act_mesh=1
local temperature=0
local temp_delay=100
local temp_refresh=100
local guy_pos=0
---------------------------------------
-- ### LOAD ###
--

function love.load()
  music = love.audio.newSource("interphace_-_escapade.mod", "stream")
  table.insert(app_fonts,love.graphics.newFont("FutilePro.ttf", 14))
  table.insert(tex,love.graphics.newImage("bg-2.jpg"))
  table.insert(tex,love.graphics.newImage("bg-2b.png"))
  table.insert(tex,love.graphics.newImage("bg-2c.png"))
  local vert, face = parseObjFile("P1X_logo.obj")
  table.insert(meshes, {vert=vert, face=face})
  local vert, face = parseObjFile("suzane.obj")
  table.insert(meshes, {vert=vert, face=face})
  local vert, face = parseObjFile("bolt.obj")
  table.insert(meshes, {vert=vert, face=face})
  dddSortZ(meshes[act_mesh])
  temperature=getTemp()
end

---------------------------------------
-- ### DRAW ###
--

function love.draw()
  love.graphics.setFont(app_fonts[1])
  local wx,wy = 490,170

  drawBackground(1,0,0)
  dddRaster(meshes[act_mesh])
  --drawRoundedRectangle(wx,wy,160,160,12,{.1,.1,.1})
  --drawWindowHeader("ENGINE LOG:",wx,wy,160)
  drawWindowText(engine_log,wx,wy)
  drawBackground(2,guy_pos,240)
  drawBackground(3,0,377)

end

---------------------------------------
-- ### UPDATE ###
--

function love.update(dt)
  engine_log = "MUSIC: Escapade\nby Interphace\n"..
  "VERT="..#meshes[act_mesh].vert..
  "\nFACE="..#meshes[act_mesh].face..
  "\nFPS="..love.timer.getFPS()..
  "\nTEMP="..temperature
  if not music:isPlaying() then
      music:play()
  end

  if temp_refresh<0 then
    temperature=getTemp()
    temp_refresh=temp_delay
  end
  temp_refresh=temp_refresh-1

  dddSortZ(meshes[act_mesh])
  keyboard()
 t=t+dt
  guy_pos=320-115+math.sin(t*.1)*160
end

---------------------------------------
-- ### EVENTS ###
--
function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if key == "return" then
      if act_mesh<#meshes then
        act_mesh=act_mesh+1
      else
        act_mesh=1
      end
  end
end

function keyboard()
  if love.keyboard.isDown("left") then
  meshes[act_mesh]=dddRotMesh(meshes[act_mesh],"y",0.03)
  end
  if love.keyboard.isDown("right") then
  meshes[act_mesh]=dddRotMesh(meshes[act_mesh],"y",-0.03)
  end
  if love.keyboard.isDown("up") then
  meshes[act_mesh]=dddRotMesh(meshes[act_mesh],"x",0.03)
  end
  if love.keyboard.isDown("down") then
  meshes[act_mesh]=dddRotMesh(meshes[act_mesh],"x",-0.03)
  end
end

---------------------------------------
-- ### UI ###
--

function drawBackground(id,x,y)
  love.graphics.draw(tex[id],x,y)
end

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
-- ### SENSORS ###
--

function getTemp()
  local handle=io.popen("vcgencmd measure_temp")
  local temp=handle:read("*a")
  handle:close()
  return string.sub(temp,6)
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
      local sp={
        dddProject(p[1]),
        dddProject(p[2]),
        dddProject(p[3])}

      local dot=dddDotProd(n,sun.pos)*sun.exp
      local c=dddShade(p[1],p[2],dot)
      love.graphics.setColor(c,c,c)
      mesh = love.graphics.newMesh(sp, "fan")
      love.graphics.draw(mesh, shift.x, shift.y)
    end
	 end
	 _p=_p+1
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



