package shader;

class GreyShader extends hxsl.Shader {
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var active: Int = 1;

        function fragment() {
            if(active > 0) {
                var average = (pixelColor.r + pixelColor.g + pixelColor.b)/3;
                pixelColor = vec4(average, average, average, pixelColor.a);
            }
        }
    }
}