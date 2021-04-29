import flixel.system.FlxAssets.FlxSoundAsset;

class SoundPlayer
{
	public static var MUSIC_ALREADY_PLAYING:String = "";
	public static var MUSIC_VOLUME:Float = 0;
	public static var SOUND_VOLUME:Float = 0;

	public static function play_music(music_name:String)
	{
		if (FlxG.sound.music == null)
			MUSIC_ALREADY_PLAYING = "";
		if (music_name != MUSIC_ALREADY_PLAYING)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			switch (music_name)
			{
				case "stage":
					FlxG.sound.playMusic(AssetPaths.StageThemeJohnnyGuy__ogg, MUSIC_VOLUME);
				case "boss":
					FlxG.sound.playMusic(AssetPaths.BossThemeJohnnyGuy__ogg, MUSIC_VOLUME);
			}
		}
		MUSIC_ALREADY_PLAYING = music_name;
	}

	public static function play_sound(sound_asset:FlxSoundAsset, vol:Float = 1)
	{
		FlxG.sound.play(sound_asset, SOUND_VOLUME * vol);
	}

	static var slots:Array<Array<FlxSoundAsset>> = [];

	public static function altSound(slot:Int, sounds:Array<FlxSoundAsset>, vol:Float = 1)
	{
		#if nomusic
		return;
		#end
		if (slots[slot] == null || slots[slot] == [])
		{
			slots[slot] = sounds;
		}

		var f:FlxRandom = new FlxRandom();
		f.shuffle(slots[slot]);

		var soundToPlay:String = slots[slot].pop();
		play_sound(soundToPlay, vol);
		slots[slot].push(soundToPlay);
	}
}
