/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.gpu;

import flash.display3D.textures.Texture;

class TextureData {

    public var id(default, null) : String;
	public var texture(default,null) : Texture;

    // TODO add the following if it happens to be necessary
	//public var originalWidth(default,null) : Int;
	//public var originalHeight(default,null) : Int;

	public var uRatio(default,null) : Float;
	public var vRatio(default,null) : Float;

    public function new(id : String, texture : Texture, uRatio : Float, vRatio : Float) {
	    this.id = id;
        this.texture = texture;

	    this.uRatio = uRatio;
	    this.vRatio = vRatio;
    }
}
