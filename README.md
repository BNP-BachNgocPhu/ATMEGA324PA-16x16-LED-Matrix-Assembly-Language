# ATMEGA324PA-16x16-LED-Matrix-Assembly-Language
Design and Simulation of 16x16 LED Matrix Control Using ATMEGA324PA Microcontroller with Assembly Language
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/f29dbcf3-dfed-43fa-825b-8caeeb600f16" width="300">
        <figcaption>Figure 1: ATmega324PA</figcaption>
    </figure>
</div>
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/4775d10c-605c-4c69-83ed-339bf64d0e48" width="200">
        <figcaption>Figure 2: 8x8 LED Matrix</figcaption>
        <img src="https://github.com/user-attachments/assets/e7105e4f-e375-45c1-844a-936abfb5dafd" width="400">
        <figcaption>Figure 3: 8x8 LED Matrix Pinout</figcaption>
    </figure>
</div>

# **Project Requirements**

## **Objective**
Design an electronic circuit using an **ATMEGA324PA** microcontroller and necessary ICs to control a **16x16 LED matrix** (composed of four **8x8 LED matrices**). Additionally, establish **UART communication** with a computer.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/6514f035-46ca-4adf-a96d-a33f803dc74c" width="300">
        <figcaption>Figure 5: 16x16 LED Matrix composed of four 8x8 LED matrices</figcaption>
    </figure>
</div>

## **Constraints**
- Only **PORT A** and **PORT B** may be used in the design.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/fbca381e-cb52-44fc-bd11-51783511efb5" width="300">
        <figcaption>Figure 6: ATmega324PA Pinout</figcaption>
    </figure>
</div>

## **Requirements for Simulation in Proteus**
### **Simulation Setup**
- Create a **simulation in Proteus** and program the **ATMEGA324PA** to illuminate a **single pixel** at the intersection of **column 0, row 0** (lowest weight).

### **Keyboard Input and Pixel Movement**
- Receive input from four keys (**W/A/S/D** or **w/a/s/d**) to move the illuminated pixel on the **LED matrix**:
  - If a key is pressed for **less than 0.5 seconds**, the pixel moves **by one position**.
  - If a key is **held for more than 0.5 seconds**, the pixel moves **one position every 0.5 seconds**.
- The four keys correspond to movement in **up/left/down/right** directions.
  - **Edge Wrapping:** If the pixel reaches the edge, it wraps around to the **opposite side**.
    - **Example:** Pressing **D**, and the pixel reaches the **right edge**, it will wrap around to the **left edge** and continue moving right.
- **Diagonal Movement:** Keys can be combined for diagonal movement.
  - **Example:** Holding **W and D** will move the pixel **diagonally up-right (45°).**

### **Notes**
- When designing the **LED matrix in Proteus**, students should connect wires **by naming them**. After wiring, they can reposition the LED matrix for clarity.
- **Ensure** that:
  - The **least significant row** is on the **left side**.
  - The **least significant column** is at the **bottom**.

---

# **Implement the Project**
## **I will analyze some of the challenges of the Project**
The difficult of this project is the only using two ports (A and B). Each 8x8 led matrix has 16 pins to connect, so 16x16 led matrix has 64 pins.
Therefore, I didn't have enough pins from MCU ATMEGA324PA (because of using two ports A and B) in order to connect all pins at 16x16 led matrix.

I have found the idea which can help me solve this problem by using 74HC573 ICs and 74HC595 ICs.

### **74HC573**
The 74HC573 is an 8-bit D-type latch from the 74HC (High-Speed CMOS) family. It is commonly used for temporarily storing data in microprocessor systems, 
data bus communication, or controlling peripheral devices.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/fdc91137-e878-4578-8534-d59ad9934740" width="300">
        <figcaption>Figure 7: 74HC573 LACHES TIPO D</figcaption>
    </figure>
</div>

**Pin Functions**  

- D0 - D7 (Pins 2 → 9): Data inputs  
- Q0 - Q7 (Pins 19 → 12): Data outputs  
- LE (Latch Enable - Pin 10): Controls data latching  
  - LE = 1: Data from D0-D7 is immediately transferred to Q0-Q7  
  - LE = 0: The last data at Q0-Q7 is held (latched)  
