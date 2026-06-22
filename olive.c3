module olive;

import std::io;
import libc;

macro @return_defer(#value) {
    return #value;
}

fn void fill(uint *pixels, usz width, usz height, uint color){
    for (usz i = 0; i < width * height; ++i){
        pixels[i] = color;
    }
}

fn void fill_rect(uint *pixels, usz img_w, usz img_h, int rx, int ry, usz rw, usz rh, uint color) {
    for (usz y = 0; y < rh; ++y) {
        int current_y = ry + (int)y;
        if (current_y < 0 || current_y >= (int)img_h) continue;

        for (usz x = 0; x < rw; ++x) {
            int current_x = rx + (int)x;
            if (current_x < 0 || current_x >= (int)img_w) continue;

            usz index = (usz)current_y * img_w + (usz)current_x;
            pixels[index] = color;
        }
    }
}

fn void fill_circle(uint *pixels, usz img_w, usz img_h, int cx, int cy, int r, uint color) {
    int start_x = cx - r;
    int start_y = cy - r;
    int end_x = cx + r;
    int end_y = cy + r;

    for (int y = start_y; y <= end_y; ++y) {
        if (y < 0 || y >= (int)img_h) continue;
        
        for (int x = start_x; x <= end_x; ++x) {
            if (x < 0 || x >= (int)img_w) continue;

            int dx = x - cx;
            int dy = y - cy;

            if (dx * dx + dy * dy <= r * r) {
                usz index = (usz)y * img_w + (usz)x;
                pixels[index] = color;
            }
        }
    }
}

fn void draw_line(uint *pixels, usz img_w, usz img_h, int x0, int y0, int x1, int y1, uint color) {
    int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
    int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
    
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    
    int err = dx - dy;

    while (true) {
        if (x0 >= 0 && x0 < (int)img_w && y0 >= 0 && y0 < (int)img_h) {
            usz index = (usz)y0 * img_w + (usz)x0;
            pixels[index] = color;
        }

        if (x0 == x1 && y0 == y1) break;

        int e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;
        }
        if (e2 < dx) {
            err += dx;
            y0 += sy;
        }
    }
}

fn libc::Errno save_to_ppm_file(uint *pixels, usz width, usz height, String file_path){
    File? f = file::open(file_path, "wb");
    if (catch err = f) {
        io::printfn("Failed to open file. libc errno: %d", libc::errno());
        @return_defer((libc::Errno)libc::errno());
    }
    
    defer (void)f.close(); 

    void*? actual_file = libc::fdopen(f.fd(), "wb");
    if (catch err = actual_file) {
        io::printfn("Failed to bind stream via fdopen. libc errno: %d", libc::errno());
        @return_defer((libc::Errno)libc::errno());
    }

    (void)libc::fprintf(actual_file, "P6\n%zu %zu\n255\n", width, height);
    
    int err_check = libc::ferror(actual_file) ?? 0;
    if (err_check != 0) {
        io::printfn("Stream error detected via ferror. libc errno: %d", libc::errno());
        @return_defer((libc::Errno)libc::errno());
    }   
    
    usz total_pixels = width * height;
    for (usz i = 0; i < total_pixels; ++i) {
        uint pixel = pixels[i];
        
        char[3] bytes;
        bytes[0] = (char)((pixel >> (8 * 2)) & 0xFF); 
        bytes[1] = (char)((pixel >> (8 * 1)) & 0xFF); 
        bytes[2] = (char)((pixel >> (8 * 0)) & 0xFF); 
        
        (void)libc::fwrite(&bytes, 1, 3, actual_file);
    }
    
    (void)libc::fflush(actual_file);
    
    @return_defer((libc::Errno)0);
    return (libc::Errno)0;
}