package ui;

import flixel.FlxCamera.FlxCameraFollowStyle;

class BossIntro extends FlxSpriteExt
{
	var boss:Enemy;
	var og:FlxPoint;

	public function new(Boss:Enemy)
	{
		super();

		boss = Boss;

		sstate("wait_start");
		SoundPlayer.play_music("boss");

		scrollFactor.set(0, 0);

		loadGraphic(AssetPaths.boss_name__png);

		setPosition(FlxG.width / 2 - width / 2, FlxG.height - height);
		og = new FlxPoint(x, y);

		PlayState.self.ui.add(this);

		PlayState.self.hitstop = 2;

		visible = false;

		PlayState.BOSS_MODE = true;

		SoundPlayer.play_sound(AssetPaths.AnnouncerBossIntroGetYourAssReady__ogg);
	}

	override function update(elapsed:Float)
	{
		if (BaseState.WIPING || PlayState.self.LEVEL_CLEAR)
			return;

		PlayState.self.hitstop = 2;

		switch (state)
		{
			case "wait_start":
				ttick();
				if (tick < 30)
					for (p in PlayState.self.players)
						p.update(elapsed);
				if (tick > 90)
				{
					sstate("camera_pan_start");
				}
			case "camera_pan_start":
				FlxG.camera.follow(boss, FlxCameraFollowStyle.TOPDOWN, 0.05);
				sstate("title_card");
				x += FlxG.width / 2;
				acceleration.x = -3000;
				SoundPlayer.play_sound(AssetPaths.AnnouncerBossIntroWholeLottaTrouble__ogg);
			case "title_card":
				ttick();
				visible = true;
				if (x <= og.x)
				{
					velocity.set(0, 0);
					acceleration.set(0, 0);
					setPosition(og.x, og.y);
					tick++;
					if (tick > 180)
					{
						acceleration.x = -3000;
						FlxG.camera.follow(PlayState.self.players.getFirstAlive(), FlxCameraFollowStyle.TOPDOWN, 0.1);
						sstate("dismiss");
					}
				}
			case "dismiss":
				if (!isOnScreen())
				{
					FlxG.camera.follow(PlayState.self.players.getFirstAlive(), FlxCameraFollowStyle.TOPDOWN);
					kill();
				}
		}
		super.update(elapsed);
	}
}
