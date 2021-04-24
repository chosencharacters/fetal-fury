package actors;

class Player extends Actor
{
	var speed:Int = 350;
	var accelFrames:Int = 15;

	var RIGHT:Bool = false;
	var UP:Bool = false;
	var LEFT:Bool = false;
	var DOWN:Bool = false;

	var head_sprite:FlxSprite;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		team = 1;

		loadAllFromAnimationSet("player_body_default");

		maxVelocity.set(speed, speed);
		drag.set(500, 500);
	}

	override function update(elapsed:Float)
	{
		controls();
		movement();
		super.update(elapsed);
	}

	function controls()
	{
		RIGHT = Ctrl.right[team];
		LEFT = Ctrl.left[team];
		UP = Ctrl.up[team];
		DOWN = Ctrl.down[team];
	}

	function movement()
	{
		if (RIGHT)
		{
			velocity.x += speed / accelFrames;
		}
		else if (LEFT)
		{
			velocity.x -= speed / accelFrames;
		}
		if (UP)
		{
			velocity.y -= speed / accelFrames;
		}
		else if (DOWN)
		{
			velocity.y += speed / accelFrames;
		}
	}
}
