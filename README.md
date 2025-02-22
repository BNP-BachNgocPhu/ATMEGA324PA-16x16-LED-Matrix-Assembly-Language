# ATMEGA324PA-16x16-LED-Matrix-Assembly-Language
Design and Simulation of 16x16 LED Matrix Control Using ATMEGA324PA Microcontroller with Assembly Language
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/f29dbcf3-dfed-43fa-825b-8caeeb600f16" width="300">
        <br>
        <figcaption>Figure 1: ATmega324PA</figcaption>
    </figure>
</div>

<br>
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/4775d10c-605c-4c69-83ed-339bf64d0e48" width="500">
        <br>
        <figcaption>Figure 2: 8x8 LED Matrix</figcaption>
        <br>
        <br>
        <img src="https://github.com/user-attachments/assets/e7105e4f-e375-45c1-844a-936abfb5dafd" width="800">
        <br>
        <figcaption>Figure 3: 8x8 LED Matrix Pinout</figcaption>
    </figure>
</div>

## **Project Requirements**

### **Objective**
Design an electronic circuit using an **ATMEGA324PA** microcontroller and necessary ICs to control a **16x16 LED matrix** (composed of four **8x8 LED matrices**). Additionally, establish **UART communication** with a computer.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/6514f035-46ca-4adf-a96d-a33f803dc74c" width="500">
        <br>
        <figcaption>Figure 5: 16x16 LED Matrix composed of four 8x8 LED matrices</figcaption>
    </figure>
</div>

### **Constraints**
- Only **PORT A** and **PORT B** may be used in the design.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/fbca381e-cb52-44fc-bd11-51783511efb5" width="800">
        <br>
        <figcaption>Figure 6: ATmega324PA Pinout</figcaption>
    </figure>
</div>

### **Requirements for Simulation in Proteus**
#### **Simulation Setup**
- Create a **simulation in Proteus** and program the **ATMEGA324PA** to illuminate a **single pixel** at the intersection of **column 0, row 0** (lowest weight).

#### **Keyboard Input and Pixel Movement**
- Receive input from four keys (**W/A/S/D** or **w/a/s/d**) to move the illuminated pixel on the **LED matrix**:
  - If a key is pressed for **less than 0.5 seconds**, the pixel moves **by one position**.
  - If a key is **held for more than 0.5 seconds**, the pixel moves **one position every 0.5 seconds**.
- The four keys correspond to movement in **up/left/down/right** directions.
  - **Edge Wrapping:** If the pixel reaches the edge, it wraps around to the **opposite side**.
    - **Example:** Pressing **D**, and the pixel reaches the **right edge**, it will wrap around to the **left edge** and continue moving right.
- **Diagonal Movement:** Keys can be combined for diagonal movement.
  - **Example:** Holding **W and D** will move the pixel **diagonally up-right (45°).**

#### **Notes**
- When designing the **LED matrix in Proteus**, students should connect wires **by naming them**. After wiring, they can reposition the LED matrix for clarity.
- **Ensure** that:
  - The **least significant row** is on the **left side**.
  - The **least significant column** is at the **bottom**.

---

## **Implement the Project**
### **I will analyze some of the challenges of the Project**
The difficult of this project is the only using two ports (A and B). Each 8x8 led matrix has 16 pins to connect, so 16x16 led matrix has 64 pins.
Therefore, I didn't have enough pins from MCU ATMEGA324PA (because of using two ports A and B) in order to connect all pins at 16x16 led matrix.

I have found the idea which can help me solve this problem by using 74HC573 ICs and 74HC595 ICs.

### **74HC573**
The 74HC573 is an 8-bit D-type latch from the 74HC (High-Speed CMOS) family. It is commonly used for temporarily storing data in microprocessor systems, 
data bus communication, or controlling peripheral devices.
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/fdc91137-e878-4578-8534-d59ad9934740" width="500">
        <br>
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
        <img src="https://github.com/user-attachments/assets/a92cf625-7c7c-4183-8684-b4cce38f242f" width="800">
        <br>
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
        <img src="https://github.com/user-attachments/assets/fabf020a-d3d2-4fa6-9e83-4c5a3a6a8bb0" width="800">
        <br>
        <figcaption>Figure 9: designed 16x16 led matrix circuit </figcaption>
        </figure>
        <br>
        <br>
        <figure>
        <img src="https://github.com/user-attachments/assets/47577e52-9b4d-4b20-905e-37820fd0b828" width="800">
        <br>
        <img src="https://github.com/user-attachments/assets/a1945d7a-207d-42e7-a08e-857fa65082dc" width="500">
        <br>
        <figcaption>Figure 10, 11: 16x16 led matrix circuit in Proteus
    </figure>