- OE (Output Enable - Pin 1): Controls output state  
  - OE = 0: Outputs Q0-Q7 are active  
  - OE = 1: Outputs Q0-Q7 are in high-impedance (Z) state  
- Vcc (Pin 20): Power supply (+5V)  
- GND (Pin 11): Ground (0V)  

**Operating Principle**  

- The 74HC573 functions as a D-Type latch:  
- When LE = 1, data from inputs D0 - D7 is immediately passed to outputs Q0 - Q7.  
- When LE transitions from 1 to 0, the output data is latched and remains unchanged even if the input D0 - D7 changes.  
- When OE = 1, the outputs Q0 - Q7 are disabled and enter a high-impedance state.  
- When OE = 0, the latched data remains available at the outputs.  

**Note**: OE only affects the output state, it does not alter the latched data.

### **74HC595**
The 74HC595 is an 8-bit serial-in, parallel-out shift register with a storage register. It is widely used for expanding microcontroller output pins, driving LEDs, segment displays, and other digital devices.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/a92cf625-7c7c-4183-8684-b4cce38f242f" width="500">
        <figcaption>Figure 8: 74HC595 Shift Register</figcaption>
    </figure>
</div>

**Pin Functions**
- SER (Serial Data Input - Pin 3): Serial data input (1 bit per clock cycle).  
- SRCLK (Shift Register Clock - Pin 5): Shifts data into the register on rising edge.  
- RCLK (Register Clock/Latch - Pin 4): Transfers data from the shift register to the output register on rising edge.  
- OE (Output Enable - Pin 2): Enables outputs (active LOW).  
  - OE = 0: Outputs Q0-Q7 are active.  
  - OE = 1: Outputs Q0-Q7 are disabled (high-impedance).  
- SRCLR (Shift Register Clear - Pin 6): Clears the shift register when LOW.  
  - SRCLR = 1: Normal operation.  
  - SRCLR = 0: Clears all shift register values to 0.  
- Q0 - Q7 (Pins 8, 9, 10, 11, 12, 13, 14, 15): Parallel data outputs.  
- Q7’ (Serial Output - Pin 1): Used to daisy-chain multiple shift registers.  
- Vcc (Pin 16): Power supply (+5V).  
- GND (Pin 7): Ground (0V).   

**Operating Principle**  
The 74HC595 works in two stages:
- Shifting Data (using SER and SRCLK):
  - Data is input bit by bit through SER.
  - On each SRCLK rising edge, the data is shifted into the register.
- Latching Data to Output (using RCLK):
  - The stored data is transferred to the parallel outputs Q0-Q7 when RCLK goes HIGH.  

**Note:** Outputs remain unchanged until RCLK is triggered, allowing stable data transfer.  

---
## **Circuit Design**
### **16x16 Led Matrix**
To create a 16x16 led matrix, I connect the four 8x8 led matrix. But, the requirements include:
the **least significant row** is on **the left side** and he **least significant column** is at **the bottom**.
Therefore, I designed like that:
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/fabf020a-d3d2-4fa6-9e83-4c5a3a6a8bb0" width="500">
        <figcaption>Figure 9: designed 16x16 led matrix circuit </figcaption>
        </figure>
        <figure>
        <img src="https://github.com/user-attachments/assets/47577e52-9b4d-4b20-905e-37820fd0b828" width="500">
        <img src="https://github.com/user-attachments/assets/a1945d7a-207d-42e7-a08e-857fa65082dc" width="300">
        <figcaption>Figure 10, 11: 16x16 led matrix circuit in Proteus
    </figure>
</div>

The **16x16 LED matrix** is divided into **four 8x8 LED blocks** (**A, B, C, D**).  
Each block has **8 rows (ROW) and 8 columns (COL)** with corresponding **P (COL) and GND (ROW) control pins** as follows: 
| **Block** | **X Range (COL)** | **Y Range (ROW)** | **Row Control Pins (ROW - GND)** | **Column Control Pins (COL - P)** |
|----------|------------------|------------------|------------------------------|------------------------------|
| **A (Bottom-Left)** | 0 → 7 | 0 → 7 | A_GND0 → A_GND7 | A_P0 → A_P7 |
| **B (Bottom-Right)** | 8 → 15 | 0 → 7 | B_GND0 → B_GND7 | B_P0 → B_P7 |
| **C (Top-Left)** | 0 → 7 | 8 → 15 | C_GND0 → C_GND7 | C_P0 → C_P7 |
| **D (Top-Right)** | 8 → 15 | 8 → 15 | D_GND0 → D_GND7 | D_P0 → D_P7 |

