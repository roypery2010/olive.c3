module olive;

import libc;
import std::io;

// Color channel shifts for standard 0xAABBGGRR pixel layout
const uint RED_SHIFT   = 0;
const uint GREEN_SHIFT = 8;
const uint BLUE_SHIFT  = 16;
const uint ALPHA_SHIFT = 24;

struct OliveC3_NormalizedRect {
    int x;
    int y;
    usz w;
    usz h;
}

// ============================================================================
// Core Inline Helpers
// ============================================================================

fn int olivec3_sign(int x) @inline {
    return (x > 0) ? 1 : ((x < 0) ? -1 : 0);
}

fn int olivec3_abs(int x) @inline {
    return (x < 0) ? -x : x;
}

fn void olivec3_swap(int *a, int *b) @inline {
    int temp = *a;
    *a = *b;
    *b = temp;
}

fn bool olivec3_canvas_null(uint *pixels) @inline {
    return pixels == null;
}

fn usz comp_index(usz stride, int x, int y) @inline {
    return (usz)y * stride + (usz)x;
}

// ============================================================================
// Library Implementation Body
// ============================================================================

fn bool olivec3_normalize_rect(uint *pixels, usz width, usz height, int x, int y, usz w, usz h, OliveC3_NormalizedRect *out_rect) {
    if (olivec3_canvas_null(pixels)) return false;

    int x1 = x;
    int y1 = y;
    int x2 = x + (int)w;
    int y2 = y + (int)h;

    if (x2 <= 0 || x1 >= (int)width) return false;
    if (y2 <= 0 || y1 >= (int)height) return false;

    if (x1 < 0) x1 = 0;
    if (y1 < 0) y1 = 0;
    if (x2 > (int)width)  x2 = (int)width;
    if (y2 > (int)height) y2 = (int)height;

    out_rect.x = x1;
    out_rect.y = y1;
    out_rect.w = (usz)(x2 - x1);
    out_rect.h = (usz)(y2 - y1);
    return true;
}

fn uint blend_pixels(uint dst, uint src) {
    uint src_a = (src >> ALPHA_SHIFT) & 0xFF;
    if (src_a == 255) return src;
    if (src_a == 0) return dst;

    float alpha = (float)src_a / 255.0f;
    float inv_alpha = 1.0f - alpha;

    uint src_r = (src >> RED_SHIFT)   & 0xFF;
    uint src_g = (src >> GREEN_SHIFT) & 0xFF;
    uint src_b = (src >> BLUE_SHIFT)  & 0xFF;

    uint dst_r = (dst >> RED_SHIFT)   & 0xFF;
    uint dst_g = (dst >> GREEN_SHIFT) & 0xFF;
    uint dst_b = (dst >> BLUE_SHIFT)  & 0xFF;

    uint out_r = (uint)((float)src_r * alpha + (float)dst_r * inv_alpha);
    uint out_g = (uint)((float)src_g * alpha + (float)dst_g * inv_alpha);
    uint out_b = (uint)((float)src_b * alpha + (float)dst_b * inv_alpha);
    uint out_a = 255;

    return ((uint)out_a << ALPHA_SHIFT) | 
           ((uint)out_b << BLUE_SHIFT)  | 
           ((uint)out_g << GREEN_SHIFT) | 
           ((uint)out_r << RED_SHIFT);
}

fn void fill(uint *pixels, usz width, usz height, uint color) {
    OliveC3_NormalizedRect bounds;
    if (!olivec3_normalize_rect(pixels, width, height, 0, 0, width, height, &bounds)) return;

    for (usz y = (usz)bounds.y; y < (usz)bounds.y + bounds.h; ++y) {
        for (usz x = (usz)bounds.x; x < (usz)bounds.x + bounds.w; ++x) {
            pixels[comp_index(width, (int)x, (int)y)] = color;
        }
    }
}

fn void fill_rect(uint *pixels, usz width, usz height, int x, int y, usz w, usz h, uint color) {
    OliveC3_NormalizedRect bounds;
    if (!olivec3_normalize_rect(pixels, width, height, x, y, w, h, &bounds)) return;

    for (usz r = 0; r < bounds.h; ++r) {
        int cur_y = bounds.y + (int)r;
        for (usz c = 0; c < bounds.w; ++c) {
            int cur_x = bounds.x + (int)c;
            usz index = comp_index(width, cur_x, cur_y);
            pixels[index] = blend_pixels(pixels[index], color);
        }
    }
}

