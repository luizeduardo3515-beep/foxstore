local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local CAM=workspace.CurrentCamera

local cfg={
	esp_on=false,esp_box=false,esp_name=false,esp_hp=false,esp_hpbar=false,
	esp_tracer=false,esp_box2d=false,
	c_enemy=Color3.fromRGB(239,68,68),c_team=Color3.fromRGB(74,222,128),esp_range=500,
	aim_on=false,aim_key=Enum.UserInputType.MouseButton2,aim_fov=150,
	aim_smooth=0.15,aim_team=true,aim_toggle=false,aim_show_fov=false,
	aim_prediction=0,c_aim=Color3.fromRGB(239,68,68),
	trig_on=false,trig_auto=false,trig_key=Enum.KeyCode.F,trig_delay=0.05,
	speed_on=false,speed_val=50,fly_on=false,fly_speed=80,
	jump_on=false,noclip_on=false,antiafk_on=false,
	cross=false,cross_size=12,c_cross=Color3.fromRGB(192,38,211),
	fullbright=false,fullbright_val=3,fps_show=false,
	antivoid=false,antifling=false,
	menu_key=Enum.KeyCode.Insert,
}

local C_UI=Color3.fromRGB(124,58,237)
local C_BG=Color3.fromRGB(22,13,38)
local C_ROW=Color3.fromRGB(29,18,51)
local C_OFF=Color3.fromRGB(29,18,51)

local gui=Instance.new("ScreenGui")
gui.Name="FoxPanel"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=999
gui.Parent=(gethui and gethui()) or LP:WaitForChild("PlayerGui")

local win=Instance.new("Frame")
win.Size=UDim2.fromOffset(440,540)
win.Position=UDim2.new(0.5,-220,0.5,-270)
win.BackgroundColor3=C_BG
win.Active=true
win.Parent=gui
local wc=Instance.new("UICorner") wc.CornerRadius=UDim.new(0,16) wc.Parent=win

local hdr=Instance.new("Frame")
hdr.Size=UDim2.new(1,0,0,46)
hdr.BackgroundColor3=C_UI
hdr.Parent=win
local hc=Instance.new("UICorner") hc.CornerRadius=UDim.new(0,16) hc.Parent=hdr

local dragging=false
local dragStart,startPos
hdr.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		dragging=true dragStart=i.Position startPos=win.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
		local d=i.Position-dragStart
		win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		dragging=false
	end
end)

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,-90,1,0)
title.Position=UDim2.fromOffset(14,0)
title.BackgroundTransparency=1
title.Text="FOX STORE"
title.TextColor3=Color3.new(1,1,1)
title.TextSize=18
title.Font=Enum.Font.GothamBold
title.TextXAlignment=Enum.TextXAlignment.Left
title.Parent=hdr

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.fromOffset(32,32)
closeBtn.Position=UDim2.new(1,-40,0.5,-16)
closeBtn.BackgroundColor3=Color3.fromRGB(200,40,60)
closeBtn.Text="X"
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=15
closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.AutoButtonColor=false
closeBtn.Parent=hdr
local cc=Instance.new("UICorner") cc.CornerRadius=UDim.new(0,8) cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function() win.Visible=false end)

local tabBar=Instance.new("Frame")
tabBar.Size=UDim2.new(1,-20,0,30)
tabBar.Position=UDim2.fromOffset(10,54)
tabBar.BackgroundTransparency=1
tabBar.Parent=win
local tabList=Instance.new("UIListLayout")
tabList.FillDirection=Enum.FillDirection.Horizontal
tabList.Padding=UDim.new(0,4)
tabList.Parent=tabBar

local pages={}
local tabBtns={}
local function showPage(name)
	for n,p in pairs(pages) do p.Visible=(n==name) end
	for n,b in pairs(tabBtns) do b.BackgroundColor3=(n==name) and C_UI or C_ROW end
end

local function newPage(name,titleTab)
	local b=Instance.new("TextButton")
	b.Size=UDim2.fromOffset(60,26)
	b.BackgroundColor3=C_ROW
	b.Text=titleTab
	b.TextColor3=Color3.new(1,1,1)
	b.Font=Enum.Font.GothamBold
	b.TextSize=10
	b.AutoButtonColor=false
	b.Parent=tabBar
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,6) bc.Parent=b
	tabBtns[name]=b
	local p=Instance.new("ScrollingFrame")
	p.Size=UDim2.new(1,-20,1,-96)
	p.Position=UDim2.fromOffset(10,90)
	p.BackgroundTransparency=1
	p.BorderSizePixel=0
	p.ScrollBarThickness=4
	p.CanvasSize=UDim2.new()
	p.AutomaticCanvasSize=Enum.AutomaticSize.Y
	p.Visible=false
	p.Parent=win
	local pl=Instance.new("UIListLayout")
	pl.Padding=UDim.new(0,6)
	pl.Parent=p
	pages[name]=p
	b.MouseButton1Click:Connect(function() showPage(name) end)
	return p
