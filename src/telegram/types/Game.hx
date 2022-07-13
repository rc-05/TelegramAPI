/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

import telegram.types.Core.Animation;
import telegram.types.Core.MessageEntity;
import telegram.types.Core.PhotoSize;
import telegram.types.Core.User;

/**
	This object represents a game.
	Use BotFather to create and edit games, their short names will act as unique identifiers.
**/
typedef Game = {
	title:String,
	description:String,
	photo:Array<PhotoSize>,
	?text:String,
	?textEntries:Array<MessageEntity>,
	?animation:Animation
}

/**
	A placeholder, currently holds no information. Use BotFather to set up your game.
**/
typedef CallbackGame = {}

/**
	This object represents one row of the high scores table for a game.
**/
typedef GameHighScore = {
	position:Int,
	user:User,
	score:Int
}
