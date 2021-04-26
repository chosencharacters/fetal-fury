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
	public var levels:FlxTypedGroup<Level>;
	public var blocks:FlxTypedGroup<Block>;
	public var exits:FlxTypedGroup<Exit>;

	public var miscFront:FlxTypedGroup<FlxSpriteExt>;
	public var miscFrontP:FlxTypedGroup<FlxSpriteExt>;

	public var miscBack:FlxTypedGroup<FlxSpriteExt>;
	public var miscBackP:FlxTypedGroup<FlxSpriteExt>;

	public var level:Level;
	public var LEVEL_CLEAR:Bool = false;

	public static var current_level:Int = 0;

	override public function create()
	{
		super.create();

		self = this;

		create_layers();

		add(levels);
		add(exits);
		add(miscBack);
		add(enemies);
		add(miscBackP);
		add(players);
		add(miscFrontP);
		add(blocks);
		add(miscFront);

		soft_reset_playstate();
	}

	override public function update(elapsed:Float)
	{
		hitstop_manager();

		FlxG.collide(players, level.col);
		FlxG.collide(enemies, level.col);

		if (FlxG.keys.anyJustPressed(["R"]))
			reset_game();

		super.update(elapsed);
	}

	function create_level()
	{
		// Create project instance
		var project = new LdtkProject();

		levels.add(level = new Level(project, "Level_" + current_level, AssetPaths.floor_1__png));

		var diff_x:Float = FlxG.width > level.width ? (FlxG.width - level.width) / 2 : 0;
		var diff_y:Float = FlxG.height > level.height ? (FlxG.height - level.height) / 2 : 0;
		FlxG.worldBounds.set(level.x, level.y, level.width, level.height);
		FlxG.camera.setScrollBounds(level.x - diff_x, level.width + diff_x, level.y - diff_y, level.height + diff_y);

		FlxG.camera.follow(players.getFirstAlive(), FlxCameraFollowStyle.TOPDOWN);
	}

	function create_layers()
	{
		levels = new FlxTypedGroup<Level>();
		players = new FlxTypedGroup<Player>();
		enemies = new FlxTypedGroup<Enemy>();
		miscFront = new FlxTypedGroup<FlxSpriteExt>();
		miscBack = new FlxTypedGroup<FlxSpriteExt>();
		miscFrontP = new FlxTypedGroup<FlxSpriteExt>();
		miscBackP = new FlxTypedGroup<FlxSpriteExt>();
		exits = new FlxTypedGroup<Exit>();
		blocks = new FlxTypedGroup<Block>();
	}

	function clear_layers()
	{
		levels.clear();
		players.clear();
		enemies.clear();
		miscFront.clear();
		miscBack.clear();
		miscFrontP.clear();
		miscBackP.clear();
		exits.clear();
		blocks.clear();
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
		current_level++;
		start_wipe(new PlayState(), true);
	}

	public function soft_reset_playstate()
	{
		LEVEL_CLEAR = false;
		clear_layers();
		create_level();
	}

	function reset_game()
	{
		LEVEL_CLEAR = false;
		current_level = 0;
		start_wipe(new PlayState(), true);
	}
}
