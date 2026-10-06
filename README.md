# 🔋 avabatt

**Native Linux battery lifespan preservation & hardware charge threshold manager.**

Most laptops plugged into wall chargers or docking stations stay pegged at 100% state of charge (SoC). For Lithium-ion and Lithium-polymer chemistries, prolonged high-voltage saturation (4.2V–4.35V per cell) combined with internal laptop heat accelerates chemical breakdown, causing permanent capacity loss and cell swelling.

`avabatt` caps battery charging at 80% (or any threshold from 50–100%) directly using native Linux kernel sysfs interfaces, with zero dependencies and no heavy third-party power suites like TLP.

---

## ⚡ 1. Rapid Install

```bash
curl -sSL https://raw.githubusercontent.com/telosdevgroup/avabatt/main/install.sh | bash
```

Or from a local clone:
```bash
git clone https://github.com/telosdevgroup/avabatt.git
cd avabatt
./install.sh
```

---

## ⌨️ 2. Quick Usage

```bash
# Query current status, charge level, and active limits
avabatt status

# Cap charge at 80% (recommended for desk / dock usage)
sudo avabatt 80
# or:
sudo avabatt on

# Restore full charging to 100% (before going mobile)
sudo avabatt 100
# or:
sudo avabatt off

# Custom threshold (50-100%)
sudo avabatt 60
```

---

## 🔬 3. How It Works (Kernel Interfaces)

Linux exposes battery charging thresholds through standardized and vendor-specific sysfs nodes. When configured, the embedded controller (EC) stops drawing power into the battery when the ceiling is reached, running the laptop purely off AC pass-through power.

`avabatt` automatically detects and actuates the appropriate sysfs nodes in order of precedence:

### Standard Linux Kernel Power Supply Interface (Linux 5.4+)
```bash
/sys/class/power_supply/BAT*/charge_control_end_threshold
/sys/class/power_supply/BAT*/charge_control_start_threshold
```
Writing `80` to `charge_control_end_threshold` commands the charge controller to halt charging at 80%. When supported, `avabatt` also sets `charge_control_start_threshold` to `75%` to prevent micro-cycling between 79% and 80%.

### Legacy ThinkPad ACPI (`tp_smapi` / `thinkpad_acpi`)
```bash
/sys/class/power_supply/BAT*/charge_stop_threshold
/sys/class/power_supply/BAT*/charge_start_threshold
```

### Lenovo IdeaPad ACPI (`VPC2004`)
For modern Lenovo IdeaPad, Legion, and Yoga laptops that govern conservation mode via the platform driver:
```bash
/sys/bus/platform/devices/VPC2004:*/conservation_mode
```
- Writing `1` activates conservation mode (firmware stops charging at 75–80%).
- Writing `0` deactivates conservation mode (charges to 100%).

---

## 🧰 4. Behavior Details

- **Already above the threshold?** If your battery is currently at 95% and you set `avabatt 80`, charging immediately halts (`Not charging`). The laptop runs on battery or pass-through until natural drain brings it down to 80%, where it settles.
- **Persistence across reboots:** Most modern laptop ECs persist charge thresholds in NVRAM across reboots.
- **Zero dependencies:** Written in pure, POSIX-friendly Bash. No Python runtime required, no pip packages, no background daemon.

---

## 📜 License

MIT License. See `LICENSE` for details.
