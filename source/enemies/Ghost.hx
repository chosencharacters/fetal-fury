package enemies;

class Ghost extends Enemy
{
	var speed:Int = 200;
	var scare_speed:Int = 600;
	var original_speed:Int = 300;

	var accel_frames:Int = 15;
	var detect_range:Float = 350;

	var vision:Int = 0;

	var og:FlxPoint;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadAllFromAnimationSet("ghost");

		maxVelocity.set(speed, speed);
		setSize(85, 112);
		drag.set(100, 100);
		offset.set(35, 16);

		immovable = true;
		grabbable = false;

		health = 999;
		str = 1;
		moves = false;

		og = new FlxPoint(x, y);

		sstateAnim("idle");
	}

	override function ai()
	{
		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
		{
			velocity.set(0, 0);
			animation.pause();
			return;
		}
		super.ai();

		switch (state)
		{
			case "idle":
				if (animation.frameIndex == 0)
					anim("idle");
				visible = true;
				DROP_SHADOW_DISABLE = false;
				moves = false;
				setPosition(og.x, og.y);
				inv = 999;
				if (Utils.getDistanceM(this, clp()) < detect_range)
				{
					inv = 0;
					sstateAnim("scare1");
				}
			case "scare1":
				if (!isOnScreen() || PlayState.self.players.getFirstAlive() == null)
				{
					sstate("idle");
					return;
				}
				moves = true;
				animProtect("scare1");
				maxVelocity.set(original_speed, original_speed);
				chase_player(original_speed / accel_frames);
				if (animation.finished)
				{
					sstateAnim("scare2");
					SoundPlayer.play_sound(AssetPaths.GhostScream__ogg);
				}
			case "scare2":
				animProtect("scare2");
				maxVelocity.set(scare_speed, scare_speed);
				chase_player(scare_speed / accel_frames);
				melee_hit_player();
				if (animation.finished)
					sstateAnim("disappear");
			case "disappear":
				DROP_SHADOW_DISABLE = true;
				animProtect("disappear");
				if (animation.finished)
				{
					ttick();
					if (tick > 30)
						sstateAnim("idle");
				}
			case "hit":
				if (stun < 0 && animation.finished)
				{
					ttick();
					visible = false;
					DROP_SHADOW_DISABLE = true;
				}
				if (tick > 30)
					sstateAnim("idle");
			case "kill":
				DYING = false;
				health = 999;
				sstateAnim("idle");
		}
	}
}
