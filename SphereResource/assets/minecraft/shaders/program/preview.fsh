#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D PreviewDiffuseSampler;

uniform vec4 ColorModulate;
uniform vec2 OutSize;
uniform float Time;

in vec2 texCoord;

out vec4 fragColor;

void main(){
    vec2 uv = floor(gl_FragCoord.xy);
    vec2 gtUV = vec2(floor(OutSize.x / 2.0), 0.0);
    float gt = floor(Time * 20.0);
    float preGt = round(texelFetch(PreviewDiffuseSampler, ivec2(gtUV), 0).r * 255.0);
    if (gt == preGt) {
        fragColor = texture(PreviewDiffuseSampler, texCoord) * ColorModulate;
    } else {
        fragColor = texture(DiffuseSampler, texCoord) * ColorModulate;
    }
    if (uv == gtUV) fragColor = vec4(gt / 255.0, 0.0, 0.0, 1.0);
}
