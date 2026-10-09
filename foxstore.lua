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
