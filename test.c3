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
    uint bg_color = 0xFF000000;
    uint rect_color = 0xFFFFFFFF; // Make alpha explicitly 0xFF to match output
    
    olive::fill(&test_pixels, TEST_W, TEST_H, bg_color);
    olive::fill_rect(&test_pixels, TEST_W, TEST_H, 10, 10, 5, 5, rect_color);

    usz valid_index = 11 * TEST_W + 11;
    assert(test_pixels[valid_index] == rect_color);
}

fn void test_alpha_blending() @test {
    uint bg_red = 0xFF0000FF;
    olive::fill(&test_pixels, TEST_W, TEST_H, bg_red);

    uint semi_blue = 0x7F000000 | (0xFF << 16); 
    olive::fill_rect(&test_pixels, TEST_W, TEST_H, 0, 0, TEST_W, TEST_H, semi_blue);

    uint blended_pixel = test_pixels[0];

    uint out_r = (blended_pixel >> 0)  & 0xFF;
    uint out_g = (blended_pixel >> 8)  & 0xFF;
    uint out_b = (blended_pixel >> 16) & 0xFF;
    uint out_a = (blended_pixel >> 24) & 0xFF;

    assert(out_r > 120 && out_r < 135);
    assert(out_b > 120 && out_b < 135);
    assert(out_g == 0);
    assert(out_a == 255); 
}

fn void test_checker_logic() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0xFF000000);
    int cell_w = 4;
    int cell_h = 4;

    for (int r = 0; r < 3; ++r) {
        for (int c = 0; c < 3; ++c) {
            // 0xAABBGGRR layout: Red color is 0xFF0000FF
            uint color = ((r + c) % 2 != 0) ? 0xFF111111 : 0xFF0000FF;
            olive::fill_rect(&test_pixels, TEST_W, TEST_H, c * cell_w, r * cell_h, (usz)cell_w, (usz)cell_h, color);
        }
    }
    // Verify against 0xAABBGGRR component layouts
    assert((test_pixels[0] & 0xFFFFFF) == 0x0000FF); // Pure Red
    assert((test_pixels[4] & 0xFFFFFF) == 0x111111); // Dark Gray
}

fn void test_fill_circle() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0xFF000000);
    olive::fill_circle(&test_pixels, TEST_W, TEST_H, 6, 6, 2, 0xFF20FF20);
    assert((test_pixels[6 * TEST_W + 6] & 0xFFFFFF) == 0x20FF20);
}

fn void test_draw_line() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0xFF000000);
    // 0xAABBGGRR layout: Pure Red is 0xFF0000FF
    olive::draw_line(&test_pixels, TEST_W, TEST_H, 0, 0, (int)TEST_W - 1, (int)TEST_H - 1, 0xFF0000FF);
    assert((test_pixels[0] & 0xFFFFFF) == 0x0000FF);
}

fn void test_fill_triangle() @test {
    olive::fill(&test_pixels, TEST_W, TEST_H, 0xFF000000);
    olive::fill_triangle(&test_pixels, TEST_W, TEST_H, 6, 2, 2, 8, 10, 8, 0xFFFFFF00);
    assert((test_pixels[6 * TEST_W + 6] & 0xFFFFFF) == 0xFFFF00); 
}