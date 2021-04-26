import flixel.system.FlxAssets.FlxSoundAsset;

class SoundPlayer
{
	static var MUSIC_ALREADY_PLAYING:String = "";
	public static var MUSIC_VOLUME:Float = 1;
	public static var SOUND_VOLUME:Float = 1;

	public static function play_music(music_name:String)
	{
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

	public static function play_sound(sound_asset:FlxSoundAsset)
	{
		FlxG.sound.play(sound_asset, SOUND_VOLUME);
	}
}
