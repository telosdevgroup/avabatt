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

The installer links `/usr/local/bin/avabatt` and configures `avabatt.service` to persist thresholds across cold boots and suspend/hibernate events.

---

## ⌨️ 2. Quick Usage

```bash
# Query current status, charge level, and active limits
avabatt status

# JSON output for telemetry or status monitoring
avabatt status --json

# Dedicated desk/dock profile: Start charging at 50%, stop at 75%
sudo avabatt 50 75

# Cap charge at 80% (recommended general desk usage)
sudo avabatt 80
# or:
sudo avabatt on

# Restore full charging to 100% (before going mobile)
sudo avabatt 100
# or:
sudo avabatt off

# Custom stop threshold (start threshold auto-calculated 5% below stop)
sudo avabatt 75
```

---

## 🔬 3. How It Works (Kernel Interfaces)

Linux exposes battery charging thresholds through standardized and vendor-specific sysfs nodes. When configured, the embedded controller (EC) stops drawing power into the battery when the ceiling is reached, running the laptop purely off AC pass-through power.

`avabatt` automatically detects and validates writable sysfs nodes across drivers:

### Standard Linux Kernel Power Supply Interface (Linux 5.4+)
```bash
/sys/class/power_supply/BAT*/charge_control_end_threshold
/sys/class/power_supply/BAT*/charge_control_start_threshold
```
Writing `75` to `charge_control_end_threshold` commands the charge controller to halt charging at 75%. Specifying a start threshold (e.g., `50`) prevents recharge cycles until the battery drains below that level.

### Legacy ThinkPad ACPI (`tp_smapi` / `thinkpad_acpi`)
```bash
/sys/class/power_supply/BAT*/charge_stop_threshold
/sys/class/power_supply/BAT*/charge_start_threshold
```

### ASUS Laptops (`asus-wmi` / `asus-nb-wmi`)
```bash
/sys/devices/platform/asus-nb-wmi/charge_control_end_threshold
```

### Samsung Laptops (`samsung-laptop`)
```bash
/sys/devices/platform/samsung/battery_life_extender
```
*(0 = Normal 100%, 1 = Cap at 80%)*

### Lenovo IdeaPad ACPI (`VPC2004`)
For modern Lenovo IdeaPad, Legion, and Yoga laptops that govern conservation mode via the platform driver:
```bash
/sys/bus/platform/devices/VPC2004:*/conservation_mode
```
- Writing `1` activates conservation mode (firmware stops charging at 75–80%).
- Writing `0` deactivates conservation mode (charges to 100%).

---

## 🧰 4. Behavior Details

- **Already above the threshold?** If your battery is currently at 98% and you set `avabatt 50 75`, charging immediately halts (`Not charging`). The laptop runs on pass-through AC power until natural drain brings it down to 50%, at which point charging resumes up to 75%.
- **Persistence across reboots & sleep:** The included `avabatt.service` systemd unit re-applies your chosen thresholds on boot and resume from suspend/hibernate.
- **Zero dependencies:** Written in pure, POSIX-friendly Bash. No Python runtime required, no pip packages, no background daemon.

---

## 📜 License

MIT License. See `LICENSE` for details.
