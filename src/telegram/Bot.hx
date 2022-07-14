/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram;

import hxsignal.impl.Signal0;
import haxe.DynamicAccess;
import haxe.Http;
import haxe.Json;
import hxsignal.Signal;
import telegram.Exception;
import telegram.types.Core;
import telegram.types.Game.GameHighScore;
import telegram.types.Inline.ChosenInlineResult;
import telegram.types.Inline.InlineQueryResult;
import telegram.types.Inline.SentWebAppMessage;
import telegram.types.Passport.PassportElementError;
import telegram.types.Payments;
import telegram.types.Stickers.MaskPosition;
import telegram.types.Stickers.StickerSet;

private typedef MarkupTypes = InlineKeyboardMarkup & ReplyKeyboardMarkup & ReplyKeyboardRemove & ForceReply;
private typedef MediaGroup = InputMediaAudio & InputMediaDocument & InputMediaPhoto & InputMediaVideo;

/**
	This object represents the response sent from the Telegram servers.
**/
typedef Response<T> = {
	ok:Bool,
	?result:T,
	?description:String,
	?error_code:Int,
	?parameters:ResponseParameters
}

/**
	This object represents an incoming update.

	At most __one__ of the optional parameters can be present in any given update.
**/
typedef Update = {
	update_id:Int,
	?message:Message,
	?editedMessage:Message,
	?channelPost:Message,
	?editedChannelPost:Message,
	?inlineQuery:Message,
	?chosenInlineResult:ChosenInlineResult,
	?callbackQuery:CallbackQuery,
	?shippingQuery:ShippingQuery,
	?preCheckoutQuery:PreCheckoutQuery,
	?poll:Poll,
	?pollAnswer:PollAnswer,
	?myChatMember:ChatMemberUpdated,
	?chatMember:ChatMemberUpdated,
	?chatJoinRequest:ChatJoinRequest
}

/**
	Class for managing a Telegram bot.
**/
class Bot {
	/**
		Token for the bot.
	**/
	var token:String;

	@:dox(hide) var requestUrl:String;
	@:dox(hide) var http:Http;

	@:dox(hide) var callbackQuerySignal:Signal<() -> Void>;
	@:dox(hide) var channelPostSignal:Signal<() -> Void>;
	@:dox(hide) var chatJoinRequestSignal:Signal<() -> Void>;
	@:dox(hide) var messageSignal:Signal<(Message) -> Void>;

	/**
		Creates a new bot with a `token`.
	**/
	public function new(token:String) {
		this.token = token;
		http = new Http(null);
		requestUrl = 'https://api.telegram.org/bot$token';

		// Instantiate the various signal objects.
		callbackQuerySignal = new Signal<() -> Void>();
		channelPostSignal = new Signal<() -> Void>();
		chatJoinRequestSignal = new Signal<() -> Void>();
		messageSignal = new Signal<(Message) -> Void>();

		// Connect each event to the corresponding signal slot.
		callbackQuerySignal.connect(onCallbackQueryEvent);
		channelPostSignal.connect(onChannelPostEvent);
		chatJoinRequestSignal.connect(onChatJoinRequestEvent);
		messageSignal.connect(onMessageEvent);
	}

	public function onCallbackQueryEvent() {}

	public function onChannelPostEvent() {}

	public function onChatJoinRequestEvent() {}

	public function onMessageEvent(message:Message) {}

	/**
		Starts the event loop for requesting and processing updates with a `delay` in seconds between each request.
	**/
	public function start(delay = 1) {
		var lastOffset = 0;

		while (true) {
			var updates = getUpdates(lastOffset);

			for (update in updates) {
				if (update.callbackQuery != null) {
					callbackQuerySignal.emit();
				}

				if (update.channelPost != null) {
					channelPostSignal.emit();
				}

				if (update.chatJoinRequest != null) {
					chatJoinRequestSignal.emit();
				}

				if (update.message != null) {
					messageSignal.emit(update.message);
				}

				lastOffset = update.update_id + 1;
			}

			Sys.sleep(delay);
		}
	}

	/**
		Performs a POST request to the running bot calling `method` with optional `parameters`.
	**/
	@:dox(hide)
	@:generic
	function performRequest<T>(method:String, ?parameters:Map<String, String>):T {
		var result:T;

		http.url = '$requestUrl/$method';

		if (parameters != null) {
			for (key => value in parameters) {
				http.addParameter(key, value);
			}
		}

		http.onData = function(data) {
			trace(data);
			var response:Response<T> = Json.parse(data);

			// We can assume that the request was succesful so directly extract the result.
			result = response.result;
		}

		http.onError = function(msg) {
			Sys.stderr().writeString('Error in performRequest: $msg');
			var response:Response<T> = Json.parse(http.responseBytes.toString());
			if (response.parameters != null) {
				throw new TelegramException('(${response.error_code}) ${response.description} -> ${response.parameters}');
			} else {
				throw new TelegramException('(${response.error_code}) ${response.description}');
			}
		}

		http.request(true);

		return result;
	}

	/**
		Performs a POST request to the running bot calling `method` with JSON `data`.
	**/
	@:dox(hide)
	@:generic
	function performJsonRequest<T>(method:String, data:Any):T {
		var result:T;

		http.url = '$requestUrl/$method';
		http.setHeader("Content-Type", "application/json");
		http.setPostData(Json.stringify(data));

		http.onData = function(data) {
			trace(data);
			var response:Response<T> = Json.parse(data);

			// We can assume that the request was succesful so directly extract the
			result = response.result;
		}

		http.onError = function(msg) {
			Sys.stderr().writeString('Error in performJsonRequest: $msg');
			var response:Response<T> = Json.parse(http.responseBytes.toString());
			if (response.parameters != null) {
				throw new TelegramException('(${response.error_code}) ${response.description} -> ${response.parameters}');
			} else {
				throw new TelegramException('(${response.error_code}) ${response.description}');
			}
		}

		http.request(true);

		return result;
	}

	/**
		Returns the updates for the bot.
	**/
	public function getUpdates(?offset:Int, ?limit, ?timeout, ?allowedUpdates:Array<String>):Array<Update> {
		var data = new DynamicAccess<Any>();

		(offset != null) ? data["offset"] = offset : null;
		(limit != null) ? data["limit"] = limit : null;
		(timeout != null) ? data["timeout"] = timeout : null;
		(allowedUpdates != null) ? data["allowed_updates"] = allowedUpdates : null;

		return performJsonRequest("getUpdates", data);
	}

	/**
		A simple method for testing your bot's authentication token. Requires no parameters.

		Returns basic information about the bot in form of a User object.
	**/
	public function getMe():User {
		return performRequest("getMe");
	}

