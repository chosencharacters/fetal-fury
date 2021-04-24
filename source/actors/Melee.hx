package actors;

class Melee extends FlxSpriteExt
{
	public var knockback:FlxPoint;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		types.push("melee");
	}
}
