use sdl2::pixels::Color;
use sdl2::rect::Rect;
use sdl2::Sdl;

use crate::config::*;

pub struct Screen {
    pub bg: Color,
    pub fg: Color,
    pub canvas: sdl2::render::WindowCanvas,
}

impl Screen {
    pub fn new(sdl_context: &Sdl) -> Result<Self, String> {
        let (r, g, b) = BACKGROUND;
        let bg = Color::RGB(r, g, b);
        let (r, g, b) = FOREGROUND;
        let fg = Color::RGB(r, g, b);

        let video_subsystem = sdl_context.video()?;

        let window = video_subsystem
            .window(
                TITLE,
                SQUARE_SIZE * (WIDTH) as u32,
                SQUARE_SIZE * (HEIGHT) as u32,
            )
            .position_centered()
            .build()
            .map_err(|e| e.to_string())?;

        let mut canvas = window.into_canvas().build().map_err(|e| e.to_string())?;

        canvas.set_draw_color(bg);
        canvas.clear();
        canvas.present();

        Ok(Self { bg, fg, canvas })
    }

    pub fn update(&mut self, disp: &[u8; 64 * 32]) -> Result<(), String> {
        self.canvas.set_draw_color(self.bg);
        self.canvas.clear();
        self.canvas.set_draw_color(self.fg);

        for y in 0..HEIGHT {
            for x in 0..WIDTH {
                let index = ((y * WIDTH) + x) as usize;
                if disp[index] == 1 {
                    let xx = (x as i32) * SQUARE_SIZE as i32;
                    let yy = (y as i32) * SQUARE_SIZE as i32;
                    // println!("x {}, y {}", xx, yy );
                    self.canvas
                        .fill_rect(Rect::new(xx, yy, SQUARE_SIZE, SQUARE_SIZE))?;
                }
            }
        }

        self.canvas.present();
        Ok(())
    }
}
