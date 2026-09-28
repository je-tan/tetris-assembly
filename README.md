# Tetris in MIPS Assembly

A Tetris game implemented in **MIPS Assembly** and designed to run using the **MARS (MIPS Assembler and Runtime Simulator)**.

## Setup

### 1. Download MARS

Download **MARS 4.5.1** from the official release page:

[Download MARS 4.5.1](https://github.com/dpetersanderson/MARS/releases/tag/v.4.5.1)

### 2. Open the Project

1. Open **MARS**.
2. Open `tetris.asm` in MARS.

### 3. Configure the Bitmap Display

In MARS:

1. Go to **Tools → Bitmap Display**.
2. Configure the display with the following settings:

| Setting        | Value              |
| -------------- | ------------------ |
| Unit Width     | `8`                |
| Unit Height    | `8`                |
| Display Width  | `256`              |
| Display Height | `256`              |
| Base Address   | `0x10008000 ($gp)` |

3. Click **Connect to MIPS**.

### 4. Configure the Keyboard

1. Go to **Tools → Keyboard and Display MMIO Simulator**.
2. Click **Connect to MIPS**.

### 5. Run the Game

1. Assemble the program using **Run → Assemble**.
2. Start the program using **Run → Go**.
3. The Tetris game should now start.

## Controls

The game controls are listed in the **multi-line comment at the top of `tetris.asm`**.
