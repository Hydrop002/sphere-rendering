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
    vec2 baseUV = floor(ScreenSize / 2.0);
    vec2 posXUV1 = baseUV;
    vec2 posYUV1 = vec2(baseUV.x + 1.0, baseUV.y);
    vec2 posZUV1 = vec2(baseUV.x + 2.0, baseUV.y);
    vec2 rotZUV1 = vec2(baseUV.x + 3.0, baseUV.y);
    // vec2 rotZUV2 = vec2(baseUV.x + 3.0, baseUV.y + 1.0);
    // vec2 rotZUV3 = vec2(baseUV.x + 3.0, baseUV.y + 2.0);
    vec2 rotYUV1 = vec2(baseUV.x + 4.0, baseUV.y);
    // vec2 rotYUV2 = vec2(baseUV.x + 4.0, baseUV.y + 1.0);
    // vec2 rotYUV3 = vec2(baseUV.x + 4.0, baseUV.y + 2.0);
    vec2 fovUV1 = vec2(baseUV.x + 5.0, baseUV.y);
    if (uv == posXUV1) {  // posX use 24 bits
        if (marker1 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == posYUV1) {  // posY use 24 bits
        if (marker2 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == posZUV1) {  // posZ use 24 bits
        if (marker3 > 0.5)
            fragColor = vec4(vertexColor.rgb, 1.0);
        else
            discard;
    } else if (uv == rotZUV1) {  // rotX use 24 bits
        if (marker1 > 0.5) {
            vec3 viewZ = vec3(ModelViewMat[0].z, ModelViewMat[1].z, ModelViewMat[2].z);
            viewZ = (viewZ + 1.0) / 2.0;
            viewZ = floor(viewZ * 255.0) / 255.0;
            fragColor = vec4(viewZ, 1.0);
        } else {
            discard;
        }
    }/* else if (uv == rotZUV2) {
        if (marker1 > 0.5) {
            vec3 viewZ = vec3(ModelViewMat[0].z, ModelViewMat[1].z, ModelViewMat[2].z);
            viewZ = (viewZ + 1.0) / 2.0;
            viewZ = floor(fract(viewZ * 255.0) * 256.0) / 255.0;
            fragColor = vec4(viewZ, 1.0);
        } else {
            discard;
        }
    } else if (uv == rotZUV3) {
        if (marker1 > 0.5) {
            vec3 viewZ = vec3(ModelViewMat[0].z, ModelViewMat[1].z, ModelViewMat[2].z);
            viewZ = (viewZ + 1.0) / 2.0;
            viewZ = floor(fract(viewZ * 255.0 * 256.0) * 256.0) / 255.0;
            fragColor = vec4(viewZ, 1.0);
        } else {
            discard;
        }
    }*/ else if (uv == rotYUV1) {  // rotY use 24 bits
        if (marker1 > 0.5) {
            vec3 viewY = vec3(ModelViewMat[0].y, ModelViewMat[1].y, ModelViewMat[2].y);
            fragColor = vec4((viewY + 1.0) / 2.0, 1.0);
        } else {
            discard;
        }
    }/* else if (uv == rotYUV2) {
        if (marker1 > 0.5) {
            vec3 viewY = vec3(ModelViewMat[0].y, ModelViewMat[1].y, ModelViewMat[2].y);
            viewY = (viewY + 1.0) / 2.0;
            viewY = floor(fract(viewY * 255.0) * 256.0) / 255.0;
            fragColor = vec4(viewY, 1.0);
        } else {
            discard;
        }
    } else if (uv == rotYUV3) {
        if (marker1 > 0.5) {
            vec3 viewY = vec3(ModelViewMat[0].y, ModelViewMat[1].y, ModelViewMat[2].y);
            viewY = (viewY + 1.0) / 2.0;
            viewY = floor(fract(viewY * 255.0 * 256.0) * 256.0) / 255.0;
            fragColor = vec4(viewY, 1.0);
        } else {
            discard;
        }
    }*/ else if (uv == fovUV1) {  // fov use 8 bits
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
