precision mediump float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel_size;
uniform float outline_thickness;
uniform vec4 outline_color;

void main()
{
    vec4 original_color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    if (original_color.a == 0.0) {
        float alpha = 0.0;
        int max_offset = int(outline_thickness);
        for (int x = -2; x <= 2; x++) {
            for (int y = -2; y <= 2; y++) {
                if (x == 0 && y == 0) continue; // Salta il pixel centrale
                vec2 offset = vec2(float(x), float(y)) * texel_size;
                alpha += texture2D(gm_BaseTexture, v_vTexcoord + offset).a;
            }
        }
        if (alpha > 0.0) {
            gl_FragColor = outline_color;
        } else {
            gl_FragColor = original_color;
        }
    } else {
        gl_FragColor = original_color;
    }
}