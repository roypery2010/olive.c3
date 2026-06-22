import std::io;
import libc;
import olive;

const int COLS = 8;
const int ROWS = 6;
const int WIDTH = 800;
const int HEIGHT = 600;
const int CELL_WIDTH = WIDTH / COLS;
const int CELL_HEIGHT = HEIGHT / ROWS;

const uint BACKGROUND_COLOR = 0x202020;
const uint FOREGROUND_COLOR = 0x20FF20; // Bright Green

uint[WIDTH * HEIGHT] pixels;

fn bool checker_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR); 
    
    for (int r = 0; r < ROWS; ++r) {
        for (int c = 0; c < COLS; ++c) {
            int rx = c * CELL_WIDTH;
            int ry = r * CELL_HEIGHT;
            
            usz rw = (usz)CELL_WIDTH;
            usz rh = (usz)CELL_HEIGHT;
            
            uint color = 0xFF2020; // Red
            if ((r + c) % 2 != 0) {
                color = 0x000000;  // Black
            }
            
            olive::fill_rect(&pixels, WIDTH, HEIGHT, rx, ry, rw, rh, color);
        }
    }
    
    String file_path = "checker_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    if ((int)result != 0) {
         io::printfn("File save failed!");
         return false;
    }
    return true;
}

fn bool circle_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR); 
    
    int radius = (CELL_WIDTH < CELL_HEIGHT ? CELL_WIDTH : CELL_HEIGHT) / 3;

    for (int r = 0; r < ROWS; ++r) {
        for (int c = 0; c < COLS; ++c) {
            int cx = (c * CELL_WIDTH) + (CELL_WIDTH / 2);
            int cy = (r * CELL_HEIGHT) + (CELL_HEIGHT / 2);
            
            olive::fill_circle(&pixels, WIDTH, HEIGHT, cx, cy, radius, FOREGROUND_COLOR);
        }
    }
    
    String file_path = "circle_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    if ((int)result != 0) {
         io::printfn("File save failed!");
         return false;
    }
    return true;
}

fn bool line_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR); 

    // Draw full canvas 'X'
    olive::draw_line(&pixels, WIDTH, HEIGHT, 0, 0, WIDTH - 1, HEIGHT - 1, FOREGROUND_COLOR);
    olive::draw_line(&pixels, WIDTH, HEIGHT, WIDTH - 1, 0, 0, HEIGHT - 1, FOREGROUND_COLOR);

    // Draw burst lines from center out to cell partitions
    int cx = WIDTH / 2;
    int cy = HEIGHT / 2;
    for (int c = 0; c <= COLS; ++c) {
        olive::draw_line(&pixels, WIDTH, HEIGHT, cx, cy, c * CELL_WIDTH, 0, 0xFF2020);
        olive::draw_line(&pixels, WIDTH, HEIGHT, cx, cy, c * CELL_WIDTH, HEIGHT - 1, 0xFF2020);
    }

    String file_path = "line_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    if ((int)result != 0) {
         io::printfn("File save failed!");
         return false;
    }
    return true;
}

fn int main(){
    if (!checker_example()) return 1;
    if (!circle_example()) return 1;
    if (!line_example()) return 1;
    
    return 0;
}