</div>
<br>

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
        <img src="https://github.com/user-attachments/assets/1815f35e-5dc6-4d50-9341-2cd169e53229" width="800">
        <br>
        <figcaption>Figure 12: Turning on the LED at (10, 8)</figcaption>
    </figure>
</div> 

### **LED Matrix ROW (0-15) Control Block**

The **ROW (0-15) control block** is responsible for selecting and activating each row in the LED matrix by setting the 
corresponding row **HIGH**, while the **column (COL) data** determines which LEDs in that row will be turned on.

The system uses **74HC573 (Latch IC)** and **74HC595 (Shift Register IC)** to direct and control the rows sequentially, ensuring accurate LED scanning.

<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/8af7f956-6be0-496d-9c49-7a9da8fdee3d" width="800">
        <br>
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
        <img src="https://github.com/user-attachments/assets/88625b9a-c277-47dd-bea5-fbd91925267a" width="800">
        <br>
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
- **Reset all LEDs** by setting **all columns (COL) to HIGH** and **all rows (ROW) to LOW**.  
- **Initialize the default lit point at (0,0)** by:  
   - Setting **COL0 to LOW** to select column 0.  
   - Setting **ROW0 to HIGH** to select row 0.  
- **Prepare registers to track the position (X, Y) of the lit point.**  

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

---

## **Algorithm Implementation**
### **Algorithm for Handling the W Key in the LED Matrix Control Circuit**

### **1. Overview**
This program processes the **W key press**, which moves the lit point **upward** in the **16x16 LED matrix**. 

- Each time the **W key is pressed**, the program **checks if the lit point exceeds the boundaries of a single 8x8 LED block**.
- If the point remains within the same block, it executes **CTC `KEY_W_LESS_7`** to move within the current block.
- If the point exceeds the block boundary, it executes **CTC `KEY_W_MORE_7`** to jump to a new LED block and place the lit point in the corresponding position.
- If the lit point **exceeds the entire 16x16 matrix**, the program **resets the LED matrix** and repositions the lit point at its original x-coordinate.

### **2. Program Explanation**

#### **Step 1: Check the new position of the lit point**
```assembly
        PUSH R16                
        INC R10                 ; Increase y-position counter
        MOV R16, R10            
        CPI R16, 8              ; Check if it exceeds the size of one 8x8 LED block
        BRCC OVER_KEY_W         ; If y >= 8, jump to OVER_KEY_W (handle crossing boundary)
        RCALL KEY_W_LESS_7      ; If y < 8, execute CTC KEY_W_LESS_7 to move within the same LED block
        RJMP EXIT_W             ; Exit the W key processing routine
```
- **R10** stores the **y-coordinate** in the 8x8 block.
- If **y < 8**, the point remains within the block, so the program calls `KEY_W_LESS_7`.
- If **y ≥ 8**, the point **crosses the upper boundary** of the LED block, so the program processes a **block transition**.

#### **Step 2: Handle block transition**
```assembly
OVER_KEY_W:
        RCALL KEY_W_MORE_7      ; Execute CTC KEY_W_MORE_7 to transition to a new LED block
        MOV R16, R0             ; Check if the lit point has exceeded the 16x16 LED matrix
        CPI R16, 2
        BRCC OVER_C_D_COL       ; If R16 >= 2, the point is outside the 16x16 LED matrix
        RCALL KEY_W_LESS_7      ; If not exceeded, continue `KEY_W_LESS_7` to finalize movement
        RJMP EXIT_W             
```
- If the lit point remains within **16x16 matrix**, it continues execution in `KEY_W_LESS_7`.
- If the lit point **exceeds the 16x16 matrix** (R16 ≥ 2), it moves to `OVER_C_D_COL` to **reset the matrix**.

