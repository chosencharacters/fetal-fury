package states;

import actors.Player;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class PlayState extends BaseState
{
	/**
	 * Layers
	 */
	public static var players:FlxTypedGroup<Player>;

	public static var miscFront:FlxTypedGroup<FlxSpriteExt>;
	public static var miscFrontP:FlxTypedGroup<FlxSpriteExt>;

	public static var miscBack:FlxTypedGroup<FlxSpriteExt>;
	public static var miscBackP:FlxTypedGroup<FlxSpriteExt>;

	override public function create()
	{
		super.create();

		create_layers();

		new Player(FlxG.width / 2 - 48, FlxG.height / 2 - 48);

		add(miscBack);
		add(miscBackP);
		add(players);
		add(miscFrontP);
		add(miscFront);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function create_layers()
	{
		add(new FlxSpriteExt(0, 0, AssetPaths.basic_bg__png));
		players = new FlxTypedGroup<Player>();
		miscFront = new FlxTypedGroup<FlxSpriteExt>();
		miscBack = new FlxTypedGroup<FlxSpriteExt>();
		miscFrontP = new FlxTypedGroup<FlxSpriteExt>();
		miscBackP = new FlxTypedGroup<FlxSpriteExt>();
	}
}
