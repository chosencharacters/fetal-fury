package ui;

import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import lime.tools.Asset;

class TimerDisplay extends FlxTypedSpriteGroup<FlxSprite>
{
	var bg:FlxSpriteExt;
	var text:FlxText;

	var flash_rate:Int = 15;
	var flash_tick:Int = 0;
	var flash_time_limit:Int = 60 * 10;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		bg = new FlxSpriteExt(AssetPaths.timer_background__png);
		text = new FlxText(2, 2, bg.width, "59:99");
		text = Utils.formatText(text, "center", FlxColor.RED, true);

		add(bg);
		add(text);

		x = FlxG.width / 2 - bg.width / 2;

		scrollFactor.set(0, 0);

		PlayState.self.ui.add(this);

		trace(text.font);
	}

	override function update(elapsed:Float)
	{
		update_timer_text(PlayState.global_timer);
		super.update(elapsed);
	}

	function update_timer_text(time_in_frames:Int = 0)
	{
		var timer_text:String = Utils.toTimer(time_in_frames);
		// timer_text = timer_text.substr(3);
		text.text = timer_text;

		if (time_in_frames <= flash_time_limit)
		{
			flash_tick++;
			if (flash_tick % flash_rate == 0)
				text.visible = !text.visible;
		}
		if (time_in_frames <= 0)
			text.visible = true;
	}
}