end

local function botao(parent,texto,key)
	local r=Instance.new("Frame")
	r.Size=UDim2.new(1,-4,0,34)
	r.BackgroundColor3=C_ROW
	r.BorderSizePixel=0
	r.Parent=parent
	local rc=Instance.new("UICorner") rc.CornerRadius=UDim.new(0,8) rc.Parent=r
	local l=Instance.new("TextLabel")
	l.Size=UDim2.new(0.65,0,1,0)
	l.Position=UDim2.fromOffset(10,0)
	l.BackgroundTransparency=1
	l.Text=texto
	l.TextColor3=Color3.fromRGB(239,233,251)
	l.TextSize=12
	l.Font=Enum.Font.Gotham
	l.TextXAlignment=Enum.TextXAlignment.Left
	l.Parent=r
	local b=Instance.new("TextButton")
	b.Size=UDim2.fromOffset(56,24)
	b.Position=UDim2.new(1,-64,0.5,-12)
	b.BackgroundColor3=C_OFF
	b.Text="OFF"
	b.Font=Enum.Font.GothamBold
	b.TextSize=11
	b.TextColor3=Color3.new(1,1,1)
	b.AutoButtonColor=false
	b.Parent=r
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,6) bc.Parent=b
	b.MouseButton1Click:Connect(function()
		cfg[key]=not cfg[key]
		b.BackgroundColor3=cfg[key] and C_UI or C_OFF
		b.Text=cfg[key] and "ON" or "OFF"
	end)
end

local keybindListening=nil
local function keyName(k)
	if typeof(k)=="EnumItem" then
		if k.EnumType==Enum.KeyCode then return k.Name end
		if k.EnumType==Enum.UserInputType then
			if k==Enum.UserInputType.MouseButton1 then return "Mouse1" end
			if k==Enum.UserInputType.MouseButton2 then return "Mouse2" end
			if k==Enum.UserInputType.MouseButton3 then return "Mouse3" end
			return k.Name
		end
	end
	return tostring(k)
end

local function keybindRow(parent,labelText,keyCfg)
	local r=Instance.new("Frame")
	r.Size=UDim2.new(1,-4,0,34)
	r.BackgroundColor3=C_ROW
	r.BorderSizePixel=0
	r.Parent=parent
	local rc=Instance.new("UICorner") rc.CornerRadius=UDim.new(0,8) rc.Parent=r
	local l=Instance.new("TextLabel")
	l.Size=UDim2.new(0.5,0,1,0)
	l.Position=UDim2.fromOffset(10,0)
	l.BackgroundTransparency=1
	l.Text=labelText
	l.TextColor3=Color3.fromRGB(239,233,251)
	l.TextSize=12
	l.Font=Enum.Font.Gotham
	l.TextXAlignment=Enum.TextXAlignment.Left
	l.Parent=r
	local b=Instance.new("TextButton")
	b.Size=UDim2.fromOffset(120,24)
	b.Position=UDim2.new(1,-130,0.5,-12)
	b.Text=keyName(cfg[keyCfg])
	b.Font=Enum.Font.GothamBold
	b.TextSize=11
	b.TextColor3=Color3.new(1,1,1)
	b.BackgroundColor3=C_UI
	b.AutoButtonColor=false
	b.Parent=r
	local bc=Instance.new("UICorner") bc.CornerRadius=UDim.new(0,6) bc.Parent=b
	b.MouseButton1Click:Connect(function()
		keybindListening=keyCfg
		b.Text="..."
		b.BackgroundColor3=Color3.fromRGB(250,204,21)
	end)
	task.spawn(function()
		while task.wait(0.05) do
			if keybindListening~=keyCfg then
				b.Text=keyName(cfg[keyCfg])
				b.BackgroundColor3=C_UI
			end
		end
	end)
end