fn void fill_circle(uint *pixels, usz width, usz height, int cx, int cy, int r, uint color) {
    OliveC3_NormalizedRect bounds;
    int x0 = cx - r;
    int y0 = cy - r;
    usz side = (usz)r * 2;

    if (!olivec3_normalize_rect(pixels, width, height, x0, y0, side, side, &bounds)) return;

    for (int y = bounds.y; y < bounds.y + (int)bounds.h; ++y) {
        for (int x = bounds.x; x < bounds.x + (int)bounds.w; ++x) {
            int dx = x - cx;
            int dy = y - cy;
            if (dx * dx + dy * dy <= r * r) {
                usz index = comp_index(width, x, y);
                pixels[index] = blend_pixels(pixels[index], color);
            }
        }
    }
}

fn void draw_line(uint *pixels, usz width, usz height, int x0, int y0, int x1, int y1, uint color) {
    int min_x = x0 < x1 ? x0 : x1;
    int min_y = y0 < y1 ? y0 : y1;
    usz span_x = (usz)olivec3_abs(x1 - x0);
    usz span_y = (usz)olivec3_abs(y1 - y0);

    OliveC3_NormalizedRect dummy;
    if (!olivec3_normalize_rect(pixels, width, height, min_x, min_y, span_x + 1, span_y + 1, &dummy)) return;

    int dx = olivec3_abs(x1 - x0);
    int dy = -olivec3_abs(y1 - y0);
    int sx = x0 < x1 ? 1 : -1;
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy;

    int cur_x = x0;
    int cur_y = y0;

    while (true) {
        if (cur_x >= 0 && cur_x < (int)width && cur_y >= 0 && cur_y < (int)height) {
            usz index = comp_index(width, cur_x, cur_y);
            pixels[index] = blend_pixels(pixels[index], color);
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

fn void fill_triangle(uint *pixels, usz width, usz height, int x0, int y0, int x1, int y1, int x2, int y2, uint color) {
    if (y0 > y1) { olivec3_swap(&x0, &x1); olivec3_swap(&y0, &y1); }
    if (y0 > y2) { olivec3_swap(&x0, &x2); olivec3_swap(&y0, &y2); }
    if (y1 > y2) { olivec3_swap(&x1, &x2); olivec3_swap(&y1, &y2); }

    if (y0 == y2) return;

    int min_x = x0 < x1 ? (x0 < x2 ? x0 : x2) : (x1 < x2 ? x1 : x2);
    int max_x = x0 > x1 ? (x0 > x2 ? x0 : x2) : (x1 > x2 ? x1 : x2);
    
    OliveC3_NormalizedRect dummy;
    if (!olivec3_normalize_rect(pixels, width, height, min_x, y0, (usz)(max_x - min_x), (usz)(y2 - y0), &dummy)) return;

    for (int y = y0; y <= y2; ++y) {
        if (y < 0 || y >= (int)height) continue;

        bool is_top_half = y < y1;
        float alpha = (float)(y - y0) / (float)(y2 - y0);
        float beta  = is_top_half ? (float)(y - y0) / (float)(y1 - y0) : (float)(y - y1) / (float)(y2 - y1);

        int ax = x0 + (int)((float)(x2 - x0) * alpha);
        int bx = is_top_half ? x0 + (int)((float)(x1 - x0) * beta) : x1 + (int)((float)(x2 - x1) * beta);

        if (ax > bx) { olivec3_swap(&ax, &bx); }

        if (ax < 0) ax = 0;
        if (bx >= (int)width) bx = (int)width - 1;

        for (int x = ax; x <= bx; ++x) {
            usz index = comp_index(width, x, y);
            pixels[index] = blend_pixels(pixels[index], color);
        }
    }
}

fn libc::Errno save_to_ppm_file(uint *pixels, usz width, usz height, String file_path) {
    if (olivec3_canvas_null(pixels)) return libc::errno();

    void *f = libc::fopen((ZString)file_path.ptr, "wb");
    if (f == null) {
        return libc::errno();
    }

    libc::fprintf(f, "P6\n%d %d\n255\n", (int)width, (int)height);

    for (usz y = 0; y < height; ++y) {
        for (usz x = 0; x < width; ++x) {
            uint pixel = pixels[comp_index(width, (int)x, (int)y)];
            char[3] bytes;
            bytes[0] = (char)((pixel >> RED_SHIFT)   & 0xFF); 
            bytes[1] = (char)((pixel >> GREEN_SHIFT) & 0xFF); 
            bytes[2] = (char)((pixel >> BLUE_SHIFT)  & 0xFF); 
            libc::fwrite(&bytes, 1, 3, f);
        }
    }

    libc::fclose(f);
    return (libc::Errno)0;
}