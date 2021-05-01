package enemies;

import ui.BossIntro;
import ui.TimeUpDisplay;

class SlimeBoss extends Enemy
{
	var speed:Int = 200;
	var accel_frames:Int = 15;
	var detect_range:Float = 700;

	var vision:Int = 0;

	var summon_time:Int = 0;
	var summon_time_set:Int = 120;

	var super_armor_activate_timer:Int = 0;
	var super_armor_activate_countdown:Int = 0;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadAllFromAnimationSet("slime_boss");

		maxVelocity.set(speed, speed);
		drag.set(100, 100);
		// setSize(76, 62);
		// offset.set(31, 46);

		health = 50;
		str = 1;

		sstateAnim("idle");

		DROP_SHADOW_DISABLE = true;

		time_value = 5;

		new BossIntro(this);
	}

	override function ai()
	{
		SUPER_ARMORED = false || super_armor_activate_timer > 0;
		super_armor_activate_timer--;

		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
		{
			velocity.set(0, 0);
			animation.pause();
			return;
		}
		else
		{
			if (animation.paused)
				animation.reset();
		}
		super.ai();

		if (health <= 0)
			sstate("split");

		switch (state)
		{
			case "idle":
				animProtect("idle");
				if (Utils.getDistanceM(this, clp()) < detect_range)
				{
					SoundPlayer.play_sound(AssetPaths.BossRolling1__ogg);
					sstateAnim("roll");
				}
			case "roll":
				if (animation.finished || animation.name == "idle")
				{
					velocity.x = velocity.x * .95;
					ttick();
					anim("idle");
					if (tick > 30)
						if (Utils.getDistanceM(this, clp()) < detect_range)
							sstateAnim("roll");
						else
							sstateAnim("idle");
					summon_time--;
					if (summon_time <= 0)
						sstateAnim("summon");
				}
				else
				{
					pathfinding_chase_player(speed / accel_frames);
					melee_hit_player();
				}
			case "hit":
				super_armor_activate_countdown++;
				if (super_armor_activate_countdown > 60)
				{
					super_armor_activate_countdown = 0;
					super_armor_activate_timer = 120;
				}
				if (stun < 0 && animation.finished)
				{
					sstateAnim("idle");
					if (health <= 0)
						sstateAnim("split");
				}
			case "split":
				animProtect("split");
				SUPER_ARMORED = true;

				velocity.set();

				if (animation.finished)
				{
					time_increment(time_value);

					var pos:FlxPoint = FlxPoint.weak(x - offset.x, y - offset.y);

					var left:SlimeMedium = new SlimeMedium(x - 17, y + 83 - 31);
					var right:SlimeMedium = new SlimeMedium(left.x + 48, left.y);
					left.sstate("spawn");
					right.sstate("spawn");
					right.flipX = true;

					right.velocity.set(999, 300);
					left.velocity.set(-999, 300);

					kill();
				}
			case "summon":
				if (animation.frameIndex == 19 && summon_time <= 0)
				{
					summon_time = summon_time_set;
					var smol = new Slime(getMidpoint().x - 71 / 2, getMidpoint().y - 71 / 2 + 48);
					if (!flipX)
						smol.x -= 48;
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
