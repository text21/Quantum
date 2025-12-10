# Quantum - Changelog

All notable changes to **Quantum Tween Engine** will be documented in this file.

---

## [0.2.0] - 2025-12-10

### Added

- **Sequence engine (`Engine/Sequence.lua`)**

  - Timeline-style animation builder:
    - `Sequence.new(name?)`
    - `:Spring(instance, property, opts)`
    - `:Wait(seconds)`
    - `:Call(callback)`
  - Integrates with `Quantum.ValueSpring` and `Quantum.Presets` so you can build multi-step animations (pop → wait → settle) without manual `task.delay` chains.

- **Track system (`Engine/Track.lua`)**

  - Per-instance animation channels that handle cancelling previous sequences:
    - `Quantum.Track.forInstance(instance, "TrackName")`
    - `track:Play(sequence)`
    - `track:Stop()`
    - `track:IsPlaying()`
  - Perfect for UI states (hover/press/release), movement overrides, and camera transitions.

- **Motion presets (`Profiles/Presets.lua`)**

  - Expanded, named profiles so devs don’t have to think about raw stiffness/damping:
    - `UI.Soft`, `UI.Snappy`, `UI.Punchy`, `UI.Tooltip`, `UI.Elastic`, `UI.Bouncy`
    - `Camera.FollowSoft`, `Camera.FollowSnappy`, `Camera.RecoilSmall`, `Camera.RecoilBig`, `Camera.ShakeShort`
    - `Physics.Bungee`, `Physics.Heavy`, `Physics.Floaty`, `Physics.RagdollLight`, `Physics.RagdollHeavy`
  - `Quantum.Presets.Get("UI.Snappy")` and `profile = "UI.Snappy"` support in springs and sequences.

- **Patterns library (`Profiles/Patterns.lua`)**

  - Pre-built “wow” motions built on top of `Sequence`:
    - `Patterns.RewardPop(target, opts?)` – big reward pop then soft settle.
    - `Patterns.AttentionPulse(target, opts?)` – subtle idle pulse.
    - `Patterns.ErrorShake(target, opts?)` – horizontal shake for validation errors.
    - `Patterns.RecoilKick(camera, opts?)` – CFrame-based camera recoil (kick then recover).
    - `Patterns.ImpactSquash(target, opts?)` – squash → overshoot → settle for clicks/impacts.
  - All exposed via `Quantum.Patterns`.

- **Baseline helper (`Util/Baseline.lua`)**

  - Captures and remembers “rest” state of instances (Size, Position, etc.):
    - `Quantum.Baseline.Capture(instance, { "Size", "Position" })`
    - `Quantum.Baseline.Get(instance, "Size")`
  - Used to make UI button interactions animate relative to a stable base (no jitter or drift).

- **Showcase button behaviour**
  - Example `ImageButton` script using:
    - Baseline capture
    - Sequence + Track
    - Smooth states:
      - Hover → slight grow
      - Press/hold → compress
      - Release on button → overshoot + bounce back to idle
      - Release off button / leave → clean return to idle
- Link: https://gyazo.com/25a22b73d3f718a16964bf0e324c61e0

### Fixed / Improved

- **Safe value scaling in Patterns**

  - Added `scaleValue` helper to correctly scale `UDim2`, `Vector2`, `Vector3`, and numbers.
  - Fixed `attempt to perform arithmetic (mul) on UDim2 and number` errors in early `RewardPop` implementation.

- **Smoother state transitions**

  - Cleaned up hover/press/release logic to avoid competing animations (no more “laggy” feel when releasing or leaving while pressed).
  - All button tweens now blend from **current** value back to **captured baseline**.

- **Example LocalScript**

```Lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Quantum = require(ReplicatedStorage.Quantum)
local ImageButton = script.Parent.ImageButton

local track = Quantum.Track.forInstance(ImageButton, "Button")

Quantum.Baseline.Capture(ImageButton, { "Size" })
local BASE_SIZE = Quantum.Baseline.Get(ImageButton, "Size") or ImageButton.Size

local isHovering = false
local isPressed = false

local function mulUDim2(u, f)
	return UDim2.new(
		u.X.Scale * f,
		u.X.Offset * f,
		u.Y.Scale * f,
		u.Y.Offset * f
	)
end

local function playSize(fromSize, toSize, profile, name)
	local seq = Quantum.Sequence.new(name or "SizeTo")
		:Spring(ImageButton, "Size", {
			from = fromSize,
			target = toSize,
			profile = profile or "UI.Soft",
		})

	track:Play(seq)
end

local function goIdle()
	playSize(ImageButton.Size, BASE_SIZE, "UI.Soft", "Idle")
end

local function hoverIn()
	if isPressed then
		return
	end
	local hoverSize = mulUDim2(BASE_SIZE, 1.05)
	playSize(ImageButton.Size, hoverSize, "UI.Snappy", "HoverIn")
end

local function hoverOut()
	if not isPressed then
		goIdle()
	end
end

local function pressDown()
	isPressed = true
	local pressedSize = mulUDim2(BASE_SIZE, 0.9)
	playSize(ImageButton.Size, pressedSize, "UI.Punchy", "Press")
end

local function release()
	if not isPressed then
		return
	end

	isPressed = false

	if isHovering then
		local overshoot = mulUDim2(BASE_SIZE, 1.08)

		local seq = Quantum.Sequence.new("ReleaseBounce")
			:Spring(ImageButton, "Size", {
				from = ImageButton.Size,
				target = overshoot,
				profile = "UI.Punchy",
			})
			:Spring(ImageButton, "Size", {
				from = overshoot,
				target = BASE_SIZE,
				profile = "UI.Soft",
			})

		track:Play(seq)
	else
		goIdle()
	end
end

ImageButton.MouseEnter:Connect(function()
	isHovering = true
	hoverIn()
end)

ImageButton.MouseLeave:Connect(function()
	isHovering = false
	hoverOut()
end)

ImageButton.MouseButton1Down:Connect(pressDown)
ImageButton.MouseButton1Up:Connect(release)

ImageButton.Size = BASE_SIZE
```

---
