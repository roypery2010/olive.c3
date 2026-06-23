module main;

import std::io;
import std::math;
import olive;

// Viewport bounds chosen to fit cleanly in a standard terminal window
const usz WIDTH = 80;
const usz HEIGHT = 60;
const uint BACKGROUND_COLOR = 0xFF181818; // Opaque Dark Gray (0xAABBGGRR)

uint[WIDTH * HEIGHT] pixels;

struct Vector3 {
    float x;
    float y;
    float z;
}

fn void checker_example() {
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
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Checker Pattern");
}

fn void circle_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2, (int)HEIGHT / 2, 15, 0xFFFF0000);
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Circle Canvas");
}

fn void line_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, 0, 0, (int)WIDTH, (int)HEIGHT, 0xFF00FF00);
    olive::draw_line(&pixels[0], WIDTH, HEIGHT, (int)WIDTH, 0, 0, (int)HEIGHT, 0xFF00FF00);
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Line Cross");
}

fn void triangle_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR); 
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, (int)WIDTH / 2, 5, 10, (int)HEIGHT - 10, (int)WIDTH - 10, (int)HEIGHT - 10, 0xFFFF00FF);            
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Triangles");
}

fn void flag_japan_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, 0xFFFFFFFF);
    int center_x = (int)(WIDTH / 2);
    int center_y = (int)(HEIGHT / 2);
    int radius = (int)(HEIGHT * 3 / 10); 
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, center_x, center_y, radius, 0xFF2D00BC);
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Flag of Japan");
}

fn void flag_romania_example() {
    usz stripe_w = WIDTH / 3;
    uint cobalt_blue = 0xFF951C00; 
    uint chrome_yellow = 0xFF00D4FC; 
    uint vermilion_red = 0xFF2B20CE; 

    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, 0, stripe_w, HEIGHT, cobalt_blue);
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, (int)stripe_w, 0, stripe_w, HEIGHT, chrome_yellow);

    usz last_stripe_w = WIDTH - (stripe_w * 2);
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, (int)(stripe_w * 2), 0, last_stripe_w, HEIGHT, vermilion_red);
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Flag of Romania");
}

fn void flag_israel_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, 0xFFFFFFFF);

    usz stripe_h = HEIGHT / 10;
    uint techelet_blue = 0xFFB37000; 

    // Horizontal bands
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, (int)stripe_h, WIDTH, stripe_h, techelet_blue);
    olive::fill_rect(&pixels[0], WIDTH, HEIGHT, 0, (int)(HEIGHT - (stripe_h * 2)), WIDTH, stripe_h, techelet_blue);

    // Geometry constructs for Magen David structure
    int cx = (int)WIDTH / 2;
    int cy = (int)HEIGHT / 2;
    int r = 10; 

    // Upward Triangle Layer
    int top_x1 = cx;
    int top_y1 = cy - r - 2;
    int top_x2 = cx - r - 4;
    int top_y2 = cy + (r / 2) + 2;
    int top_x3 = cx + r + 4;
    int top_y3 = cy + (r / 2) + 2;
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, top_x1, top_y1, top_x2, top_y2, top_x3, top_y3, techelet_blue);
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, top_x1, top_y1 + 3, top_x2 + 2, top_y2 - 1, top_x3 - 2, top_y3 - 1, 0xFFFFFFFF);

    // Downward Triangle Layer
    int bot_x1 = cx;
    int bot_y1 = cy + r + 2;
    int bot_x2 = cx - r - 4;
    int bot_y2 = cy - (r / 2) - 2;
    int bot_x3 = cx + r + 4;
    int bot_y3 = cy - (r / 2) - 2;
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, bot_x1, bot_y1, bot_x2, bot_y2, bot_x3, bot_y3, techelet_blue);
    olive::fill_triangle(&pixels[0], WIDTH, HEIGHT, bot_x1, bot_y1 - 3, bot_x2 + 2, bot_y2 + 1, bot_x3 - 2, bot_y3 + 1, 0xFFFFFFFF);

    // Open center hex intersection core
    olive::fill_circle(&pixels[0], WIDTH, HEIGHT, cx, cy, r - 3, 0xFFFFFFFF);

    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Flag of Israel");
}

fn void cube_3d_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);

    Vector3[8] vertices = {
        { -1.0f, -1.0f, -1.0f }, {  1.0f, -1.0f, -1.0f },
        {  1.0f,  1.0f, -1.0f }, { -1.0f,  1.0f, -1.0f },
        { -1.0f, -1.0f,  1.0f }, {  1.0f, -1.0f,  1.0f },
        {  1.0f,  1.0f,  1.0f }, { -1.0f,  1.0f,  1.0f }
    };

    int[24] edges = {
        0, 1,  1, 2,  2, 3,  3, 0, 
        4, 5,  5, 6,  6, 7,  7, 4, 
        0, 4,  1, 5,  2, 6,  3, 7  
    };

    float angle_x = 0.4f; 
    float angle_y = 0.5f;

    float cos_x = math::cos(angle_x);
    float sin_x = math::sin(angle_x);
    float cos_y = math::cos(angle_y);
    float sin_y = math::sin(angle_y);

    int[8] projected_x;
    int[8] projected_y;

    float fov_scale = 45.0f;
    float camera_distance = 2.5f;

    int half_w = (int)WIDTH / 2;
    int half_h = (int)HEIGHT / 2;

    for (usz i = 0; i < 8; ++i) {
        Vector3 v = vertices[i];
        float y1 = v.y * cos_x - v.z * sin_x;
        float z1 = v.y * sin_x + v.z * cos_x;
        float x2 = v.x * cos_y + z1 * sin_y;
        float z2 = -v.x * sin_y + z1 * cos_y;
        float target_z = z2 + camera_distance;

        projected_x[i] = half_w + (int)((x2 * fov_scale) / target_z);
        projected_y[i] = half_h - (int)((y1 * fov_scale) / target_z);
    }

    uint line_color = 0xFF00AAFF;
    for (usz i = 0; i < 12; ++i) {
        int idx1 = edges[i * 2];
        int idx2 = edges[i * 2 + 1];
        olive::draw_line(&pixels[0], WIDTH, HEIGHT, projected_x[idx1], projected_y[idx1], projected_x[idx2], projected_y[idx2], line_color);
    }
    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "3D Projected Cube");
}

fn void text_showcase_example() {
    olive::fill(&pixels[0], WIDTH, HEIGHT, BACKGROUND_COLOR);

    // Fallback standard text engine pipeline tests
    olive::olive_text(&pixels[0], WIDTH, HEIGHT, 6, 6, "STANDARD FONTS", 1, 0xFFFFFFFF);
    olive::olive_text(&pixels[0], WIDTH, HEIGHT, 6, 18, "OLIVE CORE ENGINE", 1, 0xFFFFAA00);

    // Drop shadow pixel-art minecraft font engine tests
    olive::draw_minecraft_text(&pixels[0], WIDTH, HEIGHT, 6, 34, "MINECRAFT LOOK", 1, 0xFF00FFCC);
    olive::draw_minecraft_text(&pixels[0], WIDTH, HEIGHT, 6, 46, "TERMINAL ONLINE", 1, 0xFF55FFFF);

    olive::render_to_terminal(&pixels[0], WIDTH, HEIGHT, "Text Variant Matrices");
}

fn int main() {
    checker_example();
    circle_example();
    line_example();
    triangle_example();
    flag_japan_example();
    flag_romania_example();
    flag_israel_example();
    cube_3d_example();
    text_showcase_example();
    
    return 0;
}