local lplr = game.Players.LocalPlayer
local UI = Instance.new("ScreenGui",lplr.PlayerGui)
UI.ResetOnSpawn = false

local mouse = lplr:GetMouse()
local function getMousePos()
	return UDim2.fromScale(mouse.X / mouse.ViewSizeX,mouse.Y / mouse.ViewSizeY)
end

local tabs = {}

local config = {
	["WindowPositions"] = {

	},
	["Buttons"] = {},
	["Toggles"] = {},
	["Pickers"] = {},
	["TextBox"] = {}
}

local lib = {
	GetScreenGui = function()
		local ui = Instance.new("ScreenGui")
		ui.ResetOnSpawn = false
		ui.Parent = game.Players.LocalPlayer.PlayerGui
		return ui
	end,
	Round = function(item)
		Instance.new("UICorner",item)
	end,
	GetFrame = function(scrolling, content)
		local frame = (not scrolling and Instance.new("Frame") or Instance.new("ScrollingFrame"))
		for i, v in pairs(content) do
			frame[i] = v
		end
		return frame
	end,
	GetImageLabel = function(content)
		local ImageLabel = Instance.new("ImageLabel")
		for i, v in pairs(content) do
			ImageLabel[i] = v
		end
		return ImageLabel
	end,
	GetHighlight = function(content)
		local Highlight = Instance.new("Highlight")
		for i, v in pairs(content) do
			Highlight[i] = v
		end
		return Highlight
	end,
	GetTextLabel = function(content)
		local label = Instance.new("TextLabel")
		for i, v in pairs(content) do
			if i == "BaseText" then
				label:GetPropertyChangedSignal("Text"):Connect(function()
					if label.Text:sub(tostring(v):len(),tostring(v):len()) ~= tostring(v) then
						label.Text = tostring(v).." "..label.Text
					end
				end)
				continue
			end
			label[i] = v
		end
		return label
	end,
	GetBillboardGui = function(content)
		local Billboard = Instance.new("BillboardGui")
		for i, v in pairs(content) do
			Billboard[i] = v
		end
		return Billboard
	end,
	GetTextButton = function(content)
		local Button = Instance.new("TextButton")
		for i, v in pairs(content) do
			Button[i] = v
		end
		return Button
	end,
	BindOnLeftClick = function(obj,func)
		obj.MouseButton1Down:Connect(func)
	end,
	BindOnRightClick = function(obj,func)
		obj.MouseButton2Down:Connect(func)
	end,
	BindOnHover = function(obj : TextButton,func,func2)
		obj.MouseEnter:Connect(func)
		obj.MouseLeave:Connect(func2)
	end,
	BlurImage = function(content)
		local image = Instance.new("ImageLabel")
		image.Image = "rbxassetid://13350795660"
		image.Transparency = 0.5
		for i,v in pairs(content) do
			image[i] = v
		end
		return image
	end,
	AddAutoSort = function(p)
		local i = Instance.new("UIListLayout",p)
		return i
	end,
}

local notifyUI = lib.GetScreenGui()
local notifyFrame = lib.GetFrame(false,{
	Parent = notifyUI,
	Position = UDim2.fromScale(0.364,0),
	Size = UDim2.fromScale(0.272,0.47),
	BackgroundTransparency = 1,
})