#### **Step 3: Reset the LED matrix if the point exceeds 16x16**
```assembly
OVER_C_D_COL:
        PUSH R13                ; Save x-position before resetting the matrix
        RCALL SETUP_MATRIX      ; Reset the LED matrix
        POP R16    
        CPI R16, 0              ; Check if x = 0
        BREQ EXIT_W             ; If x = 0, skip `SET_OVER_COL`
```
- If the point **exceeds the 16x16 LED matrix**, the system **resets the matrix** using `SETUP_MATRIX`.
- **R13 stores the x-position before reset**, and the system restores **R16 to check x-coordinate**.
- If **x = 0**, it **exits** without repositioning.

#### **Step 4: Adjust x-coordinate if needed**
```assembly
SET_OVER_COL:                
        INC R13               ; Increase x-position
        RCALL KEY_D           ; Call the D key function to shift right
        DEC R16               ; Decrease R16 counter
        BRNE SET_OVER_COL     ; If R16 is not zero, repeat the loop
```
- If **x ≠ 0**, the program **increments x and shifts the lit point right** to restore its correct position.
- This loop ensures the **lit point appears in the correct x-location after reset**.

#### **Step 5: Exit the W key processing routine**
```assembly
EXIT_W:                            
        POP R16
        RET                        ; Return to main program
```
- **Ends the W key handling routine** by restoring **R16** and **returning to the main program**.

### **3. Summary of the W Key Handling Algorithm**
1. **Increase the y-coordinate by 1 to move up.**  
2. **Check if the lit point exceeds the current block:**  
   - If **not exceeded**, move within the block (`KEY_W_LESS_7`).  
   - If **exceeded**, transition to the next LED block (`KEY_W_MORE_7`).  
3. **Check if the lit point is outside the 16x16 matrix:**  
   - If **inside**, continue normal movement.  
   - If **outside**, **reset the LED matrix** (`SETUP_MATRIX`).  
4. **If x ≠ 0 after reset, adjust x-position correctly (`SET_OVER_COL`).**  
5. **Exit the function and return to the main program.**  

### **Algorithm for Moving the Lit Point Upward When Exceeding an LED Block (KEY_W_MORE_7)**

### **1. Overview**
This program handles the **W key press when the lit point exceeds the upper boundary of an 8x8 LED block**. When this happens, the lit point must be **transferred to the corresponding LED block above** in the **16x16 LED matrix**.

- **Check the current position of the lit point** (Matrix A or B).
- **Move the lit point from A → C or B → D** when exceeding the top boundary (y=7 → y=8).
- **Ensure the x-position remains unchanged** when transitioning between blocks.
- **Update shift register values** to reflect the new coordinates.

### **2. Program Explanation**

#### **Step 1: Reset y and check the current matrix position**
```assembly
KEY_W_MORE_7:
        CLR R10                 ; Reset y-position counter in an 8x8 LED block
        MOV R16, R1
        CPI R16, 1              ; Check if the lit point is in Matrix A or B?
        BRCC MATRIX_B_TO_D      ; If R1 = 1, jump to handle Matrix B → D
```
- **R10 = 0** resets the y-position counter.
- **R1 holds the current matrix block** (R1=0: Matrix A, R1=1: Matrix B).
- If **currently in Matrix B**, jump to `MATRIX_B_TO_D`.
- If **currently in Matrix A**, continue processing `Matrix A → C`.

#### **Step 2: Transition from Matrix A → Matrix C**
```assembly
        ; Transition from Matrix A to Matrix C
        SBI PORTA,6             ; Set HIGH for C_P0
        SBI PORTA,4             
        CBI PORTA,3        
        SBI PORTA,3        
        CBI PORTA,5        
        SBI PORTA,5
        MOV R6, R11             ; Store x-position before transition
        INC R6
        DEC R6                  
        BREQ EXIT_KEY_W_MORE_7  ; If x = 0, exit
        CBI PORTA,4             ; If x > 0, proceed to set x
```
- **Configure PORTA to activate row control for Matrix C**.
- **Store the current x-position in R6** to retain the x-coordinate after transition.
- **If x = 0**, meaning the lit point is in the first column, **exit the function**.
- **If x > 0**, proceed to adjust x in Matrix C.

