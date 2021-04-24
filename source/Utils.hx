import flixel.system.FlxAssets.FlxGraphicAsset;
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
}
