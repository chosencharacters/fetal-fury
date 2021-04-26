package states;

import actors.Player;
import enemies.Slime;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import ldtk.Project;
import levels.Level;
import platforms.Exit;

class PlayState extends BaseState
{
	/**Self reference to PlayState since we're just that bad at programming */
	public static var self:PlayState;

	/**Freeze frames, while above 0 certain groups won't be active*/
	public var hitstop:Int = 0;

	/**Global timer time remaining*/
	public var global_timer:Int = 60 * 60;

	/**
	 * Layers
	 */
	public var players:FlxTypedGroup<Player>;

	public var enemies:FlxTypedGroup<Enemy>;
	public var exits:FlxTypedGroup<Exit>;

	public var miscFront:FlxTypedGroup<FlxSpriteExt>;
	public var miscFrontP:FlxTypedGroup<FlxSpriteExt>;

	public var miscBack:FlxTypedGroup<FlxSpriteExt>;
	public var miscBackP:FlxTypedGroup<FlxSpriteExt>;

	public var level:Level;
	public var LEVEL_CLEAR:Bool = false;

	override public function create()
	{
		super.create();

		self = this;

		create_layers();
		create_level();

		add(exits);
		add(miscBack);
		add(enemies);
		add(miscBackP);
		add(players);
		add(miscFrontP);
		add(miscFront);

		FlxG.camera.follow(players.getFirstAlive(), FlxCameraFollowStyle.TOPDOWN);
	}

	override public function update(elapsed:Float)
	{
		hitstop_manager();

		FlxG.collide(players, level.col);
		FlxG.collide(enemies, level.col);

		if (FlxG.keys.anyJustPressed(["R"]))
			start_wipe(new PlayState());

		super.update(elapsed);
	}

	function create_level()
	{
		// Create project instance
		var project = new LdtkProject();

		add(level = new Level(project, "Level_0", AssetPaths.floor_1__png));

		FlxG.worldBounds.set(level.x, level.y, level.width, level.height);
		FlxG.camera.setScrollBounds(level.x, level.width, level.y, level.height);
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
		exits = new FlxTypedGroup<Exit>();
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

	public function level_clear()
	{
		start_wipe(new PlayState());
	}
}
