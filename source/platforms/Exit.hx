package platforms;

class Exit extends FlxSpriteExt
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetPaths.exit__png);

		PlayState.self.exits.add(this);
	}
}
