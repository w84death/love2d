sin=math.sin
pow=math.pow
flr=math.floor
max=math.max
min=math.min
abs=math.abs
font32 = love.graphics.newFont(32, "mono")
font18 = love.graphics.newFont(18, "mono")
prod={
    ver="0.4",
    title="P1X Procedural Tunes",
    code="Krzysztof Krystian Jankowski"
}
prod.width,prod.height,flags=love.window.getMode()
prod.ratio=prod.width/prod.height

msx={
    rate = 44100,
    length = 14,
    speed = 1.2,
    tone = 40,
    chord={6,6,8,9},
    now_playing = 1,
    melody={},
    notes={0,0,10/3,12/3,15/3,10,15,12},
    tunes={},
    max_tunes=7,
    fft={}
}
t=0

plasma={
    size=0,
    size_base=200,
    offset={x=0,y=0},
    speed=2,
    pixel_scale=4
}

function love.load()
    gen_album()
    msx.tunes[1]:play()
end

equ = {
    left=1,
    padding=10,
    width=prod.width-20
}

function love.draw()
    plasma_draw()
    equalizer_draw()
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.setFont(font32)
    love.graphics.print(prod.title,equ.padding,prod.height-90)
    love.graphics.line(equ.padding,prod.height-52,prod.width-equ.padding,prod.height-52)
    love.graphics.setFont(font18)
    love.graphics.setColor(0.1,0.1,0.1)
    love.graphics.print("Version ["..prod.ver.."] | Playing track number [#"..msx.now_playing.." of "..msx.max_tunes.."] | Code ["..prod.code.."]",10+2,prod.height-50+2)
    love.graphics.setColor(1.0,1.0,1.0)
    love.graphics.print("Version ["..prod.ver.."] | Playing track number [#"..msx.now_playing.." of "..msx.max_tunes.."] | Code ["..prod.code.."]",10,prod.height-50)
end

function love.update(dt)
    t=t+plasma.speed*dt
    if not msx.tunes[msx.now_playing]:isPlaying( ) then
        msx.now_playing=msx.now_playing+1
        if msx.now_playing>#msx.tunes then msx.now_playing = 1 end
        love.audio.play(msx.tunes[msx.now_playing])
        equ.left=1
        t=t+32
    end
    equ.left=equ.left+dt*100
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function equalizer_draw()
    local stretch=250
    for i=1,equ.width*stretch-equ.padding*2,stretch do
        local ii=i/stretch
        if i+equ.left<msx.fft[msx.now_playing]:getSampleCount() then
            local sample=msx.fft[msx.now_playing]:getSample(i+equ.left)
            local c=min(abs(sample*5,1.0))
            love.graphics.setColor(c,c,c)
            love.graphics.line(equ.padding+ii,prod.height/2,equ.padding+ii,prod.height/2+sample*400)
        end
    end
end

function plasma_draw()
  for x = 0, prod.width-1,plasma.pixel_scale do
    for y = 0, prod.height-1,plasma.pixel_scale do
      local xx=x+plasma.offset.x
      local yy=y+plasma.offset.y
      local v=math.sin((xx*prod.ratio)/plasma.size+t)+math.sin((yy*prod.ratio)/plasma.size+t)+math.sin((xx+yy)/plasma.size*4.0)
      local c=(v*2)
      local tc=t*.05
      local r=math.max(0.2,math.min(c*math.sin(3+c*.025-tc),1.0))
      local g=math.max(0.2,math.min(c*math.cos(2+c*.05),.5))
      local b=math.max(0.2,math.min(c*math.sin(3+c*.05+tc),.75))
      love.graphics.setColor(r,g,b)
      love.graphics.setPointSize(plasma.pixel_scale)
      love.graphics.points(x,y)
    end
  end
  plasma.size=plasma.size_base+math.sin(t*.3)*15
  plasma.offset.x=math.sin(t*.13)*prod.width
  plasma.offset.y=math.cos(t*.12)*prod.height
end

function gen_album()
    math.randomseed(os.time())
    for mel=1,msx.max_tunes do
        msx.melody[mel] = {}
        for m=1,8 do
            table.insert(msx.melody[mel], msx.notes[math.random(#msx.notes)])
        end

        table.insert(msx.fft,gen_music(mel))
        table.insert(msx.tunes,love.audio.newSource(gen_music(mel)))
    end
end

function gen_music(track)
    local soundData=love.sound.newSoundData(flr(msx.length*msx.rate),msx.rate,16,1)
    local accu=0
    local tt=0
    for ss=0,soundData:getSampleCount()-1 do
        local u=tt/msx.rate
        for j=1,3 do
            for i=1,6 do
                local r=u*j/2
                local v=r%1
                local e=2^(-(3*v*i+.01/v))
                local f=msx.tone*msx.melody[track][1+flr(r%7)]*msx.chord[1+flr(u%3)]
                local o=sin(f*i*u*j/4)
                accu=accu+sin(i)*e*o*.0025
            end
        end
        tt=tt+msx.speed
        soundData:setSample(ss,math.min(math.max(-1, accu), 1))
    end
    return soundData
end
