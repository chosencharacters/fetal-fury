package platforms;

class Pod extends FlxSpriteExt
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetPaths.pod__png);
		PlayState.self.miscBack.add(this);

		SoundPlayer.play_sound(AssetPaths.AnnouncerNewGame__ogg);
	}

	override function update(elapsed:Float)
	{
		FlxG.collide(this, PlayState.self.players);
		super.update(elapsed);
	}
}
