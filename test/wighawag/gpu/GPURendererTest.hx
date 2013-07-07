package wighawag.gpu;

import massive.munit.Assert;

class GPURendererTest {

    public function new()
    {

    }


    @Test
    public function testGpuRenderer():Void
    {
        new GPURenderer();
        Assert.isTrue(true);
    }
    
}
