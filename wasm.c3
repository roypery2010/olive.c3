module wasm;

import olive;

const usz CANVAS_WIDTH = 800;
const usz CANVAS_HEIGHT = 600;
const usz CANVAS_SIZE = CANVAS_WIDTH * CANVAS_HEIGHT;

// Global pixel buffer array accessible inside WASM linear memory
uint[CANVAS_SIZE] wasm_pixels;

// Returns the raw memory index address of the pixel array to JavaScript
fn uint* get_canvas_ptr() @export("get_canvas_ptr") {
    return &wasm_pixels;
}

fn void wasm_fill(uint color) @export("wasm_fill") {
    olive::fill(&wasm_pixels, CANVAS_WIDTH, CANVAS_HEIGHT, color);
}

fn void wasm_fill_rect(int x, int y, usz w, usz h, uint color) @export("wasm_fill_rect") {
    olive::fill_rect(&wasm_pixels, CANVAS_WIDTH, CANVAS_HEIGHT, x, y, w, h, color);
}

fn void wasm_fill_circle(int cx, int cy, int r, uint color) @export("wasm_fill_circle") {
    olive::fill_circle(&wasm_pixels, CANVAS_WIDTH, CANVAS_HEIGHT, cx, cy, r, color);
}

fn void wasm_draw_line(int x0, int y0, int x1, int y1, uint color) @export("wasm_draw_line") {
    olive::draw_line(&wasm_pixels, CANVAS_WIDTH, CANVAS_HEIGHT, x0, y0, x1, y1, color);
}

fn void wasm_fill_triangle(int x0, int y0, int x1, int y1, int x2, int y2, uint color) @export("wasm_fill_triangle") {
    olive::fill_triangle(&wasm_pixels, CANVAS_WIDTH, CANVAS_HEIGHT, x0, y0, x1, y1, x2, y2, color);
}