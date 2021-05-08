#if html5
import io.newgrounds.NG;
import openfl.net.URLRequest;

class NewgroundsHandler
{
	public function new() {}

	public static function init()
	{
		/*
			Make sure this file exists, it's just a simple json that has this format
			{
				"app_id":"xxx",
				"encryption_key":"xxx"
			}
		 */
		var json = haxe.Json.parse(Utils.loadAssistString("assets/data/config/ng_api/ng_secrets.json"));

		NG.create(json.app_id);

		if (NG.core.loggedIn == false)
			NG.core.requestLogin(function():Void
			{
				trace("manually logged in");
				Main.NG_LOGGED_IN = true;
			});
		else
			Main.NG_LOGGED_IN = true;

		NG.core.initEncryption(json.encryption_key);
		NG.core.requestMedals();
	}

	public static function medal_popup(id:Int)
	{
		trace("got medal");
		var medal = NG.core.medals.get(id);
		trace('${medal.name} #${medal.id} is worth ${medal.value} points!');
		trace(medal.icon);
		new NGMedalPopUp(medal.name, medal.icon);
	}
}
#end
