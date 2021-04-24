package states;

import flixel.FlxState;

class BaseState extends FlxState
{
	public function new(?MaxSize:Int)
	{
		super(MaxSize);
	}

	override function update(elapsed:Float)
	{
		Ctrl.update();
		super.update(elapsed);
	}
}
