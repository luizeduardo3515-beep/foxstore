local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local CAM=workspace.CurrentCamera

local esp_on=false
local aim_on=false
local aim_key=Enum.UserInputType.MouseButton2
local aim_fov=150
local aim_smooth=0.15
local menu_key=Enum.KeyCode.Insert

local gui=Instance.new("ScreenGui")
gui.ResetOnSpawn=false
gui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")

local win=Instance.new("Frame")
win.Size=UDim2.fromOffset(300,220)
win.Position=UDim2.new(0.5,-150,0.5,-110)
win.BackgroundColor3=Color3.fromRGB(22,13,38)
win.Active=true
win.Parent=gui
local wc=Instance.new("UICorner") wc.CornerRadius=UDim.new(0,14) wc.Parent=win

local drag=false
local ds,sp
win.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drag=true ds=i.Position sp=win.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-ds
		win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundColor3=Color3.fromRGB(124,58,237)
title.Text="FOX STORE"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=16
title.Font=Enum.Font.GothamBold
title.Parent=win
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,14) tc.Parent=title

local function btn(texto,y,key)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-20,0,34)
	b.Position=UDim2.fromOffset(10,y)
	b.BackgroundColor3=Color3.fromRGB(29,18,51)
	b.Text=texto..": OFF"
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=13
	b.AutoButtonColor=false
	b.Parent=win
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,8) bc.Parent=b
	b.MouseButton1Click:Connect(function()
		if key=="esp" then esp_on=not esp_on
		elseif key=="aim" then aim_on=not aim_on end
		local on=(key=="esp" and esp_on) or (key=="aim" and aim_on)
		b.BackgroundColor3=on and Color3.fromRGB(124,58,237) or Color3.fromRGB(29,18,51)
		b.Text=texto..(on and ": ON" or ": OFF")
	end)
end

btn("ESP",50,"esp")
btn("Aimbot (botao dir)",92,"aim")

local espObjs={}
local function clearEsp(p)
	local o=espObjs[p]
	if o then
		if o.hl then o.hl:Destroy() end
		if o.bb then o.bb:Destroy() end
		espObjs[p]=nil
	end
end

RunService.Heartbeat:Connect(function()
	local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local o=espObjs[p]
			if o and o.ch~=ch then clearEsp(p) o=nil end
			if esp_on and ch and myRoot then
				if not o then
					local root=ch:FindFirstChild("HumanoidRootPart")
					local hum=ch:FindFirstChildOfClass("Humanoid")
					if root and hum then
						local h=Instance.new("Highlight")
						h.FillTransparency=1
						h.Adornee=ch
						h.Parent=ch
						local bb=Instance.new("BillboardGui")
						bb.Size=UDim2.fromOffset(160,40)
						bb.StudsOffset=Vector3.new(0,3.6,0)
						bb.AlwaysOnTop=true
						bb.Adornee=root
						bb.Parent=ch
						local t=Instance.new("TextLabel")
						t.Size=UDim2.fromScale(1,1)
						t.BackgroundTransparency=1
						t.TextColor3=Color3.fromRGB(239,68,68)
						t.Font=Enum.Font.GothamBold
						t.TextSize=13
						t.TextStrokeTransparency=0.5
						t.Parent=bb
						espObjs[p]={hl=h,bb=bb,t=t,root=root,hum=hum,ch=ch}
						o=espObjs[p]
					end
				end
				if o then
					local d=(o.root.Position-myRoot.Position).Magnitude
					local show=d<=500 and o.hum.Health>0
					o.hl.Enabled=show
					o.bb.Enabled=show
					o.hl.OutlineColor=Color3.fromRGB(239,68,68)
					o.t.Text=p.DisplayName.." | "..math.floor(o.hum.Health).." HP"
				end
			elseif o then clearEsp(p) end
		end
	end
end)
Players.PlayerRemoving:Connect(clearEsp)

local aimHeld=false
local aimBound=false

