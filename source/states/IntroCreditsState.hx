package states;

class IntroCreditsState extends BaseState
{
	var bg:FlxSpriteExt;

	var wait_for_next:Int = 60 * 10;

	override public function create()
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		bg = new FlxSpriteExt(0, 0, AssetPaths.credits__png);
		bg.scrollFactor.set(0, 0);

		add(bg);
	}

	override function update(elapsed:Float)
	{
		wait_for_next--;
		if (Ctrl.any(Ctrl.anyB) && wait_for_next > 0)
			wait_for_next = 0;
		if (wait_for_next == 0)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
			{
				FlxG.switchState(new TitleState());
			}, true);
		}
		super.update(elapsed);
	}
}
