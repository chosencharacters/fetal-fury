package ui;

class DeathCounter extends FlxSpriteExt
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetPaths.counter__png, true, 350, 150);
		scrollFactor.set(0, 0);

		setPosition(FlxG.width - width - 32, FlxG.height - height);
	}

	override function update(elapsed:Float)
	{
		if (PlayState.deaths <= 50)
			animation.frameIndex = PlayState.deaths;
		else
			animation.frameIndex = 50;
		super.update(elapsed);
	}
}
