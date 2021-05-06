import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import lime.utils.Assets;

class Utils
{
	function new() {}

	public static function XMLloadAssist(path:String):Xml
	{
		var text:String = Assets.getText(path);
		text = StringTools.replace(text, "/n", "&#xA;");
		text = StringTools.replace(text, "<&#xA;", "</n");
		return Xml.parse(text);
	}

	/*
	 * Animation int array created using string of comma seperated frames
	 * xTy = from x to y, takes r as optional form xTyRz to repeat z times
	 * xHy = hold x, y times
	 * ex: "0t2r2, 3h2" returns [0, 1, 2, 0, 1, 2, 3, 3, 3]
	 */
	public static function animFromString(animString:String):Array<Int>
	{
		var frames:Array<Int> = [];
		var framesGroup:Array<String> = StringTools.replace(animString, " ", "").toLowerCase().split(",");
		if (framesGroup.length <= 0)
			framesGroup = [animString];
		for (f in framesGroup)
		{
			if (f.indexOf("h") > -1)
			{ // hold/repeat frames
				var split:Array<String> = f.split("h"); // 0 = frame, 1 = hold frame multiplier so 1h5 is 1 hold 5 i.e. repeat 5 times
				frames = frames.concat(Utils.arrayR([Std.parseInt(split[0])], Std.parseInt(split[1])));
			}
			else if (f.indexOf("t") > -1)
			{ // from x to y frames
				var repeats:Int = 1;
				if (f.indexOf("r") != -1)
					repeats = Std.parseInt(f.substring(f.indexOf("r") + 1, f.length)); // add rInt at the end to repeat Int times
				f = StringTools.replace(f, "r", "t");
				for (i in 0...repeats)
				{
					var split:Array<String> = f.split("t"); // 0 = first frame, 1 = last frame so 1t5 is 1 to 5
					frames = frames.concat(Utils.array(Std.parseInt(split[0]), Std.parseInt(split[1])));
				}
			}
			else
			{
				frames.push(Std.parseInt(f));
			}
		}
		return frames;
	}

	/*
	 * Alias for animFromString
	 */
	public static function anim(animString:String):Array<Int>
	{
		return animFromString(animString);
	}

	/*
	 * Creates FlxSprite, attaches animation, and plays it automatically if autoPlay == true
	 */
	public static function animSprite(?X:Int = 0, Y:Int = 0, graphic:FlxGraphicAsset, animString:String, fps:Int, looped:Bool = true,
			autoPlay:Bool = true):FlxSprite
	{
		var frames:Array<Int> = anim(animString);
		var maxFrame:Int = 0;

		for (f in frames)
		{
			if (f >= maxFrame)
				maxFrame = f + 1;
		}

		var sprite:FlxSprite = new FlxSprite(X, Y);
		sprite.loadGraphic(graphic);
		sprite.loadGraphic(graphic, true, Math.floor(sprite.width / maxFrame), Math.floor(sprite.height));
		sprite.animation.add("play", frames, fps, looped);

		if (autoPlay)
			sprite.animation.play("play");

		return sprite;
	}

	public static function array(start:Int, end:Int):Array<Int>
	{
		var a:Array<Int> = [];
		if (start < end)
		{
			for (i in start...(end + 1))
			{
				a.push(i);
			}
		}
		else
		{
			for (i in (end + 1)...start)
			{
				a.push(i);
			}
		}
		return a;
	}

	/*
	 * Creates repeating array that duplicates 'toRepeat', 'repeat' times
	 */
	public static function arrayR(toRepeat:Array<Int>, repeats:Int):Array<Int>
	{
		var a:Array<Int> = [];
		for (i in 0...repeats)
		{
			for (c in toRepeat)
			{
				a.push(c);
			}
		}
		return a;
	}

	/**
	 * Get distance between two points
	 * @param P1 point 1
	 * @param P2 point 2
	 * @return distance between two points
	 */
	public static function getDistance(P1:FlxPoint, P2:FlxPoint):Float
	{
		var XX:Float = P2.x - P1.x;
		var YY:Float = P2.y - P1.y;
		return Math.sqrt(XX * XX + YY * YY);
	}

	/**
	 * Get distance between two sprite midpoints
	 * @param S1 sprite 1
	 * @param S2 sprite 2
	 * @return distance between two points
	 */
	public static function getDistanceM(S1:FlxSprite, S2:FlxSprite):Float
	{
		return getDistance(S1.getMidpoint(FlxPoint.weak()), S2.getMidpoint(FlxPoint.weak()));
	}

	/**
	 * Shakes the camera according to some handy presets
	 * @param preset 
	 */
	public static function shake(preset:String = "damage")
	{
		if (Main.DISABLE_SCREENSHAKE)
			return;

		var intensity:Float = 0;
		var time:Float = 0;

		switch (preset)
		{
			case "damage":
				intensity = 0.025;
				time = 0.1;
			case "damagelight":
				intensity = 0.01;
				time = 0.025;
			case "groundpound":
				intensity = 0.03;
				time = 0.2;
			case "explosion":
				intensity = 0.025;
				time = 0.225;
			case "light":
				shake("damagelight");
		}

		if (intensity != 0 && time != 0)
			FlxG.camera.shake(intensity, time);
	}

	/**
	 * Takes text and auto formats it
	 * @param text the FlxText to format
	 * @param alignment alignment i.e. 'center' 'left' 'right'
	 * @param color text color
	 * @param outline use an outline or not
	 * @return FlxText formatted text
	 */
	public static function formatText(text:FlxText, alignment:String = "left", color:Int = FlxColor.WHITE, outline:Bool = false, font_size:Int = 36,
			font:String = "assets/fonts/DIGITALDREAM.ttf"):FlxText
	{
		if (outline)
		{
			text.setFormat(font, font_size, color, alignment, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		else
		{
			text.setFormat(font, font_size, color, alignment);
		}
		#if !flash
		text.x -= 1;
		text.y -= 1;
		#end
		return text;
	}

	/**
	 * converts time in frames to minute, second, and frames (not nano seconds)
	 * @param time input time in frames
	 * @return String time formatted as 00:00:00
	 */
	public static function toTimer(time:Int):String
	{
		var minute:Int = Math.floor(time / (60 * 60));
		var second:Int = Math.floor((time / 60) % 60);
		var nano:Int = Math.floor(time % 60 / 60 * 100);
		var minutes:String = minute + "";
		var seconds:String = second + "";
		var nanos:String = nano + "";
		if (minute < 10)
			minutes = "0" + minutes;
		if (second < 10)
			seconds = "0" + seconds;
		if (nano < 10)
			nanos = "0" + nanos;
		return minutes + ":" + seconds + ":" + nanos;
	}
}
