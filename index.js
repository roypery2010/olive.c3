const WIDTH = 800;
const HEIGHT = 600;

async function initWasm() {
    // 1. Fetch and instantiate the compiled C3 module
    const importObject = {
        env: {}
    };
    
    const response = await fetch('olive.wasm');
    const buffer = await response.arrayBuffer();
    const obj = await WebAssembly.instantiate(buffer, importObject);
    const wasm = obj.instance.exports;

    // 2. Clear canvas with a base background color (0xFF181818 - Hex ABGR format)
    wasm.wasm_fill(0xFF181818);

    // 3. Draw shapes using the exported C3 functions
    // Background rectangle base
    wasm.wasm_fill_rect(50, 50, 150, 100, 0xFF333333);
    
    // Centered Blue Circle
    wasm.wasm_fill_circle(WIDTH / 2, HEIGHT / 2, 120, 0xFFFF0000); 
    
    // Green Cross Lines
    wasm.wasm_draw_line(0, 0, WIDTH, HEIGHT, 0xFF00FF00); 
    wasm.wasm_draw_line(WIDTH, 0, 0, HEIGHT, 0xFF00FF00);

    // Front Magenta Triangle
    wasm.wasm_fill_triangle(
        WIDTH / 2, 80, 
        200, HEIGHT - 120, 
        WIDTH - 200, HEIGHT - 120, 
        0xFFFF00FF 
    );

    // 4. Set up HTML5 Canvas contexts
    const canvasElement = document.getElementById('canvas');
    const ctx = canvasElement.getContext('2d');
    const imageData = ctx.createImageData(WIDTH, HEIGHT);

    // 5. Slice directly into the shared WASM linear memory structure
    const wasmMemory = new Uint8Array(wasm.memory.buffer);
    const pixelBufferOffset = wasm.get_canvas_ptr();
    const totalBytes = WIDTH * HEIGHT * 4; // 4 bytes per pixel (RGBA)
    
    const pixelView = wasmMemory.subarray(pixelBufferOffset, pixelBufferOffset + totalBytes);

    // 6. Copy memory layout straight to your screen frame buffer
    imageData.data.set(pixelView);
    ctx.putImageData(imageData, 0, 0);
}

// Kickstart engine
initWasm().catch(console.error);