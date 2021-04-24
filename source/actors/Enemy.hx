package actors;

class Enemy extends Actor
{
	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		types.push("enemy");
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