local pEsp=newPage("esp","ESP")
botao(pEsp,"Ativar ESP","esp_on")
botao(pEsp,"Contorno","esp_box")
botao(pEsp,"Caixa 2D","esp_box2d")
botao(pEsp,"Tracer","esp_tracer")
botao(pEsp,"Nomes","esp_name")
botao(pEsp,"Vida texto","esp_hp")
botao(pEsp,"Vida barra","esp_hpbar")

local pAim=newPage("aim","AIM")
botao(pAim,"Ativar","aim_on")
botao(pAim,"Toggle","aim_toggle")
botao(pAim,"FOV","aim_show_fov")
botao(pAim,"Ignorar time","aim_team")
keybindRow(pAim,"Tecla","aim_key")

local pTrig=newPage("trig","TRIG")
botao(pTrig,"Segurar","trig_on")
botao(pTrig,"AUTO","trig_auto")
keybindRow(pTrig,"Tecla","trig_key")

local pMov=newPage("mov","MOV")
botao(pMov,"Speed","speed_on")
botao(pMov,"Fly","fly_on")
botao(pMov,"Pulo inf","jump_on")
botao(pMov,"Noclip","noclip_on")
botao(pMov,"Anti-AFK","antiafk_on")

local pVis=newPage("vis","VIS")
botao(pVis,"Fullbright","fullbright")
botao(pVis,"FPS","fps_show")
botao(pVis,"Mira","cross")

local pCfg=newPage("cfg","CFG")
keybindRow(pCfg,"Tecla Menu","menu_key")

showPage("esp")
local fovCircle=Instance.new("Frame")
fovCircle.AnchorPoint=Vector2.new(0.5,0.5)
fovCircle.Position=UDim2.fromScale(0.5,0.5)
fovCircle.BackgroundTransparency=1
fovCircle.Visible=false
fovCircle.Parent=gui
local fovC=Instance.new("UICorner") fovC.CornerRadius=UDim.new(1,0) fovC.Parent=fovCircle
local fovS=Instance.new("UIStroke") fovS.Thickness=2 fovS.Color=cfg.c_aim fovS.Parent=fovCircle

local crossH=Instance.new("Frame")
crossH.AnchorPoint=Vector2.new(0.5,0.5)
crossH.Position=UDim2.fromScale(0.5,0.5)
crossH.BackgroundColor3=cfg.c_cross
crossH.BorderSizePixel=0
crossH.Visible=false
crossH.Parent=gui

local crossV=Instance.new("Frame")
crossV.AnchorPoint=Vector2.new(0.5,0.5)
crossV.Position=UDim2.fromScale(0.5,0.5)
crossV.BackgroundColor3=cfg.c_cross
crossV.BorderSizePixel=0
crossV.Visible=false
crossV.Parent=gui

local fpsLbl=Instance.new("TextLabel")
fpsLbl.Size=UDim2.fromOffset(100,24)
fpsLbl.Position=UDim2.new(1,-110,0,8)
fpsLbl.BackgroundTransparency=1
fpsLbl.Text=""
fpsLbl.TextColor3=Color3.new(1,1,1)
fpsLbl.TextSize=14
fpsLbl.Font=Enum.Font.GothamBold
fpsLbl.TextXAlignment=Enum.TextXAlignment.Right
fpsLbl.TextStrokeTransparency=0.5
fpsLbl.Parent=gui

local fr,ls=0,os.clock()

local fullOrig={
	Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,
	OutdoorAmbient=Lighting.OutdoorAmbient,GlobalShadows=Lighting.GlobalShadows,
	FogEnd=Lighting.FogEnd,ClockTime=Lighting.ClockTime,
}

local function aplicarTudo()
	fovCircle.Visible=cfg.aim_on and cfg.aim_show_fov
	fovCircle.Size=UDim2.fromOffset(cfg.aim_fov*2,cfg.aim_fov*2)
	fovS.Color=cfg.c_aim
	crossH.Visible=cfg.cross
	crossV.Visible=cfg.cross
	local s=cfg.cross_size*2
	crossH.Size=UDim2.fromOffset(s,2)
	crossV.Size=UDim2.fromOffset(2,s)
	if cfg.fullbright then
		Lighting.Brightness=cfg.fullbright_val
		Lighting.Ambient=Color3.fromRGB(200,200,200)
		Lighting.OutdoorAmbient=Color3.fromRGB(200,200,200)
		Lighting.GlobalShadows=false
		Lighting.FogEnd=100000
		Lighting.ClockTime=12
	else
		Lighting.Brightness=fullOrig.Brightness
		Lighting.Ambient=fullOrig.Ambient
		Lighting.OutdoorAmbient=fullOrig.OutdoorAmbient
		Lighting.GlobalShadows=fullOrig.GlobalShadows
		Lighting.FogEnd=fullOrig.FogEnd
		Lighting.ClockTime=fullOrig.ClockTime
	end
