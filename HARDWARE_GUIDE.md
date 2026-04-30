# NodeMCU Hardware & Wiring Guide

## 🔧 Complete Wiring Diagram & Setup

### Components Needed

**Electronic Components:**
- 1x NodeMCU (ESP8266)
- 4x 5V Relay Modules (SRD-05VDC-SL-C or similar)
- 4x Push Buttons (tactile switches)
- 4x 10kΩ Resistors (for pull-up)
- 1x USB Cable (for programming)
- Breadboard (optional but recommended)
- Jumper Wires (male-to-male, male-to-female)

**External Connections (Optional but Recommended):**
- 4x Light bulbs + holders
- 4x Relay Sockets
- Power supply (5V for logic, appropriate voltage for devices)
- Extension cords (for safety)

---

## 📊 Relay Module Types

### Type 1: Single Channel 5V Relay (SRD-05VDC-SL-C)
```
Pin Layout:
┌─────────────┐
│  SRD-05VDC  │
├─────────────┤
│ NO  COM  NC │  (Switch terminals)
│ +   -   IN  │  (Power & signal)
└─────────────┘

Connections:
- IN → GPIO Pin from NodeMCU
- + → 5V
- - → GND
- NO/COM → Load to control
```

### Type 2: 4-Channel Relay Module
```
Pin Layout (for 4-channel module):
┌────────────────────────────┐
│   4-CH Relay Module        │
├────────────────────────────┤
│ NO COM NC NO COM NC ... │  (Switch outputs)
│ VCC IN1 IN2 IN3 IN4 GND│  (Power & signals)
└────────────────────────────┘

Connections:
- IN1 → D1 (GPIO5)
- IN2 → D2 (GPIO4)
- IN3 → D3 (GPIO0)
- IN4 → D4 (GPIO2)
- VCC → 5V
- GND → GND
```

---

## 🔌 NodeMCU Pin Reference

```
                    ESP-12E (NodeMCU)
┌─────────────────────────────────────────┐
│                                         │
│ D0(GPIO16)  D1(GPIO5)  D2(GPIO4)       │
│ D3(GPIO0)   D4(GPIO2)  D5(GPIO14)      │
│ D6(GPIO12)  D7(GPIO13) D8(GPIO15)      │
│ D9(GPIO3)   D10(GPIO1) D11(GPIO9)      │
│ D12(GPIO10) GND        3.3V            │
│ GND         VIN        5V              │
│                                         │
└─────────────────────────────────────────┘

Usable GPIO Pins:
- D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D12, D13

DO NOT USE:
- D11 (reserved for SPI Flash)
```

---

## 🔗 Complete Wiring Connections

### Configuration 1: Single Relay Modules (Recommended for Beginners)

```
┌─────────────────────────────────────────────────────┐
│              NodeMCU (ESP8266)                      │
└─────────────────────────────────────────────────────┘
         │              │              │              │
         D1(GPIO5)      D2(GPIO4)      D3(GPIO0)      D4(GPIO2)
         │              │              │              │
         ▼              ▼              ▼              ▼
    ┌────────┐     ┌────────┐     ┌────────┐     ┌────────┐
    │Relay 1 │     │Relay 2 │     │Relay 3 │     │Relay 4 │
    │ (SRD)  │     │ (SRD)  │     │ (SRD)  │     │ (SRD)  │
    │        │     │        │     │        │     │        │
    │ IN +- │     │ IN +- │     │ IN +- │     │ IN +- │
    └────────┘     └────────┘     └────────┘     └────────┘
         │              │              │              │
         │              │              │              │
    GND  5V         GND  5V         GND  5V         GND  5V
         │              │              │              │
    ┌────┴───────────────┴───────────────┴───────────┴────┐
    │                                                    │
    │          +5V Power Supply (Common)            GND │
    └────┬────────────────────────────────────────────┬──┘
         │                                             │
      RELAY POWER SUPPLY (5V 2A minimum)
```