#### **Step 3: Update y-position in Matrix C**
```assembly
SET_Y_W:
        CBI PORTA,3        
        SBI PORTA,3    
        DEC R6
        BRNE SET_Y_W    
        CBI PORTA,5        
        SBI PORTA,5
        RJMP EXIT_KEY_W_MORE_7
```
- **Adjust the y-position in Matrix C** using **PORTA signals**.
- **Loop through x-adjustment to place the lit point correctly after transition**.

#### **Step 4: Transition from Matrix B → Matrix D**
```assembly
MATRIX_B_TO_D:
        SBI PORTA,6             ; Set HIGH for D_P0
        SBI PORTA,4        
        CBI PORTA,3                
        SBI PORTA,3    
        CBI PORTA,5        
        SBI PORTA,5    
        LDI R16, 8              ; Send 8 LOW signals to ensure D_P0=1
        CBI PORTA,4
```
- **Similar to Matrix A → C**, but applied for Matrix B → D.
- **Set control signals to activate row control for Matrix D**.

#### **Step 5: Update y-position in Matrix D**
```assembly
SET_Y_8_W_MATRIX_D:
        CBI PORTA,3        
        SBI PORTA,3
        DEC R16
        BRNE SET_Y_8_W_MATRIX_D    
        CBI PORTA,5        
        SBI PORTA,5
```
- **Decrement R16 to ensure the y-position is updated correctly within Matrix D**.

#### **Step 6: Check x and adjust if needed**
```assembly
        MOV R6, R11             ; Retrieve x-position in Matrix B
        INC R6
        DEC R6
        BREQ EXIT_KEY_W_MORE_7  ; If x=0, exit
        CBI PORTA,4             ; If x>0, proceed to set x
```
- **If x = 0**, no adjustment is needed, exit immediately.
- **If x > 0**, continue setting x.

```assembly
SET_X_W_MATRIX_D:
        CBI PORTA,3        
        SBI PORTA,3    
        DEC R6
        BRNE SET_X_W_MATRIX_D    
        CBI PORTA,5        
        SBI PORTA,5    
```
- **Loop to set the new x-position in Matrix D**.

#### **Step 7: Exit the function**
```assembly
EXIT_KEY_W_MORE_7:                
        CBI PORTA,3
        CBI PORTA,6            
        INC R0                  ; Increase the matrix position counter    
        RET                     ; Return to the main program
```
- **Deactivate control signals**.
- **Increase R0 to update the matrix position counter**.
- **Return to the main program**.

### **3. Summary of `KEY_W_MORE_7` Algorithm**
1. **Check the current matrix position (A or B).**  
2. **If in Matrix A, transition to Matrix C.**  
   - Configure control signals.  
   - Adjust y-position and set x accordingly.  
3. **If in Matrix B, transition to Matrix D.**  
   - Similar process as A → C.  
   - Ensure y and x are properly updated.  
4. **Increment the matrix coordinate counter to track movement.**  
5. **Return to the main program.**  

### **Algorithm for Moving the Lit Point to the Right (KEY_D)**

### **1. Overview**
This program processes the **D key press**, which moves the lit point **to the right** in the **16x16 LED matrix**.

- **Increments the x-coordinate to shift the lit point to the right.**
- **Checks if the lit point exceeds the right boundary of an 8x8 LED block:**
  - If **not exceeded**, it continues moving within the block (`KEY_D_LESS_7`).
  - If **exceeded**, it transitions to the adjacent block (`KEY_D_MORE_7`).
- **Checks if the lit point moves beyond the 16x16 matrix:**
  - If **inside**, it moves normally.
  - If **outside**, the matrix is reset, and the lit point is repositioned.

### **2. Program Explanation**

#### **Step 1: Check the new x-position of the lit point**
```assembly
KEY_D:    
        PUSH R16
        INC R11                 ; Increment x-position counter
        MOV R16, R11                
        CPI R16, 8              ; Check if it exceeds the size of an 8x8 LED block
        BRCC OVER_KEY_D         ; If exceeded, jump to OVER_KEY_D
        RCALL KEY_D_LESS_7      ; If not, execute `KEY_D_LESS_7` for movement within the block
        RJMP EXIT_D                    
```
- **Increments R11** to move the lit point **one step to the right**.
- If **R11 < 8**, the point remains within the block and executes `KEY_D_LESS_7`.
- If **R11 ≥ 8**, the point **crosses the right boundary** and needs to transition to the next block (`KEY_D_MORE_7`).

