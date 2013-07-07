/****
* Wighawag License:
* - free to use for commercial and non commercial application
* - provided the modification done to it are given back to the community
* - use at your own risk
* 
****/

package wighawag.gpu;

import flash.display3D.Context3D;

interface GPUProgram {

/**
* set the gpu context to setup and send the draw call
**/
public function setContext(context3D : Context3D) : Void;

/**
 * set the available texture to be used
**/
public function setAvailableTextures(availableTextures : Array<TextureData>) : Void;

/**
 * execute the draw call
**/
public function execute() : Void;


/**
 * dispose
**/
public function dispose() : Void;

}