local function getClosest()
	local myChar=LP.Character
	if not myChar then return nil end
	local myHum=myChar:FindFirstChildOfClass("Humanoid")
	if not myHum or myHum.Health<=0 then return nil end
	local center=CAM.ViewportSize/2
	local best,bestScore=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local hum=ch and ch:FindFirstChildOfClass("Humanoid")
			if ch and hum and hum.Health>0 then
				local part=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
				if part then
					local sp,on=CAM:WorldToViewportPoint(part.Position)
					if on and sp.Z>0 then
						local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
						if d<=aim_fov and d<bestScore then best,bestScore=part,d end
					end
				end
			end
		end
	end
	return best
end

local function aimLoop()
	if not aim_on or not aimHeld then return end
	local t=getClosest()
	if t then
		local cf=CAM.CFrame
		CAM.CFrame=cf:Lerp(CFrame.new(cf.Position,t.Position),math.clamp(1-aim_smooth,0.05,1))
	end
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==menu_key then gui:Destroy() return end
	if i.UserInputType==aim_key then
		aimHeld=true
		if aim_on and not aimBound then
			aimBound=true
			RunService:BindToRenderStep("FoxAim",Enum.RenderPriority.Camera.Value+1,aimLoop)
		end
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType==aim_key then
		aimHeld=false
		if aimBound then
			aimBound=false
			RunService:UnbindFromRenderStep("FoxAim")
		end
	end
end)

print("FOX STORE carregado")local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local CAM=workspace.CurrentCamera

local esp_on=false
local aim_on=false
local aim_key=Enum.UserInputType.MouseButton2
local aim_fov=150
local aim_smooth=0.15
local menu_key=Enum.KeyCode.Insert

local gui=Instance.new("ScreenGui")
gui.ResetOnSpawn=false
gui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")

local win=Instance.new("Frame")
win.Size=UDim2.fromOffset(300,220)
win.Position=UDim2.new(0.5,-150,0.5,-110)
win.BackgroundColor3=Color3.fromRGB(22,13,38)
win.Active=true
win.Parent=gui
local wc=Instance.new("UICorner") wc.CornerRadius=UDim.new(0,14) wc.Parent=win

local drag=false
local ds,sp
win.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drag=true ds=i.Position sp=win.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-ds
		win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundColor3=Color3.fromRGB(124,58,237)
title.Text="FOX STORE"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=16
title.Font=Enum.Font.GothamBold
title.Parent=win
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,14) tc.Parent=title

local function btn(texto,y,key)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-20,0,34)
	b.Position=UDim2.fromOffset(10,y)
	b.BackgroundColor3=Color3.fromRGB(29,18,51)
	b.Text=texto..": OFF"
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=13
	b.AutoButtonColor=false
	b.Parent=win
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,8) bc.Parent=b
	b.MouseButton1Click:Connect(function()
		if key=="esp" then esp_on=not esp_on
		elseif key=="aim" then aim_on=not aim_on end
		local on=(key=="esp" and esp_on) or (key=="aim" and aim_on)
		b.BackgroundColor3=on and Color3.fromRGB(124,58,237) or Color3.fromRGB(29,18,51)
		b.Text=texto..(on and ": ON" or ": OFF")
	end)
end

btn("ESP",50,"esp")
btn("Aimbot (botao dir)",92,"aim")

local espObjs={}
local function clearEsp(p)
	local o=espObjs[p]
	if o then
		if o.hl then o.hl:Destroy() end
		if o.bb then o.bb:Destroy() end
		espObjs[p]=nil
	end
end

