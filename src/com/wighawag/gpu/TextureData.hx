package com.wighawag.gpu;

import nme.display3D.textures.Texture;

class TextureData {

	public var texture(default,null) : Texture;

    // TODO add the following if it happens to be necessary
	//public var originalWidth(default,null) : Int;
	//public var originalHeight(default,null) : Int;

	public var uRatio(default,null) : Float;
	public var vRatio(default,null) : Float;

    public function new(texture : Texture, uRatio : Float, vRatio : Float) {
	    this.texture = texture;

	    this.uRatio = uRatio;
	    this.vRatio = vRatio;
    }
}
