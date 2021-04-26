package enemies;

class SlimeMedium extends Enemy
{
	var speed:Int = 200;
	var accel_frames:Int = 15;
	var detect_range:Float = 320;

	var vision:Int = 0;

	var summon_time:Int = 0;
	var summon_time_set:Int = 120;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadAllFromAnimationSet("slime_med");

		maxVelocity.set(speed, speed);
		drag.set(100, 100);
		setSize(157, 117);
		offset.set(19, 32);

		health = 10;
		str = 1;

		sstate("idle");
	}

	override function ai()
	{
		SUPER_ARMORED = false;

		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
		{
			velocity.set(0, 0);
			animation.pause();
			return;
		}
		super.ai();

		switch (state)
		{
			case "spawn":
				anim("move");
				ttick();
				if (tick > 60)
					sstateAnim("idle");
			case "idle":
				animProtect("idle");
				if (Utils.getDistanceM(this, clp()) < detect_range)
					sstateAnim("move");
			case "move":
				if (!isOnScreen())
				{
					sstate("idle");
					return;
				}

				if (tick % 120 == 1)
					SoundPlayer.altSound(2, [AssetPaths.EnemyLandAfterJump1__ogg, AssetPaths.EnemyLandAfterJump2__ogg]);

				pathfinding_chase_player(speed / accel_frames);
				melee_hit_player();

				summon_time--;
				if (summon_time <= 0)
					sstateAnim("summon");
			case "hit":
				if (stun < 0 && animation.finished)
				{
					sstateAnim("idle");
					if (health <= 0)
						sstateAnim("split");
				}
			case "split":
				SUPER_ARMORED = true;

				velocity.set();

				if (animation.finished)
				{
					var pos:FlxPoint = FlxPoint.weak(x - offset.x, y - offset.y);

					var left:Slime = new Slime(x - 17, y + 83 - 31);
					var right:Slime = new Slime(left.x + 48, left.y);
					left.sstate("spawn");
					right.sstate("spawn");
					right.flipX = true;

					right.velocity.set(999, 300);
					left.velocity.set(-999, 300);

					kill();
				}
			case "summon":
				if (animation.frameIndex == 9 && summon_time <= 0)
				{
					SoundPlayer.altSound(4, [AssetPaths.BossSpit1__ogg, AssetPaths.BossSpit2__ogg], 1);
					summon_time = summon_time_set;
					var smol = new SlimeSmol(getMidpoint().x - 71 / 2, getMidpoint().y - 71 / 2 + 32);
					smol.velocity.x = flipX ? 999 : -999;
					smol.velocity.y = 300;
					smol.flipX = flipX;
					smol.sstate("spawn");
				}
				if (animation.finished)
					sstate("idle");
		}
	}
}
