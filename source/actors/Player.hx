package actors;

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

	var continue_attacking:Bool = false;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		team = 1;
		str = 1;

		loadAllFromAnimationSet("player_body_default");
		head_sprite = new FlxSpriteExt();
		head_sprite.loadAllFromAnimationSet("player_head_default");
		head_movement();

		whip = new Melee(-999, -999, team, str, new FlxPoint(300, 100));
		whip.loadAllFromAnimationSet("whip");
		PlayState.self.miscFront.add(whip);

		maxVelocity.set(speed, speed);
		drag.set(500, 500);

		PlayState.self.players.add(this);
		PlayState.self.miscFrontP.add(head_sprite);

		sstate('move');

		setSize(24, 51);
		offset.set(39, 65);

		// head_sprite.visible = false;
	}

	override function update(elapsed:Float)
	{
		controls();
		movement();
		head_movement();
		whip_attack();

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
}