### Configuration 2: 4-Channel Relay Module (Space-Saving)

```
         NodeMCU                4-Channel Relay
    ┌─────────────┐             ┌──────────────┐
    │  D1(GPIO5) ─┼─────────────┼─ IN1         │
    │  D2(GPIO4) ─┼─────────────┼─ IN2         │
    │  D3(GPIO0) ─┼─────────────┼─ IN3         │
    │  D4(GPIO2) ─┼─────────────┼─ IN4         │
    │      5V    ─┼─────────────┼─ VCC         │
    │      GND   ─┼─────────────┼─ GND         │
    └─────────────┘             └──────────────┘
         ▲                              │
         │                    ┌─────────┴─────────┐
         │                    │                   │
      POWER SUPPLY ┌─ Relay Common          Relay NO/COM
                                 (Connected to devices)
```

---

## 🔘 Button Connections

### Simple Button Setup (without pull-up resistor)
```
    Button (Push Switch)
         │
         │
    ┌────┴────┐
    │          │
    │         \/  (Switch contacts)
    │          
    ▼
GPIO Pin (NodeMCU)
    │
    ▼
   GND (Common Ground)

Advantages:
- Simple wiring
- Uses internal pull-up
- Few components

Code:
pinMode(BUTTON_PIN, INPUT_PULLUP);
bool pressed = digitalRead(BUTTON_PIN) == LOW;  // Active low
```

### Button with External Pull-up Resistor
```
    +5V
     │
     R (10kΩ)
     │
     ├─────┬───── GPIO Pin
     │     │
   Switch (normally open)
     │
    GND

Advantages:
- More reliable
- External pull-up
- Faster response

Code:
pinMode(BUTTON_PIN, INPUT);
bool pressed = digitalRead(BUTTON_PIN) == HIGH;  // Active high
```

---

## ⚡ Power Supply Specifications

### For NodeMCU
- **Voltage:** 5V DC (via USB or VIN pin)
- **Current:** 250-500mA peak, 100mA average
- **Power Source:** USB charger or external supply

### For Relay Modules
- **Voltage:** 5V DC
- **Current:** 500mA-1A per relay (4A total for 4 relays)
- **Total Current:** 2A minimum power supply recommended

### Calculation Example
```
If using 4 relays:
- NodeMCU: ~100mA
- Relay 1 (Light): 500mA
- Relay 2 (Fan): 600mA
- Relay 3 (AC): 800mA
- Relay 4 (Pump): 700mA
─────────────────────────
Total: 2.7A

Recommended: 3A-5A power supply
```

---

## 🔗 GPIO Pin Assignment (From Code)

```cpp
#define RELAY_PIN_1 D1  // GPIO5  - Light
#define RELAY_PIN_2 D2  // GPIO4  - Fan
#define RELAY_PIN_3 D3  // GPIO0  - AC
#define RELAY_PIN_4 D4  // GPIO2  - Water Pump

#define BUTTON_PIN_1 D5  // GPIO14 - Button 1
#define BUTTON_PIN_2 D6  // GPIO12 - Button 2
#define BUTTON_PIN_3 D7  // GPIO13 - Button 3
#define BUTTON_PIN_4 D8  // GPIO15 - Button 4
```

### Pin Compatibility Matrix
```
┌─────┬─────────┬──────────┬────────────────┐
│Node │ GPIO    │ Function │ Conflict Risk  │
├─────┼─────────┼──────────┼────────────────┤
│ D0  │ GPIO16  │ Wake-up  │ WakeUP pin     │
│ D1  │ GPIO5   │ ✓ Safe   │ None           │
│ D2  │ GPIO4   │ ✓ Safe   │ None           │
│ D3  │ GPIO0   │ ⚠ Boot   │ Boot mode      │
│ D4  │ GPIO2   │ ⚠ Boot   │ Boot mode      │
│ D5  │ GPIO14  │ ✓ Safe   │ None           │
│ D6  │ GPIO12  │ ✓ Safe   │ None           │
│ D7  │ GPIO13  │ ✓ Safe   │ None           │
│ D8  │ GPIO15  │ ⚠ Boot   │ Boot mode      │
│ RX  │ GPIO3   │ Serial   │ Serial RX      │
│ TX  │ GPIO1   │ Serial   │ Serial TX      │
└─────┴─────────┴──────────┴────────────────┘

✓ Safe: No conflicts, can use for any purpose
⚠ Boot: Use with caution, affects boot process
✗ Reserved: Don't use these pins
```

