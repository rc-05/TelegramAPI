/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

import telegram.types.Core.InlineKeyboardMarkup;
import telegram.types.Core.Location;
import telegram.types.Core.MessageEntity;
import telegram.types.Core.User;
import telegram.types.Payments.LabeledPrice;

/**
	This object represents an incoming inline query.
	When the user sends an empty query, your bot could return some default or trending results.
**/
typedef InlineQuery = {
	id:String,
	from:User,
	query:String,
	?offset:String,
	?chatType:String,
	?location:Location
}

/**
	This object represents one result of an inline query.
	Telegram clients currently support results of the following 20 types:

	- InlineQueryResultCachedAudio
	- InlineQueryResultCachedDocument
	- InlineQueryResultCachedGif
	- InlineQueryResultCachedMpeg4Gif
	- InlineQueryResultCachedPhoto
	- InlineQueryResultCachedSticker
	- InlineQueryResultCachedVideo
	- InlineQueryResultCachedVoice
	- InlineQueryResultArticle
	- InlineQueryResultAudio
	- InlineQueryResultContact
	- InlineQueryResultGame
	- InlineQueryResultDocument
	- InlineQueryResultGif
	- InlineQueryResultLocation
	- InlineQueryResultMpeg4Gif
	- InlineQueryResultPhoto
	- InlineQueryResultVenue
	- InlineQueryResultVideo
	- InlineQueryResultVoice
**/
typedef InlineQueryResult = {
	?cached_audio:InlineQueryResultCachedAudio,
	?cached_document:InlineQueryResultCachedDocument,
	?cached_gif:InlineQueryResultCachedGif,
	?cached_mpeg:InlineQueryResultCachedMpeg4Gif,
	?cached_photo:InlineQueryResultCachedPhoto,
	?cached_sticker:InlineQueryResultCachedSticker,
	?cached_video:InlineQueryResultCachedVideo,
	?cached_voice:InlineQueryResultCachedVoice,
	?article:InlineQueryResultArticle,
	?audio:InlineQueryResultAudio,
	?contact:InlineQueryResultContact,
	?game:InlineQueryResultGame,
	?document:InlineQueryResultDocument,
	?gif:InlineQueryResultGif,
	?location:InlineQueryResultLocation,
	?mpeg:InlineQueryResultMpeg4Gif,
	?photo:InlineQueryResultPhoto,
	?venue:InlineQueryResultVenue,
	?video:InlineQueryResultVideo,
	?voice:InlineQueryResultVoice
}

/**
	Represents a link to an article or web page.
**/
typedef InlineQueryResultArticle = {
	type:String,
	id:String,
	title:String,
	input_message_content:InputMessageContent,
	?reply_markup:InlineKeyboardMarkup,
	?url:String,
	?hide_url:Bool,
	?description:String,
	?thumb_url:String,
	?thumb_width:Int,
	?thumb_height:Int
}