RunService.Heartbeat:Connect(function()
	local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local o=espObjs[p]
			if o and o.ch~=ch then clearEsp(p) o=nil end
			if esp_on and ch and myRoot then
				if not o then
					local root=ch:FindFirstChild("HumanoidRootPart")
					local hum=ch:FindFirstChildOfClass("Humanoid")
					if root and hum then
						local h=Instance.new("Highlight")
						h.FillTransparency=1
						h.Adornee=ch
						h.Parent=ch
						local bb=Instance.new("BillboardGui")
						bb.Size=UDim2.fromOffset(160,40)
						bb.StudsOffset=Vector3.new(0,3.6,0)
						bb.AlwaysOnTop=true
						bb.Adornee=root
						bb.Parent=ch
						local t=Instance.new("TextLabel")
						t.Size=UDim2.fromScale(1,1)
						t.BackgroundTransparency=1
						t.TextColor3=Color3.fromRGB(239,68,68)
						t.Font=Enum.Font.GothamBold
						t.TextSize=13
						t.TextStrokeTransparency=0.5
						t.Parent=bb
						espObjs[p]={hl=h,bb=bb,t=t,root=root,hum=hum,ch=ch}
						o=espObjs[p]
					end
				end
				if o then
					local d=(o.root.Position-myRoot.Position).Magnitude
					local show=d<=500 and o.hum.Health>0
					o.hl.Enabled=show
					o.bb.Enabled=show
					o.hl.OutlineColor=Color3.fromRGB(239,68,68)
					o.t.Text=p.DisplayName.." | "..math.floor(o.hum.Health).." HP"
				end
			elseif o then clearEsp(p) end
		end
	end
end)
Players.PlayerRemoving:Connect(clearEsp)

local aimHeld=false
local aimBound=false

local function getClosest()
	local myChar=LP.Character
	if not myChar then return nil end
	local myHum=myChar:FindFirstChildOfClass("Humanoid")
	if not myHum or myHum.Health<=0 then return nil end
	local center=CAM.ViewportSize/2
	local best,bestScore=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local hum=ch and ch:FindFirstChildOfClass("Humanoid")
			if ch and hum and hum.Health>0 then
				local part=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
				if part then
					local sp,on=CAM:WorldToViewportPoint(part.Position)
					if on and sp.Z>0 then
						local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
						if d<=aim_fov and d<bestScore then best,bestScore=part,d end
					end
				end
			end
		end
	end
	return best
end

local function aimLoop()
	if not aim_on or not aimHeld then return end
	local t=getClosest()
	if t then
		local cf=CAM.CFrame
		CAM.CFrame=cf:Lerp(CFrame.new(cf.Position,t.Position),math.clamp(1-aim_smooth,0.05,1))
	end
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==menu_key then gui:Destroy() return end
	if i.UserInputType==aim_key then
		aimHeld=true
		if aim_on and not aimBound then
			aimBound=true
			RunService:BindToRenderStep("FoxAim",Enum.RenderPriority.Camera.Value+1,aimLoop)
		end
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType==aim_key then
		aimHeld=false
		if aimBound then
			aimBound=false
			RunService:UnbindFromRenderStep("FoxAim")
		end
	end
end)

print("FOX STORE carregado")local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local LP=Players.LocalPlayer
local CAM=workspace.CurrentCamera

local esp_on=false
local aim_on=false
local aim_key=Enum.UserInputType.MouseButton2
local aim_fov=150
local aim_smooth=0.15
local menu_key=Enum.KeyCode.Insert

local gui=Instance.new("ScreenGui")
gui.ResetOnSpawn=false
gui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")

local win=Instance.new("Frame")
win.Size=UDim2.fromOffset(300,220)
win.Position=UDim2.new(0.5,-150,0.5,-110)
win.BackgroundColor3=Color3.fromRGB(22,13,38)
win.Active=true
win.Parent=gui
local wc=Instance.new("UICorner") wc.CornerRadius=UDim.new(0,14) wc.Parent=win

local drag=false
local ds,sp
win.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		drag=true ds=i.Position sp=win.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-ds
		win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
end)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,40)
title.BackgroundColor3=Color3.fromRGB(124,58,237)
title.Text="FOX STORE"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=16
title.Font=Enum.Font.GothamBold
title.Parent=win
local tc=Instance.new("UICorner") tc.CornerRadius=UDim.new(0,14) tc.Parent=title

