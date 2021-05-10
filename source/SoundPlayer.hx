import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;

class SoundPlayer
{
	public static var MUSIC_ALREADY_PLAYING:String = "";
	public static var MUSIC_VOLUME:Float = .6;
	public static var SOUND_VOLUME:Float = 1;

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

	public static function play_sound(sound_asset:FlxSoundAsset, vol:Float = 1):FlxSound
	{
		return FlxG.sound.play(sound_asset, SOUND_VOLUME * vol);
	}

	static var slots:Array<Array<FlxSoundAsset>> = [];

	public static function altSound(slot:Int, sounds:Array<FlxSoundAsset>, vol:Float = 1):FlxSound
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
		slots[slot].push(soundToPlay);

		return play_sound(soundToPlay, vol);
	}

	static var announcer_sound:FlxSound;
	static var current_announcer_priority:AnnouncerPriority = NONE;

	public static function announcer(priority:AnnouncerPriority, sound_asset:FlxSoundAsset, vol:Float = 1):FlxSound
	{
		trace(priority, current_announcer_priority, priority >= current_announcer_priority);
		if (priority >= current_announcer_priority || announcer_sound == null || !announcer_sound.playing)
		{
			if (announcer_sound != null)
				announcer_sound.pause();
			announcer_sound = play_sound(sound_asset, vol);
			current_announcer_priority = priority;
			announcer_sound.onComplete = reset_announcer_sound;
		}
		return announcer_sound;
	}

	public static function announcerAlt(priority:AnnouncerPriority, slot:Int, sounds:Array<FlxSoundAsset>, vol:Float = 1):FlxSound
	{
		trace(priority, current_announcer_priority, priority >= current_announcer_priority);
		if (priority >= current_announcer_priority || announcer_sound == null || !announcer_sound.playing)
		{
			if (announcer_sound != null)
				announcer_sound.pause();
			announcer_sound = altSound(slot, sounds, vol);
			current_announcer_priority = priority;
			announcer_sound.onComplete = reset_announcer_sound;
		}
		return announcer_sound;
	}

	public static function reset_announcer_sound()
	{
		current_announcer_priority = NONE;
		trace("!");
	}
}

@:enum
abstract AnnouncerPriority(Int) to Int
{
	var NONE = 0;
	var DEAD = 1;
	var COMBO = 2;
	var RESTART = 3;
	var EXIT = 4;
	var UPGRADE = 5;
	var BOSS = 6;
	var ENDING = 7;
	var RANKING = 8;
	var TIMES_UP = 9;

	@:op(A > B) static function gt(a:AnnouncerPriority, b:AnnouncerPriority):Bool;

	@:op(A >= B) static function gt(a:AnnouncerPriority, b:AnnouncerPriority):Bool;
}
