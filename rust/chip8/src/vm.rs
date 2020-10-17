use rand::{thread_rng, Rng};
use std::fs::File;
use std::io::Read;

use crate::config::*;

static FONTSET: [u8; 80] = [
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80, // F
];

pub struct Chip8 {
    pc: u16,                 // program counter
    opcode: u16,             //opcode
    mem: [u8; 4096],         // memory
    v: [u8; 16],             // registers
    i: u16,                  // index register
    pub dt: u8,              // delay timer
    pub st: u8,              // sound timer
    sp: u8,                  // stack pointer
    stack: [u16; 16],        // stack
    pub key: [u8; 16],       // keyboards state
    pub disp: [u8; 64 * 32], // graphics
    pub draw_flag: bool,
    // pub display: Display,
}

impl Chip8 {
    pub fn new(filename: &str) -> Result<Self, String> {
        let mut emu = Self {
            pc: 0x200, // 512
            opcode: 0,
            mem: [0; 4096],
            v: [0; 16],
            i: 0,
            dt: 0,
            st: 0,
            sp: 0,
            stack: [0; 16],
            key: [0; 16],
            disp: [0; 64 * 32],
            draw_flag: false,
        };

        load(&mut emu, filename);

        // set font
        for i in 0..FONTSET.len() {
            emu.mem[i] = FONTSET[i];
        }
        Ok(emu)
    }

    pub fn cycle(&mut self) {
        self.fetch();

        self.execute();
        if self.dt > 0 {
            self.dt -= 1
        }
        if self.st > 0 {
            self.st -= 1
        }
        if self.st == 1 {
            println!("BEEP")
        }
    }

    fn call_rca1802(&mut self, nnn: u16) {
        println!("call rca1802{:?}", nnn);
        self.pc += 2;
    }

    pub fn display_clear(&mut self) {
        for m in self.disp.iter_mut() {
            *m = 0;
        }
        self.draw_flag = true;
        self.pc += 2;
    }

    fn set_font(&mut self, x: u8) {
        self.i = (self.v[x as usize] * 5) as u16;
        self.pc += 2;
    }

    fn display_draw(&mut self, x: u8, y: u8, height: u8) {
        self.draw_flag = true;

        for i in 0..height {
            let mut byte = self.mem[self.i as usize + i as usize];

            for j in 0..8 {
                let cx = (self.v[x as usize]) as usize;
                let cy = (self.v[y as usize]) as usize;
                let start = (cy * WIDTH) + cx;
                let index = start + (WIDTH * i as usize) + j;
                let b = byte >> 7;

                // sucks
                if self.disp[index] == 1 && (byte >> 7) == 1 {
                    self.v[0xf] = 1;
                } else if self.disp[index] == 0 && (byte >> 7) == 1 {
                    self.v[0xf] = 0;
                }
                self.disp[index] ^= b;

                byte <<= 1;
            }
        }
        self.pc += 2;
    }

    fn fn_return(&mut self) {
        self.sp -= 1;
        self.pc = self.stack[self.sp as usize];
    }

    fn jump_nnn(&mut self, nnn: u16) {
        self.pc = nnn;
    }

    fn fn_call(&mut self, nnn: u16) {
        self.stack[self.sp as usize] = self.pc + 2;
        self.sp += 1;
        self.pc = nnn;
    }

    fn eq_nnx(&mut self, nn: u8, x: u8) {
        if self.v[x as usize] == nn {
            self.pc += 2
        }
        self.pc += 2
    }

    fn ne_nnx(&mut self, nn: u8, x: u8) {
        if self.v[x as usize] != nn {
            self.pc += 2
        }
        self.pc += 2
    }

    fn eq_xy(&mut self, x: u8, y: u8) {
        if self.v[x as usize] == self.v[y as usize] {
            self.pc += 2
        }
        self.pc += 2
    }

    fn set_xtonn(&mut self, x: u8, nn: u8) {
        self.v[x as usize] = nn;
        self.pc += 2;
    }

    fn add_nnxtox(&mut self, nn: u8, x: u8) {
        self.v[x as usize] = self.v[x as usize].wrapping_add(nn);
        self.pc += 2;
    }

    fn set_xtoy(&mut self, x: u8, y: u8) {
        self.v[x as usize] = self.v[y as usize];
        self.pc += 2;
    }

    fn bor_xytox(&mut self, x: u8, y: u8) {
        self.v[x as usize] |= self.v[y as usize];
        self.pc += 2;
    }