function lib:Notify(text,removeTime,image,barColor)
	local alert = lib.GetFrame(false,{
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.75,0),
		Parent = notifyFrame,
		BackgroundTransparency = 0,
		BackgroundColor3 = Color3.fromRGB(49, 49, 49)
	})
	local image = lib.GetImageLabel({
		BorderSizePixel = 0,
		Parent = alert,
		Size = UDim2.fromScale(0.125,0.8),
		Image = (image ~= nil and image or "http://www.roblox.com/asset/?id=6641087361"),
		BackgroundTransparency = 1
	})
	local label = lib.GetTextLabel({
		Parent = alert,
		Size = UDim2.fromScale(0.86,0.8),
		Position = UDim2.fromScale(0.123,0.057),
		BackgroundTransparency = 1,
		TextScaled = true,
		Text = text,
		TextColor3 = Color3.fromRGB(255,255,255),
		RichText = true
	})
	local bar = lib.GetFrame(false,{
		BorderSizePixel = 0,
		Parent = alert,
		Size = UDim2.fromScale(1,0.113),
		Position = UDim2.fromScale(0,0.887),
		BackgroundColor3 = (barColor ~= nil and barColor or Color3.fromRGB(0, 115, 255))
	})
	game:GetService("TweenService"):Create(alert,TweenInfo.new(0.2),{Size = UDim2.fromScale(0.75,0.08)}):Play()
	game:GetService("TweenService"):Create(bar,TweenInfo.new(removeTime),{Size = UDim2.fromScale(0,0.113)}):Play()
	task.spawn(function()
		task.wait(removeTime)
		game:GetService("TweenService"):Create(alert,TweenInfo.new(0.2),{Size = UDim2.fromScale(0.75,0)}):Play()
		task.wait(0.2)
		alert:Remove()
	end)
end

local notifySorter = lib.AddAutoSort(notifyFrame)
notifySorter.Padding = UDim.new(0.02)

local configPath = "MoonReborn/Configs/"..game.PlaceId..".json"
local configPath2 = "MoonReborn/Configs/"..game.PlaceId
if not isfile(configPath) then
	makefolder("MoonReborn")
	makefolder("MoonReborn/Configs/")
	writefile(configPath,game:GetService("HttpService"):JSONEncode(config))
end


local function saveConfig(a)
	task.spawn(function()
		if isfile(configPath) then
			delfile(configPath)
			task.wait(1)
		end

		writefile(configPath, game:GetService("HttpService"):JSONEncode(a))
		print("SAVING ATTEMPT")

		local success = false
		while not success do
			task.wait()

			if isfile(configPath) then
				local decodedConfig = game:GetService("HttpService"):JSONDecode(readfile(configPath))
				if decodedConfig and decodedConfig.Toggles and #decodedConfig.Toggles > 0 then
					success = true
				end
			end
		end

		print("SAVING SUCCESS")
	end)
end


local toggles = {

}

local function loadconfig()
	config = (game:GetService("HttpService"):JSONDecode(readfile(configPath)))
end

local arrayUI = Instance.new("ScreenGui",lplr.PlayerGui)
arrayUI.ResetOnSpawn = false
local arrayFrame = Instance.new("Frame",arrayUI)
arrayFrame.Size = UDim2.fromScale(0.163,1)
arrayFrame.Position = UDim2.fromScale(0.837,0)
arrayFrame.BackgroundTransparency = 1
local arrayLayout = Instance.new("UIListLayout",arrayFrame)
arrayLayout.SortOrder = Enum.SortOrder.LayoutOrder

local arrayModules = {}

print("lib ver 1.0.0")

local function arrayTask(a,m)
	if a then
		local label = Instance.new("TextLabel",arrayFrame)
		label.Text = m.."  "
		label.TextXAlignment = Enum.TextXAlignment.Right
		label.TextSize = 18.5
		label.BackgroundColor3 = Color3.fromRGB(0,0,0)
		label.TextColor3 = Color3.fromRGB(0,153,255)
		label.Size = UDim2.fromOffset(game:GetService("TextService"):GetTextSize(m.."   ",18.5,Enum.Font.Arial,Vector2.new(0,0)).X,game:GetService("TextService"):GetTextSize(m.."  ",18.5,Enum.Font.Arial,Vector2.new(0,0)).Y + 20)
		table.insert(arrayModules,label)
		table.sort(arrayModules,function(a,b)
			local aSize = ""
			if game:GetService("TextService"):GetTextSize(a,18.5,Enum.Font.Arial,Vector2.new(0,0)).X == game:GetService("TextService"):GetTextSize(b,18.5,Enum.Font.Arial,Vector2.new(0,0)).X then
				aSize = " "
			end
			return game:GetService("TextService"):GetTextSize(a..aSize,18.5,Enum.Font.Arial,Vector2.new(0,0)).X > game:GetService("TextService"):GetTextSize(b,18.5,Enum.Font.Arial,Vector2.new(0,0)).X
		end)
		for i,v in ipairs(arrayModules) do
			v.LayoutOrder = i
		end
	else
		for i,v in pairs(arrayModules) do
			if v.Text == m then
				table.remove(arrayModules,i)
				v:Remove()
			end
		end
	end
