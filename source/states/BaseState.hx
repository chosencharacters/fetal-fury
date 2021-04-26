package states;

import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxShader;

class BaseState extends FlxState
{
	private var wipe:FlxSpriteExt;

	public static var WIPING:Bool = false;

	private static var wipe_position:FlxPoint;
	private static var wipe_state:BaseState;
	private static var WIPE_PART_2:Bool = false;
	private static var wipe_save_frame:Int = 0;

	static var reset_playState_mode:Bool = false;

	override public function create()
	{
		super.create();

		bgColor = 0xff301417;

		wipe = new FlxSpriteExt(0, 0);
		wipe.loadGraphic(AssetPaths.transition__png, true, 1650, 560);
		wipe.animAddPlay("wipe", "0t3", 10);
		wipe.scale.set(1.65, 1.65);
		wipe.animation.frameIndex = wipe_save_frame;
		wipe.scrollFactor.set(0, 0);

		if (wipe_position == null)
			wipe_position = new FlxPoint(-999, -999);

		wipe.setPosition(wipe_position.x, wipe_position.y);

		wipe.visible = false;

		trace("NEW STATE");
	}

	override function update(elapsed:Float)
	{
		Ctrl.update();

		super.update(elapsed);

		do_wipe();
	}

	function do_wipe()
	{
		if (wipe == null)
			return;

		remove(wipe, true);
		add(wipe);

		wipe.visible = WIPING;
		wipe.velocity.x = WIPING ? -2000 * 2 : 0;

		if (!WIPING)
			return;

		wipe_save_frame = wipe.animation.frameIndex;

		wipe_position.set(wipe.x, wipe.y);

		var wipeX:Int = -200;
		if (wipe.x < wipeX && !WIPE_PART_2)
		{
			WIPE_PART_2 = true;
			if (!reset_playState_mode)
			{
				FlxG.switchState(wipe_state);
			}
			else
			{
				PlayState.self.soft_reset_playstate();
				reset_playState_mode = false;
			}
			return;
		}

		if (!wipe.isOnScreen() && wipe.x < wipeX)
		{
			WIPING = false;
			do_wipe();
		}
	}

	function start_wipe(new_wipe_state:BaseState, reset_playState_mode_set:Bool = false, force:Bool = false)
	{
		if (WIPING && !force)
			return;

		reset_playState_mode = reset_playState_mode_set;
		WIPE_PART_2 = false;
		WIPING = true;
		wipe.visible = true;
		wipe_position.set(wipe.width, 0);
		wipe.setPosition(wipe_position.x, wipe_position.y);
		wipe_state = new_wipe_state;
		add(wipe);
	}
}
