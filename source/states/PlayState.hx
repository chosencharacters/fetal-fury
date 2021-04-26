package states;

import actors.Player;
import enemies.Slime;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import ldtk.Project;
import levels.Level;
import openfl.filters.ColorMatrixFilter;
import platforms.Block;
import platforms.Exit;
import platforms.UpgradeMonitor;
import states.GameWinState;
import ui.TimeUpDisplay;
import ui.TimerDisplay;

class PlayState extends BaseState
{
	/**Self reference to PlayState since we're just that bad at programming */
	public static var self:PlayState;

	/**Freeze frames, while above 0 certain groups won't be active*/
	public var hitstop:Int = 0;

	/**Global timer time remaining*/
	public static var global_timer:Int = -1;

	/**Global timer time set*/
	static var global_timer_base:Int = 60 * 150; // 2:30

	public static var BOSS_MODE:Bool = false;
	public static var BOSS_CLEAR:Bool = false;

	public static var current_level:Int = -1;
	public static var starting_level:Int = 1;

	/**
	 * Layers
	 */
	public var players:FlxTypedGroup<Player>;

	public var enemies:FlxTypedGroup<Enemy>;
	public var levels:FlxTypedGroup<Level>;
	public var blocks:FlxTypedGroup<Block>;
	public var exits:FlxTypedGroup<Exit>;
	public var upgrades:FlxTypedGroup<UpgradeMonitor>;
	public var ui:FlxTypedGroup<FlxObject>;

	public var miscFront:FlxTypedGroup<FlxSpriteExt>;
	public var miscFrontP:FlxTypedGroup<FlxSpriteExt>;

	public var miscBack:FlxTypedGroup<FlxSpriteExt>;
	public var miscBackP:FlxTypedGroup<FlxSpriteExt>;

	public var level:Level;
	public var LEVEL_CLEAR:Bool = true;
	public var GAME_OVER:Bool = false;

	override public function create()
	{
		super.create();

		SoundPlayer.play_music("stage");

		if (current_level == -1)
			current_level = starting_level;
		if (global_timer == -1)
			global_timer = global_timer_base;

		self = this;

		create_layers();

		add(levels);
		add(exits);
		add(upgrades);
		add(miscBack);
		add(enemies);
		add(miscBackP);
		add(blocks);
		add(players);
		add(miscFrontP);
		add(miscFront);
		add(ui);

		soft_reset_playstate();
	}

	override public function update(elapsed:Float)
	{
		handle_game_over();

		hitstop_manager();

		boss_mode_handle();

		FlxG.collide(players, level.col);
		FlxG.collide(enemies, level.col);

		if (FlxG.keys.anyJustPressed(["R"]) && hitstop <= 0)
			reset_game();

		super.update(elapsed);

		if (global_timer > 0)
			if (hitstop <= 0 && !LEVEL_CLEAR && !BaseState.WIPING && !BOSS_CLEAR)
				global_timer--;
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
		upgrades = new FlxTypedGroup<UpgradeMonitor>();
		ui = new FlxTypedGroup<FlxObject>();
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
		upgrades.clear();
		ui.clear();
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
		BOSS_MODE = false;
		BOSS_CLEAR = false;
		SoundPlayer.play_music("stage");
		FlxG.camera.setFilters([]);
		LEVEL_CLEAR = false;
		clear_layers();
		create_level();
		create_ui();
	}

	function create_ui()
	{
		new TimerDisplay();
	}

	function time_up() {}

	function handle_game_over()
	{
		if (GAME_OVER)
			return;
		if (global_timer == 0)
		{
			new TimeUpDisplay();
			GAME_OVER = true;

			var matrix:Array<Float> = [
				0.5, 0.5, 0.5, 0, 0,
				0.5, 0.5, 0.5, 0, 0,
				0.5, 0.5, 0.5, 0, 0,
				  0,   0,   0, 1, 0,
			];

			FlxG.camera.setFilters([new ColorMatrixFilter(matrix)]);
		}
	}

	public function reset_game()
	{
		BOSS_MODE = false;
		BOSS_CLEAR = false;
		GAME_OVER = false;
		global_timer = global_timer_base;
		current_level = starting_level;
		Player.reset_base_stats();
		LEVEL_CLEAR = false;
		current_level = 0;
		start_wipe(new PlayState(), true);
	}

	function boss_mode_handle()
	{
		if (!BOSS_MODE)
			return;
		if (!BOSS_CLEAR)
		{
			BOSS_CLEAR = enemies.getFirstAlive() == null;
			if (BOSS_CLEAR)
			{
				hitstop = 999;
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					FlxG.switchState(new GameWinState());
				}, true);
			}
		}
	}
}
