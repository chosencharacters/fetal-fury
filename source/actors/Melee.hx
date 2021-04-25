package actors;

class Melee extends FlxSpriteExt
{
	public var knockback:FlxPoint;
	public var team:Int = 0;
	public var str:Int = 0;
	public var stun:Int = 0;
	public var melee_id:Int = 0;

	public function new(?X:Float, ?Y:Float, Team:Int, Str:Int = 0, ?Stun:Int = 0, ?Knockback:FlxPoint, MeleeID:Int = 0)
	{
		super(X, Y);
		types.push("melee");

		team = Team;
		str = Str;
		stun = Stun;
		knockback = Knockback != null ? Knockback : new FlxPoint();
	}
}
