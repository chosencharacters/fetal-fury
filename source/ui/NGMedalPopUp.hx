package ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.geom.Point;
import openfl.net.URLRequest;

class NGMedalPopUp extends FlxTypedSpriteGroup<FlxSprite>
{
	var top:FlxSpriteExt;
	var middle:FlxSpriteExt;
	var medal:FlxSpriteExt;
	var bg:FlxSpriteExt;
	var medal_name:FlxText;
	var points_text:FlxText;

	var medal_name_raw:String = "";
	var points_text_raw:String = "";

	var medal_text_dismiss:Bool = false;

	var medal_text_overflow:Bool = false;
	var medal_tick:Int = 0;

	var SOUND_IN:Bool = false;
	var SOUND_OUT:Bool = false;

	var animation_unpause_delay:Int = 0;

	var loader:Loader;
	var LOADED_MEDAL_IMAGE:Bool = false;

	var medal_text_max_length:Int = 10; // 14 for smaller letters but fetal fury is in all caps so...

	public function new(MedalName:String, MedalURL:String = "")
	{
		super();

		medal_name_raw = MedalName;

		medal_name = new FlxText(71 - 8, 35 - 4, 168 + 12, "");
		medal_name = Utils.formatText(medal_name, "center", FlxColor.WHITE, true, 22, "assets/fonts/Verdana.ttf");

		points_text = new FlxText(171 + 21, 9, 50, "");
		points_text = Utils.formatText(points_text, "center", FlxColor.WHITE, true, 12, "assets/fonts/Verdana.ttf");
		points_text.italic = true;
		points_text_raw = "100pts";

		construct_main_boxes(MedalURL);

		setPosition(FlxG.width - width, FlxG.height - height + 2);

		scrollFactor.set(0, 0);

		FlxG.state.add(this);
	}

	override function update(elapsed:Float)
	{
		if (loader != null)
		{
			if (loader.numChildren > 0 && !LOADED_MEDAL_IMAGE)
			{
				medal.makeGraphic(50, 50, FlxColor.WHITE);
				var bmp:BitmapData = cast(loader.getChildAt(0), Bitmap).bitmapData;
				var m_bmp:BitmapData = medal.graphic.bitmap;
				medal.graphic.bitmap.copyPixels(bmp, m_bmp.rect, new Point());
				LOADED_MEDAL_IMAGE = true;
			}
		}
		medal_text_manager();
		points_text_manager();
		sound_manager();
		medal.visible = top.animation.frameIndex >= 15 && top.animation.frameIndex <= 42;
		if (top.animation.finished)
			kill();
		super.update(elapsed);
	}

	function construct_main_boxes(MedalURL:String)
	{
		top = new FlxSpriteExt();
		middle = new FlxSpriteExt();
		bg = new FlxSpriteExt();

		top.loadGraphic(AssetPaths.ng_medal_popup_A__png, true, 250, 72);
		middle.loadGraphic(AssetPaths.ng_medal_popup_B__png, true, 250, 72);
		bg.loadGraphic(AssetPaths.ng_medal_popup_C__png, true, 250, 72);

		for (sprite in [top, middle, bg])
			sprite.animAddPlay("popup", "0t30,31h36,32t51", 36, false);

		medal = new FlxSpriteExt(10, 10);
		medal.visible = false;

		medal.loadGraphic(AssetPaths.no_medal__png);

		if (MedalURL != "")
		{
			loader = new Loader();
			loader.load(new URLRequest(MedalURL));
		}

		add(bg);
		add(medal);
		add(medal_name);
		add(points_text);
		add(middle);
		add(top);
	}

	function medal_text_manager()
	{
		medal_name.visible = top.animation.frameIndex > 15;
		medal_text_dismiss = top.animation.frameIndex > 31;
		if (!medal_name.visible)
			return;
		if (!medal_text_dismiss)
		{
			medal_tick++;
			if (medal_name_raw.length > 0)
			{
				if (medal_name.text.length < medal_text_max_length && !medal_text_overflow)
				{
					medal_name.text = medal_name.text + medal_name_raw.charAt(0);
					medal_name_raw = medal_name_raw.substr(1);
				}
				else
				{
					medal_text_overflow = true;
					if (medal_tick > 60 && medal_name.text.length > 0 && medal_tick % 4 == 0)
					{
						medal_name.text = medal_name.text.substr(1);
						medal_name.text = medal_name.text + medal_name_raw.charAt(0);
						medal_name_raw = medal_name_raw.substr(1);
						if (medal_name_raw.length > 1)
						{
							animation_unpause_delay = 15;
							for (sprite in [top, middle, bg])
								sprite.animation.pause();
						}
					}
				}
			}
		}
		else
		{
			if (medal_name.text.length > 0)
			{
				medal_name.text = medal_name.text.substr(0, medal_name.text.length - 1);
			}
			else
			{
				medal_name.alpha = 0;
			}
		}
		animation_unpause_delay--;
		if (animation_unpause_delay == 0)
			for (sprite in [top, middle, bg])
				sprite.animation.resume();
	}

	function points_text_manager()
	{
		points_text.visible = medal_name.visible;
		if (!points_text.visible)
			return;
		if (!medal_text_dismiss)
		{
			if (points_text_raw.length > 0)
			{
				points_text.text = points_text.text + points_text_raw.charAt(0);
				points_text_raw = points_text_raw.substr(1);
			}
		}
		else
		{
			if (points_text.text.length > 0)
			{
				points_text.text = points_text.text.substr(0, points_text.text.length - 1);
			}
			else
			{
				points_text.alpha = 0;
			}
		}
	}

	function sound_manager()
	{
		if (!SOUND_IN && top.animation.frameIndex >= 5)
		{
			SoundPlayer.play_sound(AssetPaths.ng_medal_GET__ogg);
			SOUND_IN = true;
		}
		if (!SOUND_OUT && top.animation.frameIndex >= 47)
		{
			SoundPlayer.play_sound(AssetPaths.ng_medal_GOT__ogg);
			SOUND_OUT = true;
		}
	}
}
