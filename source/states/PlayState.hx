package states;

import actors.Player;
import enemies.Slime;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class PlayState extends BaseState
{
	/**Self reference to PlayState since we're just that bad at programming */
	public static var self:PlayState;

	/**Freeze frames, while above 0 certain groups won't be active*/
	public var hitstop:Int = 0;

	/**
	 * Layers
	 */
	public var players:FlxTypedGroup<Player>;

	public var enemies:FlxTypedGroup<Enemy>;

	public var miscFront:FlxTypedGroup<FlxSpriteExt>;
	public var miscFrontP:FlxTypedGroup<FlxSpriteExt>;

	public var miscBack:FlxTypedGroup<FlxSpriteExt>;
	public var miscBackP:FlxTypedGroup<FlxSpriteExt>;

	override public function create()
	{
		super.create();

		self = this;

		create_layers();

		new Player(FlxG.width / 2 - 48, FlxG.height / 2 - 48);
		new Slime(players.getFirstAlive().x + 120, players.getFirstAlive().y + 120);

		add(miscBack);
		add(enemies);
		add(miscBackP);
		add(players);
		add(miscFrontP);
		add(miscFront);
	}

	override public function update(elapsed:Float)
	{
		hitstop_manager();

		if (FlxG.keys.anyJustPressed(["R"]))
			FlxG.switchState(new PlayState());

		super.update(elapsed);
	}

	function create_layers()
	{
		add(new FlxSpriteExt(0, 0, AssetPaths.basic_bg__png));
		players = new FlxTypedGroup<Player>();
		enemies = new FlxTypedGroup<Enemy>();
		miscFront = new FlxTypedGroup<FlxSpriteExt>();
		miscBack = new FlxTypedGroup<FlxSpriteExt>();
		miscFrontP = new FlxTypedGroup<FlxSpriteExt>();
		miscBackP = new FlxTypedGroup<FlxSpriteExt>();
	}

	function hitstop_manager()
	{
		if (hitstop < 0)
			return;
		for (group in [players, enemies, miscFrontP, miscBackP, miscBack, miscFront])
			group.active = hitstop <= 0;
		hitstop--;
	}

	override function kill()
	{
		self = null;
		super.kill();
	}
}
