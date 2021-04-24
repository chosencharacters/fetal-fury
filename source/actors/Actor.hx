package actors;

class Actor extends FlxSpriteExt
{
	var team:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		types.push("actor");
	}
}
