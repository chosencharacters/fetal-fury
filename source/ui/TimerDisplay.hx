package ui;

import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;

class TimerDisplay extends FlxTypedSpriteGroup<FlxSprite>
{
	var bg:FlxSpriteExt;
	var text:FlxText;
	var text_bonus:FlxText;
	var fg:FlxSpriteExt;

	var flash_rate:Int = 15;
	var flash_tick:Int = 0;
	var flash_time_limit:Int = 60 * 10;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		bg = new FlxSpriteExt(AssetPaths.timer_background__png);
		fg = new FlxSpriteExt(AssetPaths.timer_foreground__png);

		text = new FlxText(2, 7, bg.width, "59:99");
		text = Utils.formatText(text, "center", FlxColor.RED, true);

		text_bonus = new FlxText(-12, text.y + text.height + 4, bg.width, "+99:99:99");
		text_bonus = Utils.formatText(text_bonus, "center", FlxColor.LIME, true);

		add(bg);
		add(text);
		add(fg);
		add(text_bonus);

		x = FlxG.width / 2 - bg.width / 2;

		scrollFactor.set(0, 0);

		PlayState.self.ui.add(this);

		text_bonus.visible = false;
	}

	override function update(elapsed:Float)
	{
		update_timer_text(PlayState.global_timer);
		super.update(elapsed);
	}

	function update_timer_text(time_in_frames:Int = 0)
	{
		text.color = PlayState.bonus_time % 60 >= 45 && PlayState.bonus_time >= 0 ? FlxColor.ORANGE : FlxColor.RED;

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

		text_bonus.text = "+" + Utils.toTimer(PlayState.bonus_time);
		if (PlayState.bonus_time > 0 && PlayState.bonus_time_delay <= 0)
		{
			PlayState.bonus_time -= 2;
			PlayState.global_timer += 2;
			text_bonus.offset.y = text_bonus.offset.y >= 0 ? -1 : 1;
		}
		if (PlayState.bonus_time_delay > 0)
			text_bonus.offset.y = 0;
		text_bonus.visible = PlayState.bonus_time > 0;
		PlayState.bonus_time_delay--;
	}

	public static function add_time(seconds:Float)
	{
		if (PlayState.bonus_time <= 0)
			PlayState.bonus_time_delay = 30;
		PlayState.bonus_time += Math.floor(seconds * 60);
	}
}
