// Fragment Shader (FSH)
precision mediump float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 texel_size;
uniform vec4 glow_color;
uniform float glow_intensity;

void main()
{
    vec4 original_color = texture2D(gm_BaseTexture, v_vTexcoord);
    vec4 glow = vec4(0.0);
    
    for (float x = -3.0; x <= 3.0; x += 1.0) {
        for (float y = -3.0; y <= 3.0; y += 1.0) {
            vec2 offset = vec2(x, y) * texel_size;
            glow += texture2D(gm_BaseTexture, v_vTexcoord + offset);
        }
    }
    
    glow /= 49.0; // Media dei pixel circostanti
    glow *= glow_intensity;
    
    gl_FragColor = mix(original_color, glow_color, glow.a * glow_color.a);
}