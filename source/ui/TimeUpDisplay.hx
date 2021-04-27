package ui;

class TimeUpDisplay extends FlxSpriteExt
{
	var gray_scale_delay:Int = 60;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		scrollFactor.set(0, 0);

		loadGraphic(AssetPaths.time_up__png);

		FlxG.sound.music.pause();
		SoundPlayer.play_sound(AssetPaths.record_scratch__ogg);

		PlayState.self.hitstop = 2;

		PlayState.self.ui.add(this);

		y -= height;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		gray_scale_delay--;

		PlayState.self.hitstop = 2;

		if (gray_scale_delay > 0)
			return;
		if (gray_scale_delay == 0)
		{
			SoundPlayer.play_sound(AssetPaths.game_over__ogg);
		}

		if (y <= 0)
			acceleration.y = 5000;
		if (y > 0)
		{
			acceleration.y = 0;
			y = 0;
			if (Ctrl.anyB[1])
			{
				FlxG.sound.music.resume();
				PlayState.self.reset_game();
			}
		}
	}
}
