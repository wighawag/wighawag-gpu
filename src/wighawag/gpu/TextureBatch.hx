/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.gpu;

import flash.utils.ByteArray;
import wighawag.asset.load.AssetManager;

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