    fn band_xytox(&mut self, x: u8, y: u8) {
        self.v[x as usize] &= self.v[y as usize];
        self.pc += 2;
    }

    fn bxor_xytox(&mut self, x: u8, y: u8) {
        self.v[x as usize] ^= self.v[y as usize];
        self.pc += 2;
    }

    fn add_xytox(&mut self, x: u8, y: u8) {
        let (res, carry) = self.v[x as usize].overflowing_add(self.v[y as usize]);
        self.v[0xf] = if carry { 1 } else { 0 };
        self.v[x as usize] = res;
        self.pc += 2;
    }

    fn sub_xytox(&mut self, x: u8, y: u8) {
        let (res, borrow) = self.v[x as usize].overflowing_sub(self.v[y as usize]);
        self.v[0xf] = if borrow { 0 } else { 1 };
        self.v[x as usize] = res;
        self.pc += 2;
    }

    fn rshift_x(&mut self, x: u8) {
        self.v[0xf] = self.v[x as usize] & 0b0000_0001;
        self.v[x as usize] >>= 1;
        self.pc += 2;
    }

    fn sub_yxtox(&mut self, x: u8, y: u8) {
        let (res, borrow) = self.v[y as usize].overflowing_sub(self.v[x as usize]);
        self.v[0xf] = if borrow { 0 } else { 1 };
        self.v[x as usize] = res;
        self.pc += 2;
    }

    fn lshift_x(&mut self, x: u8) {
        self.v[0xf] = (self.v[x as usize] & 0b1000_0000) >> 7;
        self.v[x as usize] <<= 1;
        self.pc += 2;
    }

    fn ne_xy(&mut self, x: u8, y: u8) {
        if self.v[x as usize] == self.v[y as usize] {
            self.pc += 2
        }
        self.pc += 2
    }

    fn set_nnntoi(&mut self, nnn: u16) {
        self.i = nnn;
        self.pc += 2;
    }

    fn jump_v0plusnnn(&mut self, nnn: u16) {
        self.pc = self.v[0] as u16 + nnn;
    }

    fn set_rand(&mut self, nn: u8, x: u8) {
        let rand_val: u8 = thread_rng().gen();
        self.v[x as usize] = nn & rand_val;
        self.pc += 2;
    }

    fn key_pressed(&mut self, x: u8) {
        if self.key[self.v[x as usize] as usize] == 1 {
            self.pc += 2;
        }
        self.pc += 2;
    }

    fn key_not_pressed(&mut self, x: u8) {
        if self.key[self.v[x as usize] as usize] == 0 {
            self.pc += 2;
        }
        self.pc += 2;
    }

    fn get_delay(&mut self, x: u8) {
        self.v[x as usize] = self.dt;
        self.pc += 2;
    }

