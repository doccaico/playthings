extern crate sdl2;

use sdl2::event::Event;
use sdl2::keyboard::Keycode;
use std::thread;
use std::time::{Duration};

use chip8::gfx::{Screen};
use chip8::input;
use chip8::vm::Chip8;

fn main() -> Result<(), String> {
    let argv: Vec<String> = std::env::args().collect();
    let filename = format!("rom/{}", &argv[1]);
    let mut emu = Chip8::new(&filename)?;
    let sdl_context = sdl2::init()?;
    let mut screen = Screen::new(&sdl_context)?;
    let mut event_pump = sdl_context.event_pump()?;

    'running: loop {
        for event in event_pump.poll_iter() {
            match event {
                Event::Quit { .. }
                | Event::KeyDown {
                    keycode: Some(Keycode::Escape),
                    ..
                } => break 'running,
                _ => {}
            }
        }

        emu.cycle();

        input::get_keys(&mut emu.key, &event_pump);

        if emu.draw_flag {
            screen.update(&emu.disp)?;
            emu.draw_flag = false;
        }
        thread::sleep(Duration::from_secs_f64(0.0056));
    }

    Ok(())
}