/**
	Represents a link to a photo.
	By default, this photo will be sent by the user with optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the photo.
**/
typedef InlineQueryResultPhoto = {
	type:String,
	id:String,
	photo_url:String,
	thumb_url:String,
	?photo_width:Int,
	?photo_height:Int,
	?title:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to an animated GIF file.
	By default, this animated GIF file will be sent by the user with optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the animation.
**/
typedef InlineQueryResultGif = {
	type:String,
	id:String,
	gif_url:String,
	?gif_width:Int,
	?gif_height:Int,
	?gif_duration:Int,
	thumb_url:String,
	?thumb_mime_type:String,
	?title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a video animation (H.264/MPEG-4 AVC video without sound).
	By default, this animated MPEG-4 file will be sent by the user with optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the animation.
**/
typedef InlineQueryResultMpeg4Gif = {
	type:String,
	id:String,
	mpeg4_url:String,
	?mpeg4_width:Int,
	?mpeg4_height:Int,
	thumb_url:String,
	?thumb_mime_type:String,
	?title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a page containing an embedded video player or a video file.
	By default, this video file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the video.
**/
typedef InlineQueryResultVideo = {
	type:String,
	id:String,
	video_url:String,
	mime_type:String,
	thumb_url:String,
	title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?video_width:Int,
	?video_height:Int,
	?description:String,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to an MP3 audio file.
	By default, this audio file will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the audio.
**/
typedef InlineQueryResultAudio = {
	type:String,
	id:String,
	audio_url:String,
	title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?performer:String,
	?audio_duration:Int,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a voice recording in an .OGG container encoded with OPUS.
	By default, this voice recording will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the the voice message.
**/
typedef InlineQueryResultVoice = {
	type:String,
	id:String,
	voice_url:String,
	title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?voice_duration:Int,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a file.
	By default, this file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the file.

	Currently, only _.PDF_ and _.ZIP_ files can be sent using this method.
**/
typedef InlineQueryResultDocument = {
	type:String,
	id:String,
	title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	document_url:String,
	mime_type:String,
	?description:String,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent,
	?thumb_url:String,
	?thumb_width:Int,
	?thumb_height:Int
}

/**
	Represents a location on a map.
	By default, the location will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the location.
**/
typedef InlineQueryResultLocation = {
	type:String,
	id:String,
	latitude:Float,
	longitude:Float,
	title:String,
	?horizontal_accuracy:Float,
	?live_period:Int,
	?heading:Int,
	?proximity_alert_radius:Int,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent,
	?thumb_url:String,
	?thumb_width:Int,
	?thumb_height:Int
}

/**
	Represents a venue.
	By default, the venue will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the venue.
**/
typedef InlineQueryResultVenue = {
	type:String,
	id:String,
	latitude:Float,
	longitude:Float,
	title:String,
	address:String,
	?foursquare_id:String,
	?foursquare_type:String,
	?google_place_id:String,
	?google_place_type:String,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent,
	?thumb_url:String,
	?thumb_width:Int,
	?thumb_height:Int
}

/**
	Represents a contact with a phone number.
	By default, this contact will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the contact.
**/
typedef InlineQueryResultContact = {
	type:String,
	id:String,
	phone_number:String,
	first_name:String,
	?last_name:String,
	?vcard:String,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent,
	?thumb_url:String,
	?thumb_width:Int,
	?thumb_height:Int
}

/**
	Represents a [Game](https://core.telegram.org/bots/api#games).
**/
typedef InlineQueryResultGame = {
	type:String,
	id:String,
	game_short_name:String,
	?reply_markup:InlineKeyboardMarkup
}

/**
	Represents a link to a photo stored on the Telegram servers.
	By default, this photo will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the photo.
**/
typedef InlineQueryResultCachedPhoto = {
	type:String,
	id:String,
	photo_file_id:String,
	?title:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to an animated GIF file stored on the Telegram servers.
	By default, this animated GIF file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with specified content instead of the animation.
**/
typedef InlineQueryResultCachedGif = {
	type:String,
	id:String,
	gif_file_id:String,
	?title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a video animation (H.264/MPEG-4 AVC video without sound) stored on the Telegram servers.
	By default, this animated MPEG-4 file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the animation.
**/
typedef InlineQueryResultCachedMpeg4Gif = {
	type:String,
	id:String,
	mpeg4_file_id:String,
	?title:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a sticker stored on the Telegram servers.
	By default, this sticker will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the sticker.
**/
typedef InlineQueryResultCachedSticker = {
	type:String,
	id:String,
	sticker_file_id:String,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a file stored on the Telegram servers.
	By default, this file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the file.
**/
typedef InlineQueryResultCachedDocument = {
	type:String,
	id:String,
	title:String,
	document_file_id:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a video file stored on the Telegram servers.
	By default, this video file will be sent by the user with an optional caption.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the video.
**/
typedef InlineQueryResultCachedVideo = {
	type:String,
	id:String,
	video_file_id:String,
	title:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to a voice message stored on the Telegram servers.
	By default, this voice message will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the voice message.
**/
typedef InlineQueryResultCachedVoice = {
	type:String,
	id:String,
	voice_file_id:String,
	title:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	Represents a link to an MP3 audio file stored on the Telegram servers.
	By default, this audio file will be sent by the user.

	Alternatively, you can use `input_message_content` to send a message with the specified content instead of the voice message.
**/
typedef InlineQueryResultCachedAudio = {
	type:String,
	id:String,
	audio_file_id:String,
	title:String,
	?description:String,
	?caption:String,
	?parse_mode:String,
	?caption_entities:Array<MessageEntity>,
	?reply_markup:InlineKeyboardMarkup,
	?input_message_content:InputMessageContent
}

/**
	This object represents the content of a message to be sent as a result of an inline query.
	Telegram clients currently support the following 5 types:

	- InputTextMessageContent
	- InputLocationMessageContent
	- InputVenueMessageContent
	- InputContactMessageContent
	- InputInvoiceMessageContent
**/
typedef InputMessageContent = {
	?text:InputTextMessageContent,
	?location:InputLocationMessageContent,
	?venue:InputVenueMessageContent,
	?contact:InputContactMessageContent,
	?invoice:InputInvoiceMessageContent
}

/**
	Represents the content of a text message to be sent as the result of an inline query.
**/
typedef InputTextMessageContent = {
	message_text:String,
	?parse_mode:String,
	?entities:Array<MessageEntity>,
	?disable_web_page_preview:Bool
}

/**
	Represents the content of a location message to be sent as the result of an inline query.
**/
typedef InputLocationMessageContent = {
	latitude:Float,
	longitude:Float,
	?horizontal_accuracy:Float,
	?live_period:Int,
	?heading:Int,
	?proximity_alert_radius:Int
}

/**
	Represents the content of a venue message to be sent as the result of an inline query.
**/
typedef InputVenueMessageContent = {
	latitude:Float,
	longitude:Float,
	title:String,
	address:String,
	?foursquare_id:String,
	?foursquare_type:String,
	?google_place_id:String,
	?google_place_type:String
}

/**
	Represents the content of a contact message to be sent as the result of an inline query.
**/
typedef InputContactMessageContent = {
	phone_number:String,
	first_name:String,
	?last_name:String,
	?vcard:String
}

/**
	Represents the content of an invoice message to be sent as the result of an inline query.
**/
typedef InputInvoiceMessageContent = {
	title:String,
	description:String,
	payload:String,
	provider_token:String,
	currency:String,
	prices:Array<LabeledPrice>,
	?max_tip_amount:Int,
	?suggested_tip_amounts:Array<Int>,
	?provider_data:String,
	?photo_url:String,
	?photo_size:Int,
	?photo_width:Int,
	?photo_height:Int,
	?need_name:Bool,
	?need_email:Bool,
	?need_shipping_address:Bool,
	?send_phone_number_to_provider:Bool,
	?send_email_to_provider:Bool,
	?is_flexible:Bool
}

/**
	Represents a result of an inline query that was chosen by the user and sent to their chat partner.
**/
typedef ChosenInlineResult = {
	result_id:String,
	from:User,
	?location:Location,
	?inline_message_id:String,
	query:String
}

/**
	Describes an inline message sent by a [Web App](https://core.telegram.org/bots/webapps) on behalf of a user.
**/
typedef SentWebAppMessage = {
	?inline_message_id:String
}
