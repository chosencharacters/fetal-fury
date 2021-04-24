package actors;

class Actor extends FlxSpriteExt
{
	var team:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		types.push("actor");
	}

	function hit(m:Melee)
	{
		velocity.x -= m.knockback.x;
		velocity.y -= m.knockback.y;
	}
}
