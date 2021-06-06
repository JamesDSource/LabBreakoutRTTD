package shader;

class BuildingShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;
        @:import h3d.shader.NoiseLib;

        @param var offset: Float = 0;
        @param var bandSpacing: Float = 20;
        @param var bandThickness: Float = 6;
        @param var color: Vec3 = vec3(0.1, 0.1, 0.9);

        function fragment() {
            noiseSeed = 5;

            pixelColor.a *= 0.8;
            if(floor(absolutePosition.y + offset)%bandSpacing < bandThickness) {
                pixelColor = vec4(color, pixelColor.a);
            }
            else {
                pixelColor *= vec4(color, 1.0);
            }

            var noise = rgrad2(vec2(absolutePosition.x, absolutePosition.y + offset), 30);
            pixelColor.rgb += vec3((noise.x*noise.y)/4);

        }
    };
}