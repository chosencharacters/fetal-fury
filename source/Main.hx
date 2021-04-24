package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var game_width:Int = 960;
	var game_height:Int = 540;
	var fps:Int = 60;

	public static var reverseMenuControls:Bool = false;

	public function new()
	{
		super();

		Ctrl.set();
		addChild(new FlxGame(game_width, game_height, PlayState, 1, fps, fps, true));

		FlxG.mouse.visible = false;
	}
}