#### **Step 2: Check if the lit point exceeds the 16x16 matrix**
```assembly
OVER_KEY_D:
        RCALL KEY_D_MORE_7      ; Execute `KEY_D_MORE_7` to move to the new block
        MOV R16, R1             ; Check if the lit point has exceeded the 16x16 LED matrix
        CPI R16, 2
        BRCC OVER_B_D_ROW       ; If exceeded, jump to OVER_B_D_ROW
        RCALL KEY_D_LESS_7      ; If not, continue normal movement
        RJMP EXIT_D
```
- If the lit point is **within the 16x16 matrix**, it continues moving normally.
- If the lit point **exceeds the 16x16 matrix**, it jumps to `OVER_B_D_ROW` to reset the matrix.

#### **Step 3: Reset the matrix if the lit point exceeds the 16x16 limit**
```assembly
OVER_B_D_ROW:
        PUSH R12                ; Save y-position before resetting the matrix
        RCALL SETUP_MATRIX      ; Reset the LED matrix
        POP R16
        CPI R16, 0              ; Check if y = 0?
        BREQ EXIT_D             ; If y = 0, skip SET_OVER_ROW
```
- **If the lit point moves outside the 16x16 matrix**, the system resets using `SETUP_MATRIX`.
- **R12 stores the y-position before reset**, and the system restores **R16 to check y**.
- If **y = 0**, it exits without adjusting y.

#### **Step 4: Adjust y-position if needed**
```assembly
SET_OVER_ROW:
        INC R12
        RCALL KEY_W
        DEC R16
        BRNE SET_OVER_ROW
```
- If **y ≠ 0**, the program **increments y and moves the point up (W direction).**
- **This ensures correct positioning before the reset.**

#### **Step 5: Exit the D key processing routine**
```assembly
EXIT_D:
        POP R16
        RET
```
- **Ends the D key handling routine** by restoring **R16** and returning to the main program.

#### **Step 6: Move within a single LED block (`KEY_D_LESS_7`)**
```assembly
KEY_D_LESS_7:
        PUSH R16        
        MOV R16, R0            
        CPI R16, 1              ; Check if in Matrix A, B or C, D
        BRCC MATRIX_C_D_X       ; If in Matrix C or D, handle it separately
```
- **Checks whether the lit point is in Matrix A, B (R0 = 0) or Matrix C, D (R0 = 1).**

##### **If in Matrix A or B**
```assembly
        SBI PORTA,6             ; Use shift register 595 to control P of Matrix A, B
        CBI    PORTA,1          ; Send LOW signal to parallel outputs
        CBI PORTA,0             ; Move the lit point one step right
        SBI PORTA,0        
        CBI PORTA,2        
        SBI PORTA,2    
        CBI PORTA,0
        CBI PORTA,6            
        RJMP EXIT_KEY_D_LESS_7  ; Finish movement
```
- **Sends a signal to the shift register** to update the P control of Matrix A, B.
- **Shifts the lit point to the right** using control pulses.

##### **If in Matrix C or D**
```assembly
MATRIX_C_D_X:
        SBI PORTA,6             ; Use shift register 595 to control P of Matrix C, D
        CBI    PORTA,4          ; Send LOW signal to parallel outputs
        CBI PORTA,3             ; Move the lit point one step right
        SBI PORTA,3    
        CBI PORTA,5        
        SBI PORTA,5
        CBI PORTA,3    
        CBI PORTA,6        
EXIT_KEY_D_LESS_7:                
        POP R16
        RET
```
- **Similar to Matrix A, B but for Matrix C, D.**
- **Updates the shift register to move the lit point right.**

### **3. Summary of the `KEY_D` Algorithm**
1. **Increment x by 1 to move right.**  
2. **Check if the lit point exceeds the current block:**  
   - If **not exceeded**, move normally (`KEY_D_LESS_7`).  
   - If **exceeded**, jump to the adjacent LED block (`KEY_D_MORE_7`).  
3. **Check if it exceeds the 16x16 matrix:**  
   - If **inside**, continue normal movement.  
   - If **outside**, **reset the LED matrix** (`SETUP_MATRIX`).  
