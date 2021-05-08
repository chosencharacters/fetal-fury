package;

import flixel.FlxGame;
import openfl.display.Sprite;
import states.*;

class Main extends Sprite
{
	var game_width:Int = 1280;
	var game_height:Int = 720;
	var fps:Int = 60;

	public static var REVERSE_MENU_CONTROLS:Bool = false;
	public static var DISABLE_SCREENSHAKE:Bool = false;
	public static var NG_LOGGED_IN:Bool = false;

	public function new()
	{
		super();

		trace("vid game");

		#if html5
		trace("vid game!!!");
		NewgroundsHandler.init();
		#end
		Lists.init();
		Ctrl.set();

		addChild(new FlxGame(game_width, game_height, PlayState, 1, fps, fps, true));

		FlxG.mouse.visible = false;
	}
}
