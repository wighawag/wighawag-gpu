package com.wighawag.gpu;

import nme.utils.ByteArray;
import nme.utils.ByteArray;
import nme.utils.Endian;

import nme.geom.Matrix3D;
import nme.display3D.Context3D;


import nme.display3D.IndexBuffer3D;
import nme.display3D.VertexBuffer3D;
import nme.display3D.shaders.glsl.GLSLProgram;
import nme.display3D.shaders.glsl.GLSLVertexShader;
import nme.display3D.shaders.glsl.GLSLFragmentShader;

class GPUProgram {

	public var byteArrays : Hash<TextureBatch>;


	private var glslProgram : GLSLProgram;

	private var proj : Matrix3D;

	private var vertexBuffer : VertexBuffer3D;
	private var indexBuffer : IndexBuffer3D;

	private var context3D : Context3D;
	private var availableTextures : Hash<TextureData>;

    public function new() {
	    byteArrays = new Hash();
    }

	public function setContext(context3D : Context3D) : Void{
		if(this.context3D != context3D){
			this.context3D = context3D;


            var vertShader =
            "attribute vec2 position;" +
            "attribute vec2 uv;" +
            "attribute float alpha;" +
            "uniform mat4 proj;" +
            "varying vec2 vTexCoord;" +
            "varying float vAlpha;" +
            "void main() {" +
            " gl_Position = proj * vec4(position, 0.0, 1.0);" +
            " vTexCoord = uv;" +
            " vAlpha = alpha;" +
            "}";

        var vertexAgalInfo = '{"varnames":{"uv":"va1","proj":"vc0","alpha":"va2","position":"va0"},"agalasm":"m44 op, va0, vc0\\nmov v0, va1\\nmov v1, va2","storage":{},"types":{},"info":"","consts":{}}';


        var fragShader = // - not on desktop ? 'precision mediump float;' +
            "varying vec2 vTexCoord;" +
            "varying float vAlpha;" +
            "uniform sampler2D texture;" +
            "void main() {" +
            "vec4 texColor = texture2D(texture, vTexCoord);" +
            "float blendAlpha = vAlpha * texColor.w;" +
            "texColor.w = blendAlpha;" +
            "gl_FragColor = texColor;"+
            "}";

            var fragmentAgalInfo = '{"varnames":{"texture":"fs0"},"agalasm":"mov ft0, v0\\ntex ft1, ft0, fs0 <2d,clamp,linear>\\nmul ft1.w v1.x ft1.w\\nmov oc, ft1","storage":{},"types":{},"info":"","consts":{}}';

            glslProgram = new GLSLProgram(context3D);
            glslProgram.upload(new GLSLVertexShader(vertShader, vertexAgalInfo),new GLSLFragmentShader(fragShader, fragmentAgalInfo));


		}
	}

	public function setAvailableTextures(availableTextures : Hash<TextureData>) : Void{
		if(this.availableTextures !=availableTextures){
			this.availableTextures = availableTextures;
			for (textureId in availableTextures.keys()){
				var abyteArrays : Array<ByteArray> = new Array();
				var ba = new ByteArray();
				ba.endian = Endian.LITTLE_ENDIAN;
				abyteArrays.push(ba);
				var ba = new ByteArray();
				ba.endian = Endian.LITTLE_ENDIAN;
				abyteArrays.push(ba);
				byteArrays.set(textureId, new TextureBatch(textureId, abyteArrays, availableTextures.get(textureId)));
			}
		}

	}

	public function setProjectionMatrix(proj : Matrix3D) : Void{
		this.proj = proj;
	}

	public function reset() : Void{
		// reset bytearrays (at least the position)
		for(textureBatch in byteArrays){
			textureBatch.byteArrays[0].position =0;
			textureBatch.byteArrays[1].position =0;
		}

	}

	public function execute() : Void{

		// TODO texture need to be ordered
		for (textureBatch in byteArrays){

			if(textureBatch.byteArrays[0].position == 0){
				continue;
			}

			var dataPerVertex = 5;
			var indexByteArray = textureBatch.byteArrays[0];
			var numIndices = Std.int(indexByteArray.position / 2);
			var vertexByteArray = textureBatch.byteArrays[1];
			var numVertices = Std.int(vertexByteArray.position / (4 *dataPerVertex));


			// TODO might move it into initialization for optimization if possible (knowing how many things to draw)
			vertexBuffer  = context3D.createVertexBuffer(numVertices, dataPerVertex);
			vertexBuffer.uploadFromByteArray(vertexByteArray, 0, 0, numVertices);

            glslProgram.attach();
            glslProgram.setVertexUniformFromMatrix("proj",proj, true);
            glslProgram.setTextureAt("texture", textureBatch.textureData.texture);
            glslProgram.setVertexBufferAt("position",vertexBuffer, 0, nme.display3D.Context3DVertexBufferFormat.FLOAT_2);
            glslProgram.setVertexBufferAt("uv",vertexBuffer, 2, nme.display3D.Context3DVertexBufferFormat.FLOAT_2);
            glslProgram.setVertexBufferAt("alpha",vertexBuffer, 4, nme.display3D.Context3DVertexBufferFormat.FLOAT_1);


			indexBuffer = context3D.createIndexBuffer(numIndices);
			indexBuffer.uploadFromByteArray(indexByteArray,0,0, numIndices);
			context3D.drawTriangles(indexBuffer, 0, Std.int(numVertices /2));

		}

	}

	public function dispose() : Void{
		//TODO destroy bindings and buffers
	}
}






