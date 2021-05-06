package states;

import ui.NGMedalPopUp;

class IntroCreditsState extends BaseState
{
	var bg:FlxSpriteExt;

	var wait_for_next:Int = 60 * 10;
	var medal_tick:Int = 60;

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
		medal_tick--;
		if (medal_tick == 0)
			new NGMedalPopUp("This is in your play history forever");
		wait_for_next--;
		if (Ctrl.any(Ctrl.anyB) && wait_for_next > 0 && medal_tick <= 0)
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
