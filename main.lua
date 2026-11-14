math.randomseed(os.time())

local serpentusa = {}

local function spawnApple()
  local wrong = false
  repeat
    Apple = {hor = math.random(1, 17), ver = math.random(1, 15)}
    wrong = false
    for i = 1, #serpentusa do
      if serpentusa[i].hor == Apple.hor and serpentusa[i].ver == Apple.ver then
        wrong = true
        break
      end
    end
  until wrong == false
end

local function checkBounds()
  if serpentusa[1].hor < 1 or serpentusa[1].hor > 17 or serpentusa[1].ver < 1 or serpentusa[1].ver > 15 then
    GameOver = true
    Pipe:play()
  end
end

local function checkSelf()
  for i = 2, #serpentusa do
    if serpentusa[i].hor == serpentusa[1].hor and serpentusa[i].ver == serpentusa[1].ver then
      GameOver = true
      Pipe:play()
      break
    end
  end
end

local function checkAte()
  if Apple.hor == serpentusa[1].hor and Apple.ver == serpentusa[1].ver then
      Ate = true
    end
end

local function freshState()
  serpentusa = {
    [1] = {hor = 6, ver = 12},
    [2] = {hor = 5, ver = 12},
    [3] = {hor = 4, ver = 12}
  }
  GameOver = false
  Pipe:stop()
  Background:play()
  Background:setVolume(0.4)
  spawnApple()
  Count = 1
  Clock = 0
  Speed = 0.5
  Direction = "east"
  Ate = false
  Cambiada = false
end

local scaleaX
local scaleaY

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  Skin = love.graphics.newImage("fumador.png")
  Skina = love.graphics.newImage("apple.png")
  Pipe = love.audio.newSource("metal-pipe-falling-sound-effect.mp3", "static")
  Background = love.audio.newSource("background.mp3", "stream")
  Background:setLooping(true)
  Yoshi = love.audio.newSource("yoshi-tongue.mp3", "static")
  Size = 25
  Column = 17
  Row = 15
  scaleaX = Size / Skina:getWidth()
  scaleaY = Size / Skina:getHeight()

  love.window.setMode(Column * Size, Row * Size)
  freshState()
end

function love.keypressed(key)
  if key == "r" then
    freshState()
  end
end

function love.update(dt)

  if GameOver then Background:stop() return end
  if not Cambiada then
    if love.keyboard.isDown("w", "up") and Direction ~= "south" and Direction ~= "north" then
      Direction = "north"
      Cambiada = true
    elseif love.keyboard.isDown("s", "down") and Direction ~= "north" and Direction ~= "south" then
      Direction = "south"
      Cambiada = true
    elseif love.keyboard.isDown("a", "left") and Direction ~= "east" and Direction ~= "west" then
      Direction = "west"
      Cambiada = true
    elseif love.keyboard.isDown("d", "right") and Direction ~= "west" and Direction ~= "east" then
      Direction = "east"
      Cambiada = true
    end
  end

  if Yoshi:isPlaying() then
    Background:setVolume(0.1)
  elseif not Yoshi:isPlaying() and Background:getVolume() < 0.4 then
    Background:setVolume(0.4)
  end

  Clock = Clock + dt
  if Clock >= Speed then
    Cambiada = false
    Clock = Clock - Speed
    if Direction == "north" then
      table.insert(serpentusa, 1, {hor = serpentusa[1].hor, ver = serpentusa[1].ver - 1})
    elseif Direction == "south" then
      table.insert(serpentusa, 1, {hor = serpentusa[1].hor, ver = serpentusa[1].ver + 1})
    elseif Direction == "west" then
      table.insert(serpentusa, 1, {hor = serpentusa[1].hor - 1, ver = serpentusa[1].ver})
    elseif Direction == "east" then
      table.insert(serpentusa, 1, {hor = serpentusa[1].hor + 1, ver = serpentusa[1].ver})
    end
    checkBounds()
    checkAte()
    if Ate then
      Yoshi:setVolume(0.5)
      Yoshi:stop()
      Yoshi:play()
      Count = Count + 1
      Ate = false
      spawnApple()
      Speed = math.max(0.11, 0.5 * 0.95 ^ (Count - 1))
    else
      table.remove(serpentusa, #serpentusa)
    end
    checkSelf()
  end
end
function love.draw()

  if GameOver then
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Skin, -30, 00, 0, 0.9, 1.8)
    love.graphics.setColor(0,0,0)
    love.graphics.print("Game Over. press r to reset", 30, 320, 0, 2.2, 2.2)
    return
  end

  for i = 1, #serpentusa do
    local pixelX = (serpentusa[i].hor - 1) * Size
    local pixelY = (serpentusa[i].ver - 1) * Size
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", pixelX, pixelY, Size, Size)
  end
  local pixelaX = (Apple.hor - 1) * Size
  local pixelaY = (Apple.ver - 1) * Size
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(Skina, pixelaX, pixelaY, 0, scaleaX, scaleaY)
  love.graphics.print(Count, 204, 23, 0, 1.9, 1.9)
end