- **GND pins (ROW control)**: Controls the rows. When set to **LOW**, LEDs in that row can turn on.  
- **P pins (COL control)**: Controls the columns. When set to **HIGH**, LEDs in that column can turn on.  

**Example: Turning on the LED at (10, 8)**  
Determine the block containing the pixel  
- X = 10 (Falls within 8 → 15)  
- Y = 8 (Falls within 8 → 15)  

The pixel belongs to Block D (Top-Right). Identify the control pins in Block D  
- Column (COL): X = 10 → D_P2  
- Row (ROW): Y = 8 → D_GND0  

Control the LED  
- D_GND0 = LOW (Select row 0 in Block D).  
- D_P2 = HIGH (Select column 2 in Block D).

<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/1815f35e-5dc6-4d50-9341-2cd169e53229" width="500">
        <figcaption>Figure 12: Turning on the LED at (10, 8)</figcaption>
    </figure>
</div> 

### **LED Matrix ROW (0-15) Control Block**

The **ROW (0-15) control block** is responsible for selecting and activating each row in the LED matrix by setting the 
corresponding row **HIGH**, while the **column (COL) data** determines which LEDs in that row will be turned on.

The system uses **74HC573 (Latch IC)** and **74HC595 (Shift Register IC)** to direct and control the rows sequentially, ensuring accurate LED scanning.

<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/8af7f956-6be0-496d-9c49-7a9da8fdee3d" width="500">
        <figcaption>Figure 13: Circuit Controlling Rows (ROW0 - ROW15)</figcaption>
    </figure>
</div> 

#### **Main Components of the ROW Control Block**

##### **74HC573 Latch IC (U2)**
**Function:**
- Determines the row group to be controlled:
  - **ROW0 - ROW7** (Block A & B)
  - **ROW8 - ROW15** (Block C & D)
- Sends signals to the shift registers to select a specific row.  

**Working Principle:**
- Receives data from the microcontroller.
- Latches data to decide whether the row belongs to **0-7** or **8-15**.

##### **74HC595 Shift Register IC (U5, U8, U10, U11)**
**Function:**
- Shifts row data from **Q0 → Q7**, setting **HIGH** on the selected row.
- Divided into two control groups:
  - **U5 & U8**: Controls **ROW0 - ROW7** (Block A & B).
  - **U10 & U11**: Controls **ROW8 - ROW15** (Block C & D).

**Working Principle:**
- When receiving the **SH_CP (Shift Clock)** pulse, the IC shifts bits from **Q0 → Q7**.
- The bit set to **HIGH** activates the corresponding row.

#### **Operation Process of the ROW (0-15) Control Circuit**
- The microcontroller sends row control data to the **74HC573 (U2)** IC.
- **U2 directs the signal** based on the target row:
   - **ROW0 - ROW7** → Signal goes to **U5 and U8**.
   - **ROW8 - ROW15** → Signal goes to **U10 and U11**.
- **74HC595 shift registers** shift data to select the specific row:
   - A **single HIGH bit** is shifted from **Q0 → Q7** to choose the row.
   - Example: If **ROW3** needs to be activated, **Q3** of the 595 IC will be set **HIGH**.
- The selected row in **Block A, B, C, or D** is activated.
- The **selected row is set HIGH**, and **column data** determines which LEDs turn on.
- The process repeats for other rows to create the desired **LED matrix display**.

### **LED Matrix COLUMN(0-15) Control Block**

The COLUMN (COL 0-15) control block is responsible for selecting and activating each column in the LED matrix by setting the corresponding column to **LOW**, while the row (ROW) data determines which LEDs in that column will be turned on.

The system utilizes **74HC573 (Latch IC) and 74HC595 (Shift Register IC)** to control and direct the column scanning process, ensuring proper LED display operation.

<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/88625b9a-c277-47dd-bea5-fbd91925267a" width="500">
        <figcaption>Figure 14: Circuit Controlling Columns (COL0 - COL15)</figcaption>
    </figure>
