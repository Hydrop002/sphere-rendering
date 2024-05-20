#version 150

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

in vec4 vertexColor;
in float marker1;
in float marker2;
in float marker3;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = color * ColorModulator;

    vec2 uv = floor(gl_FragCoord.xy);
    vec2 posUV1 = floor(ScreenSize / 2.0);
    vec2 posUV2 = vec2(posUV1.x + 1.0, posUV1.y);
    vec2 posUV3 = vec2(posUV1.x + 2.0, posUV1.y);
    vec2 rotUV1 = vec2(posUV1.x, posUV1.y + 1.0);
    vec2 rotUV2 = vec2(posUV1.x + 1.0, posUV1.y + 1.0);
    vec2 fovUV = vec2(posUV1.x + 2.0, posUV1.y + 1.0);
    if (uv == posUV1) {
        if (marker1 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == posUV2) {
        if (marker2 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == posUV3) {
        if (marker3 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == rotUV1) {
        if (marker1 > 0.5) {
            vec3 viewZ = vec3(ModelViewMat[0].z, ModelViewMat[1].z, ModelViewMat[2].z);
            fragColor = vec4((viewZ + 1.0) / 2.0, 1.0);
        } else {
            discard;
        }
    } else if (uv == rotUV2) {
        if (marker1 > 0.5) {
            vec3 viewY = vec3(ModelViewMat[0].y, ModelViewMat[1].y, ModelViewMat[2].y);
            fragColor = vec4((viewY + 1.0) / 2.0, 1.0);
        } else {
            discard;
        }
    } else if (uv == fovUV) {
        if (marker1 > 0.5) {
            float halfFovY = atan(1.0 / ProjMat[1][1]);
            fragColor = vec4(vec3(halfFovY / 1.5708), 1.0);
        } else {
            discard;
        }
    } else if (marker1 > 0.5 || marker2 > 0.5 || marker3 > 0.5) {
        discard;
    }
}
