#version 400

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ParticlesSampler;
uniform sampler2D ParticlesDepthSampler;
uniform sampler2D WeatherSampler;
uniform sampler2D WeatherDepthSampler;
uniform sampler2D CloudsSampler;
uniform sampler2D CloudsDepthSampler;

uniform mat4 ProjMat;
uniform vec2 OutSize;
uniform float Time;

in vec2 texCoord;

#define NUM_LAYERS 6

#define STYLE 0  // 0:room,1:bloom,2:glass

vec4 color_layers[NUM_LAYERS];
float depth_layers[NUM_LAYERS];
int active_layers = 0;

mat4 proj;

out vec4 fragColor;

void try_insert( vec4 color, float depth ) {
    if ( color.a == 0.0 ) {
        return;
    }

    color_layers[active_layers] = color;
    depth_layers[active_layers] = depth;

    int jj = active_layers++;
    int ii = jj - 1;
    while ( jj > 0 && depth_layers[jj] > depth_layers[ii] ) {
        float depthTemp = depth_layers[ii];
        depth_layers[ii] = depth_layers[jj];
        depth_layers[jj] = depthTemp;

        vec4 colorTemp = color_layers[ii];
        color_layers[ii] = color_layers[jj];
        color_layers[jj] = colorTemp;

        jj = ii--;
    }
}

vec3 blend( vec3 dst, vec4 src ) {
    return ( dst * ( 1.0 - src.a ) ) + src.rgb;
}

float depth2dist(float depth) {
    float depth_ndc = depth * 2.0 - 1.0;
    float n = 0.05;
    float f = 768.0;
    return 2.0 * f * n / (f + n - (f - n) * depth_ndc);
}

vec3 screen2view(vec2 uv, float z) {
    vec3 pos_ndc = vec3(uv, z) * 2.0 - 1.0;
    vec4 view_pos = inverse(proj) * vec4(pos_ndc, 1.0);
    return view_pos.xyz / view_pos.w;
}

vec3 view2screen(vec3 pos) {
    vec4 pos_ndc = proj * vec4(pos, 1.0);
    pos_ndc /= pos_ndc.w;
    return (pos_ndc.xyz + 1.0) / 2.0;
}

vec2 get_sphere_depth(vec2 uv, vec3 center, float radius) {
    vec2 uv_ndc = uv * 2.0 - 1.0;
    mat4 proj_inv = inverse(proj);

    float a1 = proj_inv[2][0] - proj_inv[2][3] * center.x;
    float a2 = proj_inv[2][1] - proj_inv[2][3] * center.y;
    float a3 = proj_inv[2][2] - proj_inv[2][3] * center.z;
    float a4 = proj_inv[2][3] * radius;
    float c1 = (proj_inv[0][0] - proj_inv[0][3] * center.x) * uv_ndc.x + (proj_inv[1][0] - proj_inv[1][3] * center.x) * uv_ndc.y + proj_inv[3][0] - proj_inv[3][3] * center.x;
    float c2 = (proj_inv[0][1] - proj_inv[0][3] * center.y) * uv_ndc.x + (proj_inv[1][1] - proj_inv[1][3] * center.y) * uv_ndc.y + proj_inv[3][1] - proj_inv[3][3] * center.y;
    float c3 = (proj_inv[0][2] - proj_inv[0][3] * center.z) * uv_ndc.x + (proj_inv[1][2] - proj_inv[1][3] * center.z) * uv_ndc.y + proj_inv[3][2] - proj_inv[3][3] * center.z;
    float c4 = proj_inv[0][3] * uv_ndc.x * radius + proj_inv[1][3] * uv_ndc.y * radius + proj_inv[3][3] * radius;

    float a = a1 * a1 + a2 * a2 + a3 * a3 - a4 * a4;
    float b = 2.0 * (c1 * a1 + c2 * a2 + c3 * a3 - c4 * a4);
    float c = c1 * c1 + c2 * c2 + c3 * c3 - c4 * c4;
    float delta = 4.0 * (pow(a1 * c4 - a4 * c1, 2.0) + pow(a2 * c4 - a4 * c2, 2.0) + pow(a3 * c4 - a4 * c3, 2.0) - pow(a1 * c2 - a2 * c1, 2.0) - pow(a1 * c3 - a3 * c1, 2.0) - pow(a2 * c3 - a3 * c2, 2.0));
    if (delta >= 0.0) {
        float delta_sqrt = sqrt(delta);
        return (vec2((-b - delta_sqrt) / (2.0 * a), (-b + delta_sqrt) / (2.0 * a)) + 1.0) / 2.0;
    } else {
        return vec2(-1.0);
    }
}