    fn get_key(&mut self, x: u8) {
        if self.key != [0; 16] {
            'key_checking: for (i, k) in self.key.iter().enumerate() {
                if *k != 0 {
                    self.v[x as usize] = i as u8;
                    self.pc += 2;
                    break 'key_checking;
                }
            }
        }
    }

    fn set_delaytimer(&mut self, x: u8) {
        self.dt = self.v[x as usize];
        self.pc += 2;
    }

    fn set_soundtimer(&mut self, x: u8) {
        self.st = self.v[x as usize];
        self.pc += 2;
    }

    fn add_ixtoi(&mut self, x: u8) {
        // Adds VX to I. VF is set to 1 when there is a range overflow (I+VX>0xFFF), and to 0 when there isn't.
        //This is an undocumented feature of the CHIP-8 and used by the Spacefight 2091! game
        self.i += self.v[x as usize] as u16;

        self.v[0xf] = if self.i > 0xfff {
            self.i -= 0xfff + 0x1;
            1
        } else {
            0
        };
        self.pc += 2;
    }

    fn set_bcd(&mut self, x: u8) {
        self.mem[self.i as usize] = self.v[x as usize] / 100;
        self.mem[(self.i + 1) as usize] = (self.v[x as usize] % 100) / 10;
        self.mem[(self.i + 2) as usize] = self.v[x as usize] % 10;
        self.pc += 2;
    }

    fn reg_dump(&mut self, x: u8) {
        // Stores V0 to VX (including VX) in memory starting at address I. The offset from I is increased by 1 for each value written, and I itself is left incremented. (for CHIP-8 and CHIP-48)
        // let index = (self.i + (self.v[x as u16] as usize) as usize);

        for offset in 0..=x {
            let i = (self.i + offset as u16) as usize;
            let j = offset as usize;
            self.mem[i] = self.v[j];
            // self.i += 1;
        }
        self.pc += 2;
    }

    fn reg_load(&mut self, x: u8) {
        for offset in 0..=x {
            let i = (self.i + offset as u16) as usize;
            let j = offset as usize;
            self.v[j] = self.mem[i];
            // self.i += 1;
        }
        self.pc += 2;
    }

    pub fn execute(&mut self) {
        let n: u8 = (self.opcode & 0x000F) as u8;
        let nn: u8 = (self.opcode & 0x00FF) as u8;
        let nnn: u16 = self.opcode & 0x0FFF;
        let x: u8 = ((self.opcode & 0x0F00) >> 8) as u8;
        let y: u8 = ((self.opcode & 0x00F0) >> 4) as u8;

        let op: (u8, u8, u8, u8) = (
            ((self.opcode & 0xF000) >> 12) as u8,
            x,
            y,
            (self.opcode & 0x000F) as u8,
        );

        match op {
            (0x0, 0x0, 0xe, 0x0) => self.display_clear(),
            (0x0, 0x0, 0xe, 0xe) => self.fn_return(),
            (0x0, _, _, _) => self.call_rca1802(nnn),
            (0x1, _, _, _) => self.jump_nnn(nnn),
            (0x2, _, _, _) => self.fn_call(nnn),
            (0x3, _, _, _) => self.eq_nnx(nn, x),
            (0x4, _, _, _) => self.ne_nnx(nn, x),
            (0x5, _, _, 0x0) => self.eq_xy(x, y),
            (0x6, _, _, _) => self.set_xtonn(x, nn),
            (0x7, _, _, _) => self.add_nnxtox(nn, x),
            (0x8, _, _, 0x0) => self.set_xtoy(x, y),
            (0x8, _, _, 0x1) => self.bor_xytox(x, y),
            (0x8, _, _, 0x2) => self.band_xytox(x, y),
            (0x8, _, _, 0x3) => self.bxor_xytox(x, y),
            (0x8, _, _, 0x4) => self.add_xytox(x, y),
            (0x8, _, _, 0x5) => self.sub_xytox(x, y),
            (0x8, _, _, 0x6) => self.rshift_x(x),
            (0x8, _, _, 0x7) => self.sub_yxtox(x, y),
            (0x8, _, _, 0xe) => self.lshift_x(x),
            (0x9, _, _, 0x0) => self.ne_xy(x, y),
            (0xa, _, _, _) => self.set_nnntoi(nnn),
            (0xb, _, _, _) => self.jump_v0plusnnn(nnn),
            (0xc, _, _, _) => self.set_rand(nn, x),
            (0xd, _, _, _) => self.display_draw(x, y, n),
            (0xe, _, 0x9, 0xe) => self.key_pressed(x),
            (0xe, _, 0xa, 0x1) => self.key_not_pressed(x),
            (0xf, _, 0x0, 0x7) => self.get_delay(x),
            (0xf, _, 0x0, 0xa) => self.get_key(x),

            (0xf, _, 0x1, 0x5) => self.set_delaytimer(x),
            (0xf, _, 0x1, 0x8) => self.set_soundtimer(x),
            (0xf, _, 0x1, 0xe) => self.add_ixtoi(x),
            (0xf, _, 0x2, 0x9) => self.set_font(x),
            (0xf, _, 0x3, 0x3) => self.set_bcd(x),
            (0xf, _, 0x5, 0x5) => self.reg_dump(x),
            (0xf, _, 0x6, 0x5) => self.reg_load(x),
            (_, _, _, _) => (),
        }
    }

    pub fn disp_clear(&mut self) {
        self.draw_flag = true;
        self.disp.iter_mut().for_each(|d| *d = 0);
        self.pc += 2;
    }

    pub fn fetch(&mut self) {
        let hi = self.mem[self.pc as usize] as u16;
        let lo = self.mem[self.pc as usize + 1] as u16;
        self.opcode = (hi << 8) | lo;
    }
}

pub fn load(emu: &mut Chip8, filename: &str) {
    let mut buffer = [0u8; 3583]; // 0xFFF - 0x200 = 0xdff(3583)

    let bytes_read = File::open(filename).unwrap().read(&mut buffer).unwrap();

    for i in 0..bytes_read {
        emu.mem[emu.pc as usize + i] = buffer[i];
    }
}