end

task.wait(1)
loadconfig()



local GuiLibrary = {
	MakeWindow = function(tab)
		local tabDragTween = {}
		local name = tab["Name"]
		local tabName = Instance.new("TextLabel", UI)
		tabName.Size = UDim2.fromScale(0.1, 0.046)
		tabName.Active = true
		tabName.Draggable = true
		tabName.Text = "  "..name
		tabName.TextColor3 = Color3.fromRGB(255,255,255)
		tabName.TextXAlignment = Enum.TextXAlignment.Left
		tabName.BorderSizePixel = 0
		tabName.TextSize = 16
		tabName.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		local dragging = false
		tabName.DragBegin:Connect(function()
			task.spawn(function()
				dragging = true
				tabName.Draggable = false
				repeat task.wait()
					for i,v in pairs(tabDragTween) do
						pcall(function()
							v:Cancel()
						end)
						table.remove(tabDragTween,i)
					end
					local tween = game:GetService("TweenService"):Create(tabName,TweenInfo.new(0.1),{Position = getMousePos()})
					table.insert(tabDragTween,tween)
					tween:Play()
				until not dragging
			end)
		end)
		tabName.DragStopped:Connect(function()
			task.spawn(function()
				dragging = false
				tabName.Draggable = true
				config["WindowPositions"][name] = {X = {Scale = tabName.Position.X.Scale,Offset = tabName.Position.X.Offset},Y = {Scale = tabName.Position.Y.Scale,Offset = tabName.Position.Y.Offset}}
				task.wait(0.05)
				saveConfig(config)
			end)
		end)
		local tabTimes = 0
		for i,v in pairs(tabs) do
			tabTimes += 1
		end
		tabName.Position = UDim2.fromScale(0.15 + (0.15 * tabTimes), 0.17)
		local frame = Instance.new("Frame", tabName)
		tabs[tab["Name"]] = frame
		frame.Name = name
		frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
		frame.BackgroundTransparency = 1
		frame.Size = UDim2.fromScale(1, 18)
		frame.BorderSizePixel = 0
		frame.Position = UDim2.fromScale(0, 1)
		local listlayout = Instance.new("UIListLayout", frame)
		listlayout.SortOrder = Enum.SortOrder.LayoutOrder
		print(not (config["WindowPositions"][name] == nil or config["WindowPositions"][name].X == nil or config["WindowPositions"][name].Y == nil))
		if config["WindowPositions"][name] == nil or config["WindowPositions"][name].X == nil or config["WindowPositions"][name].Y == nil then
			config["WindowPositions"][name] = {X = {Scale = tabName.Position.X.Scale,Offset = tabName.Position.X.Offset},Y = {Scale = tabName.Position.Y.Scale,Offset = tabName.Position.Y.Offset}}
		else
			tabName.Position = UDim2.fromScale(tonumber(config["WindowPositions"][name].X.Scale),tonumber(config["WindowPositions"][name].Y.Scale))
		end
	end,
	SendNotification = function(text,removeTime,image,barColor)
		lib:Notify(text,removeTime,image,barColor)
	end,
	MakeButton = function(tab)
		local name = tab["Name"]
		if config["Buttons"][tab["Name"]] == nil then
			config["Buttons"][tab["Name"]] = {
				Enabled = false,
				Keybind = Enum.KeyCode.RightShift,
				Dropdowns = {
					Toggles = {

					},
					Pickers = {

					}
				}
			}
		end
		local Window = tab["Window"]
		local btn = Instance.new("TextButton",tabs[Window])
		local funcs
		local colorBTN
		local toggleFrame = Instance.new("Frame",tabs[Window])
		toggleFrame.Visible = false
		toggleFrame.BackgroundColor3 = Color3.fromRGB(27,27,27)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Size = UDim2.fromScale(1,0.5)
		toggleFrame.ZIndex = 2
		local keybind = config["Buttons"][tab["Name"]].Keybind
		local toggleFrameLayout = Instance.new("UIListLayout",toggleFrame)
		toggleFrameLayout.SortOrder = Enum.SortOrder.LayoutOrder
		funcs = {
			ToggleButton = function(t)
				funcs.Enabled = t
				arrayTask(t,tab["Name"])
				if t then
					lib:Notify(tab["Name"].." Has Been Enabled!",1.6,"http://www.roblox.com/asset/?id=9405926389")
					tab["Function"](true)
					game:GetService("TweenService"):Create(btn,TweenInfo.new(0.3),{BackgroundColor3 = Color3.fromRGB(0, 102, 255)}):Play()
				else
					lib:Notify(tab["Name"].." Has Been Disabled!",1.6,"http://www.roblox.com/asset/?id=9405926389")
					tab["Function"](false)
					btn.BackgroundTransparency = 0
					game:GetService("TweenService"):Create(btn,TweenInfo.new(0.3),{BackgroundColor3 = Color3.fromRGB(27,27,27)}):Play()
				end
				task.wait(0.05)
				config["Buttons"][tab["Name"]] = {
					Enabled = t,
					Keybind = tostring(keybind),
					Dropdowns = {
						Toggles = toggles,
						Pickers = {

						}
					}
				}
				task.spawn(function()
					task.wait(0.05)
					saveConfig(config)
				end)
			end,
			Enabled = false,
			NewTextBox = function(tab)
				if config.TextBox[tab["Name"]:gsub(" ","_")] == nil then
					config.TextBox[tab["Name"]:gsub(" ","_")] = {Text = ""}
				else
					config.TextBox[tab["Name"]:gsub(" ","_")] = {Text = config.TextBox[tab["Name"]:gsub(" ","_")].Text}
				end

				local toggle
				local ToggleInst = Instance.new("TextBox",toggleFrame)
				toggle = {
					Value = "",
					SetValue = function(t)
						config.TextBox[tab["Name"]:gsub(" ","_")].Text = t
						ToggleInst.Text = t
						toggle.Value = t
						task.wait(0.06)
						saveConfig(config)
					end,
				}
				if toggles[tab["Name"]] == nil then
					toggles[tab["Name"]] = {Enabled = false}
				end
				ToggleInst.Size = UDim2.fromScale(1,0.09)
				ToggleInst.BackgroundColor3 = Color3.fromRGB(25,25,25)
				ToggleInst.BorderSizePixel = 0
				ToggleInst.TextXAlignment = Enum.TextXAlignment.Left
				ToggleInst.Text = "  "..tab["Name"]
				ToggleInst.ZIndex = 5
				ToggleInst.TextColor3 = Color3.fromRGB(255,255,255)
				ToggleInst.TextSize = 12
				if config.TextBox[tab["Name"]:gsub(" ","_")].Text then
					toggle.SetValue(config.TextBox[tab["Name"]:gsub(" ","_")].Text)
					ToggleInst.Text = "  "..tab["Name"].." : "..config.TextBox[tab["Name"]:gsub(" ","_")].Text
				end
				ToggleInst.FocusLost:Connect(function()
					config.TextBox[tab["Name"]:gsub(" ","_")].Text = ToggleInst.Text
					toggle.Value = ToggleInst.Text
					ToggleInst.Text = "  "..tab["Name"].." : "..config.TextBox[tab["Name"]:gsub(" ","_")].Text
					task.wait(0.06)
					saveConfig(config)
				end)
				return toggle
			end,
			NewToggle = function(tab)
				if config.Toggles[tab["Name"]:gsub(" ","_")] == nil then
					config.Toggles[tab["Name"]:gsub(" ","_")] = {Enabled = false}
				else
					config.Toggles[tab["Name"]:gsub(" ","_")] = {Enabled = config.Toggles[tab["Name"]:gsub(" ","_")].Enabled}
				end

				local toggle
				local ToggleInst = Instance.new("TextButton",toggleFrame)
				toggle = {
					Enabled = false,
					Toggle = function(t)
						toggle.Enabled = t
						if tab["Function"] ~= nil then
							tab["Function"](t)
						end
						if t then
							game:GetService("TweenService"):Create(ToggleInst,TweenInfo.new(0.3),{BackgroundColor3 = Color3.fromRGB(0, 102, 255)}):Play()
						else
							game:GetService("TweenService"):Create(ToggleInst,TweenInfo.new(0.3),{BackgroundColor3 = Color3.fromRGB(27,27,27)}):Play()
						end
					end,
				}
				if toggles[tab["Name"]] == nil then
					toggles[tab["Name"]] = {Enabled = false}
				end
				ToggleInst.Size = UDim2.fromScale(1,0.09)
				ToggleInst.BackgroundColor3 = Color3.fromRGB(25,25,25)
				ToggleInst.BorderSizePixel = 0
				ToggleInst.TextXAlignment = Enum.TextXAlignment.Left
				ToggleInst.Text = "  "..tab["Name"]
				ToggleInst.ZIndex = 5
				ToggleInst.TextColor3 = Color3.fromRGB(255,255,255)
				ToggleInst.TextSize = 12
				if config.Toggles[tab["Name"]:gsub(" ","_")].Enabled then
					toggle.Toggle(true)
				end
				ToggleInst.MouseButton1Down:Connect(function()
					local v = not toggle.Enabled
					toggle.Toggle(v)
					config.Toggles[tab["Name"]:gsub(" ","_")].Enabled = v
					task.wait(0.06)
					saveConfig(config)
				end)
				return toggle
			end,
			NewPicker = function(tab)
				if config.Pickers[tab["Name"]] == nil then
					print("TEST")
					config.Pickers[tab["Name"]] = {Option = tab["Options"][1]}
					task.wait(0.06)
					saveConfig(config)
				end

				local toggle
				local PickerInst = Instance.new("TextButton",toggleFrame)
				toggle = {
					Value = tab["Options"][1],
					SetValue = function(t)
						toggle.Value = tab["Options"][t]
						if tab["Function"] ~= nil then
							tab["Function"](tab["Options"][t])
						end
						PickerInst.Text = "  "..tab["Name"].." : "..tab["Options"][t]
					end,
				}
				PickerInst.Size = UDim2.fromScale(1,0.09)
				PickerInst.BackgroundColor3 = Color3.fromRGB(25,25,25)
				PickerInst.BorderSizePixel = 0
				PickerInst.TextXAlignment = Enum.TextXAlignment.Left
				PickerInst.Text = "  "..tab["Name"].." : "..tab["Options"][1]
				PickerInst.ZIndex = 5
				PickerInst.TextColor3 = Color3.fromRGB(255,255,255)
				PickerInst.TextSize = 12
				local tabIndex = 1
				for i,v in pairs(tab["Options"]) do
					if v == config.Pickers[tab["Name"]].Option then
						toggle.SetValue(i)
						tabIndex = i
					end
				end
				PickerInst.MouseButton1Down:Connect(function()
					tabIndex += 1
					if tabIndex > #tab["Options"] then
						tabIndex = 1
					end
					toggle.SetValue(tabIndex)
					config.Pickers[tab["Name"]] = {Option = tab["Options"][tabIndex]}
					task.wait(0.06)
					saveConfig(config)
				end)
				PickerInst.MouseButton2Down:Connect(function()
					tabIndex -= 1
					if tabIndex < 1 then
						tabIndex = #tab["Options"]
					end
					toggle.SetValue(tabIndex)
					config.Pickers[tab["Name"]] = {Option = tab["Options"][tabIndex]}
					task.wait(0.06)
					saveConfig(config)
				end)
				return toggle
			end,
		}
		btn.Size = UDim2.fromScale(1,0.05)
		btn.BackgroundColor3 = Color3.fromRGB(27,27,27)
		btn.TextSize = 10
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Text = "   "..name
		btn.BorderSizePixel = 0
		btn.ZIndex = 3
		btn.MouseButton1Down:Connect(function()
			funcs.Enabled = not funcs.Enabled
			funcs.ToggleButton(funcs.Enabled)
		end)


		local keybindInst = Instance.new("TextButton",toggleFrame)
		keybindInst.Size = UDim2.fromScale(1,0.09)
		keybindInst.BackgroundColor3 = Color3.fromRGB(25,25,25)
		keybindInst.BorderSizePixel = 0
		keybindInst.TextXAlignment = Enum.TextXAlignment.Left
		keybindInst.Text = "  Keybind : "..tostring(keybind):sub(tostring(keybind):len(),tostring(keybind):len()):upper()
		if keybind == Enum.KeyCode.RightShift then
			keybindInst.Text = "  Keybind : "
		end
		keybindInst.ZIndex = 5
		keybindInst.TextColor3 = Color3.fromRGB(255,255,255)
		keybindInst.TextSize = 12

		local keybindConnection
		keybindInst.MouseButton1Down:Connect(function()
			keybindInst.Text = "  Press Any Key.."
			keybindConnection = game:GetService("UserInputService").InputBegan:Connect(function(key, gpe)
				if gpe then return end
				if key.KeyCode == Enum.KeyCode.Delete or key.KeyCode == Enum.KeyCode.W or key.KeyCode == Enum.KeyCode.S or key.KeyCode == Enum.KeyCode.A or key.KeyCode == Enum.KeyCode.D or key.UserInputType == Enum.UserInputType.MouseButton1 or key.UserInputType == Enum.UserInputType.MouseButton2 then return end
				pcall(function()
					keybindConnection:Disconnect()
				end)
				task.wait(0.07)
				keybind = key.KeyCode
				keybindInst.Text = "  Keybind : "..tostring(keybind):sub(tostring(keybind):len(),tostring(keybind):len()):upper()
				config["Buttons"][tab["Name"]] = {
					Enabled = config["Buttons"][tab["Name"]].Enabled,
					Keybind = tostring(keybind),
					Dropdowns = {
						Toggles = {

						},
						Pickers = {

						}
					}
				}
				task.spawn(function()
					task.wait(0.05)
					saveConfig(config)
				end)
			end)
		end)
		btn.MouseButton2Down:Connect(function()
			toggleFrame.Visible = not toggleFrame.Visible
			if toggleFrame.Visible then
				toggleFrame.Size = UDim2.fromScale(1,0)
				game:GetService("TweenService"):Create(toggleFrame,TweenInfo.new(0.2),{Size = UDim2.fromScale(1,0.5)}):Play()
			else
				toggleFrame.Visible = not toggleFrame.Visible
				game:GetService("TweenService"):Create(toggleFrame,TweenInfo.new(0.2),{Size = UDim2.fromScale(1,0)}):Play()
				toggleFrame.Visible = not toggleFrame.Visible
			end
			toggleFrame.LayoutOrder = btn.LayoutOrder + 1
		end)

		game:GetService("UserInputService").InputBegan:Connect(function(key, gpe)
			if gpe then return end
			if key.KeyCode == Enum.KeyCode[tostring(keybind):sub(tostring(keybind):len(),tostring(keybind):len())] then
				funcs.Enabled = not funcs.Enabled
				funcs.ToggleButton(funcs.Enabled)
			end
		end)

		pcall(function()
			if config["Buttons"][tab["Name"]] ~= nil then
				if config["Buttons"][tab["Name"]].Enabled then
					funcs.ToggleButton(true)
				end
			end
		end)
		return funcs
	end,
	tabs = function()
		return #tabs
	end,
}

game:GetService("UserInputService").InputBegan:Connect(function(key,gpe)
	if gpe then return end
	if key.KeyCode == Enum.KeyCode.Delete then
		for i,v in pairs(UI:GetDescendants()) do
			pcall(function()
				v.Visible = not v.Visible
			end)
		end
	end
end)

GuiLibrary.MakeWindow({["Name"]="Combat"})
GuiLibrary.MakeWindow({["Name"]="Movement"})
GuiLibrary.MakeWindow({["Name"]="Visuals"})
GuiLibrary.MakeWindow({["Name"]="Utility"})
GuiLibrary.MakeWindow({["Name"]="Scripts"})

GuiLibrary.SendNotification("Moon Loaded!",10)
return GuiLibrary
