/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import telegram.types.Core.Message;
import telegram.Bot;

final class Test extends Bot {
	public function new() {
		super("Insert token here");

		setMyCommands([
			{
				command: "about",
				description: "Get info about this bot."
			},
			{
				command: "help",
				description: "Display an helpful message."
			}
		]);
		var cmds = getMyCommands();
		trace(cmds);
	}

	override function onMessageEvent(message:Message) {
		if (message.text == "/about") {
			sendPhoto(message.chat.id, "https://haxe.org/img/branding/haxe-logo-white-background.png", "Bot written in Haxe", "", null, true);
		} else {
			sendMessage(message.chat.id, ${message.text});
		}
	}

	static function main() {
		var bot = new Test();
		bot.start();
	}
}
