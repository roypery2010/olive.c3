module main;

import std::io;
import libc;
import olive;

const usz WIDTH = 800;
const usz HEIGHT = 600;
const uint BACKGROUND_COLOR = 0x181818;

uint[WIDTH * HEIGHT] pixels;

fn bool checker_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);

    int cols = 8;
    int rows = 6;
    int cell_w = (int)WIDTH / cols;
    int cell_h = (int)HEIGHT / rows;

    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            int rx = c * cell_w;
            int ry = r * cell_h;
            uint color = ((r + c) % 2 != 0) ? 0x333333 : 0x222222;
            olive::fill_rect(&pixels, WIDTH, HEIGHT, rx, ry, (usz)cell_w, (usz)cell_h, color);
        }
    }

    String file_path = "checker_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool circle_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);
    olive::fill_circle(&pixels, WIDTH, HEIGHT, (int)WIDTH / 2, (int)HEIGHT / 2, 150, 0x0000FF);

    String file_path = "circle_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool line_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);
    olive::draw_line(&pixels, WIDTH, HEIGHT, 0, 0, (int)WIDTH, (int)HEIGHT, 0x00FF00);
    olive::draw_line(&pixels, WIDTH, HEIGHT, (int)WIDTH, 0, 0, (int)HEIGHT, 0x00FF00);

    String file_path = "line_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool triangle_example() {
    olive::fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR); 

    // Base background triangle
    olive::fill_triangle(&pixels, WIDTH, HEIGHT, 
                         (int)WIDTH / 2, 100,       
                         150, (int)HEIGHT - 100,    
                         (int)WIDTH - 150, (int)HEIGHT - 100, 
                         0xFF00FF);            

    // Intersecting secondary triangle
    olive::fill_triangle(&pixels, WIDTH, HEIGHT, 
                         (int)WIDTH / 2 - 50, (int)HEIGHT / 2 - 50,
                         (int)WIDTH / 2 + 50, (int)HEIGHT / 2 - 50,
                         (int)WIDTH / 2, (int)HEIGHT / 2 + 100, 
                         0x00FFFF);            

    String file_path = "triangle_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels, WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn int main() {
    if (!checker_example()) return 1;
    if (!circle_example()) return 1;
    if (!line_example()) return 1;
    if (!triangle_example()) return 1;
    
    io::printfn("All image examples compiled successfully!");
    return 0;
}