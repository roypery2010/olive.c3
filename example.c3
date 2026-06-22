module main;

import std::io;
import libc;
import olive;

const usz WIDTH = 800;
const usz HEIGHT = 600;
const uint BACKGROUND_COLOR = 0xFF181818; // Opaque Dark Gray (0xAABBGGRR)

uint[WIDTH * HEIGHT] pixels;

fn bool checker_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);

    int cols = 8;
    int rows = 6;
    int cell_w = (int)WIDTH / cols;
    int cell_h = (int)HEIGHT / rows;

    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            int rx = c * cell_w;
            int ry = r * cell_h;
            uint color = ((r + c) % 2 != 0) ? 0xFF333333 : 0xFF222222;
            olive::fill_rect(&pixels[0], WIDTH, HEIGHT, rx, ry, (usz)cell_w, (usz)cell_h, color);
        }
    }

    String file_path = "checker_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool circle_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);
    // 0xAABBGGRR -> Pure Blue: 0xFFFF0000
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2, (int)HEIGHT / 2, 150, 0xFFFF0000);

    String file_path = "circle_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool line_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);
    // 0xAABBGGRR -> Pure Green: 0xFF00FF00
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, 0, 0, (int)WIDTH, (int)HEIGHT, 0xFF00FF00);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, (int)WIDTH, 0, 0, (int)HEIGHT, 0xFF00FF00);

    String file_path = "line_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool triangle_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR); 

    // Base background triangle (Opaque Magenta: 0xFFFF00FF)
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, 
                         (int)WIDTH / 2, 100,       
                         150, (int)HEIGHT - 100,    
                         (int)WIDTH - 150, (int)HEIGHT - 100, 
                         0xFFFF00FF);            

    // Intersecting secondary triangle (Opaque Cyan: 0xFFFFFF00)
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, 
                         (int)WIDTH / 2 - 50, (int)HEIGHT / 2 - 50,
                         (int)WIDTH / 2 + 50, (int)HEIGHT / 2 - 50,
                         (int)WIDTH / 2, (int)HEIGHT / 2 + 100, 
                         0xFFFFFF00);            

    String file_path = "triangle_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool alpha_example() {
    // Start with a solid white canvas to make the color mixing obvious
    olive::fill(&pixels[0], WIDTH, HEIGHT, 0xFFFFFFFF);

    // Draw an opaque base layer rect (Solid Slate Gray)
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 100, 100, 600, 400, 0xFF555555);

    // Layer 1: Translucent Red Circle (~50% Alpha = 0x80)
    // 0x800000FF -> Alpha=80, Blue=00, Green=00, Red=FF
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2 - 100, (int)HEIGHT / 2, 150, 0x800000FF);

    // Layer 2: Translucent Blue Circle (~50% Alpha = 0x80)
    // 0x80FF0000 -> Alpha=80, Blue=FF, Green=00, Red=00
    // Where this overlaps the Red circle, it will blend dynamically into Purple!
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2 + 100, (int)HEIGHT / 2, 150, 0x80FF0000);

    // Layer 3: Highly transparent Green Rectangle (~30% Alpha = 0x4C)
    // 0x4C00FF00 -> Alpha=4C, Blue=00, Green=FF, Red=00
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2 - 200, (int)HEIGHT / 2 - 50, 400, 100, 0x4C00FF00);

    String file_path = "alpha_example.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool flag_japan_example() {
    // 1. Fill canvas background with solid pure white (0xFFFFFFFF)
    olive::fill(&pixels[0], WIDTH, HEIGHT, 0xFFFFFFFF);

    // 2. Calculate coordinates and radius scaled properly to our global canvas
    int center_x = (int)(WIDTH / 2);
    int center_y = (int)(HEIGHT / 2);
    int radius = (int)(HEIGHT * 3 / 10); // Standard layout proportion rules

    // Render the centered red sun disc (Crimson Red: 0xFF2D00BC in 0xAABBGGRR)
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, center_x, center_y, radius, 0xFF2D00BC);

    // 3. Save directly out to path asset target
    String file_path = "flag_japan.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool flag_israel_example() {
    // Define Opaque Colors (0xAABBGGRR format)
    uint white = 0xFFFFFFFF;
    uint blue  = 0xFFFF3300; // Hex 0x0033FF

    // Clear canvas to white
    olive::fill(&pixels[0], WIDTH, HEIGHT, white);

    // Dynamic stripe dimensions based on the 32-unit aspect standard proportions (3:5:16:5:3)
    int stripe_h = (int)((HEIGHT * 5) / 32);
    int top_stripe_y = (int)((HEIGHT * 3) / 32);
    int bottom_stripe_y = (int)((HEIGHT * 24) / 32);

    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, top_stripe_y, WIDTH, (usz)stripe_h, blue);
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, bottom_stripe_y, WIDTH, (usz)stripe_h, blue);

    // Target geometric measurements for the Star of David
    int cx = (int)WIDTH / 2;
    int cy = (int)HEIGHT / 2;
    int r  = (int)HEIGHT / 6;

    int cos30 = (int)((float)r * 0.866025f);
    int sin30 = r / 2;

    // Upward pointing triangle coordinate nodes
    int top_x = cx;
    int top_y = cy - r;
    int b_left_x = cx - cos30;
    int b_left_y = cy + sin30;
    int b_right_x = cx + cos30;
    int b_right_y = cy + sin30;

    olive::draw_line(&pixels[0], WIDTH, HEIGHT, top_x, top_y, b_left_x, b_left_y, blue);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, b_left_x, b_left_y, b_right_x, b_right_y, blue);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, b_right_x, b_right_y, top_x, top_y, blue);

    // Downward pointing triangle coordinate nodes
    int bottom_x = cx;
    int bottom_y = cy + r;
    int t_left_x = cx - cos30;
    int t_left_y = cy - sin30;
    int t_right_x = cx + cos30;
    int t_right_y = cy - sin30;

    olive::draw_line(&pixels[0], WIDTH, HEIGHT, bottom_x, bottom_y, t_left_x, t_left_y, blue);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, t_left_x, t_left_y, t_right_x, t_right_y, blue);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, t_right_x, t_right_y, bottom_x, bottom_y, blue);

    String file_path = "flag_israel.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn bool flag_romania_example() {
    // Proportions: 3 equal vertical bands (Blue, Yellow, Red)
    usz stripe_w = WIDTH / 3;

    // Official colors in 0xAABBGGRR hex format:
    uint cobalt_blue = 0xFF951C00; // #001C95
    uint chrome_yellow = 0xFF00D4FC; // #FCD400
    uint vermilion_red = 0xFF2B20CE; // #CE202B

    // Band 1: Blue
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, 0, stripe_w, HEIGHT, cobalt_blue);

    // Band 2: Yellow (Center)
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, (int)stripe_w, 0, stripe_w, HEIGHT, chrome_yellow);

    // Band 3: Red (Right)
    // Using remainder width for the last block handles uneven divisions perfectly
    usz last_stripe_w = WIDTH - (stripe_w * 2);
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, (int)(stripe_w * 2), 0, last_stripe_w, HEIGHT, vermilion_red);

    String file_path = "flag_romania.ppm";
    libc::Errno result = olive::save_to_ppm_file(&pixels[0], WIDTH, HEIGHT, file_path);
    return (int)result == 0;
}

fn int main() {
    if (!checker_example()) return 1;
    if (!circle_example()) return 1;
    if (!line_example()) return 1;
    if (!triangle_example()) return 1;
    if (!alpha_example()) return 1;
    if (!flag_japan_example()) return 1;
    if (!flag_israel_example()) return 1;
    if (!flag_romania_example()) return 1;
    
    io::printfn("All images generated successfully via native executable pipeline!");
    return 0;
}