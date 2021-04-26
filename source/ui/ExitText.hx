package ui;

class ExitText extends FlxSpriteExt
{
	var og:FlxPoint;

	public function new(?X:Float, ?Y:Float)
	{
		super(X, Y);

		loadGraphic(AssetPaths.exit_text__png);

		setPosition(FlxG.width / 2 - width / 2, FlxG.height / 2 - height / 2);
		og = new FlxPoint(x, y);
		x += FlxG.width / 2;

		scrollFactor.set(0, 0);

		sstate("scroll_in");
		PlayState.self.ui.add(this);
		maxVelocity.set(999999, 99999);
		velocity.x = -2000;
	}

	override function update(elapsed:Float)
	{
		switch (state)
		{
			case "scroll_in":
				acceleration.x = -5000;
				if (x <= og.x)
				{
					sstate("hold");
					acceleration.set(0, 0);
					velocity.set(0, 0);
					setPosition(og.x, og.y);
				}
			case "hold":
				ttick();
				if (tick > 30)
				{
					sstate("dismiss");
					velocity.x = -2000;
				}
			case "dismiss":
				acceleration.x = -5000;
				if (!isOnScreen())
					kill();
		}
		super.update(elapsed);
	}
}
