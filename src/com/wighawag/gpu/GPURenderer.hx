package com.wighawag.gpu;

import nme.display3D.Context3DBlendFactor;

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.display3D.Context3DBlendFactor;


import nme.display.Stage3D;

import nme.events.ErrorEvent;
import nme.events.Event;


import com.wighawag.asset.load.BitmapAsset;
import com.wighawag.asset.renderer.Renderer;

import com.wighawag.utils.MathUtils;

import nme.display3D.Context3DTextureFormat;
import nme.display3D.textures.Texture;
import nme.display3D.Context3D;

import promhx.Promise;

import msignal.Signal;

class GPURenderer implements Renderer<GPUContext, BitmapAsset>{

	private var gpuContext : GPUContext;
	private var context3D : Context3D;


	private var stage3D : Stage3D;

	private var initialised : Promise<GPURenderer>;

	private var nativeTextures : Array<TextureData>;
	private var texturesToProcess : Array<BitmapAsset>;

    public var onResize(default, null) : Signal2<Int, Int>;
    public var width(default, null) : Int;
    public var height(default, null) : Int;

    public function new() {
        onResize = new Signal2();

	    nativeTextures = new Array();
    }

	public function init() : Promise<GPURenderer>{

        if(initialised == null){

            initialised = new Promise();

            var stage = nme.Lib.current.stage;


            // Use the first available Stage3D
            for (stage3D in stage.stage3Ds) {
                if (stage3D.context3D == null) {
                    this.stage3D = stage3D;
                }
            }

            if(stage3D ==null){
                Report.anError("GPURenderer", "No free Stage3Ds available");
                gotError(null);
            }


            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
            stage3D.addEventListener(ErrorEvent.ERROR, gotError);
            stage3D.requestContext3D();
        }

        return initialised;
	}

	private function gotError(event : ErrorEvent) : Void{
		dispose();
		initialised.reject(event);
	}

	public function onContext3DCreate(event : Event) : Void{

		stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
		context3D = stage3D.context3D;

		// TODO enabled through constructor argument or a debug method
		context3D.enableErrorChecking = true;

		gpuContext = new GPUContext(context3D);
		onResizeEvent(null);
		nme.Lib.current.stage.addEventListener(Event.RESIZE, onResizeEvent);

		if(texturesToProcess != null){
			uploadTextures(texturesToProcess);
			texturesToProcess = null;
		}

		initialised.resolve(this);

	}


	public function dispose() : Void
	{
		if(context3D != null)
		{
			context3D.dispose();
		}

		stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContext3DCreate);
		stage3D.removeEventListener(ErrorEvent.ERROR, gotError);
		stage3D = null;

        unloadAllTextures();
        gpuContext.dispose();
		gpuContext = null;
		context3D = null;


	}

	private function onResizeEvent (event : Event)
	{
        var stage = nme.Lib.current.stage;

        width = stage.stageWidth;
        height = stage.stageHeight;
        onResize.dispatch(width, height);

		if (gpuContext != null) {
			gpuContext.resize(width, height);
		}
	}

	public function lock() : GPUContext{
		gpuContext.reset();
		gpuContext.setAvailableTextures(nativeTextures);
		return gpuContext;
	}

	public function unlock() : Void{

	}

    public function reset() : Void{
        gpuContext.reset();
        unloadAllTextures();
    }

    public function setClearColor(r : Int, g : Int, b : Int, a : Int) :Void{
       gpuContext.setClearColor(r,g,b,a);
    }

    public function setAntiAlias(value : Int) : Void{
        gpuContext.setAntiAlias(value);
    }


// TODO ensure Textures
	public function uploadTextures(textures : Array<BitmapAsset>) : Void{

		if (context3D == null){
			texturesToProcess = textures;
			return;
		}

		for(texture in textures){

			var bitmapData = texture.bitmapData;

			var resizedWidth = MathUtils.nextPowerOfTwo(bitmapData.width);
			var resizedHeight = MathUtils.nextPowerOfTwo(bitmapData.height);

			var maxU = bitmapData.width / resizedWidth;
			var maxV = bitmapData.height / resizedHeight;

			if (bitmapData.width != resizedWidth || bitmapData.height != resizedHeight) {
				var resized = new BitmapData(resizedWidth, resizedHeight, bitmapData.transparent);
				resized.copyPixels(bitmapData,
				new Rectangle(0, 0, bitmapData.width, bitmapData.height), new Point(0, 0));
				bitmapData = resized;
			}

			// TODO compressed texture     (and optimize fro render to texture ?)
			// TODO mipmap ?
			var nativeTexture = context3D.createTexture(bitmapData.width, bitmapData.height,Context3DTextureFormat.BGRA, false);
			nativeTexture.uploadFromBitmapData(bitmapData);

			var textureData = new TextureData(texture.id, nativeTexture, maxU / texture.bitmapData.width, maxV /texture.bitmapData.height);

			//TODO  store maxU and maxV
			nativeTextures.push(textureData);
		}

        nativeTextures = nativeTextures.copy(); // ensure the ne texture are taken in consideration

	}

    public function unloadAllTextures() : Void{
        for(texture in nativeTextures){
            texture.texture.dispose();
        }
        nativeTextures = new Array();
    }

	public function unloadTextures(bitmapAssets : Array<BitmapAsset>) : Void{
        var newNativeTextures = new Array();

        for (texture in nativeTextures){
            var toBeRemoved : Bool = false;
            for (bitmapAsset in bitmapAssets){
                if(texture.id == bitmapAsset.id){
                    toBeRemoved = true;
                    texture.texture.dispose();
                    break;
                }
            }
            if(!toBeRemoved){
                newNativeTextures.push(texture);
            }

        }

        nativeTextures = newNativeTextures;
	}

}
