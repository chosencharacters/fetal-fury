package actors;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;

class Player extends Actor
{
	var speed:Int = 250;
	var accelFrames:Int = 15;

	var RIGHT:Bool = false;
	var UP:Bool = false;
	var LEFT:Bool = false;
	var DOWN:Bool = false;
	var ATTACK:Bool = false;
	var CHARGE_ATTACK:Bool = false;
	var GRAPPLE:Bool = false;

	var head_sprite:FlxSpriteExt;
	var whip:Melee;
	var impact_hit:Melee;

	var grappling_hook:FlxTypedGroup<FlxSpriteExt>;
	var grapple_point:FlxPoint = new FlxPoint(-999, -999);
	var grapple_enemy:Enemy;

	var MAX_GRAPPLE_LENGTH:Int = 20;
	var GRAPPLE_RATE:Int = 1;
	var GRAPPLE_PIECE_WIDTH:Int = 17;

	var continue_attacking:Bool = false;

	var root_offset:FlxPoint = new FlxPoint(39, 65);

	var DYING:Bool = false;

	var spawn_point:FlxPoint;

	var land_melee:Melee;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);
		spawn_point = new FlxPoint(x, y);

		health = 1;
		team = 1;
		str = 1;

		loadAllFromAnimationSet("player_body_default");
		head_sprite = new FlxSpriteExt();
		head_sprite.loadAllFromAnimationSet("player_head_default");
		head_movement();

		whip = new Melee(-999, -999, team, str, new FlxPoint(300, 100));
		whip.loadAllFromAnimationSet("whip");
		PlayState.self.miscFront.add(whip);

		impact_hit = new Melee(-999, -999, team, str, new FlxPoint(500, 100));

		maxVelocity.set(speed, speed);
		drag.set(500, 500);

		grappling_hook = new FlxTypedGroup<FlxSpriteExt>();

		PlayState.self.players.add(this);
		PlayState.self.miscFrontP.add(head_sprite);

		sstate("enter_start");

		setSize(24, 51);
		offset.set(root_offset.x, root_offset.y);

		head_sprite.visible = false;

		land_melee = new Melee(-99, -99, team, 0, 30, FlxPoint.weak(2000, 2000), 3);
		land_melee.makeGraphic(frameWidth, frameHeight, FlxColor.WHITE);
	}

	override function update(elapsed:Float)
	{
		if (!DYING)
		{
			controls();
			enter();
			movement();
			head_movement();
			whip_attack();
			grapple();
		}
		else
		{
			die();
		}
		whip.visible = !whip.animation.finished;
		super.update(elapsed);
	}

	/**set initial controls**/
	function controls()
	{
		RIGHT = Ctrl.right[team];
		LEFT = Ctrl.left[team];
		UP = Ctrl.up[team];
		DOWN = Ctrl.down[team];
		ATTACK = Ctrl.jattack[team];
		GRAPPLE = Ctrl.jgrapple[team];
		CHARGE_ATTACK = Ctrl.attack[team];
	}

	function enter()
	{
		if (state.indexOf("enter") <= -1)
			return;
		switch (state)
		{
			case "enter_start":
				offset.set(root_offset.x, root_offset.y + 325);
				animProtect("fall");
				sstate("enter_fall");
				inv = 999;
			case "enter_fall":
				if (BaseState.WIPING)
					return;
				offset.y -= 25;
				if (offset.x == root_offset.x && offset.y == root_offset.y)
				{
					offset.set(root_offset.x, root_offset.y);
					sstate("enter_land");
					anim("land");
					tick = 0;
					land_melee.setPosition(x - offset.x, y - offset.y);
					for (e in PlayState.self.enemies)
						e.hitM(land_melee);
				}
			case "enter_land":
				land_melee.setPosition(-99, -99);
				ttick();
				if (tick >= 5)
				{
					anim("idle");
					sstate("move");
					inv = 15;
				}
		}
	}

	/**define movement actions*/
	function movement()
	{
		if (state != "move")
			return;

		maxVelocity.set(speed, speed);
		drag.set(500, 500);

		var HORZ_MOVE:Bool = RIGHT || LEFT;
		var VERT_MOVE:Bool = UP || DOWN;

		var ACL_RATE:Float = speed / accelFrames;
		var ACL_RATE_REVERSE:Float = ACL_RATE * 1.5;

		if (RIGHT)
		{
			velocity.x += ACL_RATE;
			if (velocity.x < 0)
				velocity.x += ACL_RATE_REVERSE;
		}
		else if (LEFT)
		{
			velocity.x -= ACL_RATE;
			if (velocity.x > 0)
				velocity.x -= ACL_RATE_REVERSE;
		}
		if (UP)
		{
			velocity.y -= ACL_RATE;
			if (velocity.y > 0)
				velocity.y -= ACL_RATE_REVERSE;
		}
		else if (DOWN)
		{
			velocity.y += ACL_RATE;
			if (velocity.y < 0)
				velocity.y += ACL_RATE_REVERSE;
		}
		if (HORZ_MOVE && !VERT_MOVE)
		{
			anim("horz_move");
			flipX = LEFT;
			if (LEFT && RIGHT)
				flipX = velocity.x < 0;
		}
		else if (!HORZ_MOVE && VERT_MOVE)
		{
			anim("vert_move");
			flipX = false;
		}

		if (!HORZ_MOVE && !VERT_MOVE)
		{
			animation.stop();
			head_sprite.animation.stop();
		}
	}

	function whip_attack()
	{
		if (state == "move" && ATTACK)
		{
			anim("idle");
			state = "whip";
			if (LEFT && !flipX)
				flipX = true;
			if (RIGHT && flipX)
				flipX = false;
		}
		if (state != "whip")
			return;

		if (ATTACK && animation.frameIndex >= 8)
			continue_attacking = true;

		animProtect("whip");

		maxVelocity.set(speed * 1.65, speed * 1.65);
		drag.set(1000, 1000);

		whip.flipX = flipX;
		whip.velocity.copyFrom(velocity);
		whip.drag.copyFrom(drag);
		whip.acceleration.copyFrom(acceleration);

		if (!flipX)
			whip.setPosition(x, y - 1);
		if (flipX)
			whip.setPosition(x - 50, y - 1);

		whip.setPosition(whip.x - offset.x, whip.y - offset.y);

		whip.visible = true;
		// whip.color = FlxColor.PURPLE;

		if (prevFrame != animation.frameIndex)
		{
			switch (animation.frameIndex)
			{
				case 8:
					velocity.x = maxVelocity.x;
					velocity.x = flipX ? -Math.abs(velocity.x) : Math.abs(velocity.x);
					if (UP)
						velocity.y = -maxVelocity.y;
					if (DOWN)
						velocity.y = maxVelocity.y;
					whip.animProtect("reset");
					whip.animProtect("whip");
					whip.flipY = false;
					whip.melee_id = 1;
				case 11:
					velocity.x = maxVelocity.x;
					velocity.x = flipX ? -Math.abs(velocity.x) : Math.abs(velocity.x);
					if (UP)
						velocity.y = -maxVelocity.y;
					if (DOWN)
						velocity.y = maxVelocity.y;
					whip.animProtect("reset");
					whip.animProtect("whip");
					whip.flipY = true;
					whip.melee_id = 2;
			}
		}

		if (LEFT && velocity.x > 0)
			velocity.x = velocity.x * .9;
		if (RIGHT && velocity.x < 0)
			velocity.x = velocity.x * .9;

		if (animation.finished || animation.frameIndex >= 10 && !continue_attacking)
		{
			if (!continue_attacking)
				anim("idle");
			state = "move";
			whip.visible = false;
			continue_attacking = false;
			if (continue_attacking)
				anim("idle");
		}

		var enemy_hit:Bool = false;
		for (e in PlayState.self.enemies)
			if (e.hitM(whip))
				enemy_hit = true;

		if (enemy_hit)
		{
			velocity.set(velocity.x * .5, velocity.y * .5);
		}
	}

	function head_movement()
	{
		var left_mod:Int = flipX ? -21 : 0;
		head_sprite.flipX = flipX;
		head_sprite.velocity.copyFrom(velocity);
		head_sprite.drag.copyFrom(drag);
		head_sprite.acceleration.copyFrom(acceleration);

		var FRONT_HEAD:Bool = !(UP && FlxMath.inBounds(animation.frameIndex, 4, 7));

		switch (animation.frameIndex)
		{
			// head
			case 0:
				head_sprite.setPosition(x + 11 + left_mod, y - 12);
				head_sprite.anim("side");
			case 1:
				head_sprite.setPosition(x + 10 + left_mod, y - 9);
				head_sprite.anim("side");
			case 2:
				head_sprite.setPosition(x + 4 + left_mod, y - 4);
				head_sprite.anim("side");
			case 3:
				head_sprite.setPosition(x + 2 + left_mod, y - 8);
				head_sprite.anim("side");
			case 4:
				head_sprite.setPosition(x - 4, y - 16);
				UP ? head_sprite.anim("back_squash") : head_sprite.anim("front_squash");
				head_sprite.flipX = true;
			case 5:
				head_sprite.setPosition(x - 3, y - 20);
				UP ? head_sprite.anim("back") : head_sprite.anim("front");
				head_sprite.flipX = true;
			case 6:
				head_sprite.setPosition(x - 3, y - 19);
				UP ? head_sprite.anim("back_squash") : head_sprite.anim("front_squash");
				head_sprite.flipX = false;
			case 7:
				head_sprite.setPosition(x - 2, y - 20);
				UP ? head_sprite.anim("back") : head_sprite.anim("front");
				head_sprite.flipX = false;
			// whip 1
			case 8:
				head_sprite.setPosition(x + 15 + left_mod, y - 16);
				head_sprite.anim("back");
				FRONT_HEAD = false;
			case 9:
				head_sprite.setPosition(x - 1 + left_mod, y - 15);
				head_sprite.anim("side");
				FRONT_HEAD = true;
			case 10:
				head_sprite.setPosition(x + 5 + left_mod, y - 23);
				head_sprite.anim("side");
			// whip 2
			case 11:
				head_sprite.setPosition(x + 6 + left_mod, y - 10);
				head_sprite.anim("whip_front");
			case 12:
				head_sprite.setPosition(x + 11 + left_mod, y - 18);
				head_sprite.anim("side");
			// grapple
			case 13:
				head_sprite.setPosition(x + 10 + left_mod, y - 2);
				head_sprite.anim("grapple");
			case 14:
				head_sprite.setPosition(x + 10 + left_mod, y - 2);
				head_sprite.anim("grapple");
			case 15:
				head_sprite.setPosition(x + 10 + left_mod, y - 2);
				head_sprite.anim("grapple");
			case 16:
				head_sprite.setPosition(x + 10 + left_mod, y - 2);
				head_sprite.anim("grapple");
		}

		if (FRONT_HEAD && PlayState.self.miscBackP.members.indexOf(head_sprite) > -1)
		{
			PlayState.self.miscBackP.remove(head_sprite, true);
			PlayState.self.miscFrontP.add(head_sprite);
		}
		else if (!FRONT_HEAD && PlayState.self.miscFrontP.members.indexOf(head_sprite) > -1)
		{
			PlayState.self.miscFrontP.remove(head_sprite, true);
			PlayState.self.miscBackP.add(head_sprite);
		}

		head_sprite.setPosition(head_sprite.x - offset.x, head_sprite.y - offset.y);
	}

	function grapple()
	{
		if (state == "move" && GRAPPLE)
		{
			anim("idle");
			state = "grapple_shoot";
			if (LEFT && !flipX)
				flipX = true;
			if (RIGHT && flipX)
				flipX = false;
		}
		if (state.indexOf("grapple") <= -1)
			return;
		switch (state)
		{
			case "grapple_shoot":
				animProtect("grapple");
				head_sprite.animProtect("grapple");
				var len:Int = grappling_hook.length;
				if (tick % GRAPPLE_RATE == 0)
				{
					// keep shooting grappling hook
					if (len < MAX_GRAPPLE_LENGTH)
					{
						var grapple_piece:FlxSpriteExt = new FlxSpriteExt(0, 0, AssetPaths.grapple__png);
						grappling_hook.add(grapple_piece);

						for (c in 0...len)
						{
							var spawn_point:FlxPoint = c > 0 ? grappling_hook.members[c - 1].getMidpoint(FlxPoint.weak()) : getMidpoint(FlxPoint.weak());

							if (flipX)
								spawn_point.x -= GRAPPLE_PIECE_WIDTH * 2;
							else
								spawn_point.x += GRAPPLE_PIECE_WIDTH;

							grappling_hook.members[c].setPosition(spawn_point.x, spawn_point.y - GRAPPLE_PIECE_WIDTH / 2);

							for (e in PlayState.self.enemies)
							{
								if (e.overlaps(grappling_hook.members[c]) && FlxG.pixelPerfectOverlap(e, grappling_hook.members[c]))
								{
									sstate("grapple_pull");
									grapple_enemy = e;
									grapple_enemy.moves = false;
									grapple_enemy.color = FlxColor.GRAY;
									// PlayState.self.hitstop = 10;
								}
							}
						}
						PlayState.self.miscFrontP.add(grapple_piece);
					}
					else // max grappling hook range reached
					{
						grappling_hook.members.pop();
						sstate("grapple_retract");
					}
				}
				ttick();
			case "grapple_retract":
				if (grappling_hook.getFirstAlive() != null)
				{
					grappling_hook.members[grappling_hook.members.length - 1].kill();
					PlayState.self.miscFrontP.remove(grappling_hook.members[grappling_hook.members.length - 1], true);
					grappling_hook.members.pop();
				}
				else
				{
					grappling_hook.clear();
					sstate("move");
					anim("idle");
					head_sprite.anim("side");
				}
			case "grapple_pull":
				immovable = true;
				var grp:FlxSpriteExt = grappling_hook.getFirstAlive();
				anim("grapple");
				head_sprite.anim("grapple");

				if (grp != null && grp.x != 0 && grp.y != 0)
				{
					var mp1:FlxPoint = getMidpoint();
					var mp2:FlxPoint = grp.getMidpoint();
					setPosition(mp2.x - width / 2 - grp.width / 2, mp2.y - height / 2 - grp.height / 2);
					if (overlaps(grp))
					{
						grp.kill();
						PlayState.self.miscFrontP.remove(grp, true);
					}
					inv = 15;
				}
				else
				{
					if (grapple_enemy != null)
					{
						grapple_enemy.damage(0, 10, getMidpoint(), FlxPoint.weak(1500, 100));
						grapple_enemy.color = FlxColor.WHITE;
						grapple_enemy.moves = true;
						grapple_enemy = null;
					}
					grappling_hook.clear();
					sstate("move");
					immovable = false;
					velocity.set(0, 0);
					anim("idle");
					head_sprite.anim("side");
				}
		}
	}

	override function killAssist()
	{
		if (DYING)
			return;
		DYING = true;
		sstate("die_hit");
		super.killAssist();
		inv = 999;
		trace("KILL ASSIST " + inv);
	}

	function die()
	{
		if (state.indexOf("die") <= -1)
			return;
		// trace(tick, state, animation.name);
		inv = 999;

		switch (state)
		{
			case "die_hit":
				if (grappling_hook.length < 0)
				{
					for (point in grappling_hook)
						point.kill();
					grappling_hook.clear();
				}
				anim("hit");
				ttick();
				if (tick > 5)
					sstate("die_anim");
			case "die_anim":
				animProtect("die");
				// trace(animation.frameIndex, animation.finished);
				if (animation.finished)
				{
					sstate("die_wait");
					blood_explode();
				}
			case "die_wait":
				visible = false;
				ttick();
				if (tick > 15)
				{
					visible = true;
					DYING = false;
					sstate("enter_start");
					setPosition(spawn_point.x, spawn_point.y);
					enter();
				}
		}
	}
}