local function btn(texto,y,key)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,-20,0,34)
	b.Position=UDim2.fromOffset(10,y)
	b.BackgroundColor3=Color3.fromRGB(29,18,51)
	b.Text=texto..": OFF"
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=13
	b.AutoButtonColor=false
	b.Parent=win
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,8) bc.Parent=b
	b.MouseButton1Click:Connect(function()
		if key=="esp" then esp_on=not esp_on
		elseif key=="aim" then aim_on=not aim_on end
		local on=(key=="esp" and esp_on) or (key=="aim" and aim_on)
		b.BackgroundColor3=on and Color3.fromRGB(124,58,237) or Color3.fromRGB(29,18,51)
		b.Text=texto..(on and ": ON" or ": OFF")
	end)
end

btn("ESP",50,"esp")
btn("Aimbot (botao dir)",92,"aim")

local espObjs={}
local function clearEsp(p)
	local o=espObjs[p]
	if o then
		if o.hl then o.hl:Destroy() end
		if o.bb then o.bb:Destroy() end
		espObjs[p]=nil
	end
end

RunService.Heartbeat:Connect(function()
	local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local o=espObjs[p]
			if o and o.ch~=ch then clearEsp(p) o=nil end
			if esp_on and ch and myRoot then
				if not o then
					local root=ch:FindFirstChild("HumanoidRootPart")
					local hum=ch:FindFirstChildOfClass("Humanoid")
					if root and hum then
						local h=Instance.new("Highlight")
						h.FillTransparency=1
						h.Adornee=ch
						h.Parent=ch
						local bb=Instance.new("BillboardGui")
						bb.Size=UDim2.fromOffset(160,40)
						bb.StudsOffset=Vector3.new(0,3.6,0)
						bb.AlwaysOnTop=true
						bb.Adornee=root
						bb.Parent=ch
						local t=Instance.new("TextLabel")
						t.Size=UDim2.fromScale(1,1)
						t.BackgroundTransparency=1
						t.TextColor3=Color3.fromRGB(239,68,68)
						t.Font=Enum.Font.GothamBold
						t.TextSize=13
						t.TextStrokeTransparency=0.5
						t.Parent=bb
						espObjs[p]={hl=h,bb=bb,t=t,root=root,hum=hum,ch=ch}
						o=espObjs[p]
					end
				end
				if o then
					local d=(o.root.Position-myRoot.Position).Magnitude
					local show=d<=500 and o.hum.Health>0
					o.hl.Enabled=show
					o.bb.Enabled=show
					o.hl.OutlineColor=Color3.fromRGB(239,68,68)
					o.t.Text=p.DisplayName.." | "..math.floor(o.hum.Health).." HP"
				end
			elseif o then clearEsp(p) end
		end
	end
end)
Players.PlayerRemoving:Connect(clearEsp)

local aimHeld=false
local aimBound=false

local function getClosest()
	local myChar=LP.Character
	if not myChar then return nil end
	local myHum=myChar:FindFirstChildOfClass("Humanoid")
	if not myHum or myHum.Health<=0 then return nil end
	local center=CAM.ViewportSize/2
	local best,bestScore=nil,math.huge
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local hum=ch and ch:FindFirstChildOfClass("Humanoid")
			if ch and hum and hum.Health>0 then
				local part=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
				if part then
					local sp,on=CAM:WorldToViewportPoint(part.Position)
					if on and sp.Z>0 then
						local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
						if d<=aim_fov and d<bestScore then best,bestScore=part,d end
					end
				end
			end
		end
	end
	return best
end

local function aimLoop()
	if not aim_on or not aimHeld then return end
	local t=getClosest()
	if t then
		local cf=CAM.CFrame
		CAM.CFrame=cf:Lerp(CFrame.new(cf.Position,t.Position),math.clamp(1-aim_smooth,0.05,1))
	end
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==menu_key then gui:Destroy() return end
	if i.UserInputType==aim_key then
		aimHeld=true
		if aim_on and not aimBound then
			aimBound=true
			RunService:BindToRenderStep("FoxAim",Enum.RenderPriority.Camera.Value+1,aimLoop)
		end
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType==aim_key then
		aimHeld=false
		if aimBound then
			aimBound=false
			RunService:UnbindFromRenderStep("FoxAim")
		end
	end
end)

print("FOX STORE carregado")