void main() {
    color_layers[0] = texture( DiffuseSampler, texCoord );
    depth_layers[0] = texture( DiffuseDepthSampler, texCoord ).r;
    active_layers = 1;

    try_insert( texture( TranslucentSampler, texCoord ), texture( TranslucentDepthSampler, texCoord ).r );
    try_insert( texture( ItemEntitySampler, texCoord ), texture( ItemEntityDepthSampler, texCoord ).r );
    try_insert( texture( ParticlesSampler, texCoord ), texture( ParticlesDepthSampler, texCoord ).r );
    try_insert( texture( WeatherSampler, texCoord ), texture( WeatherDepthSampler, texCoord ).r );
    try_insert( texture( CloudsSampler, texCoord ), texture( CloudsDepthSampler, texCoord ).r );

    vec3 texelAccum = color_layers[0].rgb;
    float depthAccum = depth_layers[active_layers - 1];
    for ( int ii = 1; ii < active_layers; ++ii ) {
        texelAccum = blend( texelAccum, color_layers[ii] );
    }

    fragColor = vec4( texelAccum, 1.0 );

    ivec2 baseUV = ivec2(floor(OutSize / 2.0));
    ivec2 posUV1 = baseUV;
    ivec2 posUV2 = ivec2(baseUV.x, baseUV.y + 1);
    ivec2 posUV3 = ivec2(baseUV.x, baseUV.y + 2);
    ivec2 posUV4 = ivec2(baseUV.x, baseUV.y + 3);
    ivec2 rotZUV1 = ivec2(baseUV.x + 1, baseUV.y);
    ivec2 rotZUV2 = ivec2(baseUV.x + 1, baseUV.y + 1);
    ivec2 rotZUV3 = ivec2(baseUV.x + 1, baseUV.y + 2);
    ivec2 rotZUV4 = ivec2(baseUV.x + 1, baseUV.y + 3);
    ivec2 rotYUV1 = ivec2(baseUV.x + 2, baseUV.y);
    ivec2 rotYUV2 = ivec2(baseUV.x + 2, baseUV.y + 1);
    ivec2 rotYUV3 = ivec2(baseUV.x + 2, baseUV.y + 2);
    ivec2 rotYUV4 = ivec2(baseUV.x + 2, baseUV.y + 3);
    ivec2 miscUV1 = ivec2(baseUV.x + 3, baseUV.y);
    ivec2 miscUV2 = ivec2(baseUV.x + 3, baseUV.y + 1);
    ivec2 miscUV3 = ivec2(baseUV.x + 3, baseUV.y + 2);

    if (texelFetch(DiffuseSampler, ivec2(baseUV.x - 1, baseUV.y), 0) != vec4(0.0, 0.0, 0.0, 1.0)) return;

    uvec3 u1, u2, u3, u4;
    uint ux, uy, uz;

    vec3 pos;
    u1 = uvec3(texelFetch(DiffuseSampler, posUV1, 0).rgb * 255.0);
    u2 = uvec3(texelFetch(DiffuseSampler, posUV2, 0).rgb * 255.0);
    u3 = uvec3(texelFetch(DiffuseSampler, posUV3, 0).rgb * 255.0);
    u4 = uvec3(texelFetch(DiffuseSampler, posUV4, 0).rgb * 255.0);
    ux = bitfieldInsert(ux, u1.r, 0, 8);
    ux = bitfieldInsert(ux, u1.g, 8, 8);
    ux = bitfieldInsert(ux, u1.b, 16, 8);
    ux = bitfieldInsert(ux, u2.r, 24, 8);
    pos.x = uintBitsToFloat(ux);
    uy = bitfieldInsert(uy, u2.g, 0, 8);
    uy = bitfieldInsert(uy, u2.b, 8, 8);
    uy = bitfieldInsert(uy, u3.r, 16, 8);
    uy = bitfieldInsert(uy, u3.g, 24, 8);
    pos.y = uintBitsToFloat(uy);
    uz = bitfieldInsert(uz, u3.b, 0, 8);
    uz = bitfieldInsert(uz, u4.r, 8, 8);
    uz = bitfieldInsert(uz, u4.g, 16, 8);
    uz = bitfieldInsert(uz, u4.b, 24, 8);
    pos.z = uintBitsToFloat(uz);
    vec3 viewZ;
    u1 = uvec3(texelFetch(DiffuseSampler, rotZUV1, 0).rgb * 255.0);
    u2 = uvec3(texelFetch(DiffuseSampler, rotZUV2, 0).rgb * 255.0);
    u3 = uvec3(texelFetch(DiffuseSampler, rotZUV3, 0).rgb * 255.0);
    u4 = uvec3(texelFetch(DiffuseSampler, rotZUV4, 0).rgb * 255.0);
    ux = bitfieldInsert(ux, u1.r, 0, 8);
    ux = bitfieldInsert(ux, u1.g, 8, 8);
    ux = bitfieldInsert(ux, u1.b, 16, 8);
    ux = bitfieldInsert(ux, u2.r, 24, 8);
    viewZ.x = uintBitsToFloat(ux);
    uy = bitfieldInsert(uy, u2.g, 0, 8);
    uy = bitfieldInsert(uy, u2.b, 8, 8);
    uy = bitfieldInsert(uy, u3.r, 16, 8);
    uy = bitfieldInsert(uy, u3.g, 24, 8);
    viewZ.y = uintBitsToFloat(uy);
    uz = bitfieldInsert(uz, u3.b, 0, 8);
    uz = bitfieldInsert(uz, u4.r, 8, 8);
    uz = bitfieldInsert(uz, u4.g, 16, 8);
    uz = bitfieldInsert(uz, u4.b, 24, 8);
    viewZ.z = uintBitsToFloat(uz);
    vec3 viewY;
    u1 = uvec3(texelFetch(DiffuseSampler, rotYUV1, 0).rgb * 255.0);
    u2 = uvec3(texelFetch(DiffuseSampler, rotYUV2, 0).rgb * 255.0);
    u3 = uvec3(texelFetch(DiffuseSampler, rotYUV3, 0).rgb * 255.0);
    u4 = uvec3(texelFetch(DiffuseSampler, rotYUV4, 0).rgb * 255.0);
    ux = bitfieldInsert(ux, u1.r, 0, 8);
    ux = bitfieldInsert(ux, u1.g, 8, 8);
    ux = bitfieldInsert(ux, u1.b, 16, 8);
    ux = bitfieldInsert(ux, u2.r, 24, 8);
    viewY.x = uintBitsToFloat(ux);
    uy = bitfieldInsert(uy, u2.g, 0, 8);
    uy = bitfieldInsert(uy, u2.b, 8, 8);
    uy = bitfieldInsert(uy, u3.r, 16, 8);
    uy = bitfieldInsert(uy, u3.g, 24, 8);
    viewY.y = uintBitsToFloat(uy);
    uz = bitfieldInsert(uz, u3.b, 0, 8);
    uz = bitfieldInsert(uz, u4.r, 8, 8);
    uz = bitfieldInsert(uz, u4.g, 16, 8);
    uz = bitfieldInsert(uz, u4.b, 24, 8);
    viewY.z = uintBitsToFloat(uz);
    vec3 viewX = cross(viewY, viewZ);
    u1 = uvec3(texelFetch(DiffuseSampler, miscUV1, 0).rgb * 255.0);
    u2 = uvec3(texelFetch(DiffuseSampler, miscUV2, 0).rgb * 255.0);
    u3 = uvec3(texelFetch(DiffuseSampler, miscUV3, 0).rgb * 255.0);
    ux = bitfieldInsert(ux, u1.r, 0, 8);
    ux = bitfieldInsert(ux, u1.g, 8, 8);
    ux = bitfieldInsert(ux, u1.b, 16, 8);
    ux = bitfieldInsert(ux, u2.r, 24, 8);
    float cot = uintBitsToFloat(ux);
    uy = bitfieldInsert(uy, u2.g, 0, 8);
    uy = bitfieldInsert(uy, u2.b, 8, 8);
    uy = bitfieldInsert(uy, u3.r, 16, 8);
    uy = bitfieldInsert(uy, u3.g, 24, 8);
    float time = uintBitsToFloat(uy);

    float aspect = OutSize.x / OutSize.y;
    float n = 0.05;
    float f = 768.0;
    proj = mat4(cot / aspect, 0.0, 0.0, 0.0,
                0.0, cot, 0.0, 0.0,
                0.0, 0.0, -(f + n) / (f - n), -1.0,
                0.0, 0.0, -2.0 * f * n / (f - n), 0.0);

    mat3 viewInv = mat3(viewX, viewY, viewZ);
    mat3 view = transpose(viewInv);
    vec3 viewPos = screen2view(texCoord, depthAccum);
    vec3 worldPos = viewInv * viewPos;

    vec3 center = pos;
    vec3 viewCenter = view * center;
    float radius = 2.0 * time;
    vec4 tintColor = vec4(0.5, 0.8, 1.0, 1.0);
    float fresnel = 0.5;

    #if STYLE == 1
    vec4 lightColor = vec4(1.0, 0.5, 0.1, 1.0);
    float luminance = 2.0;
    float light = 0.0;
    float viewDist = length(worldPos);
    float lumiDist = length(worldPos - center) - radius;
    if (lumiDist > 0.0 && lumiDist < luminance) {
        light = 1.0 - lumiDist / luminance;
    }
    float bloom = 0.0;
    float centerDist = length(center);
    float angle = acos(dot(worldPos, center) / viewDist / centerDist);
    float angleMin = asin(radius / centerDist);
    float tanDist = centerDist * cos(angleMin);
    lumiDist = tanDist * tan(angle - angleMin);
    float bloomDist = tanDist / cos(angle - angleMin);
    if (lumiDist > 0.0 && lumiDist < luminance && viewDist > bloomDist) {
        bloom = 1.0 - lumiDist / luminance;
    }
    if (centerDist > radius && centerDist < radius + luminance) {
        bloom = max((radius + luminance - centerDist) / luminance, bloom);
    }
    light = max(light, bloom) * lightColor.a;
    #elif STYLE == 2
    float distortion = 0.2;
    #endif

    vec2 depthNearFar = get_sphere_depth(texCoord, viewCenter, radius);
    if (depthNearFar.x >= 0.0 || depthNearFar.y >= 0.0) {
        vec2 centerUV = view2screen(viewCenter).xy;
        if (depthNearFar.x <= depthNearFar.y) {  // cameraOutside
            vec3 posNear = viewInv * screen2view(texCoord, depthNearFar.x);
            vec3 normalNear = posNear - center;
            float dp = dot(-posNear, normalNear) / length(posNear) / length(normalNear);
            if (fresnel >= 0.0) fresnel *= dp;
            else fresnel *= dp - 1.0;
            if (depthAccum > depthNearFar.y) {
                #if STYLE == 0
                fragColor *= mix(tintColor * tintColor, vec4(1.0), fresnel);
                #elif STYLE == 1
                fragColor += mix(vec4(0.0), lightColor, light);
                fragColor += mix(tintColor * 2.0, vec4(0.0), fresnel);
                #elif STYLE == 2
                vec2 bias = normalize((centerUV - texCoord) * OutSize) * OutSize.y / OutSize * (1.0 - dp) * distortion;
                fragColor = texture(DiffuseSampler, texCoord + bias);
                fragColor *= mix(tintColor * tintColor, vec4(1.0), fresnel);
                #endif
            } else if (depthAccum > depthNearFar.x) {
                #if STYLE == 0
                fragColor *= mix(tintColor, vec4(1.0), fresnel);
                #elif STYLE == 1
                fragColor += mix(vec4(0.0), lightColor, light);
                fragColor += mix(tintColor, vec4(0.0), fresnel);
                #elif STYLE == 2
                vec2 bias = normalize((centerUV - texCoord) * OutSize) * OutSize.y / OutSize * (1.0 - dp) * distortion;
                fragColor = texture(DiffuseSampler, texCoord + bias);
                fragColor *= mix(tintColor, vec4(1.0), fresnel);
                #endif
            } else {
                #if STYLE == 1
                fragColor += mix(vec4(0.0), lightColor, light);
                #endif
            }
        } else {  // cameraInside
            vec3 posFar = viewInv * screen2view(texCoord, depthNearFar.y);
            vec3 normalFar = posFar - center;
            float dp = dot(posFar, normalFar) / length(posFar) / length(normalFar);
            if (fresnel >= 0.0) fresnel *= dp;
            else fresnel *= dp - 1.0;
            if (depthAccum > depthNearFar.y) {
                #if STYLE == 0
                fragColor *= mix(tintColor, vec4(1.0), fresnel * 0.5);
                #elif STYLE == 1
                fragColor += mix(vec4(0.0), tintColor, tintColor.a * 0.8);
                fragColor += mix(tintColor, vec4(0.0), fresnel * 0.5);
                #elif STYLE == 2
                vec2 bias = normalize((centerUV - texCoord) * OutSize) * OutSize.y / OutSize * (1.0 - dp) * distortion;
                fragColor = texture(DiffuseSampler, texCoord + bias);
                fragColor *= mix(tintColor, vec4(1.0), fresnel * 0.5);
                #endif
            } else {
                #if STYLE == 1
                fragColor += mix(vec4(0.0), tintColor, tintColor.a * 0.8);
                #endif
            }
        }
    } else {
        #if STYLE == 1
        fragColor += mix(vec4(0.0), lightColor, light);
        #endif
    }
    fragColor.a = 1.0;
    // if (gl_FragCoord.x < 100.0) fragColor = vec4(pos, 1.0);
}