4. **If y ≠ 0 after reset, shift the lit point up correctly (`SET_OVER_ROW`).**  
5. **Exit the function and return to the main program.**  

### **Algorithm for Moving the Lit Point to the Right When Exceeding an LED Block (KEY_D_MORE_7)**

### **1. Overview**
This program processes the **D key press when the lit point exceeds the right boundary of an 8x8 LED block**. When this happens, the lit point must be **transferred to the corresponding LED block to the right** in the **16x16 LED matrix**.

- **Check whether the lit point is in Matrix A or C** to **control the correct shift register hardware**.
- **If the lit point is in Matrix A**, it **moves to Matrix B** upon exceeding the right boundary.
- **If the lit point is in Matrix C**, it **moves to Matrix D** upon exceeding the right boundary.
- **Update the new coordinates after shifting** to ensure the lit point remains in the correct position.

### **2. Program Explanation**

#### **Step 1: Reset x and check the current matrix position**
```assembly
KEY_D_MORE_7:
        CLR R11                 ; Reset x-position counter within an 8x8 LED block
        MOV R16, R0                
        CPI R16, 1              ; Check if the lit point is in Matrix A or C?
        BRCC MATRIX_C_TO_D      ; If in Matrix C, jump to MATRIX_C_TO_D
```
- **R11 = 0** resets the x-position counter.
- **R0 stores the current matrix block** (R0=0: Matrix A, R0=1: Matrix C).
- If **currently in Matrix C**, the program jumps to `MATRIX_C_TO_D` for handling **C → D transition**.
- If **currently in Matrix A**, it continues handling **A → B transition**.

#### **Step 2: Transition from Matrix A → Matrix B**
```assembly
        ; Transition from Matrix A to Matrix B
        SBI PORTA,7                
        CBI PORTA,4             ; Initialize LOW level at B_GND0 of Matrix B
        CBI PORTA,3        
        SBI PORTA,3        
        CBI PORTA,5        
        SBI PORTA,5
        MOV R5, R10             ; Store y-position before transition
        INC R5    
        DEC R5
        BREQ EXIT_KEY_D_MORE_7  ; If y=0, exit
        SBI PORTA,4             ; Adjust B_GND0 to B_GNDy position    
```
- **Configure PORTA to set up row control for Matrix B**.
- **Store the current y-position in R5** to maintain the y-coordinate after transition.
- **If y = 0**, meaning the lit point is in the first row, **exit the function**.
- **If y > 0**, proceed to update the new y position in Matrix B.

#### **Step 3: Update y-position in Matrix B**
```assembly
UP_1:
        CBI PORTA,3        
        SBI PORTA,3    
        DEC R5
        BRNE UP_1    
        CBI PORTA,5        
        SBI PORTA,5    
        RJMP EXIT_KEY_D_MORE_7  ; Jump to exit
```
- **Adjust the y-position to ensure the lit point appears correctly in Matrix B**.
- **Update control signals to reflect the position change**.

#### **Step 4: Transition from Matrix C → Matrix D**
```assembly
MATRIX_C_TO_D:
        SBI PORTA,7                
        CBI PORTA,4             ; Initialize LOW level at B_GND0
        CBI PORTA,3    
        SBI PORTA,3
        CBI PORTA,5        
        SBI PORTA,5    
        LDI R16, 8              ; Shift LOW level from B_GND0 to D_GND0
        SBI PORTA,4
```
- **Similar to the A → B transition but applied for C → D**.
- **Set control signals to ensure correct row control in Matrix D**.

#### **Step 5: Update y-position in Matrix D**
```assembly
LOOP_595_COL_2:
        CBI PORTA,3        
        SBI PORTA,3
        DEC R16
        BRNE LOOP_595_COL_2        
        CBI PORTA,5        
        SBI PORTA,5
        MOV R5, R10             ; Store y-position before transition to Matrix D
        INC R5
        DEC R5
        BREQ EXIT_KEY_D_MORE_7  ; If y=0, exit
        SBI PORTA,4             ; Adjust D_GND0 to D_GNDy position
```
- **Shift control signals to ensure the lit point appears in the correct position in Matrix D**.

