package states;

class TitleState extends BaseState
{
	var bg:FlxSpriteExt;
	var press_z:FlxSpriteExt;

	var GAME_STARTED:Bool = false;

	var tick:Int = 0;

	var start_delay:Int = 0;

	var CAN_GO_ON:Bool = false;

	override public function create()
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		bg = new FlxSpriteExt(0, 0);
		bg.loadAllFromAnimationSet("titlecard");
		bg.scrollFactor.set(0, 0);

		press_z = new FlxSpriteExt(0, 0);
		press_z.loadAllFromAnimationSet("pressZforFury");
		press_z.setPosition(FlxG.width / 2 - press_z.width / 2, FlxG.height - press_z.height);
		press_z.scrollFactor.set(0, 0);

		FlxG.camera.fade(FlxColor.BLACK, 0.25, true, function()
		{
			SoundPlayer.play_sound(AssetPaths.AnnouncerTitle__ogg);
			CAN_GO_ON = true;
		});

		add(bg);
		add(press_z);
	}

	override function update(elapsed:Float)
	{
		tick++;
		press_z.visible = (tick % 30 > 10 || GAME_STARTED) && CAN_GO_ON;

		if (!GAME_STARTED && Ctrl.any(Ctrl.jgrapple))
		{
			GAME_STARTED = true;
			press_z.anim("pressed");

			SoundPlayer.play_sound(AssetPaths.MenuSelect__wav);

			Utils.shake("damage");
		}

		if (GAME_STARTED)
		{
			start_delay++;
			if (start_delay == 20)
			{
				start_wipe(new PlayState());
			}
		}
		super.update(elapsed);
	}
}