	/**
		Use this method to log out from the cloud Bot API server before launching the bot locally.
		You must log out the bot before running it locally, otherwise there is no guarantee that the bot will receive updates.
		After a successful call, you can immediately log in on a local server, but will not be able
		to log in back to the cloud Bot API server for 10 minutes.

		Returns True on success. Requires no parameters.
	**/
	public function logOut():Bool {
		return performRequest("logOut");
	}

	/**
		Use this method to send text messages.

		On success, the sent Message is returned.
	**/
	public function sendMessage(chatId:Any, text:String, parseMode:String = "", ?entities:Array<MessageEntity>, ?disableWebPageReview:Bool,
			?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["text"] = text;
		data["parse_mode"] = parseMode;
		data["text"] = text;
		entities != null ? data["entities"] = entities : null;
		disableWebPageReview != null ? data["disable_web_page_preview"] = disableWebPageReview : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendMessage", data);
	}

	/**
		Use this method to forward messages of any kind.
		Service messages can't be forwarded.

		On success, the sent Message is returned.
	**/
	public function forwardMessage(chatId:Any, fromChatId:Int, messageId:Int, ?disableNotification:Bool, ?protectContent:Bool):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["from_chat_id"] = fromChatId;
		data["message_id"] = messageId;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;

		return performJsonRequest("forwardMessage", data);
	}

	/**
		Use this method to copy messages of any kind. Service messages and invoice messages can't be copied.
		The method is analogous to the method `forwardMessage`, but the copied message doesn't have a link to the original message.

		Returns the MessageId of the sent message on success.
	**/
	public function copyMessage(chatId:Any, fromChatId:Int, messageId:Int, ?caption:String, ?parseMode:String, ?captionEntries:Array<MessageEntity>,
			?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):MessageId {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["from_chat_id"] = fromChatId;
		data["message_id"] = messageId;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntries != null ? data["caption_entries"] = captionEntries : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("copyMessage", data);
	}

	/**
		Use this method to send photos.

		On success, the sent Message is returned.
	**/
	public function sendPhoto(chatId:Any, photo:String, ?caption:String, ?parseMode:String, ?captionEntries:Array<MessageEntity>, ?disableNotification:Bool,
			?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["photo"] = photo;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntries != null ? data["caption_entries"] = captionEntries : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendPhoto", data);
	}

	/**
		Use this method to send audio files, if you want Telegram clients to display them in the music player.
		Your audio must be in the .MP3 or .M4A format.

		On success, the sent Message is returned.

		Bots can currently send audio files of up to 50 MB in size, this limit may be changed in the future.

		For sending voice messages, use the `sendVoice` method instead.
	**/
	public function sendAudio(chatId:Any, audio:String, ?caption:String, ?parseMode:String, ?captionEntries:Array<MessageEntity>, ?duration:Int,
			?performer:Int, ?title:String, ?thumb:String, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["audio"] = audio;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntries != null ? data["caption_entries"] = captionEntries : null;
		duration != null ? data["duration"] = duration : null;
		performer != null ? data["performer"] = performer : null;
		title != null ? data["title"] = title : null;
		thumb != null ? data["thumb"] = thumb : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendAudio", data);
	}

	/**
		Use this method to send video files, Telegram clients support MPEG4 videos (other formats may be sent as Document).

		On success, the sent Message is returned.

		Bots can currently send video files of up to 50 MB in size, this limit may be changed in the future.
	**/
	public function sendVideo(chatId:Any, video:String, ?duration:Int, ?width:Int, ?height:Int, ?thumb:String, ?caption:String, ?parseMode:String,
			?captionEntities:Array<MessageEntity>, ?supportsStreaming:Bool, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["video"] = video;
		duration != null ? data["duration"] = duration : null;
		width != null ? data["width"] = width : null;
		height != null ? data["height"] = height : null;
		thumb != null ? data["thumb"] = thumb : null;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntities != null ? data["caption_entities"] = captionEntities : null;
		supportsStreaming != null ? data["supports_streaming"] = supportsStreaming : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendVideo", data);
	}

	/**
		Use this method to send animation files (GIF or H.264/MPEG-4 AVC video without sound).

		On success, the sent Message is returned.

		Bots can currently send animation files of up to 50 MB in size, this limit may be changed in the future.
	**/
	public function sendAnimation(chatId:Any, animation:String, ?duration:Int, ?width:Int, ?height:Int, ?thumb:String, ?caption:String, ?parseMode:String,
			?captionEntities:Array<MessageEntity>, ?supportsStreaming:Bool, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["animation"] = animation;
		duration != null ? data["duration"] = duration : null;
		width != null ? data["width"] = width : null;
		height != null ? data["height"] = height : null;
		thumb != null ? data["thumb"] = thumb : null;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntities != null ? data["caption_entities"] = captionEntities : null;
		supportsStreaming != null ? data["supports_streaming"] = supportsStreaming : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendAnimation", data);
	}

	/**
		Use this method to send audio files, if you want Telegram clients to display the file as a playable voice message.
		For this to work, your audio must be in an .OGG file encoded with OPUS (other formats may be sent as Audio or Document).

		On success, the sent Message is returned.

		Bots can currently send voice messages of up to 50 MB in size, this limit may be changed in the future.
	**/
	public function sendVoice(chatId:Any, voice:String, ?caption:String, ?parseMode:String, ?captionEntities:Array<MessageEntity>, ?duration:Int,
			?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["voice"] = voice;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntities != null ? data["caption_entities"] = captionEntities : null;
		duration != null ? data["duration"] = duration : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendAnimation", data);
	}

	/**
		As of v.4.0, Telegram clients support rounded square MPEG4 videos of up to 1 minute long.
		Use this method to send video messages.

		On success, the sent Message is returned.
	**/
	public function sendVideoNote(chatId:Any, videoNote:String, ?duration:Int, ?length:Int, ?thumb:String, ?caption:String, ?parseMode:String,
			?captionEntities:Array<MessageEntity>, ?supportsStreaming:Bool, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["video_note"] = videoNote;
		duration != null ? data["duration"] = duration : null;
		length != null ? data["length"] = length : null;
		thumb != null ? data["thumb"] = thumb : null;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntities != null ? data["caption_entities"] = captionEntities : null;
		supportsStreaming != null ? data["supports_streaming"] = supportsStreaming : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendVideo", data);
	}

	/**
		Use this method to send a group of photos, videos, documents or audios as an album.
		Documents and audio files can be only grouped in an album with messages of the same type.

		On success, an array of Messages that were sent is returned.
	**/
	public function sendMediaGroup(chatId:Any, media:MediaGroup, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["media"] = media;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;

		return performJsonRequest("sendMediaGroup", data);
	}

	/**
		Use this method to send point on the map.

		On success, the sent Message is returned.
	**/
	public function sendLocation(chatId:Any, latitude:Float, longitude:Float, ?horizontalAccuracy:Float, ?livePeriod:Int, ?heading:Int,
			?proximityAlertRadius:Int, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool,
			?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["latitude"] = latitude;
		data["longitude"] = longitude;
		horizontalAccuracy != null ? data["horizontal_accuracy"] = horizontalAccuracy : null;
		livePeriod != null ? data["live_period"] = livePeriod : null;
		heading != null ? data["heading"] = heading : null;
		proximityAlertRadius != null ? data["proximity_alert_radius"] = proximityAlertRadius : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["allow_sending_without_reply"] = replyMarkup : null;

		return performJsonRequest("sendLocation", data);
	}

	/**
		Use this method to edit live location messages.
		A location can be edited until its live_period expires or editing is explicitly disabled by a call to stopMessageLiveLocation.

		On success, if the edited message is not an inline message,
		the edited Message is returned, otherwise True is returned.
	**/
	public function editMessageLiveLocation<T:Message & Bool>(latitude:Float, longitude:Float, ?chatId:Any, ?messageId:Int, ?inlineMessageId:String,
			?horizontalAccuracy:Float, ?heading:Int, ?proximityAlertRadius:Int, ?replyMarkup:InlineKeyboardMarkup):T {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		data["latitude"] = latitude;
		data["longitude"] = longitude;
		horizontalAccuracy != null ? data["horizontal_accuracy"] = horizontalAccuracy : null;
		heading != null ? data["heading"] = heading : null;
		proximityAlertRadius != null ? data["proximity_alert_radius"] = proximityAlertRadius : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("editMessageLiveLocation", data);
	}

	/**
		Use this method to stop updating a live location message before live_period expires.

		On success, if the message is not an inline message,
		the edited Message is returned, otherwise True is returned.
	**/
	public function stopMessageLiveLocation<T:Message & Bool, A:Int & String>(?chatId:A, ?messageId:Int, ?inlineMessageId:String,
			?replyMarkup:InlineKeyboardMarkup):T {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("stopMessageLiveLocation", data);
	}

	/**
		Use this method to send information about a venue.

		On success, the sent Message is returned.
	**/
	public function sendVenue(chatId:Any, latitude:Float, longitude:Float, title:String, address:String, ?foursquareId:String, ?foursquareType:String,
			?googlePlaceId:String, ?googlePlaceType:String, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["latitude"] = latitude;
		data["longitude"] = longitude;
		data["title"] = title;
		data["address"] = address;
		foursquareId != null ? data["foursquare_id"] = foursquareId : null;
		foursquareType != null ? data["foursquare_type"] = foursquareType : null;
		googlePlaceId != null ? data["google_place_id"] = googlePlaceId : null;
		googlePlaceType != null ? data["google_place_type"] = googlePlaceType : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendVenue", data);
	}

	/**
		Use this method to send phone contacts.

		On success, the sent Message is returned.
	**/
	public function sendContact(chatId:Any, phoneNumber:String, firstName:String, ?lastName:String, ?vCard:String, ?disableNotification:Bool,
			?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["phone_number"] = phoneNumber;
		data["first_name"] = firstName;
		lastName != null ? data["last_name"] = lastName : null;
		vCard != null ? data["v_card"] = vCard : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendContact", data);
	}

	/**
		Use this method to send a native poll.

		On success, the sent Message is returned.
	**/
	public function sendPoll(chatId:Any, question:String, options:Array<String>, ?isAnonymous:Bool, ?type:String, ?allowsMultipleAnswers:Bool,
			?correctOptionId:Int, ?explanation:String, ?explanationParseMode:String, ?explanationEntities:Array<MessageEntity>, ?openPeriod:Int,
			?closeDate:Int, ?isClosed:Bool, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool,
			?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["question"] = question;
		data["options"] = options;
		isAnonymous != null ? data["is_anonymous"] = isAnonymous : null;
		type != null ? data["type"] = type : null;
		allowsMultipleAnswers != null ? data["allows_multiple_answers"] = allowsMultipleAnswers : null;
		correctOptionId != null ? data["correct_option_id"] = correctOptionId : null;
		explanation != null ? data["explanation"] = explanation : null;
		explanationParseMode != null ? data["explanation_parse_mode"] = explanationParseMode : null;
		explanationEntities != null ? data["explanation_entities"] = explanationEntities : null;
		openPeriod != null ? data["open_period"] = openPeriod : null;
		closeDate != null ? data["close_date"] = closeDate : null;
		isClosed != null ? data["is_closed"] = isClosed : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendPoll", data);
	}

	/**
		Use this method to send an animated emoji that will display a random value.

		On success, the sent Message is returned.
	**/
	public function sendDice(chatId:Any, emoji:String, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int, ?allowSendingWithoutReply:Bool,
			?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["emoji"] = emoji;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendDice", data);
	}

	/**
		Use this method when you need to tell the user that something is happening on the bot's side.
		The status is set for 5 seconds or less (when a message arrives from your bot, Telegram clients clear its typing status).

		Returns True on success.

		__Example:__
		The ImageBot needs some time to process a request and upload the image.
		Instead of sending a text message along the lines of “Retrieving image, please wait…”, the bot may use sendChatAction with action = upload_photo.
		The user will see a “sending photo” status for the bot.

		We only recommend using this method when a response from the bot will take a noticeable amount of time to arrive.
	**/
	public function sendChatAction(chatId:Any, action:String):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["action"] = action;

		return performJsonRequest("sendChatAction", data);
	}

	/**
		Use this method to get a list of profile pictures for a user.

		Returns a UserProfilePhotos object.
	**/
	public function getUserProfilePhotos(userId:Int, ?offset:Int, ?limit:Int):UserProfilePhotos {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		offset != null ? data["offset"] = offset : null;
		limit != null ? data["limit"] = limit : null;

		return performJsonRequest("getUserProfilePhotos", data);
	}

	/**
		Use this method to get basic information about a file and prepare it for downloading.
		For the moment, bots can download files of up to 20MB in size.

		On success, a File object is returned.

		The file can then be downloaded via the link `https://api.telegram.org/file/bot<token>/<file_path>`, where `<file_path>` is taken from the response.
		It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile again.

		_Note:_ This public function may not preserve the original file name and MIME type. You should save the file's MIME type and name (if available) when the File object is received.
	**/
	public function getFile(fileId:String):File {
		var data = new DynamicAccess<Any>();

		data["file_id"] = fileId;

		return performJsonRequest("getFile", data);
	}

	/**
		Use this method to ban a user in a group, a supergroup or a channel.
		In the case of supergroups and channels, the user will not be able to return to the chat on their own using invite links, etc., unless unbanned first.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function banChatMember(chatId:Any, userId:Int, ?untilDate:Int, ?revokeMessages:Bool):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;
		untilDate != null ? data["until_date"] = untilDate : null;
		revokeMessages != null ? data["revoke_messages"] = revokeMessages : null;

		return performJsonRequest("banChatMember", data);
	}

	/**
		Use this method to unban a previously banned user in a supergroup or channel.
		The user will not return to the group or channel automatically, but will be able to join via link, etc.

		The bot must be an administrator for this to work.

		By default, this method guarantees that after the call the user is not a member of the chat, but will be able to join it.
		So if the user is a member of the chat they will also be removed from the chat.
		If you don't want this, use the parameter only_if_banned

		Returns True on success.
	**/
	public function unbanChatMember(chatId:Any, userId:Int, ?onlyIfBanned:Bool):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;
		onlyIfBanned != null ? data["only_if_banned"] = onlyIfBanned : null;

		return performJsonRequest("unbanChatMember", data);
	}

	/**
		Use this method to restrict a user in a supergroup.

		The bot must be an administrator in the supergroup for this to work and must have the appropriate administrator rights.

		Pass True for all permissions to lift restrictions from a user.

		Returns True on success.
	**/
	public function restrictChatMember(chatId:Any, userId:Int, ?permissions:ChatPermissions, ?untilDate:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;
		permissions != null ? data["permissions"] = permissions : null;
		untilDate != null ? data["until_date"] = untilDate : null;

		return performJsonRequest("restrictChatMember", data);
	}

	/**
		Use this method to promote or demote a user in a supergroup or a channel.
		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Pass False for all boolean parameters to demote a user.

		Returns True on success.
	**/
	public function promoteChatMember(chatId:Any, userId:Int, ?isAnonymous:Bool, ?canManageChat:Bool, ?canPostMessages:Bool, ?canEditMessages:Bool,
			?canDeleteMessages:Bool, ?canManageVideoChats:Bool, ?canRestrictMembers:Bool, ?canPromoteMembers:Bool, ?canChangeInfo:Bool, ?canInviteUsers:Bool,
			?canPinMessages:Bool):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;
		isAnonymous != null ? data["is_anonymous"] = isAnonymous : null;
		canManageChat != null ? data["can_manage_chat"] = canManageChat : null;
		canPostMessages != null ? data["can_post_messages"] = canPostMessages : null;
		canEditMessages != null ? data["can_edit_messages"] = canEditMessages : null;
		canDeleteMessages != null ? data["can_delete_messages"] = canDeleteMessages : null;
		canManageVideoChats != null ? data["can_manage_video_chats"] = canManageVideoChats : null;
		canRestrictMembers != null ? data["can_restrict_members"] = canRestrictMembers : null;
		canPromoteMembers != null ? data["can_promote_members"] = canPromoteMembers : null;
		canChangeInfo != null ? data["can_change_info"] = canChangeInfo : null;
		canInviteUsers != null ? data["can_invite_users"] = canInviteUsers : null;
		canPinMessages != null ? data["can_pin_messages"] = canPinMessages : null;

		return performJsonRequest("promoteChatMember", data);
	}

	/**
		Use this method to set a custom title for an administrator in a supergroup promoted by the bot.

		Returns True on success.
	**/
	public function setChatAdministratorCustomTitle(chatId:Any, userId:Int, customTitle:String):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;
		data["custom_title"] = customTitle;

		return performJsonRequest("setChatAdministratorCustomTitle", data);
	}

	/**
		Use this method to ban a channel chat in a supergroup or a channel.
		Until the chat is unbanned, the owner of the banned chat won't be able to send messages on behalf of __any of their channels__.

		The bot must be an administrator in the supergroup or channel for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function banChatSenderChat(chatId:Any, senderChatId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["sender_chat_id"] = senderChatId;

		return performJsonRequest("banChatSenderChat", data);
	}

	/**
		Use this method to unban a previously banned channel chat in a supergroup or channel.

		The bot must be an administrator for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function unbanChatSenderChat(chatId:Any, senderChatId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["sender_chat_id"] = senderChatId;

		return performJsonRequest("unbanChatSenderChat", data);
	}

	/**
		Use this method to set default chat permissions for all members.

		The bot must be an administrator in the group or a supergroup for this to work and must have the `can_restrict_members` administrator rights.

		Returns True on success.
	**/
	public function setChatPermissions(chatId:Any, permissions:ChatPermissions):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["permissions"] = permissions;

		return performJsonRequest("setChatPermissions", data);
	}

	/**
		Use this method to generate a new primary invite link for a chat; any previously generated primary link is revoked.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns the new invite link as String on success.

		_Note:_ Each administrator in a chat generates their own invite links. Bots can't use invite links generated by other administrators.
		If you want your bot to work with invite links, it will need to generate its own link using exportChatInviteLink or by calling the getChat method.
		If your bot needs to generate a new primary invite link replacing its previous one, use exportChatInviteLink again.
	**/
	public function exportChatInviteLink(chatId:Any):String {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("exportChatInviteLink", data);
	}

	/**
		Use this method to create an additional invite link for a chat.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.
		The link can be revoked using the method `revokeChatInviteLink`.

		Returns the new invite link as ChatInviteLink object.
	**/
	public function createChatInviteLink(chatId:Any, ?name:String, ?expireDate:Int, ?memberLimit:Int, ?createsJoinRequest:Bool):ChatInviteLink {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		name != null ? data["name"] = name : null;
		expireDate != null ? data["expire_date"] = expireDate : null;
		memberLimit != null ? data["member_limit"] = memberLimit : null;
		createsJoinRequest != null ? data["creates_join_request"] = createsJoinRequest : null;

		return performJsonRequest("createChatInviteLink", data);
	}

	/**
		Use this method to edit a non-primary invite link created by the bot.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns the edited invite link as a ChatInviteLink object.
	**/
	public function editChatInviteLink(chatId:Any, inviteLink:String, ?name:String, ?expireDate:Int, ?memberLimit:Int,
			?createsJoinRequest:Bool):ChatInviteLink {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["invite_link"] = inviteLink;
		name != null ? data["name"] = name : null;
		expireDate != null ? data["expire_date"] = expireDate : null;
		memberLimit != null ? data["member_limit"] = memberLimit : null;
		createsJoinRequest != null ? data["creates_join_request"] = createsJoinRequest : null;

		return performJsonRequest("editChatInviteLink", data);
	}

	/**
		Use this method to revoke an invite link created by the bot.
		If the primary link is revoked, a new link is automatically generated.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns the revoked invite link as ChatInviteLink object.
	**/
	public function revokeChatInviteLink(chatId:Any, inviteLink:String):ChatInviteLink {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["invite_link"] = inviteLink;

		return performJsonRequest("revokeChatInviteLink", data);
	}

	/**
		Use this method to approve a chat join request.

		The bot must be an administrator in the chat for this to work and must have the `can_invite_users` administrator right.

		Returns True on success.
	**/
	public function approveChatJoinRequest(chatId:Any, userId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;

		return performJsonRequest("approveChatJoinRequest", data);
	}

	/**
		Use this method to decline a chat join request.

		The bot must be an administrator in the chat for this to work and must have the `can_invite_users` administrator right.

		Returns True on success.
	**/
	public function declineChatJoinRequest(chatId:Any, userId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;

		return performJsonRequest("declineChatJoinRequest", data);
	}

	/**
		Use this method to set a new profile photo for the chat. Photos can't be changed for private chats.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function setChatPhoto(chatId:Any, photo:InputFile):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["photo"] = photo;

		return performJsonRequest("setChatPhoto", data);
	}

	/**
		Use this method to delete a chat photo. Photos can't be changed for private chats.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function deleteChatPhoto(chatId:Any):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("deleteChatPhoto", data);
	}

	/**
		Use this method to change the title of a chat. Titles can't be changed for private chats.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function setChatTitle(chatId:Any, title:String):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["title"] = title;

		return performJsonRequest("setChatTitle", data);
	}

	/**
		Use this method to change the description of a group, a supergroup or a channel.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Returns True on success.
	**/
	public function setChatDescription(chatId:Any, description:String):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["description"] = description;

		return performJsonRequest("setChatDescription", data);
	}

	/**
		Use this method to add a message to the list of pinned messages in a chat.

		If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the `can_pin_messages`
		administrator right in a supergroup or `can_edit_messages` administrator right in a channel.

		Returns True on success.
	**/
	public function pinChatMessage(chatId:Any, messageId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["message_id"] = messageId;

		return performJsonRequest("pinChatMessage", data);
	}

	/**
		Use this method to remove a message from the list of pinned messages in a chat.

		If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the `can_pin_messages`
		administrator right in a supergroup or `can_edit_messages` administrator right in a channel.

		Returns True on success.
	**/
	public function unpinChatMessage(chatId:Any, messageId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["message_id"] = messageId;

		return performJsonRequest("unpinChatMessage", data);
	}

	/**
		Use this method to clear the list of pinned messages in a chat.

		If the chat is not a private chat, the bot must be an administrator in the chat for this to work and must have the `can_pin_messages`
		administrator right in a supergroup or `can_edit_messages` administrator right in a channel.

		Returns True on success.
	**/
	public function unpinAllChatMessages(chatId:Any):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("unpinAllChatMessages", data);
	}

	/**
		Use this method for your bot to leave a group, supergroup or channel.

		Returns True on success.
	**/
	public function leaveChat(chatId:Any):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("leaveChat", data);
	}

	/**
		Use this method to get up to date information about the chat
		(current name of the user for one-on-one conversations, current username of a user, group or channel, etc.).

		Returns a Chat object on success.
	**/
	public function getChat(chatId:Any):Chat {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("getChat", data);
	}

	/**
		Use this method to get a list of administrators in a chat.

		On success, returns an Array of ChatMember objects that contains information about all chat administrators except other bots.

		If the chat is a group or a supergroup and no administrators were appointed, only the creator will be returned.
	**/
	public function getChatAdministrators(chatId:Any):Array<ChatMember> {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("getChatAdministrators", data);
	}

	/**
		Use this method to get the number of members in a chat.

		Returns Int on success.
	**/
	public function getChatMemberCount(chatId:Any):Int {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("getChatMemberCount", data);
	}

	/**
		Use this method to get information about a member of a chat.

		Returns a ChatMember object on success.
	**/
	public function getChatMember(chatId:Any, userId:Int):ChatMember {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["user_id"] = userId;

		return performJsonRequest("getChatMember", data);
	}

	/**
		Use this method to set a new group sticker set for a supergroup.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method.

		Returns True on success.
	**/
	public function setChatStickerSet(chatId:Any, stickerSetName:String):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["sticker_set_name"] = stickerSetName;

		return performJsonRequest("setChatStickerSet", data);
	}

	/**
		Use this method to delete a group sticker set from a supergroup.

		The bot must be an administrator in the chat for this to work and must have the appropriate administrator rights.

		Use the field can_set_sticker_set optionally returned in getChat requests to check if the bot can use this method.

		Returns True on success.
	**/
	public function deleteChatStickerSet(chatId:Any):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;

		return performJsonRequest("deleteChatStickerSet", data);
	}

	/**
		Use this method to send answers to callback queries sent from inline keyboards.
		The answer will be displayed to the user as a notification at the top of the chat screen or as an alert.

		On success, True is returned.

		---
		Alternatively, the user can be redirected to the specified Game URL.

		For this option to work, you must first create a game for your bot via @BotFather and accept the terms.
		Otherwise, you may use links like t.me/your_bot?start=XXXX that open your bot with a parameter.
	**/
	public function answerCallbackQuery(callbackQueryId:Int, ?text:String, ?showAlert:Bool, ?url:String, ?cacheTime:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["callback_query_id"] = callbackQueryId;
		text != null ? data["text"] = text : null;
		showAlert != null ? data["show_alert"] = showAlert : null;
		url != null ? data["url"] = url : null;
		cacheTime != null ? data["cache_time"] = cacheTime : null;

		return performJsonRequest("answerCallbackQuery", data);
	}

	/**
		Use this method to change the list of the bot's commands.

		See https://core.telegram.org/bots#commands for more details about bot commands.

		Returns True on success.
	**/
	public function setMyCommands(commands:Array<BotCommand>, ?scope:BotCommandScope, ?languageCode:String):Bool {
		var data = new DynamicAccess<Any>();

		data["commands"] = commands;
		scope != null ? data["scope"] = scope : null;
		languageCode != null ? data["language_code"] = languageCode : null;

		return performJsonRequest("setMyCommands", data);
	}

	/**
		Use this method to delete the list of the bot's commands for the given scope and user language.

		After deletion, [higher level commands](https://core.telegram.org/bots/api#determining-list-of-commands) will be shown to affected users.

		Returns True on success.
	**/
	public function deleteMyCommands(?scope:BotCommandScope, ?languageCode:String):Bool {
		var data = new DynamicAccess<Any>();

		scope != null ? data["scope"] = scope : null;
		languageCode != null ? data["language_code"] = languageCode : null;

		return performJsonRequest("deleteMyCommands", data);
	}

	/**
		Use this method to get the current list of the bot's commands for the given scope and user language.

		Returns Array of BotCommand on success.

		If commands aren't set, an empty list is returned.
	**/
	public function getMyCommands(?scope:BotCommandScope, ?languageCode:String):Array<BotCommand> {
		var data = new DynamicAccess<Any>();

		scope != null ? data["scope"] = scope : null;
		languageCode != null ? data["language_code"] = languageCode : null;

		return performJsonRequest("getMyCommands", data);
	}

	/**
		Use this method to change the bot's menu button in a private chat, or the default menu button.

		Returns True on success.
	**/
	public function setChatMenuButton(?chatId:Any, ?menuButton:MenuButton):Bool {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		menuButton != null ? data["menu_button"] = menuButton : null;

		return performJsonRequest("setChatMenuButton", data);
	}

	/**
		Use this method to get the current value of the bot's menu button in a private chat, or the default menu button.

		Returns MenuButton on success.
	**/
	public function getChatMenuButton(?chatId:Any):MenuButton {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;

		return performJsonRequest("getChatMenuButton", data);
	}

	/**
		Use this method to change the default administrator rights requested by the bot when it's added as an administrator to groups or channels.
		These rights will be suggested to users, but they are are free to modify the list before adding the bot.

		Returns True on success.
	**/
	public function setMyDefaultAdministratorRights(?rights:ChatAdministratorRights, ?forChannels:Bool):Bool {
		var data = new DynamicAccess<Any>();

		rights != null ? data["rights"] = rights : null;
		forChannels != null ? data["for_channels"] = forChannels : null;

		return performJsonRequest("setMyDefaultAdministratorRights", data);
	}

	/**
		Use this method to get the current default administrator rights of the bot.

		Returns ChatAdministratorRights on success.
	**/
	public function getMyDefaultAdministratorRights(?forChannels:Bool):ChatAdministratorRights {
		var data = new DynamicAccess<Any>();

		forChannels != null ? data["for_channels"] = forChannels : null;

		return performJsonRequest("getMyDefaultAdministratorRights", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Updating messages
	////////////////////////////////////////////////////////////////////////////

	/**
		Use this method to edit text and game messages.

		On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
	**/
	public function editMessageText(text:String, ?chatId:Any, ?messageId:Int, ?inlineMessageId:String, ?parseMode:String, ?entities:Array<MessageEntity>,
			?disableWebPagePreview:Bool, ?replyMarkup:InlineKeyboardMarkup):Any {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		data["text"] = text;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		entities != null ? data["entities"] = entities : null;
		disableWebPagePreview != null ? data["disable_web_page_preview"] = disableWebPagePreview : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("editMessageText", data);
	}

	/**
		Use this method to edit captions of messages.

		On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
	**/
	public function editMessageCaption(?chatId:Any, ?messageId:Int, ?inlineMessageId:String, ?caption:String, ?parseMode:String,
			?captionEntities:Array<MessageEntity>, ?replyMarkup:InlineKeyboardMarkup):Any {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		caption != null ? data["caption"] = caption : null;
		parseMode != null ? data["parse_mode"] = parseMode : null;
		captionEntities != null ? data["caption_entities"] = captionEntities : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("editMessageCaption", data);
	}

	/**
		Use this method to edit animation, audio, document, photo, or video messages.
		If a message is part of a message album, then it can be edited only to an audio for audio albums,
		only to a document for document albums and to a photo or a video otherwise.
		When an inline message is edited, a new file can't be uploaded; use a previously uploaded file via its file_id or specify a URL.

		On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
	**/
	public function editMessageMedia(media:InputMedia, ?chatId:Any, ?messageId:Int, ?inlineMessageId:String, ?replyMarkup:InlineKeyboardMarkup):Any {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		data["media"] = media;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("editMessageMedia", data);
	}

	/**
		Use this method to edit only the reply markup of messages.

		On success, if the edited message is not an inline message, the edited Message is returned, otherwise True is returned.
	**/
	public function editMessageReplyMarkup(?chatId:Any, ?messageId:Int, ?inlineMessageId:String, ?replyMarkup:InlineKeyboardMarkup):Any {
		var data = new DynamicAccess<Any>();

		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("editMessageReplyMarkup", data);
	}

	/**
		Use this method to stop a poll which was sent by the bot.

		On success, the stopped Poll is returned.
	**/
	public function stopPoll(chatId:Any, messageId:Int, ?replyMarkup:InlineKeyboardMarkup):Poll {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["message_id"] = messageId;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("stopPoll", data);
	}

	/**
		Use this method to delete a message, including service messages, with the following limitations:

		- A message can only be deleted if it was sent less than 48 hours ago.
		- A dice message in a private chat can only be deleted if it was sent more than 24 hours ago.
		- Bots can delete outgoing messages in private chats, groups, and supergroups.
		- Bots can delete incoming messages in private chats.
		- Bots granted can_post_messages permissions can delete outgoing messages in channels.
		- If the bot is an administrator of a group, it can delete any message there.
		- If the bot has can_delete_messages permission in a supergroup or a channel, it can delete any message there.

		Returns True on success.
	**/
	public function deleteMessage(chatId:Any, messageId:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["message_id"] = messageId;

		return performJsonRequest("deleteMessage", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Stickers
	////////////////////////////////////////////////////////////////////////////

	/**
		Use this method to send static .WEBP, animated .TGS, or video .WEBM stickers.

		On success, the sent Message is returned.
	**/
	public function sendSticker(chatId:Any, sticker:Any, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendindWithoutReply:Bool, ?replyMarkup:MarkupTypes):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["sticker"] = sticker;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendindWithoutReply != null ? data["allow_sendind_without_reply"] = allowSendindWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendSticker", data);
	}

	/**
		Use this method to get a sticker set.

		On success, a StickerSet object is returned.
	**/
	public function getStickerSet(name:String):StickerSet {
		var data = new DynamicAccess<Any>();

		data["name"] = name;

		return performJsonRequest("getStickerSet", data);
	}

	/**
		Use this method to upload a .PNG file with a sticker for later use in
		`createNewStickerSet` and `addStickerToSet` methods (can be used multiple times).

		Returns the uploaded File on success.
	**/
	public function uploadStickerFile(userId:Int, pngSticker:InputFile):File {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		data["png_sticker"] = pngSticker;

		return performJsonRequest("uploadStickerFile", data);
	}

	/**
		Use this method to create a new sticker set owned by a user.
		The bot will be able to edit the sticker set thus created.

		You __must__ use exactly one of the fields `png_sticker`, `tgs_sticker`, or `webm_sticker`.

		Returns True on success.
	**/
	public function createNewStickerSet(userId:Int, name:String, title:String, emojis:String, ?pngSticker:Any, ?tgsSticker:InputFile, ?webmSticker:InputFile,
			?containsMasks:Bool, ?maskPosition:MaskPosition):Bool {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		data["name"] = name;
		data["title"] = title;
		pngSticker != null ? data["png_sticker"] = pngSticker : null;
		tgsSticker != null ? data["tgs_sticker"] = tgsSticker : null;
		webmSticker != null ? data["webm_sticker"] = webmSticker : null;
		data["emojis"] = emojis;
		containsMasks != null ? data["contains_masks"] = containsMasks : null;
		maskPosition != null ? data["mask_position"] = maskPosition : null;

		return performJsonRequest("createNewStickerSet", data);
	}

	/**
		Use this method to add a new sticker to a set created by the bot.

		You __must__ use exactly one of the fields `png_sticker`, `tgs_sticker`, or `webm_sticker`.

		Animated stickers can be added to animated sticker sets and only to them.
		Animated sticker sets can have up to 50 stickers. Static sticker sets can have up to 120 stickers.

		Returns True on success.
	**/
	public function addStickerToSet(userId:Int, name:String, emojis:String, ?pngSticker:Any, ?tgsSticker:InputFile, ?webmSticker:InputFile,
			?maskPosition:MaskPosition):Bool {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		data["name"] = name;
		pngSticker != null ? data["png_sticker"] = pngSticker : null;
		tgsSticker != null ? data["tgs_sticker"] = tgsSticker : null;
		webmSticker != null ? data["webm_sticker"] = webmSticker : null;
		data["emojis"] = emojis;
		maskPosition != null ? data["mask_position"] = maskPosition : null;

		return performJsonRequest("addStickerToSet", data);
	}

	/**
		Use this method to move a sticker in a set created by the bot to a specific position.

		Returns True on success.
	**/
	public function setStickerPositionInSet(sticker:String, position:Int):Bool {
		var data = new DynamicAccess<Any>();

		data["sticker"] = sticker;
		data["position"] = position;

		return performJsonRequest("setStickerPositionInSet", data);
	}

	/**
		Use this method to delete a sticker from a set created by the bot.

		Returns True on success.
	**/
	public function deleteStickerFromSet(sticker:String):Bool {
		var data = new DynamicAccess<Any>();

		data["sticker"] = sticker;

		return performJsonRequest("deleteStickerFromSet", data);
	}

	/**
		Use this method to set the thumbnail of a sticker set.

		Animated thumbnails can be set for animated sticker sets only.
		Video thumbnails can be set only for video sticker sets only.

		Returns True on success.
	**/
	public function setStickerSetThumb(name:String, userId:Int, ?thumb:Any):Bool {
		var data = new DynamicAccess<Any>();

		data["name"] = name;
		data["user_id"] = userId;
		thumb != null ? data["thumb"] = thumb : null;

		return performJsonRequest("setStickerSetThumb", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Inline mode
	////////////////////////////////////////////////////////////////////////////

	/**
		Use this method to send answers to an inline query.

		On success, True is returned.

		No more than __50__ results per query are allowed.
	**/
	public function answerInlineQuery(inlineQueryId:String, results:Array<InlineQueryResult>, ?cacheTime:Int, ?isPersonal:Bool, ?nextOffset:String,
			?switchPmText:String, ?switchPmParameter:String):Bool {
		var data = new DynamicAccess<Any>();

		data["inlineQueryId"] = inlineQueryId;
		data["results"] = results;
		cacheTime != null ? data["cache_time"] = cacheTime : null;
		isPersonal != null ? data["is_personal"] = isPersonal : null;
		nextOffset != null ? data["next_offset"] = nextOffset : null;
		switchPmText != null ? data["switch_pm_text"] = switchPmText : null;
		switchPmParameter != null ? data["switch_pm_parameter"] = switchPmParameter : null;

		return performJsonRequest("answerInlineQuery", data);
	}

	/**
		Use this method to set the result of an interaction with a [Web App](https://core.telegram.org/bots/webapps)
		and send a corresponding message on behalf of the user to the chat from which the query originated.

		On success, a SentWebAppMessage object is returned.
	**/
	public function answerWebAppQuery(webAppQueryId:String, result:InlineQueryResult):SentWebAppMessage {
		var data = new DynamicAccess<Any>();

		data["web_app_query_id"] = webAppQueryId;
		data["result"] = result;

		return performJsonRequest("answerWebAppQuery", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Payments
	////////////////////////////////////////////////////////////////////////////

	/**
		Use this method to send invoices.

		On success, the sent Message is returned.
	**/
	public function sendInvoice(chatId:Any, title:String, description:String, payload:String, providerToken:String, currency:String,
			prices:Array<LabeledPrice>, ?maxTipAmount:Int, ?suggestedTipAmounts:Array<Int>, ?startParameter:String, ?providerData:String, ?photoUrl:String,
			?photoSize:Int, ?photoWidth:Int, ?photoHeight:Int, ?needName:Bool, ?needPhoneNumber:Bool, ?needEmail:Bool, ?needShippingAddress:Bool,
			?sendPhoneNumberToProvider:Bool, ?sendEmailToProvider:Bool, ?isFlexible:Bool, ?disableNotification:Bool, ?protectContent:Bool,
			?replyToMessageId:Int, ?allowSendingWithoutReply:Bool, ?replyMarkup:InlineKeyboardMarkup):Message {
		var data = new DynamicAccess<Any>();

		data["chatId"] = chatId;
		data["title"] = title;
		data["description"] = description;
		data["payload"] = payload;
		data["provider_token"] = providerToken;
		data["currency"] = currency;
		data["prices"] = prices;
		maxTipAmount != null ? data["max_tip_amount"] = maxTipAmount : null;
		suggestedTipAmounts != null ? data["suggested_tip_amounts"] = suggestedTipAmounts : null;
		startParameter != null ? data["start_parameter"] = startParameter : null;
		providerData != null ? data["provider_data"] = providerData : null;
		photoUrl != null ? data["photo_url"] = photoUrl : null;
		photoSize != null ? data["photo_size"] = photoSize : null;
		photoWidth != null ? data["photo_width"] = photoWidth : null;
		photoHeight != null ? data["photo_height"] = photoHeight : null;
		needName != null ? data["need_name"] = needName : null;
		needPhoneNumber != null ? data["need_phone_number"] = needPhoneNumber : null;
		needEmail != null ? data["need_email"] = needEmail : null;
		needShippingAddress != null ? data["need_shipping_address"] = needShippingAddress : null;
		sendPhoneNumberToProvider != null ? data["send_phone_number_to_provider"] = sendPhoneNumberToProvider : null;
		sendEmailToProvider != null ? data["send_email_to_provider"] = sendEmailToProvider : null;
		isFlexible != null ? data["is_flexible"] = isFlexible : null;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendInvoice", data);
	}

	/**
		Use this method to create a link for an invoice.

		Returns the created invoice link as String on success.
	**/
	public function createInvoiceLink(title:String, description:String, payload:String, providerToken:String, currency:String, prices:Array<LabeledPrice>,
			?maxTipAmount:Int, ?suggestedTipAmounts:Array<Int>, ?providerData:String, ?photoUrl:String, ?photoSize:Int, ?photoWidth:Int, ?photoHeight:Int,
			?needName:Bool, ?needPhoneNumber:Bool, ?needEmail:Bool, ?needShippingAddress:Bool, ?sendPhoneNumberToProvider:Bool, ?sendEmailToProvider:Bool,
			?isFlexible:Bool):Message {
		var data = new DynamicAccess<Any>();

		data["title"] = title;
		data["description"] = description;
		data["payload"] = payload;
		data["provider_token"] = providerToken;
		data["currency"] = currency;
		data["prices"] = prices;
		maxTipAmount != null ? data["max_tip_amount"] = maxTipAmount : null;
		suggestedTipAmounts != null ? data["suggested_tip_amounts"] = suggestedTipAmounts : null;
		providerData != null ? data["provider_data"] = providerData : null;
		photoUrl != null ? data["photo_url"] = photoUrl : null;
		photoSize != null ? data["photo_size"] = photoSize : null;
		photoWidth != null ? data["photo_width"] = photoWidth : null;
		photoHeight != null ? data["photo_height"] = photoHeight : null;
		needName != null ? data["need_name"] = needName : null;
		needPhoneNumber != null ? data["need_phone_number"] = needPhoneNumber : null;
		needEmail != null ? data["need_email"] = needEmail : null;
		needShippingAddress != null ? data["need_shipping_address"] = needShippingAddress : null;
		sendPhoneNumberToProvider != null ? data["send_phone_number_to_provider"] = sendPhoneNumberToProvider : null;
		sendEmailToProvider != null ? data["send_email_to_provider"] = sendEmailToProvider : null;
		isFlexible != null ? data["is_flexible"] = isFlexible : null;

		return performJsonRequest("sendInvoice", data);
	}

	/**
		If you sent an invoice requesting a shipping address and the parameter `is_flexible` was specified,
		the Bot API will send an Update with a `shipping_query` field to the bot.

		Use this method to reply to shipping queries.

		On success, True is returned.
	**/
	public function answerShippingQuery(shippingQueryId:String, ok:Bool, ?shippingOptions:Array<ShippingOption>, ?errorMessage:String):Bool {
		var data = new DynamicAccess<Any>();

		data["shipping_query_id"] = shippingQueryId;
		data["ok"] = ok;
		shippingOptions != null ? data["shipping_options"] = shippingOptions : null;
		errorMessage != null ? data["error_message"] = errorMessage : null;

		return performJsonRequest("answerShippingQuery", data);
	}

	/**
		Once the user has confirmed their payment and shipping details, the Bot API sends the final confirmation in the form of an Update
		with the field `pre_checkout_query`.

		Use this method to respond to such pre-checkout queries.

		On success, True is returned.

		__Note:__ The Bot API must receive an answer within 10 seconds after the pre-checkout query was sent.
	**/
	public function answerPreCheckoutQuery(preCheckoutQueryId:String, ok:Bool, ?errorMessage:String):Bool {
		var data = new DynamicAccess<Any>();

		data["pre_checkout_query_id"] = preCheckoutQueryId;
		data["ok"] = ok;
		errorMessage != null ? data["error_message"] = errorMessage : null;

		return performJsonRequest("answerPreCheckoutQuery", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Passport
	////////////////////////////////////////////////////////////////////////////

	/**
		Informs a user that some of the Telegram Passport elements they provided contains errors.
		The user will not be able to re-submit their Passport to you until the errors are fixed
		(the contents of the field for which you returned the error must change).

		Returns True on success.

		Use this if the data submitted by the user doesn't satisfy the standards your service requires for any reason.

		For example, if a birthday date seems invalid, a submitted document is blurry, a scan shows evidence of tampering, etc.
		Supply some details in the error message to make sure the user knows how to correct the issues.
	**/
	public function setPassportDataErrors(userId:Int, errors:Array<PassportElementError>):Bool {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		data["errors"] = errors;

		return performJsonRequest("setPassportDataErrors", data);
	}

	////////////////////////////////////////////////////////////////////////////
	// Games
	////////////////////////////////////////////////////////////////////////////

	/**
		Use this method to send a game.

		On success, the sent Message is returned.
	**/
	public function sendGame(chatId:Int, gameShortName:String, ?disableNotification:Bool, ?protectContent:Bool, ?replyToMessageId:Int,
			?allowSendingWithoutReply:Bool, ?replyMarkup:InlineKeyboardMarkup):Message {
		var data = new DynamicAccess<Any>();

		data["chat_id"] = chatId;
		data["game_short_name"] = gameShortName;
		disableNotification != null ? data["disable_notification"] = disableNotification : null;
		protectContent != null ? data["protect_content"] = protectContent : null;
		replyToMessageId != null ? data["reply_to_message_id"] = replyToMessageId : null;
		allowSendingWithoutReply != null ? data["allow_sending_without_reply"] = allowSendingWithoutReply : null;
		replyMarkup != null ? data["reply_markup"] = replyMarkup : null;

		return performJsonRequest("sendGame", data);
	}

	/**
		Use this method to set the score of the specified user in a game message.

		On success, if the message is not an inline message, the Message is returned, otherwise True is returned.

		Returns an error, if the new score is not greater than the user's current score in the chat and force is False.
	**/
	public function setGameScore(userId:Int, score:Int, ?force:Bool, ?disableEditMessage:Bool, ?chatId:Int, ?messageId:Int, ?inlineMessageId:String):Any {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		data["score"] = score;
		force != null ? data["force"] = force : null;
		disableEditMessage != null ? data["disable_edit_message"] = disableEditMessage : null;
		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;

		return performJsonRequest("setGameScore", data);
	}

	/**
		Use this method to get data for high score tables.
		Will return the score of the specified user and several of their neighbors in a game.

		On success, returns an Array of GameHighScore objects.

		> This method will currently return scores for the target user, plus two of their closest neighbors on each side.
		Will also return the top three users if the user and their neighbors are not among them.

		> Please note that this behavior is subject to change.
	**/
	public function getGameHighScores(userId:Int, ?chatId:Int, ?messageId:Int, ?inlineMessageId:String):Array<GameHighScore> {
		var data = new DynamicAccess<Any>();

		data["user_id"] = userId;
		chatId != null ? data["chat_id"] = chatId : null;
		messageId != null ? data["message_id"] = messageId : null;
		inlineMessageId != null ? data["inline_message_id"] = inlineMessageId : null;

		return performJsonRequest("getGameHighScores", data);
	}
}
