local platano = 
{
	closed = true,
	key = 121,
	entityEnumerator = 
	{
	  __gc = function(enum)
		if enum.destructor and enum.handle then
		  enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	  end
	}
}

function platano:enumerate_vehicles()
  return coroutine.wrap(function()
    local iter, id =  FindFirstVehicle()
    if not id or id == 0 then
      EndFindVehicle(iter)
      return
    end
    
    local enum = {handle = iter, destructor = EndFindVehicle}
    setmetatable(enum, platano.entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = FindNextVehicle(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    EndFindVehicle(iter)
  end)
end

function platano:rectangle(x, y, w, h, r, g, b, a)
	local resx, resy = GetActiveScreenResolution()
	local rectw, recth = w / resx, h / resy
	local rectx, recty = x / resx + rectw / 2, y / resy + recth / 2
	DrawRect(rectx, recty, rectw, recth, r, g, b, a)
end

function platano:text (text, font, centered, x, y, scale, r, g, b, a)
	local resx, resy = GetActiveScreenResolution()
	SetTextFont(font)
	SetTextScale(scale, scale)  
	SetTextCentre(centered)  
	SetTextColour(r, g, b, a) 
	BeginTextCommandDisplayText("STRING")  
	AddTextComponentSubstringPlayerName(text)  
	EndTextCommandDisplayText(x / resx, y / resy)
end

function platano:hovered (x, y, w, h)
	local mousex, mousey = GetNuiCursorPosition() 
	if mousex >= x and mousex <= x + w and mousey >= y and mousey <= y + h then 
		return true 
	else 
		return false 
	end 
end

function platano:button(name,xx,yy,r,g,b)
	local x,y = GetNuiCursorPosition()
	platano:text(name,4,0,xx,yy + 8, 0.3,255, 255,255,255)

	if platano:hovered(xx,yy + 8,100,18) then 
	
		if IsDisabledControlPressed(0, 92) then
			platano:text(name,4,0,xx,yy + 8, 0.3,r, g,b,255)
		end
		
		if IsDisabledControlJustPressed(0, 92) then
			return true
		end
		
	else
		return false
	end
end

function platano:rainbow(speed)
    local return_values = {}
	
    local game_timer = GetGameTimer() / 200
	
    return_values.r = math.floor(math.sin(game_timer * speed + 0) * 127 + 128)
    return_values.g = math.floor(math.sin(game_timer * speed + 2) * 127 + 128)
    return_values.b = math.floor(math.sin(game_timer * speed + 4) * 127 + 128)
	
    return return_values
end

Citizen.CreateThread(function()
  while true do
  	if IsDisabledControlJustPressed(1, platano.key) then
		platano.closed = not platano.closed
	end
  
	if platano.closed == false then
	

		local rainbow = platano:rainbow(1.0)

		platano:rectangle(19,19,152,502,rainbow.r,rainbow.g,rainbow.b,255)
		platano:rectangle(20,20,150,500,0,0,0,255)

		local x,y = GetNuiCursorPosition()
				
		local i = 0

		for veh in platano:enumerate_vehicles() do				
			if IsEntityDead(veh) then
				i = i + 1
				if platano:button(GetDisplayNameFromVehicleModel(GetEntityModel(veh)) .. " [~r~DESTRUIDO~w~]",25,i * 16,255,255,255) then
					SetVehicleFixed(veh)
					SetPedIntoVehicle(GetPlayerPed(-1),veh,-1)
				end
			else	
				if GetPedInVehicleSeat(veh,-1) == 0 then
					i = i + 1
					if platano:button(GetDisplayNameFromVehicleModel(GetEntityModel(veh)) .. " [~g~SEM MOTORISTA~w~]",25,i * 16,255,255,255) then
						SetPedIntoVehicle(GetPlayerPed(-1),veh,-1)
					end
				end
			end
		end
		
		platano:rectangle(x, y, 5, 5, rainbow.r,rainbow.g,rainbow.b,255)

	end
    Citizen.Wait(0)
  end
end)