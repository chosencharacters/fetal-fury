package states;

import actors.Player;
import flixel.FlxState;
import flixel.text.FlxText;

class PlayState extends BaseState
{
	override public function create()
	{
		super.create();

		add(new Player(FlxG.width / 2 - 48, FlxG.height / 2 - 48));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
