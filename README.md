# ATMEGA324PA-16x16-LED-Matrix-Assembly-Language
Design and Simulation of 16x16 LED Matrix Control Using ATMEGA324PA Microcontroller with Assembly Language

# **Project Requirements**

<div align="center">
    <img src="https://github.com/user-attachments/assets/f29dbcf3-dfed-43fa-825b-8caeeb600f16" width="400">
</div>


# **Project Requirements**

## **Objective**
Design an electronic circuit using an **ATMEGA324PA** microcontroller and necessary ICs to control a **16x16 LED matrix** (composed of four **8x8 LED matrices**). Additionally, establish **UART communication** with a computer.

## **Constraints**
- Only **PORT A** and **PORT B** may be used in the design.

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



