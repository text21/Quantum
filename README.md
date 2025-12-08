# Quantum

> **Quantum** is a spring-driven tween engine for Roblox that unifies **UI animation**, **camera & movement feel**, and **lightweight physics-style behaviours** under one clean API.

- Spring-based instead of step tweens – everything eases, overshoots, and settles.
- Works with **UI, parts, cameras, and custom values**.
- Includes higher-level **relationship systems** (Orbit, Chain, Follow, RagdollUI).
- Shipping with real usage examples: **selector arrows**, **grapple hooks**, etc.
- Backwards-friendly with a **TweenService-like shim** for a drop-in feel.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
  - [Option A – RBXM (drag & drop)](#option-a--rbxm-drag--drop)
  - [Option B – Rojo + Wally project](#option-b--rojo--wally-project)
- [Folder Layout](#folder-layout)
- [Quickstart](#quickstart)
  - [Hello Spring (ValueSpring)](#hello-spring-valuespring)
  - [Tween a Property](#tween-a-property)
- [UI Examples](#ui-examples)
  - [Spring Buttons (hover, press, hold)](#spring-buttons-hover-press-hold)
  - [Arrow Selector Bar](#arrow-selector-bar)
  - [Panel Open/Close](#panel-openclose)
- [Physics Examples](#physics-examples)
  - [Simple Grapple Pull](#simple-grapple-pull)
- [Relationship Systems](#relationship-systems)
- [API Overview](#api-overview)
- [Design Philosophy](#design-philosophy)
- [License](#license)

---

## Showcase

### Arrow Selection

https://gyazo.com/0dc86c6a645ebc3b6fe3bc98288a8269

---

## Features

### Core Engine

- **SpringMotor / ValueSpring**

  - N-dimensional spring integrators.
  - Drive **numbers, Vector2/3, CFrame** or custom value types.
  - Per-spring **stiffness / damping** or named profiles.

- **Engine / Scheduler**

  - Single heartbeat loop that steps all active springs.
  - **TimeScale**, pausing, and debug stepping.

- **PropertyBinder**
  - Bridges Roblox properties ⇄ numeric/struct value representation.
  - Lets you drive `Position`, `Size`, `BackgroundColor3`, etc. with the same spring API.

### Relationships

Higher-level systems built on springs:

- `Quantum.Relationship.Orbit`
  - Orbit multiple instances around a center (UI or world) with springy positioning.
- `Quantum.Relationship.Chain`
  - Lagging chains (tabs, trails, rope-like lists of objects).
- `Quantum.Relationship.Follow`
  - Smooth follow towards a moving target (mouse, part, camera).
- `Quantum.Relationship.RagdollUI`
  - 2D “soft body” behaviour for UI chips / tags that bounce inside a frame.

### Compatibility

- `Quantum.Compat.TweenService`
  - TweenService-like shim:
    - `Quantum.TweenService:Create(instance, info, goalTable)`
    - Under the hood: uses springs instead of step tweens.
  - Lets you migrate existing TweenService code without rewriting everything at once.

### Examples Included

- **Arrow Selector Bar**

  - A shared arrow that lerps between buttons with a spring.
  - Buttons changing gradient colors via ValueSpring.

- **Grapple Hook**

  - Hook to the wall

---

## Installation

Quantum is designed to be painless to drop into any project.

### Option A – RBXM (drag & drop)

1. Download the **`Quantum.rbxm`** file.
2. In Roblox Studio, **drag the RBXM into the Explorer**.
3. Place the contents as:

   - `ReplicatedStorage/Quantum` (main module)
   - `ReplicatedStorage/Packages` (dependencies if included)

4. Require it anywhere:

   ```lua
   local ReplicatedStorage = game:GetService("ReplicatedStorage")
   local Quantum = require(ReplicatedStorage:WaitForChild("Quantum"))
   ```

> This is the recommended option for most developers.

---

### Option B – Rojo + Wally project

If you prefer source control and package management:

1. Clone / download the project folder.
2. Open a terminal in the project root and install dependencies with **Wally**:

   ```bash
   wally install
   ```

3. Build or sync with **Rojo**:

   ```bash
   rojo build default.project.json -o Quantum.rbxm
   -- or
   rojo serve default.project.json
   ```

4. Ensure your `default.project.json` maps Quantum into `ReplicatedStorage`:

   ```json
   {
     "name": "quantum",
     "tree": {
       "$className": "DataModel",
       "ReplicatedStorage": {
         "Quantum": {
           "$path": "src"
         },
         "Packages": {
           "$path": "Packages"
         }
       }
     }
   }
   ```

5. Require as usual:

   ```lua
   local Quantum = require(game:GetService("ReplicatedStorage").Quantum)
   ```

---

## Folder Layout

```text
src
├── init.lua                 -- main entry, returns Quantum table
├── Engine
│   ├── Engine.lua           -- central spring registry / ticking
│   ├── Scheduler.lua        -- RunService binding, TimeScale, pause
│   ├── SpringMotor.lua      -- N-dimensional spring integrator
│   ├── ValueMotor.lua       -- scalar / abstract values
│   └── PropertyBinder.lua   -- map properties <-> numeric reps
├── Relationships
│   ├── Orbit.lua            -- orbit system
│   ├── Chain.lua            -- chained motion
│   ├── Follow.lua           -- follow / easing towards target
│   └── RagdollUI.lua        -- 2D ragdoll-ish UI behaviour
├── Compat
│   └── TweenService.lua     -- TweenService-like shim
├── Util
│   ├── Types.lua            -- type aliases
│   ├── MathUtils.lua        -- lerp helpers, clamps, vector ops
│   └── SpringConfig.lua     -- presets (Snappy, Soft, Bouncy...)
└── Profiles
    └── Presets.lua          -- named motion profiles (UI, Camera…)
```

---

## Quickstart

### Hello Spring (ValueSpring)

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quantum = require(ReplicatedStorage:WaitForChild("Quantum"))

-- Spring a number from 0 → 1 with a bit of bounce:
local motor = Quantum.ValueSpring(0, {
    stiffness = 20,
    damping = 3,
    onStep = function(value)
        print("Current value:", value)
    end,
})

motor:SetTarget(1)
```

### Tween a Property

```lua
local frame = script.Parent:WaitForChild("Frame")

Quantum.Spring(frame, "Position", {
    target = UDim2.new(0.5, 0, 0.5, 0),
    stiffness = 18,
    damping = 2.8,
})

-- or with a profile:
Quantum.Spring(frame, "Size", {
    target = UDim2.fromScale(0.6, 0.6),
    profile = "Snappy", -- defined in Profiles/Presets.lua
})
```

---

## UI Examples

### Spring Buttons (hover, press, hold)

Quantum plays very well with `UIScale` + background color:

```lua
local button = script.Parent
local Quantum = require(game.ReplicatedStorage.Quantum)

local uiScale = button:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", button)
uiScale.Scale = 0.96

local baseColor = button.BackgroundColor3
local hoverColor = baseColor:Lerp(Color3.new(1, 1, 1), 0.18)
local pressColor = Color3.new(baseColor.R * 0.8, baseColor.G * 0.8, baseColor.B * 0.8)

local scaleMotor = Quantum.ValueSpring(0, {
    stiffness = 36,
    damping = 4,
    onStep = function(v)
        uiScale.Scale = 0.96 + 0.08 * v
    end,
})

local colorMotor = Quantum.ValueSpring(baseColor, {
    stiffness = 18,
    damping = 3,
    onStep = function(c)
        button.BackgroundColor3 = c
    end,
})

local function idle()
    scaleMotor:SetTarget(0)
    colorMotor:SetTarget(baseColor)
end

local function hover()
    scaleMotor:SetTarget(1)
    colorMotor:SetTarget(hoverColor)
end

local function press()
    scaleMotor:SetTarget(-0.35)
    colorMotor:SetTarget(pressColor)
end

button.MouseEnter:Connect(hover)
button.MouseLeave:Connect(idle)
button.MouseButton1Down:Connect(press)
button.MouseButton1Up:Connect(hover)

idle()
```

---

### Arrow Selector Bar

This powers a tab-style selector with a shared arrow that springs between buttons:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Quantum = require(ReplicatedStorage:WaitForChild("Quantum"))

local buttonsFrame = script.Parent
local arrow = buttonsFrame:WaitForChild("ArrowSelect")

local buttons = {}
for _, child in ipairs(buttonsFrame:GetChildren()) do
    if child:IsA("TextButton") then
        table.insert(buttons, child)
    end
end
table.sort(buttons, function(a, b)
    return a.LayoutOrder < b.LayoutOrder
end)

local ACTIVE_TOP = Color3.fromRGB(0, 61, 99)
local ACTIVE_BOTTOM = Color3.fromRGB(0, 27, 44)
local INACTIVE_TOP = Color3.fromRGB(41, 41, 41)
local INACTIVE_BOTTOM = Color3.fromRGB(24, 25, 29)

local MOVE_SPRING = { stiffness = 38, damping = 5.6 }
local COLOR_SPRING = { stiffness = 24, damping = 3.6 }

arrow.AnchorPoint = Vector2.new(0.5, 0)
local arrowScale = arrow:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", arrow)
arrowScale.Scale = 1

local function ensureGradient(button)
    local grad = button:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Rotation = 90
        grad.Color = ColorSequence.new(INACTIVE_TOP, INACTIVE_BOTTOM)
        grad.Parent = button
    end
    return grad
end
for _, btn in ipairs(buttons) do
    ensureGradient(btn)
end

local function lerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local buttonMotors = {}
local selected

local function setButtonState(button, active)
    if buttonMotors[button] then
        buttonMotors[button]:Stop()
    end

    local grad = ensureGradient(button)
    local current = grad.Color.Keypoints
    local fromTop = current[1].Value
    local fromBottom = current[#current].Value
    local toTop = active and ACTIVE_TOP or INACTIVE_TOP
    local toBottom = active and ACTIVE_BOTTOM or INACTIVE_BOTTOM

    local motor = Quantum.ValueSpring(0, {
        stiffness = COLOR_SPRING.stiffness,
        damping = COLOR_SPRING.damping,
        onStep = function(a)
            local top = lerpColor(fromTop, toTop, a)
            local bottom = lerpColor(fromBottom, toBottom, a)
            grad.Color = ColorSequence.new(top, bottom)
        end,
    })
    buttonMotors[button] = motor
    motor:SetTarget(1)
end

local function getArrowTargetForButton(btn)
    local parent = buttonsFrame
    local parentAbsPos = parent.AbsolutePosition
    local parentSize = parent.AbsoluteSize
    local btnAbsPos = btn.AbsolutePosition
    local btnSize = btn.AbsoluteSize

    local centerX = (btnAbsPos.X - parentAbsPos.X) + btnSize.X / 2
    local bottomY = (btnAbsPos.Y - parentAbsPos.Y) + btnSize.Y

    local xScale = centerX / parentSize.X
    local yScale = (bottomY + 4) / parentSize.Y
    return xScale, yScale
end

local arrowMotorX = Quantum.ValueSpring(arrow.Position.X.Scale, {
    stiffness = MOVE_SPRING.stiffness,
    damping = MOVE_SPRING.damping,
    onStep = function(x)
        arrow.Position = UDim2.new(x, 0, arrow.Position.Y.Scale, 0)
    end,
})
local arrowMotorY = Quantum.ValueSpring(arrow.Position.Y.Scale, {
    stiffness = MOVE_SPRING.stiffness,
    damping = MOVE_SPRING.damping,
    onStep = function(y)
        arrow.Position = UDim2.new(arrow.Position.X.Scale, 0, y, 0)
    end,
})

local function pulseArrow()
    local motor = Quantum.ValueSpring(1, {
        stiffness = 40,
        damping = 5,
        onStep = function(v)
            arrowScale.Scale = v
        end,
    })
    motor:SetTarget(1.3)
    task.delay(0.08, function()
        motor:SetTarget(1)
    end)
end

local function selectButton(btn)
    if selected == btn then
        return
    end
    if selected then
        setButtonState(selected, false)
    end
    selected = btn
    setButtonState(btn, true)

    local x, y = getArrowTargetForButton(btn)
    arrowMotorX:SetTarget(x)
    arrowMotorY:SetTarget(y)
    pulseArrow()
end

for _, btn in ipairs(buttons) do
    btn.MouseButton1Click:Connect(function()
        selectButton(btn)
    end)
end

if buttons[1] then
    selectButton(buttons[1])
end
```

---

### Panel Open/Close

Open:

```lua
local panel = mainFrame:WaitForChild("BG")

local function slideIn(gui)
    local originalPos = gui.Position
    local startPos = originalPos + UDim2.new(0, 0, 0.06, 36)
    local endPos = originalPos + UDim2.new(0, 0, -0.015, -12)

    gui.Position = startPos
    local originalTransparency = gui.BackgroundTransparency
    gui.BackgroundTransparency = 1

    local motor = Quantum.ValueSpring(0, {
        stiffness = 26,
        damping = 3.2,
        onStep = function(a)
            gui.Position = startPos:Lerp(endPos, a)
            gui.BackgroundTransparency = 1 - (1 - originalTransparency) * a
        end,
    })

    motor:SetTarget(1)
end
```

Close:

```lua
local isClosing = false

local function closeWithTween(gui)
    if isClosing then return end
    isClosing = true

    local uiScale = gui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", gui)
    uiScale.Scale = 1

    local startPos = gui.Position
    local endPos = startPos + UDim2.new(0, 0, 0.35, 80)
    local startTransparency = gui.BackgroundTransparency

    local motor = Quantum.ValueSpring(0, {
        stiffness = 26,
        damping = 3.2,
        onStep = function(a)
            gui.Position = startPos:Lerp(endPos, a)
            uiScale.Scale = 1 - 0.25 * a
            gui.BackgroundTransparency = startTransparency + (1 - startTransparency) * a
        end,
    })

    motor:SetTarget(1)
    motor:OnComplete(function()
        gui.Parent.Parent:Destroy() -- e.g. destroy entire ScreenGui
    end)
end
```

---

## Physics Examples

### Simple Grapple Pull

```lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Quantum = require(ReplicatedStorage:WaitForChild("Quantum"))

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { character }

local function fireGrapple()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local origin = camera.CFrame.Position
	local dir = (mouse.Hit.Position - origin).Unit * 200
	local result = Workspace:Raycast(origin, dir, rayParams)
	if not result then return end

	local hitPos = result.Position
	local startPos = hrp.Position
	local direction = (hitPos - startPos)
	local unitDir = direction.Unit

	local motor = Quantum.ValueSpring(0, {
		stiffness = 20,
		damping = 3,
		onStep = function(alpha)
			alpha = math.clamp(alpha, 0, 1.1)
			local pos = startPos:Lerp(hitPos + unitDir * 2, alpha)
			hrp.CFrame = CFrame.new(pos, pos + unitDir)
		end,
	})

	motor:SetTarget(1.1)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Q then
		fireGrapple()
	end
end)
```

---

## Relationship Systems

API shape (simplified):

```lua
-- Orbit
local handle = Quantum.Relationship.Orbit({
    center = someInstance,      -- UIElement or Part
    items = { icon1, icon2, icon3 },
    radius = 70,
    angularSpeed = math.rad(40),
    layout = "even",            -- or "fan"
    spring = {
        stiffness = 20,
        damping = 2.5,
    },
})

handle:Pause()
handle:Resume()
handle:Destroy()

-- Chain
Quantum.Relationship.Chain({
    nodes = { tab1, tab2, tab3, tab4 },
    property = "Position",      -- or "CFrame"
    stiffness = 18,
    damping = 2.4,
    tailDrag = 0.7,
})

-- Follow
Quantum.Relationship.Follow({
    effector = cursorFrame,     -- or Part
    target = "Mouse",           -- or a Part / Vector3
    stiffness = 22,
    damping = 2.8,
})

-- RagdollUI
Quantum.Relationship.RagdollUI({
    nodes = {
        { object = chip1, mass = 1 },
        { object = chip2, mass = 1 },
    },
    bounds = someFrame,
    gravity = Vector2.new(0, 1800),
    stiffness = 20,
    damping = 5,
    bounce = 0.4,
})
```

---

## API Overview

**Core**

- `Quantum.ValueSpring(initialValue, configTable)`

  - `stiffness: number`
  - `damping: number`
  - `onStep: (value) -> ()`
  - `onComplete: (() -> ())?`
  - Methods: `SetTarget(value)`, `SetConfig(configTable)`, `Stop()`, `OnComplete(callback)`

- `Quantum.Spring(instance, propertyName, paramsTable)`
  - `target: any`
  - `stiffness/damping` or `profile`
  - Optional `onStep` if you want extra hooks.

**Relationships**

- `Quantum.Relationship.Orbit(opts)`
- `Quantum.Relationship.Chain(opts)`
- `Quantum.Relationship.Follow(opts)`
- `Quantum.Relationship.RagdollUI(opts)`

**Compatibility**

- `Quantum.TweenService:Create(instance, tweenInfo, goalTable)`
- `Quantum.TweenService:Play(tweenHandle)`

**Profiles / Presets**

- `Quantum.Profiles:Get(name)` → `{ stiffness, damping }`
- Example names:
  - `"UI.Snappy"`, `"UI.Soft"`, `"Camera.Recoil.Small"`, `"Physics.Bungee"` (configurable in `Profiles/Presets.lua`).

---

## Design Philosophy

- **Feel over math**
  Stiffness and damping are exposed, but you’re encouraged to use **named profiles** and helper APIs instead of hand-tuning everything.

- **UI + Gameplay, not just one**
  The same engine powers:

  - UI cards and buttons.
  - Cameras, grapples, dashes, and small world props.

- **Batteries included, not batteries required**
  You can drop in just the bits you want:
  - Use it as “TweenService with better feel”.
  - Or lean into Relationships and Movement helpers for more advanced systems.

---

## License

Quantum is distributed under the **MSI License**.

See `LICENSE` in the repository / project for the full license text.
