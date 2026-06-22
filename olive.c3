module olive;

import libc;
import std::io;

fn void swap_int(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

fn void fill(uint *pixels, usz img_w, usz img_h, uint color) {
    for (usz i = 0; i < img_w * img_h; ++i) {
        pixels[i] = color;
    }
}

fn void fill_rect(uint *pixels, usz img_w, usz img_h, int x, int y, usz w, usz h, uint color) {
    for (usz r = 0; r < h; ++r) {
        int cur_y = y + (int)r;
        if (cur_y < 0 || cur_y >= (int)img_h) continue;

        for (usz c = 0; c < w; ++c) {
            int cur_x = x + (int)c;
            if (cur_x < 0 || cur_x >= (int)img_w) continue;

            usz index = (usz)cur_y * img_w + (usz)cur_x;
            pixels[index] = color;
        }
    }
}

fn void fill_circle(uint *pixels, usz img_w, usz img_h, int cx, int cy, int r, uint color) {
    int x0 = cx - r;
    int y0 = cy - r;
    int x1 = cx + r;
    int y1 = cy + r;

    for (int y = y0; y <= y1; ++y) {
        if (y < 0 || y >= (int)img_h) continue;
        for (int x = x0; x <= x1; ++x) {
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
    int dx = libc::abs(x1 - x0);
    int dy = -libc::abs(y1 - y0);
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int cur_x = x0;
    int cur_y = y0;

    while (true) {
        if (cur_x >= 0 && cur_x < (int)img_w && cur_y >= 0 && cur_y < (int)img_h) {
            usz index = (usz)cur_y * img_w + (usz)cur_x;
            pixels[index] = color;
        }

        if (cur_x == x1 && cur_y == y1) break;

        int e2 = 2 * err;
        if (e2 >= dy) {
            err += dy;
            cur_x += sx;
        }
        if (e2 <= dx) {
            err += dx;
            cur_y += sy;
        }
    }
}

fn void fill_triangle(uint *pixels, usz img_w, usz img_h, int x0, int y0, int x1, int y1, int x2, int y2, uint color) {
    if (y0 > y1) { swap_int(&x0, &x1); swap_int(&y0, &y1); }
    if (y0 > y2) { swap_int(&x0, &x2); swap_int(&y0, &y2); }
    if (y1 > y2) { swap_int(&x1, &x2); swap_int(&y1, &y2); }

    if (y0 == y2) return;

    for (int y = y0; y <= y2; ++y) {
        if (y < 0 || y >= (int)img_h) continue;

        bool is_top_half = y < y1;
        float alpha = (float)(y - y0) / (float)(y2 - y0);
        float beta  = is_top_half ? (float)(y - y0) / (float)(y1 - y0) : (float)(y - y1) / (float)(y2 - y1);

        int ax = x0 + (int)((float)(x2 - x0) * alpha);
        int bx = is_top_half ? x0 + (int)((float)(x1 - x0) * beta) : x1 + (int)((float)(x2 - x1) * beta);

        if (ax > bx) swap_int(&ax, &bx);

        if (ax < 0) ax = 0;
        if (bx >= (int)img_w) bx = (int)img_w - 1;

        for (int x = ax; x <= bx; ++x) {
            usz index = (usz)y * img_w + (usz)x;
            pixels[index] = color;
        }
    }
}

fn libc::Errno save_to_ppm_file(uint *pixels, usz img_w, usz img_h, String file_path) {
    void *f = libc::fopen((ZString)file_path.ptr, "wb");
    if (f == null) {
        return libc::errno(); // Added parentheses to call the function
    }

    libc::fprintf(f, "P6\n%Z %Z\n255\n", img_w, img_h);

    for (usz i = 0; i < img_w * img_h; ++i) {
        uint pixel = pixels[i];
        char[3] bytes;
        bytes[0] = (char)((pixel >> (8 * 0)) & 0xFF); // R
        bytes[1] = (char)((pixel >> (8 * 1)) & 0xFF); // G
        bytes[2] = (char)((pixel >> (8 * 2)) & 0xFF); // B
        libc::fwrite(&bytes, 1, 3, f);
    }

    libc::fclose(f);
    return (libc::Errno)0;
}