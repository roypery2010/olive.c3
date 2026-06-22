module test;

import std::io;
import olive;

const usz TEST_W = 12;
const usz TEST_H = 12;
uint[144] test_pixels;

fn void test_fill() @test {
    uint target_color = 0xFF00FF;
    olive::fill(&test_pixels, TEST_W, TEST_H, target_color);

    for (usz i = 0; i < TEST_W * TEST_H; ++i) {
        assert(test_pixels[i] == target_color);
    }
}

fn void test_fill_rect_bounds() @test {
    uint bg_color = 0x000000;
    uint rect_color = 0xFFFFFF;
    
    olive::fill(&test_pixels, TEST_W, TEST_H, bg_color);
    olive::fill_rect(&test_pixels, TEST_W, TEST_H, 10, 10, 5, 5, rect_color);

    usz valid_index = 11 * TEST_W + 11;
    assert(test_pixels[valid_index] == rect_color);
}

fn void test_checker_logic() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0x000000);
    int cell_w = 4;
    int cell_h = 4;

    for (int r = 0; r < 3; ++r) {
        for (int c = 0; c < 3; ++c) {
            uint color = ((r + c) % 2 != 0) ? 0x111111 : 0xFF2020;
            olive::fill_rect(&test_pixels, TEST_W, TEST_H, c * cell_w, r * cell_h, (usz)cell_w, (usz)cell_h, color);
        }
    }
    assert(test_pixels[0] == 0xFF2020);
    assert(test_pixels[4] == 0x111111);
}

fn void test_fill_circle() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0x000000);
    olive::fill_circle(&test_pixels, TEST_W, TEST_H, 6, 6, 2, 0x20FF20);
    assert(test_pixels[6 * TEST_W + 6] == 0x20FF20);
}

fn void test_draw_line() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0x000000);
    olive::draw_line(&test_pixels, TEST_W, TEST_H, 0, 0, (int)TEST_W - 1, (int)TEST_H - 1, 0xFF2020);
    assert(test_pixels[0] == 0xFF2020);
    assert(test_pixels[(TEST_H - 1) * TEST_W + (TEST_W - 1)] == 0xFF2020);
}

fn void test_fill_triangle() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0x000000);
    // Draw small flat-bottomed triangle in center
    olive::fill_triangle(&test_pixels, TEST_W, TEST_H, 6, 2, 2, 8, 10, 8, 0x00FFFF);
    assert(test_pixels[6 * TEST_W + 6] == 0x00FFFF); // Center should be filled
}