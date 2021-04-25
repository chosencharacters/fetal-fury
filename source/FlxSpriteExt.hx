import flixel.FlxSprite;
import flixel.graphics.frames.FlxTileFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * Extends FlxSprite with a bunch of useful stuff, mostly for animations
 */
class FlxSpriteExt extends FlxSprite
{
	/**Defined types of this, can be attributes and special effects and such*/
	var types:Array<String> = [];

	/**Animations that auto link when an animation is over*/
	var animationLinks:Array<Array<String>> = [];

	/**The previous anim played*/
	var lastAnim:String = "";

	var hitboxOverritten:Bool = false;

	/**logic state*/
	var state:String = "";

	/**simple tick**/
	var tick:Int = 0;

	/**Previous frame of animation**/
	var prevFrame:Int = 0;

	/**Was the last frame and current frame different?**/
	var isOnNewFrame:Bool = false;

	public function new(?X:Float, ?Y:Float, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	override function update(elapsed:Float)
	{
		isOnNewFrame = prevFrame != animation.frameIndex;

		prevFrame = animation.frameIndex;
		super.update(elapsed);
	}

	/***Loads the Image AND Animations from an AnimationSet***/
	public function loadAllFromAnimationSet(image:String, unique:Bool = false, autoIdle:Bool = true):Bool
	{
		var animSet:AnimSetData = Lists.getAnimationSet(image);

		if (animSet == null)
			return false;

		var animWidth:Float = animSet.dimensions.x;
		var animHeight:Float = animSet.dimensions.y;

		var fullPath:String = animSet.path + "/" + animSet.image + ".png";

		loadGraphic(fullPath);

		if (animWidth == 0)
			animWidth = graphic.width / (animSet.maxFrame + 1);
		if (animHeight == 0)
			animHeight = graphic.height;

		// debug(fullPath, animWidth, animHeight);

		if (animSet.offset.x != -999)
			offset.x = animSet.offset.x;
		if (animSet.offset.y != -999)
			offset.y = animSet.offset.y;

		frames = FlxTileFrames.fromGraphic(graphic, FlxPoint.get(animWidth, animHeight));

		if (animSet.hitbox.x != 0)
		{
			setSize(animSet.hitbox.x, animSet.hitbox.y);
			hitboxOverritten = true;
		}

		return loadAnimsFromAnimationSet(image, autoIdle);
	}

	public function loadAnimsFromAnimationSet(image:String, autoIdle:Bool = true):Bool
	{
		var animSet:AnimSetData = Lists.getAnimationSet(image);

		if (animSet == null)
			return false;

		for (set in animSet.animations)
		{
			animAdd(set.name, set.frames, set.fps, set.looping, false, false, set.linked);
			if (autoIdle && set.name == "idle")
				anim("idle");
		}

		// debug(getHitbox());

		return true;
	}

	/*
	 * Shorthand for animation play
	 */
	public function anim(s:String)
	{
		animation.play(s);
		lastAnim = s;
	}

	/*
	 * Adds an animation using the Renaine shorthand
	 */
	public function animAdd(animName:String, animString:String, ?fps:Int = 14, loopSet:Bool = true, flipXSet:Bool = false, flipYSet:Bool = false,
			animationLink:String = "")
	{
		animation.add(animName, Utils.anim(animString), fps, loopSet, flipXSet, flipYSet);
		if (animationLink.length > 0)
			addAnimationLink(animName, animationLink);
	}

	/*
	 * Adds an animation using the Renaine shorthand and immediately plays it
	 */
	public function animAddPlay(animName:String, animString:String, fps:Int = 14, loopSet:Bool = true, flipXSet:Bool = false, flipYSet:Bool = false,
			animationLink:String = "")
	{
		animation.add(animName, Utils.anim(animString), fps, loopSet, flipXSet, flipYSet);
		animation.play(animName);
	}

	/*
	 * Plays an animation if and only if it's not playing already.
	 */
	public function animProtect(animation_name:String = ""):Bool
	{
		if (animation.name != animation_name)
		{
			anim(animation_name);
			return true;
		}
		return false;
	}

	/**
		Adds a linking animation when this animation ends, "from" must not be Looped!
		@param	from a non-looped anim
		@param	to another anim, doesn't matter if it's looped or not
	**/
	public function addAnimationLink(from:String, to:String)
	{
		animationLinks.push([from, to]);
	}

	/*add a type*/
	public function addType(type_to_add:String):Bool
	{
		if (!isType(type_to_add))
		{
			types.push(type_to_add);
			return true;
		}
		return false;
	}

	/*check if this is a type*/
	public function isType(type_to_check:String):Bool
	{
		return types.indexOf(type_to_check) > -1;
	}

	/**
	 * Switch state
	 * @param new_state new state
	 * @param reset_tick reset tick? defaults to true, tick will reset on the state change
	 */
	function sstate(new_state:String, reset_tick:Bool = true)
	{
		if (reset_tick)
			tick = 0;
		state = new_state;
	}

	public function sstateAnim(s:String, resetInt:Bool = true)
	{
		sstate(s);
		anim(s);
	}

	function ttick()
	{
		tick++;
	}
}