---

## 🛠️ Step-by-Step Assembly

### Step 1: Prepare NodeMCU
1. Get NodeMCU development board
2. Check USB port connection
3. Install CH340 driver (Windows users):
   - Download from: https://github.com/nodemcu/nodemcu-devkit
   - Install USB driver

### Step 2: Mount on Breadboard
```
Breadboard Layout:
┌─────────────────────────────┐
│                             │
│  D0 D1 D2 D3 D4 D5 D6 D7   │  ← NodeMCU top row
│  D8 D9 D10 TX RX GND 3.3V  │  ← NodeMCU bottom row
│                             │
│  ═════════════════════════  │  ← Power rails (5V, GND)
│                             │
│  Relay modules area         │
│  Button area                │
│                             │
└─────────────────────────────┘
```

### Step 3: Connect Power Rails
```
1. Connect NodeMCU GND to breadboard GND rail
2. Connect NodeMCU 3.3V to breadboard 3.3V rail (if available)
3. Connect 5V supply GND to breadboard GND rail
4. Connect 5V supply +5V to breadboard 5V rail
```

### Step 4: Connect Relays
1. Connect each relay module IN to respective GPIO pin
2. Connect all relay VCC pins to 5V rail
3. Connect all relay GND pins to GND rail
4. Connect relay outputs (NO/COM) to controllable devices

### Step 5: Connect Buttons
1. One side of button to GPIO pin
2. Other side of button to GND
3. Enable INPUT_PULLUP in code

### Step 6: Test Connections
```cpp
// Test code to verify connections
void setup() {
  Serial.begin(115200);
  pinMode(D1, OUTPUT);
  Serial.println("Testing relay on D1...");
}

void loop() {
  digitalWrite(D1, LOW);   // Relay ON
  Serial.println("Relay ON");
  delay(2000);
  
  digitalWrite(D1, HIGH);  // Relay OFF
  Serial.println("Relay OFF");
  delay(2000);
}
```

---

## 🚨 Common Wiring Mistakes

### ❌ Mistake 1: Wrong Relay Pin Logic
```
WRONG:
digitalWrite(pin, state ? HIGH : LOW);

CORRECT (for active-low relays):
digitalWrite(pin, state ? LOW : HIGH);

or use explicit:
digitalWrite(pin, state ? LOW : HIGH);  // HIGH = OFF
```

### ❌ Mistake 2: Missing Ground Connection
```
WRONG: Only connecting positive
┌─────────┐
│ Relay   │
│    + ───┼─→ 5V
│    - ───┼─→ (floating)
│    IN ──┼─→ GPIO

CORRECT: Both positive and ground
┌─────────┐
│ Relay   │
│    + ───┼─→ 5V
│    - ───┼─→ GND
│    IN ──┼─→ GPIO
```

### ❌ Mistake 3: Wrong Power Supply
```
PROBLEM: Using 3.3V for 5V relays
- Relays won't click properly
- Unreliable operation

SOLUTION: Use 5V supply for relays
- NodeMCU can accept 5V on VIN
- Relays need 5V on VCC
```

### ❌ Mistake 4: Button Not Debounced
```
WRONG: No debounce
if (digitalRead(BUTTON_PIN) == LOW) {
  // Reads multiple times per button press
}

CORRECT: With debounce
if (digitalRead(BUTTON_PIN) == LOW && 
    (millis() - lastTime) > 50) {
  lastTime = millis();
  // Execute once per button press
}
```