</div> 

#### **Main Components of the COLUMN Control Block**

##### **74HC573 Latch IC (U3)**
**Function:**
- Determines the column group to be controlled:
  - COL0 - COL7 (Block A & C)
  - COL8 - COL15 (Block B & D)
- Sends signals to the shift registers to select a specific column.

**Working Principle:**
- Receives data from the microcontroller.
- Latches data to decide whether the column belongs to 0-7 or 8-15.

##### **74HC595 Shift Register IC (U6, U4, U7, U9)**
**Function:**
- Shifts column data from **Q0 → Q7**, setting **LOW** on the selected column.
- Divided into two control groups:
  - **U6 & U7:** Controls **COL0 - COL7** (Block A & C).
  - **U4 & U9:** Controls **COL8 - COL15** (Block B & D).

**Working Principle:**
- When receiving the **SH_CP (Shift Clock)** pulse, the IC shifts bits from **Q0 → Q7**.
- The bit set to **LOW** activates the corresponding column.

#### **Operation Process of the COLUMN (COL 0-15) Control Circuit**
The microcontroller sends column control data to the **74HC573 (U3) IC**.
   - If the target column is within **COL0 - COL7**, U3 directs the signal to **U6 and U7**.
   - If the target column is within **COL8 - COL15**, U3 directs the signal to **U4 and U9**.

**74HC595 shift registers** shift data to select the specific column.
   - A single **LOW** bit is shifted from **Q0 → Q7** to choose the column.
   - **Example:** If **COL5** needs to be activated, **Q5 of the 595 IC** will be set **LOW**.

The selected column in **Block A, B, C, or D** is activated. The selected column is set **LOW**, and row data determines which LEDs turn on.

---
## **Algorithm Works**
### **1. LED Matrix Initialization Process**  
1. **Reset all LEDs** by setting **all columns (COL) to HIGH** and **all rows (ROW) to LOW**.  
2. **Initialize the default lit point at (0,0)** by:  
   - Setting **COL0 to LOW** to select column 0.  
   - Setting **ROW0 to HIGH** to select row 0.  
3. **Prepare registers to track the position (X, Y) of the lit point.**  

### **2. Controlling the Movement of the Lit Point**  
The system allows **users to press keys** to move the lit point in **8 main directions**:  
- **W** → Up  
- **S** → Down  
- **A** → Left  
- **D** → Right  
- **Q, E, Z, C** → Diagonal movement  

### **2.1 Handling Straight Movements (W, S, A, D)**  
| **Direction** | **When hitting a boundary** | **New position** |
|--------------|--------------------------|------------------|
| **W (Up)** | y = 0 | y = 15 |
| **S (Down)** | y = 15 | y = 0 |
| **A (Left)** | x = 0 | x = 15 |
| **D (Right)** | x = 15 | x = 0 |

**Principle:** If hitting a boundary in **straight directions**, the lit point **appears on the opposite boundary** to create a looping effect.  

### **2.2 Handling Diagonal Movements (Q, E, Z, C)**  
| **Direction** | **Hitting top boundary (y = 15)** | **Hitting bottom boundary (y = 0)** | **Hitting left boundary (x = 0)** | **Hitting right boundary (x = 15)** |
|--------------|--------------------------------|--------------------------------|--------------------------------|--------------------------------|
| **Q (Up - Left)** | **(15, x)** | No change | **(y, 0)** | No change |
| **E (Up - Right)** | **(0, 15 - x)** | No change | No change | **(15 - y, 0)** |
| **Z (Down - Left)** | No change | **(15, 15 - x)** | **(15 - y, 15)** | No change |
| **C (Down - Right)** | No change | **(0, x)** | No change | **(y, 15)** |

**Principle:** If hitting a boundary while **moving diagonally**, the lit point **reflects at the intersection of the diagonal path and the opposite boundary**, instead of looping like W, S, A, D.  

### **3. Delay Mechanism for Movement Control**  
- **If a key is pressed for less than 0.5 seconds**, the lit point **moves only 1 step**.  
- **If the key is held for more than 0.5 seconds**, the lit point **moves continuously in that direction**.  
- **A 500ms delay prevents excessive speed** and ensures accurate LED display. 

