/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.gpu;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.geom.Matrix3D;
using flash.Vector;
import flash.display3D.Context3D;
import flash.utils.Endian;

using flash.display3D.Context3DUtils;

import msignal.Signal;

class GPUContext {

	private var context3D : Context3D;

	private  var availableTextures : Array<TextureData>;
	private var programs(default,null) : Array<GPUProgram>;

    public var onResize(default, null) : Signal2<Int, Int>;
    public var width(default, null) : Int;
    public var height(default, null) : Int;

    private var r : Int = 0;
    private var g : Int = 0;
    private var b : Int = 0;
    private var a : Int = 1;

    private var antiAlias : Int = 0;

    private var disposed : Bool;

    public function new(context3D : Context3D) : Void {


        programs = new Array();
        onResize = new Signal2();


	    this.context3D = context3D;
        disposed = false;

        context3D.setRenderCallback(render);


        reset();
    }

	public function setAvailableTextures(nativeTextures : Array<TextureData>) : Void{
		this.availableTextures = nativeTextures;
	}

    public function setClearColor(r : Int, g : Int, b : Int, a : Int) :Void{
        this.r = r;
        this.g = g;
        this.b = b;
        this.a = a;
    }

    public function setAntiAlias(value : Int) : Void{
        this.antiAlias = value;
        configureBackBuffer();
    }

	public function render(event : Event) : Void{
        if(disposed){
            Report.aWarning("GPUContext", "Context3D has been disposed");
            return;
        }

        context3D.clear(r, g, b, a);

		for(program in programs){
			program.execute();
		}

		context3D.present();
	}

	public function resize(width : Int, height : Int) : Void{
        this.width = width;
        this.height = height;
        configureBackBuffer();
        onResize.dispatch(width, height);
	}

    private function configureBackBuffer(): Void{
        context3D.configureBackBuffer(width, height, antiAlias, false); //TODO depth and stencil ?
    }

	public function reset() : Void{
		programs.splice(0,programs.length);  // TODO check is it better than "programs = new Array();" ?
	}

	public function addProgram(program : GPUProgram) : Void{
		program.setContext(context3D);
		program.setAvailableTextures(availableTextures);
		programs.push(program);
	}

    public function dispose() : Void{
        context3D.removeRenderCallback(render);
        context3D = null;
        availableTextures = null;
        for(program in programs){
            program.dispose();
        }
        programs = null;
        onResize = null;
        disposed = true;
    }

}
