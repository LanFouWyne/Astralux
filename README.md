# 🌟 Astralux - PetaPeta Script
---

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Detailed Usage](#-usage)
- [Stage Guides](#-stage-guides)
- [Configuration](#-configuration)
- [FAQ](#-faq)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🎯 Main Features

- **ESP System** - Highlight all important items
  - 👻 Enemy ESP (Red)
  - 📦 Box ESP (Green)
  - 🔐 Safe ESP (Yellow)
  - 🎎 Doll ESP (Multiple colors)
  - 🔑 Key ESP (Gold)
  - 📄 Hint Paper ESP (Cyan)

### 🚀 Auto Complete Features

- **Stage 1 Auto** - Complete stage 1 automatically
- **Stage 2/3 Auto** - Unlock safe and get ofuda
- **Stage 4 Auto** - Set all dolls automatically
- **Stage 5 Auto** - Complete dial puzzle
- **Stage 6 Teleport** - Jump to finish line

### ⚡ Quality of Life

- **Speed Slider** (16-100) - Adjust walk speed
- **Proximity Bypass** - Instant interactions
- **Dynamic Enemy Follow** - Auto follow enemy
- **Enemy to Ofuda** - Teleport enemy to ofuda
- **Teleport Options** - Quick travel to items

---

## 📥 Installation

### Method 1: Direct Load (Recommended)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/LanFouWyne/Astralux/main/petapeta.lua"))()
```

### Method 2: Manual Load

1. Download `petapeta.lua` from this repository
2. Copy the entire script content
3. Paste into your executor
4. Execute the script

### Requirements

- ✅ A working Roblox executor
- ✅ Pet-a-Pet game open
- ✅ Stable internet connection

---

## 🎮 Quick Start

1. **Load the script** using one of the methods above
2. **Enable ESP** to see all items
3. **Adjust speed** if needed (default: 16)
4. **Use auto-complete** buttons for each stage
5. **Enjoy** the game!

---

## 📖 Usage

### ESP System

Toggle ESP to highlight important objects in the game:

```
Enable All ESP → Toggle ON/OFF
```

**ESP Color Guide:**
| Item | Color | Description |
|------|-------|-------------|
| Enemy | Red | Main enemy entity |
| Box | Green | Item boxes |
| Safe | Yellow | Vault safes |
| Doll Black | Dark Blue | Black head doll |
| Doll Blue | Blue | Blue doll |
| Doll Red | Red | Red doll |
| Doll Yellow | Yellow | Yellow doll |
| Doll White | White | White doll |
| Key | Gold | Important keys |
| Hint Paper | Cyan | Puzzle hints |

### Speed Control

Adjust your character's movement speed:

```
Walk Speed Slider: 16 → 100
```

- Persists through respawns
- Works while hiding or sprinting
- Default: 16 (normal speed)

### Proximity Bypass

Skip hold duration on proximity prompts:

```
Bypass ProximityPrompt → Toggle ON
```

⚠️ **Note:** This makes all interactions instant

### Dynamic Enemy Follow

Automatically follow and position yourself in front of the enemy:

```
Dynamic Enemy Follow → Toggle ON
```

- Maintains 10 studs distance
- Always faces the enemy
- Stops near ofuda box (safety feature)

### Enemy to Ofuda

Teleport the enemy directly to your ofuda location:

```
Teleport Enemy to Ofuda → Toggle ON
```

⚠️ **Warning:** Use carefully, may affect game mechanics

---

## 🎯 Stage Guides

### Stage 1: Key & Ofuda

**Auto Complete Button:** `Auto Complete Stage 1`

**Manual Steps:**
1. Enable ESP to locate key
2. Teleport to key
3. Pick up key and equip (slot 1)
4. Go to ofuda box
5. Open box with key
6. Take ofuda and equip
7. Approach enemy

**Script Actions:**
- ✅ Finds key automatically
- ✅ Teleports to key
- ✅ Takes and equips key
- ✅ Opens ofuda box
- ✅ Takes and equips ofuda

---

### Stage 2/3: Safe & Ofuda

**Auto Complete Button:** `Auto Complete Stage 2/3`

**Manual Steps:**
1. Enable ESP to locate safe
2. Teleport to safe
3. Unlock safe (use "Unlock All Safes" button)
4. Open safe
5. Take key from safe
6. Go to ofuda box
7. Open box with key
8. Take ofuda

**Script Actions:**
- ✅ Finds safe in any room
- ✅ Unlocks safe automatically
- ✅ Opens safe
- ✅ Takes key
- ✅ Goes to ofuda box
- ✅ Takes ofuda

**Alternative Button:** `Take Ofuda Only`
- Only gets ofuda from box (if you already have key)

---

### Stage 4: Doll House

**Auto Complete Button:** `Auto Set All Dolls`

**Manual Steps:**
1. Use "Move to Doll Room (Front)" to position yourself
2. Find all dolls using ESP:
   - Black doll (with head)
   - Blue doll
   - White doll
   - Red doll
   - Yellow doll
3. Place each doll in correct position
4. Click "Auto Set All Dolls" to complete
5. Click "Finish" to end stage

**Script Actions:**
- ✅ Sets all doll values (Finished, Installed, Obtained)
- ✅ Sets black doll head values
- ✅ Completes DollAllSet

**Teleport Options:**
- `Move to Doll Room (Front)` - Face the doll house
- `Move to Doll Room (Back)` - Behind the doll house

---

### Stage 5: Dial Puzzle

**Auto Complete Button:** `Complete Stage 5`

**Script Actions:**
- ✅ Opens dial
- ✅ Sets dish (Obtained, Installed)
- ✅ Sets lighter (Obtained, Installed)
- ✅ Sets rope (Obtained, Installed)
- ✅ Completes stage end

---

### Stage 6: Finish

**Teleport Button:** `Teleport to Finish`

**Script Actions:**
- ✅ Teleports to ShoeRack (finish line)
- ✅ Positions behind the rack

---

## ⚙️ Configuration

### Recommended Settings

**For Speed Running:**
```
- ESP: ON
- Speed: 60-80
- Proximity Bypass: ON
- Dynamic Enemy Follow: ON
```

**For Safe Playing:**
```
- ESP: ON
- Speed: 30-40
- Proximity Bypass: OFF
- Dynamic Enemy Follow: OFF
```

**For Farming:**
```
- ESP: ON
- Speed: 50
- Proximity Bypass: ON
- Use auto-complete buttons for each stage
```

---

## 🔧 Troubleshooting

### Script not loading?
- Check your executor is up to date
- Make sure you're in the Pet-a-Pet game
- Try reloading the script

### ESP not showing?
- Toggle ESP OFF then ON again
- Rejoin the game
- Check if items are spawned

### Auto-complete not working?
- Make sure you're at the correct stage
- Check console for error messages
- Try manual steps first

### Speed not applying?
- Wait for character to respawn
- Adjust slider again
- Check if humanoid exists

---

## ❓ FAQ

**Q: Is this script safe to use?**
A: Use at your own risk. We recommend using on alternate accounts.

**Q: Can I use this with other scripts?**
A: It depends on the script. Some may conflict with Astralux.

**Q: The script stopped working after update?**
A: Check for updates on this repository. Game updates may break the script.

**Q: How do I report bugs?**
A: Open an issue on GitHub with detailed information.

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork** the repository
2. **Create** a new branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Contribution Guidelines

- Follow existing code style
- Test your changes thoroughly
- Update documentation if needed
- Add comments for complex logic

---

## 📝 Changelog

### Version 1.0.0 (Current)
- ✨ Initial release
- ✨ Full ESP system
- ✨ Auto-complete for all stages
- ✨ Speed control
- ✨ Proximity bypass
- ✨ Dynamic enemy follow
- ✨ Teleport features

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Credits

- **Developer:** LanFouWyne
- **UI Library:** [Fluent Renewed](https://github.com/ActualMasterOogway/Fluent-Renewed)
- **Game:** PetaPeta

---

## 📞 Support

- 🐛 **Bug Reports:** [Open an Issue](../../issues)
- 💡 **Feature Requests:** [Open an Issue](../../issues)

---

<div align="center">

**⭐ If you like this project, please give it a star! ⭐**

Made with ❤️ by LanFouWyne

</div>