### ❌ Mistake 5: Floating GPIO Pins
```
WRONG:
pinMode(pin, INPUT);  // Floating, unstable

CORRECT:
pinMode(pin, INPUT_PULLUP);  // Pulled high
```

---

## 📌 Relay Pin Outputs

### Relay Terminal Functions
```
NO  = Normally Open (circuit open at rest)
NC  = Normally Closed (circuit closed at rest)
COM = Common terminal

For typical load control:
CONNECT LOAD TO: NO (Normally Open) and COM
This way:
- When relay is OFF (no power): Load is OFF
- When relay is ON (powered): Load is ON
```

### Wiring Load Connections
```
Light Bulb Example:

     Power Supply (+5V)
            │
            ├─── Light Bulb
            │
         Relay (NO-COM)
            │
            ├─── GND

When relay ON: Current flows through bulb → Light ON
When relay OFF: No current → Light OFF
```

---

## ✅ Pre-Flight Checklist

Before uploading code to NodeMCU:

- [ ] NodeMCU USB port detected in Arduino IDE
- [ ] CH340 driver installed (Windows)
- [ ] Board selected: "NodeMCU 1.0 (ESP-12E Module)"
- [ ] Port selected correctly
- [ ] Upload speed set to 115200
- [ ] Relays powered with 5V supply
- [ ] All relay grounds connected to common ground
- [ ] Buttons connected to GPIO pins
- [ ] No missing jumper wires
- [ ] No reversed polarity connections
- [ ] Breadboard power rails properly connected
- [ ] WiFi credentials updated in code
- [ ] Firebase credentials updated in code

---

## 🔍 Troubleshooting Connections

### Problem: Relay clicks but doesn't control load
**Solutions:**
- Check relay output connections (should be NO-COM)
- Verify load power supply is on
- Test relay manually with multimeter
- Check for loose wires

### Problem: Button press doesn't register
**Solutions:**
- Check button wiring (should be GPIO-GND)
- Test button with multimeter
- Verify debounce timing in code
- Check GPIO pin is available

### Problem: NodeMCU won't program
**Solutions:**
- Check USB cable connection
- Verify USB driver installed (Windows CH340)
- Try different USB port
- Hold FLASH button while uploading

### Problem: Random relay triggering
**Solutions:**
- Add pull-up resistors to GPIO pins
- Check for electrical noise
- Verify power supply is stable
- Check for loose connections

---

## 🎓 Additional Resources

- **NodeMCU Pinout:** https://github.com/nodemcu/nodemcu-devkit
- **Arduino ESP8266:** https://arduino-esp8266.readthedocs.io/
- **Relay Modules:** Check datasheet for exact pinout
- **Button Debouncing:** https://www.arduino.cc/en/Tutorial/Debounce

---

## 📋 Shopping List

### Essential Components
```
Item                      | Qty | Est. Cost
─────────────────────────┼─────┼──────────
NodeMCU ESP8266          │ 1   │ $5-8
5V Relay Modules         │ 4   │ $3-4 each
Push Buttons             │ 4   │ $0.5 each
10kΩ Resistors           │ 10  │ $0.1 each
Breadboard (830 holes)   │ 1   │ $5-10
Jumper Wires (M-M)       │ 1 pack│ $3-5
USB Cable (Micro-B)      │ 1   │ $2-3
5V Power Supply (2A)     │ 1   │ $8-12
─────────────────────────┴─────┴──────────
Total (Approximate)                $35-60
```

---

## 🎯 Next Steps

1. **Assemble hardware** following this guide
2. **Upload code** to NodeMCU from `esp8266_nodeMCU_code.ino`
3. **Configure** WiFi and Firebase credentials
4. **Test** each relay individually
5. **Test** each button
6. **Monitor** Serial output (Tools → Serial Monitor)
7. **Connect** physical loads (lights, fans, etc.)
8. **Verify** integration with Flutter app

---

**Happy IoT Building! 🚀**