end

local espObjs={}
local function clearEsp(p)
	local o=espObjs[p]
	if o then
		if o.hl then o.hl:Destroy() end
		if o.bb then o.bb:Destroy() end
		if o.hpFrame then o.hpFrame:Destroy() end
		if o.box2d then o.box2d:Destroy() end
		if o.line then o.line:Destroy() end
		espObjs[p]=nil
	end
end

local function makeEsp(p,ch)
	local root=ch:FindFirstChild("HumanoidRootPart")
	local hum=ch:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local h=Instance.new("Highlight") h.FillTransparency=1 h.Adornee=ch h.Parent=ch
	local bb=Instance.new("BillboardGui")
	bb.Size=UDim2.fromOffset(160,40) bb.StudsOffset=Vector3.new(0,3.6,0)
	bb.AlwaysOnTop=true bb.Adornee=root bb.Parent=ch
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1
	t.Font=Enum.Font.GothamBold t.TextSize=13 t.TextStrokeTransparency=0.5 t.Parent=bb
	local hpFrame=Instance.new("Frame")
	hpFrame.Size=UDim2.fromOffset(6,30)
	hpFrame.BackgroundColor3=Color3.fromRGB(20,20,20)
	hpFrame.BorderSizePixel=0 hpFrame.Visible=false hpFrame.Parent=gui
	local hpc=Instance.new("UICorner") hpc.CornerRadius=UDim.new(0,2) hpc.Parent=hpFrame
	local hpFill=Instance.new("Frame")
	hpFill.Size=UDim2.new(1,0,1,0)
	hpFill.BackgroundColor3=Color3.fromRGB(74,222,128)
	hpFill.BorderSizePixel=0
	hpFill.AnchorPoint=Vector2.new(0,1)
	hpFill.Position=UDim2.new(0,0,1,0)
	hpFill.Parent=hpFrame
	local hfc=Instance.new("UICorner") hfc.CornerRadius=UDim.new(0,2) hfc.Parent=hpFill
	local box2d=Instance.new("Frame")
	box2d.BackgroundTransparency=1 box2d.BorderSizePixel=0 box2d.Visible=false box2d.Parent=gui
	local boxStroke=Instance.new("UIStroke") boxStroke.Thickness=1 boxStroke.Parent=box2d
	local line=Instance.new("Frame")
	line.AnchorPoint=Vector2.new(0,0.5)
	line.BackgroundColor3=cfg.c_enemy
	line.BorderSizePixel=0 line.Visible=false line.Parent=gui
	espObjs[p]={hl=h,bb=bb,t=t,hpFrame=hpFrame,hpFill=hpFill,box2d=box2d,boxStroke=boxStroke,line=line,root=root,hum=hum,ch=ch}
end

