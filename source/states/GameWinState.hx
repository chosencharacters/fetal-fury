package states;

class GameWinState extends BaseState
{
	var bg:FlxSprite;

	override public function create()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, true, true);

		bg = new FlxSprite(0, 0);
		bg.loadGraphic(AssetPaths.game_win_screen__png);
		bg.setPosition(FlxG.width / 2 - bg.width / 2, FlxG.height / 2 - bg.height / 2);
		bg.scrollFactor.set(0, 0);

		add(bg);
	}
}
