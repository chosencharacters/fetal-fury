/***This is default animation sets associated with a particular spritesheet***/
typedef AnimSetData =
{
	var image:String;
	var animations:Array<AnimDef>;
	var dimensions:FlxPoint;
	var offset:FlxPoint;
	var flipOffset:FlxPoint;
	var hitbox:FlxPoint;
	var maxFrame:Int;
	var path:String;
}

/***This an animation definition to be used with AnimSetData***/
typedef AnimDef =
{
	var name:String;
	var frames:String;
	var fps:Int;
	var looping:Bool;
	var linked:String;
}

class Lists
{
	/** All the animation data*/
	public static var animSets:Map<String, AnimSetData> = new Map<String, AnimSetData>();

	static var base_animation_fps:Int = 14;

	function new() {}

	public static function init()
	{
		loadAnimationSets();
	}

	/***
	 * Animation Set Loading and Usage
	***/
	/**Loads all the animations from several xml files**/
	static function loadAnimationSets()
	{
		for (file in ["player_anims", "general_anims", "enemy_anims"])
		{
			loadAnimationSet("assets/data/anims/" + file + ".xml");
		}
	}

	static function loadAnimationSet(path:String)
	{
		var xml:Xml = Utils.XMLloadAssist(path);
		for (root in xml.elementsNamed("root"))
		{
			for (sset in root.elementsNamed("animSet"))
			{
				var allFrames:String = "";
				var animSet:AnimSetData = {
					image: "",
					animations: [],
					dimensions: new FlxPoint(),
					offset: new FlxPoint(-999, -999),
					flipOffset: new FlxPoint(-999, -999),
					hitbox: new FlxPoint(),
					maxFrame: 0,
					path: ""
				};

				for (aanim in sset.elementsNamed("anim"))
				{
					var animDef:AnimDef = {
						name: "",
						frames: "",
						fps: base_animation_fps,
						looping: true,
						linked: ""
					};

					if (aanim.get("fps") != null)
						animDef.fps = Std.parseInt(aanim.get("fps"));
					if (aanim.get("looping") != null)
						animDef.looping = aanim.get("looping") == "true";
					if (aanim.get("linked") != null)
						animDef.linked = aanim.get("linked");
					if (aanim.get("link") != null)
						animDef.linked = aanim.get("link");

					animDef.name = aanim.get("name");
					animDef.frames = aanim.firstChild().toString();
					allFrames = allFrames + animDef.frames + ",";

					animSet.animations.push(animDef);
				}

				animSet.image = sset.get("image");
				animSet.path = StringTools.replace(sset.get("path"), "\\", "/");

				if (sset.get("x") != null)
					animSet.offset.x = Std.parseFloat(sset.get("x"));
				if (sset.get("y") != null)
					animSet.offset.y = Std.parseFloat(sset.get("y"));

				if (sset.get("width") != null)
					animSet.dimensions.x = Std.parseFloat(sset.get("width"));
				if (sset.get("height") != null)
					animSet.dimensions.y = Std.parseFloat(sset.get("height"));

				if (sset.get("hitbox") != null)
				{
					var hitbox:Array<String> = sset.get("hitbox").split(",");
					animSet.hitbox.set(Std.parseFloat(hitbox[0]), Std.parseFloat(hitbox[1]));
				}

				if (sset.get("flipOffset") != null)
				{
					var flipOffset:Array<String> = sset.get("flipOffset").split(",");
					animSet.flipOffset.set(Std.parseFloat(flipOffset[0]), Std.parseFloat(flipOffset[1]));
				}

				var maxFrame:Int = 0;

				allFrames = StringTools.replace(allFrames, "t", ",");

				for (frame in allFrames.split(","))
				{
					if (frame.indexOf("h") > -1)
						frame = frame.substring(0, frame.indexOf("h"));

					var compFrame:Int = Std.parseInt(frame);

					if (compFrame > maxFrame)
					{
						maxFrame = compFrame;
					}
				}
				animSet.maxFrame = maxFrame;

				animSets.set(animSet.image, animSet);
			}
		}
	}

	public static function getAnimationSet(image:String):AnimSetData
	{
		return animSets.get(image);
	}
}