RunService.Heartbeat:Connect(function()
	aplicarTudo()
	local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local o=espObjs[p]
			if o and o.ch~=ch then clearEsp(p) o=nil end
			if cfg.esp_on and ch and myRoot then
				if not o then makeEsp(p,ch) o=espObjs[p] end
				if o then
					local d=(o.root.Position-myRoot.Position).Magnitude
					local show=d<=cfg.esp_range and o.hum.Health>0
					o.hl.Enabled=show o.bb.Enabled=show
					local isTeam=p.Team and LP.Team and p.Team==LP.Team
					local cor=isTeam and cfg.c_team or cfg.c_enemy
					o.hl.OutlineColor=cor
					o.hl.OutlineTransparency=cfg.esp_box and 0 or 1
					o.t.TextColor3=cor
					local parts={}
					if cfg.esp_name then table.insert(parts,p.DisplayName) end
					if cfg.esp_hp then table.insert(parts,math.floor(o.hum.Health).." HP") end
					o.t.Text=table.concat(parts," | ")
					if cfg.esp_hpbar and show then
						local top=CAM:WorldToViewportPoint(o.root.Position+Vector3.new(0,3,0))
						local bot=CAM:WorldToViewportPoint(o.root.Position-Vector3.new(0,3,0))
						if top.Z>0 and bot.Z>0 then
							local altura=math.abs(bot.Y-top.Y)
							local xOffset=altura*0.35+8
							o.hpFrame.Visible=true
							o.hpFrame.Size=UDim2.fromOffset(6,altura)
							o.hpFrame.Position=UDim2.fromOffset(top.X+xOffset,top.Y)
							local pct=math.clamp(o.hum.Health/o.hum.MaxHealth,0,1)
							o.hpFill.Size=UDim2.new(1,0,pct,0)
							if pct>0.6 then o.hpFill.BackgroundColor3=Color3.fromRGB(74,222,128)
							elseif pct>0.3 then o.hpFill.BackgroundColor3=Color3.fromRGB(250,204,21)
							else o.hpFill.BackgroundColor3=Color3.fromRGB(239,68,68) end
						else o.hpFrame.Visible=false end
					else o.hpFrame.Visible=false end
					if cfg.esp_box2d and show then
						local top,on=CAM:WorldToViewportPoint(o.root.Position+Vector3.new(0,3,0))
						local bot=CAM:WorldToViewportPoint(o.root.Position-Vector3.new(0,3,0))
						if on and top.Z>0 and bot.Z>0 then
							local altura=math.abs(bot.Y-top.Y)
							local largura=altura*0.55
							o.box2d.Visible=true
							o.box2d.Position=UDim2.fromOffset(top.X-largura/2,top.Y)
							o.box2d.Size=UDim2.fromOffset(largura,altura)
							o.boxStroke.Color=cor
						else o.box2d.Visible=false end
					else o.box2d.Visible=false end
					if cfg.esp_tracer and show then
						local tg=CAM:WorldToViewportPoint(o.root.Position)
						if tg.Z>0 then
							local center=CAM.ViewportSize/2
							local dx=tg.X-center.X
							local dy=tg.Y-center.Y
							local dist=math.sqrt(dx*dx+dy*dy)
							local ang=math.atan2(dy,dx)
							o.line.Visible=true
							o.line.Position=UDim2.fromOffset(center.X,center.Y)
							o.line.Size=UDim2.fromOffset(dist,1)
							o.line.Rotation=math.deg(ang)
							o.line.BackgroundColor3=cor
						else o.line.Visible=false end
					else o.line.Visible=false end
				end
			elseif o then clearEsp(p) end
		end
	end
end)
Players.PlayerRemoving:Connect(clearEsp)

local aimHeld=false
local aimToggled=false
local aimBound=false
local trigHeld=false

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
				local isTeam=p.Team and LP.Team and p.Team==LP.Team
				if not (cfg.aim_team and isTeam) then
					local part=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
					if part then
						local pos=part.Position
						if cfg.aim_prediction>0 then
							pos=pos+part.AssemblyLinearVelocity*(cfg.aim_prediction/100)
						end
						local sp,on=CAM:WorldToViewportPoint(pos)
						if on and sp.Z>0 then
							local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
							if d<=cfg.aim_fov and d<bestScore then best,bestScore=part,d end
						end
					end
				end
			end
		end
	end
	return best
end

local function isOnCrosshair()
	local myChar=LP.Character
	if not myChar then return nil end
	local myHum=myChar:FindFirstChildOfClass("Humanoid")
	if not myHum or myHum.Health<=0 then return nil end
	local center=CAM.ViewportSize/2
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			local ch=p.Character
			local hum=ch and ch:FindFirstChildOfClass("Humanoid")
			if ch and hum and hum.Health>0 then
				local isTeam=p.Team and LP.Team and p.Team==LP.Team
				if not (cfg.aim_team and isTeam) then
					local part=ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
					if part then
						local sp,on=CAM:WorldToViewportPoint(part.Position)
						if on and sp.Z>0 then
							local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
							if d<=10 then return part end
						end
					end
				end
			end
		end
	end
	return nil
end

local function aimLoop()
	if not cfg.aim_on or not (aimHeld or aimToggled) then return end
	local t=getClosest()
	if t then
		local cf=CAM.CFrame
		CAM.CFrame=cf:Lerp(CFrame.new(cf.Position,t.Position),math.clamp(1-cfg.aim_smooth/100,0.05,1))
	end
end

local function startAim()
	if aimBound then return end
	aimBound=true
	RunService:BindToRenderStep("FoxAim",Enum.RenderPriority.Camera.Value+1,aimLoop)
end
local function stopAim()
	if not aimBound then return end
	aimBound=false
	RunService:UnbindFromRenderStep("FoxAim")
