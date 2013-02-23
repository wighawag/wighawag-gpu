package com.wighawag.gpu;

import nme.utils.ByteArray;
import com.wighawag.asset.load.AssetManager;

class TextureBatch {

	public var bitmapId(default,null) : AssetId;
	public var byteArrays : Array<ByteArray>;

	public var textureData : TextureData;

    public function new(bitmapId : AssetId, byteArrays : Array<ByteArray>, texture : TextureData) {
	    this.bitmapId = bitmapId;
	    this.byteArrays = byteArrays;

	    this.textureData = texture;
    }
}
