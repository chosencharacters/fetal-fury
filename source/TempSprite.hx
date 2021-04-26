import flixel.system.FlxAssets.FlxGraphicAsset;

class TempSprite extends FlxSpriteExt
{
	public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (animation.finished)
			kill();
	}
}
