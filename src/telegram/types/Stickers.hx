/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

import telegram.types.Core.File;
import telegram.types.Core.PhotoSize;

/**
	This object represents a sticker.
**/
typedef Sticker = {
	fileId:String,
	fileUniqueId:String,
	width:Int,
	height:Int,
	isAnimated:Bool,
	isVideo:Bool,
	?thumb:PhotoSize,
	?emoji:String,
	?setName:String,
	?premiumAnimation:File,
	?maskPosition:MaskPosition,
	?fileSize:Int
}

/**
	This object represents a sticker set.
**/
typedef StickerSet = {
	name:String,
	title:String,
	isAnimated:Bool,
	isVideo:Bool,
	containsMasks:Bool,
	stickers:Array<Sticker>,
	?thumb:PhotoSize
}

/**
	This object describes the position on faces where a mask should be placed by default.
**/
typedef MaskPosition = {
	point:String,
	xShift:Float,
	yShift:Float,
	scale:Float
}