end

local function matchKey(input,key)
	if typeof(key)=="EnumItem" then
		if input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==key then return true end
		if input.UserInputType==key then return true end
	end
	return false
end

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if keybindListening then
		if i.UserInputType==Enum.UserInputType.Keyboard then
			cfg[keybindListening]=i.KeyCode
			keybindListening=nil
		elseif i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.MouseButton2 or i.UserInputType==Enum.UserInputType.MouseButton3 then
			cfg[keybindListening]=i.UserInputType
			keybindListening=nil
		end
		return
	end
	if matchKey(i,cfg.menu_key) then
		if gui then gui:Destroy() end
		return
	end
	if matchKey(i,cfg.aim_key) then
		if cfg.aim_toggle then aimToggled=not aimToggled else aimHeld=true end
		if cfg.aim_on and (aimHeld or aimToggled) then
			startAim()
			task.spawn(function() for k=1,5 do aimLoop() task.wait() end end)
		end
		return
	end
	if matchKey(i,cfg.trig_key) then trigHeld=true return end
end)

UIS.InputEnded:Connect(function(i)
	if matchKey(i,cfg.aim_key) then
		if not cfg.aim_toggle then aimHeld=false stopAim() end
	elseif matchKey(i,cfg.trig_key) then trigHeld=false end
end)

task.spawn(function()
	while task.wait(0.02) do
		if not gui or not gui.Parent then return end
		if cfg.trig_on and trigHeld then
			local t=getClosest()
			if t and LP.Character then
				local tool=LP.Character:FindFirstChildOfClass("Tool")
				if tool then tool:Activate() end
				task.wait(cfg.trig_delay/100)
			end
		end
	end
end)

task.spawn(function()
	while task.wait(0.03) do
		if not gui or not gui.Parent then return end
		if cfg.trig_auto and LP.Character then
			local myHum=LP.Character:FindFirstChildOfClass("Humanoid")
			if myHum and myHum.Health>0 then
				local target=isOnCrosshair()
				if target then
					local tool=LP.Character:FindFirstChildOfClass("Tool")
					if tool then tool:Activate()
					else
						local vu=game:GetService("VirtualUser")
						vu:CaptureController()
						vu:ClickButton1(Vector2.new())
					end
					task.wait(0.05)
				end
			end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	fr=fr+1
	local n=os.clock()
	if n-ls>=1 then
		if cfg.fps_show then fpsLbl.Text=math.floor(fr/(n-ls)).." FPS" else fpsLbl.Text="" end
		fr=0 ls=n
	end
end)

RunService.Heartbeat:Connect(function()
	local ch=LP.Character
	local hum=ch and ch:FindFirstChildOfClass("Humanoid")
	if hum then
		local ws=16
		if cfg.speed_on then ws=cfg.speed_val end
		hum.WalkSpeed=ws
	end
	if cfg.jump_on and hum then
		hum.UseJumpPower=true
		hum.JumpPower=100
	end
	if cfg.fly_on then
		local root=ch and ch:FindFirstChild("HumanoidRootPart")
		if root and not root:FindFirstChild("FoxFly") then
			local bv=Instance.new("BodyVelocity")
			bv.Name="FoxFly"
			bv.MaxForce=Vector3.new(1e5,1e5,1e5)
			bv.Velocity=Vector3.new(0,0,0)
			bv.Parent=root
		end
	else
		local root=ch and ch:FindFirstChild("HumanoidRootPart")
		if root then
			local bv=root:FindFirstChild("FoxFly")
			if bv then bv:Destroy() end
		end
	end
	if cfg.noclip_on and ch then
		for _,part in ipairs(ch:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
		end
	end
	if cfg.antivoid and ch then
		local root=ch:FindFirstChild("HumanoidRootPart")
		if root and root.Position.Y<-50 then
			root.CFrame=CFrame.new(0,50,0)
		end
	end
	if cfg.antifling and ch then
		local root=ch:FindFirstChild("HumanoidRootPart")
		if root and root.AssemblyLinearVelocity.Magnitude>200 then
			root.AssemblyLinearVelocity=Vector3.new(0,0,0)
		end
	end
end)

task.spawn(function()
	while task.wait(60) do
		if cfg.antiafk_on then
			local vu=game:GetService("VirtualUser")
			vu:CaptureController()
			vu:ClickButton2(Vector2.new())
		end
	end
end)

print("FOX STORE carregado")
