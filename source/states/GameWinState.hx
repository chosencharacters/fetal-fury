package states;

import flixel.text.FlxText;
import ui.DeathCounter;

class GameWinState extends BaseState
{
	var bg:FlxSpriteExt;
	var tick:Int = 0;
	var deaths:DeathCounter;

	var final_time:FlxText = new FlxText();

	var GAME_RESETTING:Bool = false;

	override public function create()
	{
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		SoundPlayer.play_sound(AssetPaths.AnnouncerBossPlayerWins__ogg);

		FlxG.camera.fade(FlxColor.BLACK, 1, true, true);

		bg = new FlxSpriteExt(0, 0);
		bg.loadAllFromAnimationSet("endcard");
		bg.setPosition(FlxG.width / 2 - bg.width / 2, FlxG.height / 2 - bg.height / 2);
		bg.scrollFactor.set(0, 0);

		final_time = new FlxText(2, 7, bg.width, "");
		final_time = Utils.formatText(final_time, "left", FlxColor.WHITE, true);
		final_time.setPosition(2, FlxG.height - final_time.height);
		final_time.text = Utils.toTimer(PlayState.reverse_global_timer);

		add(bg);
		add(deaths = new DeathCounter());
		add(final_time);

		deaths.setPosition(deaths.x, 0);
	}

	override function update(elapsed:Float)
	{
		tick++;
		if (tick >= 60 * 5)
		{
			bg.anim("end?");
		}
		if (tick >= 60)
		{
			if (FlxG.keys.anyJustPressed(["R"]) && !GAME_RESETTING)
			{
				GAME_RESETTING = true;
				PlayState.current_level = -1;
				start_wipe(new PlayState());
			}
		}
		super.update(elapsed);
	}
}
