#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;
out float marker1;
out float marker2;
out float marker3;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);;

    vertexColor = Color;

    float alpha = round(vertexColor.a * 255.0);
    marker1 = float(alpha == 0.0);
    marker2 = float(alpha == 1.0);
    marker3 = float(alpha == 2.0);
    if (marker1 > 0.5 || marker2 > 0.5 || marker3 > 0.5) {
        vertexColor.a = 1.0;
    }
}
