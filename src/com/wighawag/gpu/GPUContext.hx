package com.wighawag.gpu;
import nme.geom.Rectangle;
import nme.utils.ByteArray;
import nme.geom.Matrix3D;
using nme.Vector;
import nme.display3D.Context3D;
import nme.utils.Endian;

class GPUContext {

	private var context3D : Context3D;
	private var projectionMatrix : Matrix3D;

	private  var availableTextures : Hash<TextureData>;
	private var programs(default,null) : Array<GPUProgram>;

    public function new(context3D : Context3D) : Void {
	    this.context3D = context3D;
	    #if cpp
	    context3D.setRenderMethod(render);
	    #end
	    reset();
    }

	public function setAvailableTextures(nativeTextures : Hash<TextureData>) : Void{
		this.availableTextures = nativeTextures;
	}

    private var i = 0;
	public function render(rect : Rectangle) : Void{

        context3D.setBlendFactors(nme.display3D.Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA, nme.display3D.Context3DBlendFactor.ONE);

        context3D.clear(0, 0, 0, 1);

		for(program in programs){
			program.execute();
		}

		context3D.present();

		reset();
	}

	public function resize(width : Int, height : Int) : Void{
		context3D.configureBackBuffer(width, height, 2, false); //antialis, depth and stencil ?

		projectionMatrix = new Matrix3D(Vector.ofArray([
		2/width, 0, 0, 0,
		0, -2/height, 0, 0,
		0, 0, -1, 0,
		-1, 1, 0, 1
		]));
	}

	public function reset() : Void{
		programs = new Array();
	}

	public function addProgram(program : GPUProgram) : Void{
		program.setContext(context3D);
		program.setProjectionMatrix(projectionMatrix);
		program.setAvailableTextures(availableTextures);
		programs.push(program);
	}

}