#### **Step 6: Update y-position in Matrix D**
```assembly
UP_2:
        CBI PORTA,3        
        SBI PORTA,3    
        DEC R5
        BRNE UP_2    
        CBI PORTA,5        
        SBI PORTA,5
```
- **Adjust the y-position in Matrix D to ensure correct placement**.

#### **Step 7: Exit the function**
```assembly
EXIT_KEY_D_MORE_7:                ; Exit routine
        CBI PORTA,3    
        CBI PORTA,7            
        INC R1
        RET
```
- **Deactivate control signals**.
- **Increment R1 to update the matrix coordinate counter**.
- **Return to the main program to continue processing**.

### **3. Summary of the `KEY_D_MORE_7` Algorithm**
1. **Check whether the lit point is in Matrix A or C.**  
2. **If in Matrix A, transition to Matrix B.**  
   - Configure control signals.  
   - Adjust y and set the correct position.  
3. **If in Matrix C, transition to Matrix D.**  
   - Similar process as A → B.  
   - Ensure the correct y-position update.  
4. **Increment the matrix coordinate counter to reflect movement.**  
5. **Return to the main program to continue processing.**  

### **Implementing A, S, Q, E, Z, C Keys Based on W and D**

At this point, we have established **W** for moving **up** and **D** for moving **right**. The remaining movement keys **A, S, Q, E, Z, C** can be derived using a combination of **W and D**, as the shift register **only functions in one direction**.

### **1. Implementing Basic Keys A, S Using W, D**
| **Key** | **Movement Direction** | **Derived From** |
|---------|----------------------|-----------------|
| **A (Left)** | X decreases | Press **(16 - 1) times D** |
| **S (Down)** | Y decreases | Press **(16 - 1) times W** |

- **Principle:**  
  - **A = "Reverse" of D** → Since D shifts right, A must shift **(16-1) times D** to move left.  
  - **S = "Reverse" of W** → Since W shifts up, S must shift **(16-1) times W** to move down.  


### **2. Implementing Diagonal Movement Keys (Q, E, Z, C)**
The diagonal movement keys **Q, E, Z, C** are combinations of **W (up) and D (right)**.  
| **Key** | **Movement Direction** | **Combination of Keys** |
|---------|----------------------|-----------------|
| **Q (Left - Up)** | X decreases, Y increases | A + W |
| **E (Right - Up)** | X increases, Y increases | D + W |
| **Z (Left - Down)** | X decreases, Y decreases | A + S |
| **C (Right - Down)** | X increases, Y decreases | D + S |

- **Principle:**  
  - **Q = A + W** (Moves diagonally left-up).  
  - **E = D + W** (Moves diagonally right-up).  
  - **Z = A + S** (Moves diagonally left-down).  
  - **C = D + S** (Moves diagonally right-down).  

### **3. Handling Boundary Collisions**
For **Q, E, Z, C**, when colliding with a boundary, the lit point **reflects at the intersection of the diagonal path and the opposite boundary**.  
- Example: **If the lit point is at (3,15) and E is pressed (moving diagonally up)**:  
  - It hits the top boundary **y = 15**, but since it moves diagonally, it reflects at **the left boundary**, resulting in **a new position of (0, 15 - 3)**.  

<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/6e0d9fb6-b2df-4eed-9ab3-6c6002ebb351" width="800">
        <br>
        <figcaption>Figure 15: RS232-based system using UART for keyboard data transmission and 16x16 LED matrix control with ATmega324PA</figcaption>
    </figure>
</div> 
<br>
<div align="center">
    <figure>
        <img src="https://github.com/user-attachments/assets/eb311a2f-fe97-4876-b43d-e22ca6ecf4a1" width="800">
        <br>
        <figcaption>Figure 16: Using Onboard Buttons Instead of UART </figcaption>
    </figure>
</div> 


## **System operation video**

### 🔗 Button Control Point
<div align="center">



[![Button Operation](https://img.youtube.com/vi/3XSUUd_ZQuQ/0.jpg)](https://youtu.be/3XSUUd_ZQuQ)
</div>

### 🔗 UART Control Point  
<div align="center">

[![UART Control](https://img.youtube.com/vi/4y26vJ2dfxk/0.jpg)](https://youtu.be/4y26vJ2dfxk)

</div>
