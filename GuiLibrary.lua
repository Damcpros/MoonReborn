local lplr = game.Players.LocalPlayer
local UI = Instance.new("ScreenGui",lplr.PlayerGui)
UI.ResetOnSpawn = false

local canDoStuff = true

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

local configPath = "MoonReborn/Configs/"..game.PlaceId..".json"
local configPath2 = "MoonReborn/Configs/"..game.PlaceId
if not isfile(configPath) or not isfile("MoonReborn/Configs/") then
	makefolder("MoonReborn")
	makefolder("MoonReborn/Configs/")
	writefile(configPath,game:GetService("HttpService"):JSONEncode(config))
end


local function saveConfig()
	task.spawn(function()
		if isfile(configPath) then
			delfile(configPath)
		end
		task.wait(1)
		writefile(configPath,game:GetService("HttpService"):JSONEncode(config))
	end)
end

local toggles = {

}

local toggleFunctions = {}

local function loadconfig()
	config = (game:GetService("HttpService"):JSONDecode(readfile(configPath)))
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
				saveConfig()
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

		funcs = {
			ToggleButton = function(t)
				funcs.Enabled = t
				if t then
					tab["Function"](true)
					game:GetService("TweenService"):Create(btn,TweenInfo.new(0.3),{BackgroundColor3 = Color3.fromRGB(0, 102, 255)}):Play()
				else
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
					saveConfig()
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
						saveConfig()
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
					if canDoStuff then
						config.TextBox[tab["Name"]:gsub(" ","_")].Text = ToggleInst.Text
						toggle.Value = ToggleInst.Text
						ToggleInst.Text = "  "..tab["Name"].." : "..config.TextBox[tab["Name"]:gsub(" ","_")].Text
						task.wait(0.06)
						saveConfig()
					end
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
					saveConfig()
				end)
				return toggle
			end,
			NewPicker = function(tab)
				if config.Pickers[tab["Name"]] == nil then
					print("TEST")
					config.Pickers[tab["Name"]] = {Option = tab["Options"][1]}
					task.wait(0.06)
					saveConfig()
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
					saveConfig()
				end)
				PickerInst.MouseButton2Down:Connect(function()
					tabIndex -= 1
					if tabIndex < 1 then
						tabIndex = #tab["Options"]
					end
					toggle.SetValue(tabIndex)
					config.Pickers[tab["Name"]] = {Option = tab["Options"][tabIndex]}
					task.wait(0.06)
					saveConfig()
				end)
				return toggle
			end,
		}
		table.insert(toggleFunctions,funcs)
		btn.Size = UDim2.fromScale(1,0.05)
		btn.BackgroundColor3 = Color3.fromRGB(27,27,27)
		btn.TextSize = 10
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Text = "   "..name
		btn.BorderSizePixel = 0
		btn.ZIndex = 3
		btn.MouseButton1Down:Connect(function()
			if canDoStuff then
				funcs.Enabled = not funcs.Enabled
				funcs.ToggleButton(funcs.Enabled)
			end
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
			if canDoStuff then
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
						saveConfig()
					end)
				end)
			end
		end)
		btn.MouseButton2Down:Connect(function()
			if canDoStuff then
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
			end
		end)

		game:GetService("UserInputService").InputBegan:Connect(function(key, gpe)
			if gpe then return end
			if key.KeyCode == Enum.KeyCode[tostring(keybind):sub(tostring(keybind):len(),tostring(keybind):len())] then
				funcs.Enabled = not funcs.Enabled
				funcs.ToggleButton(funcs.Enabled)
			end
		end)

		pcall(function()
			funcs.ToggleButton(config["Buttons"][tab["Name"]].Enabled)
		end)
		return funcs
	end,
	tabs = function()
		return #tabs
	end,
	Uninject = function()
		canDoStuff = false
		task.wait(1)
		for i,v in pairs(toggleFunctions) do
			if v.Enabled then
				v.ToggleButton(false)
			end
		end
		UI:Remove()
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

return GuiLibrary
