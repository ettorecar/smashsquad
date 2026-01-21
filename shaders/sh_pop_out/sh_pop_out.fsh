precision mediump float;

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float brightness_boost;
uniform float saturation_boost;

void main()
{
    vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord);
    
    // Aumenta la luminosità
    vec3 boosted_color = base_color.rgb * (1.0 + brightness_boost);
    
    // Aumenta la saturazione
    float luminance = dot(boosted_color, vec3(0.299, 0.587, 0.114));
    boosted_color = mix(vec3(luminance), boosted_color, 1.0 + saturation_boost);
    
    gl_FragColor = vec4(boosted_color, base_color.a) * v_vColour;
}