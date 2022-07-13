/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

import telegram.types.Game.CallbackGame;
import telegram.types.Passport.PassportData;
import telegram.types.Payments.Invoice;
import telegram.types.Payments.SuccesfulPayment;
import telegram.types.Stickers.Sticker;

/**
	This object represents a Telegram user or bot.
**/
typedef User = {
	id:Int,
	is_bot:Bool,
	first_name:String,
	?last_name:String,
	?username:String,
	?language_code:String,
	?can_join_groups:Bool,
	?can_read_all_group_messages:Bool,
	?supports_inline_queries:Bool
}

/**
	This object represents a chat.
**/
typedef Chat = {
	id:Int,
	type:String,
	?title:String,
	?username:String,
	?first_name:String,
	?last_name:String,
	?photo:ChatPhoto,
	?bio:String,
	?has_private_forwards:Bool,
	?description:String,
	?invite_link:String,
	?pinned_message:Message,
	?permissions:ChatPermissions,
	?slow_mode_delay:Int,
	?message_auto_delete_time:Int,
	?has_protected_content:Bool,
	?sticker_set_name:String,
	?can_set_sticker_set:Bool,
	?linked_chat_id:Int,
	?location:ChatLocation
}

/**
	This object represents a message.
**/
typedef Message = {
	message_id:Int,
	?from:User,
	?sender_chat:Chat,
	date:Int,
	chat:Chat,
	?forward_from:User,
	?forward_from_chat:Chat,
	?forward_from_message_id:Int,
	?forward_signature:String,
	?forward_sender_name:String,
	?forward_date:Int,
	?is_automatic_forward:Bool,
	?reply_to_message:Message,
	?via_bot:User,
	?edit_date:Int,
	?has_protected_content:Bool,
	?media_group_id:String,
	?author_signature:String,
	?text:String,
	?entities:Array<MessageEntity>,
	?animation:Animation,
	?audio:Audio,
	?document:Document,
	?photo:Array<PhotoSize>,
	?sticker:Sticker,
	?video:Video,
	?video_note:VideoNote,
	?voice:Voice,
	?caption:String,
	?caption_entries:Array<MessageEntity>,
	?contact:Contact,
	?dice:Dice,
	?game:Game,
	?poll:Poll,
	?venue:Venue,
	?location:Location,
	?new_chat_members:Array<User>,
	?left_chat_member:User,
	?new_chat_title:String,
	?new_chat_photo:Array<PhotoSize>,
	?delete_chat_photo:Bool,
	?group_chat_created:Bool,
	?supergroup_chat_created:Bool,
	?channel_chat_created:Bool,
	?message_auto_delete_timer_changed:MessageAutoDeleteTimerChanged,
	?migrate_to_chat_id:Int,
	?migrate_from_chat_id:Int,
	?pinned_message:Message,
	?invoice:Invoice,
	?succesful_payment:SuccesfulPayment,
	?connected_website:String,
	?passport_data:PassportData,
	?proximity_alert_triggered:ProximityAlertTriggered,
	?video_chat_scheduled:VideoChatScheduled,
	?video_chat_started:VideoChatStarted,
	?video_chat_ended:VideoChatEnded,
	?video_chat_participants_invited:VideoChatParticipantsInvited,
	?web_app_data:WebAppData,
	?reply_markup:InlineKeyboardMarkup
}

/**
	This object represents a unique message identifier.
**/
typedef MessageId = {
	message_id:Int
}

/**
	This object represents one special entity in a text message. For example, hashtags, usernames, URLs, etc.
**/
typedef MessageEntity = {
	type:String,
	offset:Int,
	length:Int,
	?url:String,
	?user:User,
	?language:String
}

/**
	This object represents one size of a photo or a file / sticker thumbnail.
**/
typedef PhotoSize = {
	file_id:String,
	file_unique_id:String,
	width:Int,
	height:Int,
	?file_size:Int
}

/**
	This object represents an animation file (GIF or H.264/MPEG-4 AVC video without sound).
**/
typedef Animation = {
	file_id:String,
	file_unique_id:String,
	width:Int,
	height:Int,
	duration:Int,
	?thumb:PhotoSize,
	?file_name:String,
	?mime_type:String,
	?file_size:Int
}

/**
	This object represents an audio file to be treated as music by the Telegram clients.
**/
typedef Audio = {
	file_id:String,
	file_unique_id:String,
	duration:Int,
	performer:String,
	title:String,
	?file_name:String,
	?mime_type:String,
	?file_size:Int,
	?thumb:PhotoSize
}

/**
	This object represents a general file (as opposed to photos, voice messages and audio files).
**/
typedef Document = {
	file_id:String,
	file_unique_id:String,
	?thumb:PhotoSize,
	?file_name:String,
	?mime_type:String,
	?file_size:Int
}

/**
	This object represents a video file.
**/
typedef Video = {
	file_id:String,
	file_unique_id:String,
	width:Int,
	height:Int,
	duration:Int,
	?thumb:PhotoSize,
	?file_name:String,
	?mime_type:String,
	?file_size:Int
}

/**
	This object represents a video message (available in Telegram apps as of v.4.0).
**/
typedef VideoNote = {
	file_id:String,
	file_unique_id:String,
	length:Int,
	duration:Int,
	?thumb:PhotoSize,
	?file_size:Int
}

/**
	This object represents a voice note.
**/
typedef Voice = {
	file_id:String,
	file_unique_id:String,
	duration:Int,
	?mime_type:String,
	?file_size:Int
}

/**
	This object represents a phone contact.
**/
typedef Contact = {
	phone_number:String,
	first_name:String,
	?last_name:String,
	?user_id:Int,
	?vcard:String
}

/**
	This object represents an animated emoji that displays a random value.
**/
typedef Dice = {
	emoji:String,
	value:Int
}

/**
	This object contains information about one answer option in a poll.
**/
typedef PollOption = {
	text:String,
	voter_count:Int
}

/**
	This object represents an answer of a user in a non-anonymous poll.
**/
typedef PollAnswer = {
	poll_id:String,
	user:User,
	option_ids:Array<Int>
}

/**
	This object contains information about a poll.
**/
typedef Poll = {
	id:String,
	question:String,
	options:Array<PollOption>,
	total_voter_count:Int,
	is_closed:Bool,
	is_anonymous:Bool,
	type:String,
	allows_multiple_answers:Bool,
	?correct_option_id:Int,
	?explanation:String,
	?explanation_entities:Array<MessageEntity>,
	?open_period:Int,
	?close_date:Int
}

/**
	This object represents a point on the map.
**/
typedef Location = {
	longitude:Float,
	latitude:Float,
	?horizontal_accuracy:Float,
	?live_period:Int,
	?heading:Int,
	?proximity_alert_radius:Int
}

/**
	This object represents a venue.
**/
typedef Venue = {
	location:Location,
	title:String,
	address:String,
	?foursquare_id:String,
	?foursquare_type:String,
	?google_place_id:String,
	?google_place_type:String
}

/**
	Contains data sent from a [Web App](https://core.telegram.org/bots/webapps) to the bot.
**/
typedef WebAppData = {
	data:String,
	button_text:String
}

/**
	This object represents the content of a service message, sent whenever a user in the chat triggers a proximity alert set by another user.
**/
typedef ProximityAlertTriggered = {
	traveler:User,
	watcher:User,
	distance:Int
}

/**
	This object represents a service message about a change in auto-delete timer settings.
**/
typedef MessageAutoDeleteTimerChanged = {
	message_auto_delete_time:Int
}

/**
	This object represents a service message about a video chat scheduled in the chat.
**/
typedef VideoChatScheduled = {
	start_date:Int
}

/**
	This object represents a service message about a video chat started in the chat. Currently holds no information.
**/
typedef VideoChatStarted = {}

/**
	This object represents a service message about a video chat ended in the chat.
**/
typedef VideoChatEnded = {
	duration:Int
}

/**
	This object represents a service message about new members invited to a video chat.
**/
typedef VideoChatParticipantsInvited = {
	users:Array<User>
}

/**
	This object represent a user's profile pictures.
**/
typedef UserProfilePhotos = {
	total_count:Int,
	photos:Array<Array<PhotoSize>>
}

/**
	This object represents a file ready to be downloaded. The file can be downloaded via the link `https://api.telegram.org/file/bot<token>/<file_path>`.
	It is guaranteed that the link will be valid for at least 1 hour. When the link expires, a new one can be requested by calling getFile.
**/
typedef File = {
	file_id:String,
	file_unique_id:String,
	?file_size:Int,
	?file_path:String
}

/**
	Contains information about a [Web App](https://core.telegram.org/bots/webapps).
**/
typedef WebAppInfo = {
	url:String
}

/**
	This object represents a custom keyboard with reply options.
**/
typedef ReplyKeyboardMarkup = {
	keyboard:Array<KeyboardButton>,
	?resize_keyboard:Bool,
	?one_time_keyboard:Bool,
	?input_field_placeolder:String,
	?selective:Bool
}

/**
	This object represents one button of the reply keyboard. For simple text buttons String can be used instead of this object to specify text of the button.
	Optional fields `web_app`, `request_contact`, `request_location`, and `request_poll` are mutually exclusive.

	__Notes__:
	- `request_contact` and `request_location` options will only work in Telegram versions released after 9 April, 2016.
	Older clients will display *unsupported message*.
	- `request_poll` option will only work in Telegram versions released after 23 January, 2020. Older clients will display _unsupported message_.
	- `web_app` option will only work in Telegram versions released after 16 April, 2022. Older clients will display _unsupported message_.
**/
typedef KeyboardButton = {
	text:String,
	?request_contact:Bool,
	?request_location:Bool,
	?request_poll:KeyboardButtonPollType,
	?web_app:WebAppInfo
}

/**
	This object represents type of a poll, which is allowed to be created and sent when the corresponding button is pressed.
**/
typedef KeyboardButtonPollType = {
	?type:String
}

/**
	Upon receiving a message with this object, Telegram clients will remove the current custom keyboard and display the default letter-keyboard.
	By default, custom keyboards are displayed until a new keyboard is sent by a bot.
	An exception is made for one-time keyboards that are hidden immediately after the user presses a button (see `ReplyKeyboardMarkup`).
**/
typedef ReplyKeyboardRemove = {
	remove_keyboard:Bool,
	?selective:Bool
}

/**
	This object represents an inline keyboard that appears right next to the message it belongs to.

	__Note__: This will only work in Telegram versions released after 9 April, 2016. Older clients will display _unsupported message_.
**/
typedef InlineKeyboardMarkup = {
	inline_keyboard:Array<Array<InlineKeyboardButton>>
}

/**
	This object represents one button of an inline keyboard. You __must__ use exactly one of the optional fields.
**/
typedef InlineKeyboardButton = {
	text:String,
	?url:String,
	?callback_data:String,
	?web_app:WebAppInfo,
	?login_url:LoginUrl,
	?switch_inline_query:String,
	?switch_inline_query_current_chat:String,
	?callback_game:CallbackGame,
	?pay:Bool
}

/**
	This object represents a parameter of the inline keyboard button used to automatically authorize a user.
	Serves as a great replacement for the Telegram Login Widget when the user is coming from Telegram.
	All the user needs to do is tap/click a button and confirm that they want to log in.

	Telegram apps support these buttons as of version 5.7.
**/
typedef LoginUrl = {
	url:String,
	?forward_text:String,
	?bot_username:String,
	?request_write_access:Bool
}

/**
	This object represents an incoming callback query from a callback button in an inline keyboard.
	If the button that originated the query was attached to a message sent by the bot, the field `message` will be present.
	If the button was attached to a message sent via the bot (in inline mode), the field `inline_message_id` will be present.
	Exactly one of the fields data or `game_short_name` will be present.
**/
typedef CallbackQuery = {
	id:String,
	from:User,
	?message:Message,
	?inline_message_id:String,
	?chat_instance:String,
	?data:String,
	?game_short_name:String
}

/**
	Upon receiving a message with this object, Telegram clients will display a reply interface to the user
	(act as if the user has selected the bot's message and tapped 'Reply').
	This can be extremely useful if you want to create user-friendly step-by-step interfaces without having to sacrifice privacy mode.
**/
typedef ForceReply = {
	force_reply:Bool,
	?input_field_placeholder:String,
	?selective:Bool
}

/**
	This object represents a chat photo.
**/
typedef ChatPhoto = {
	small_file_id:String,
	small_file_unique_id:String,
	big_file_id:String,
	big_file_unique_id:String
}

/**
	Represents an invite link for a chat.
**/
typedef ChatInviteLink = {
	invite_link:String,
	creator:User,
	creates_join_request:Bool,
	is_primary:Bool,
	is_revoked:Bool,
	?name:String,
	?expire_date:Int,
	?member_limit:Int,
	?pending_join_request_count:Int
}

/**
	Represents the rights of an administrator in a chat.
**/
typedef ChatAdministratorRights = {
	is_anonymous:Bool,
	can_manage_chat:Bool,
	can_delete_messages:Bool,
	can_manage_video_chats:Bool,
	can_restrict_members:Bool,
	can_promote_members:Bool,
	can_change_info:Bool,
	can_invite_users:Bool,
	?can_post_messages:Bool,
	?can_edit_messages:Bool,
	?can_pin_messages:Bool
}

typedef ChatMember = {
	?owner:ChatMemberOwner,
	?admin:ChatMemberAdministrator,
	?member:ChatMemberMember,
	?restricted:ChatMemberRestricted,
	?left:ChatMemberLeft,
	?banned:ChatMemberBanned
}

/**
	Represents a chat member that owns the chat and has all administrator privileges.
**/
typedef ChatMemberOwner = {
	status:String,
	user:User,
	is_anonymous:Bool,
	?custom_title:String
}

/**
	Represents a chat member that has some additional privileges.
**/
typedef ChatMemberAdministrator = {
	status:String,
	user:User,
	can_be_edited:Bool,
	is_anonymous:Bool,
	can_manage_chat:Bool,
	can_delete_messages:Bool,
	can_manage_video_chats:Bool,
	can_restrict_members:Bool,
	can_promote_members:Bool,
	can_change_info:Bool,
	can_invite_users:Bool,
	?can_post_messages:Bool,
	?can_edit_messages:Bool,
	?can_pin_messages:Bool,
	?custom_title:String
}

/**
	Represents a chat member that has no additional privileges or restrictions.
**/
typedef ChatMemberMember = {
	status:String,
	user:User
}

/**
	Represents a chat member that is under certain restrictions in the chat. Supergroups only.
**/
typedef ChatMemberRestricted = {
	status:String,
	user:User,
	is_member:Bool,
	can_change_info:Bool,
	can_invite_users:Bool,
	can_pin_messages:Bool,
	can_send_messages:Bool,
	can_send_media_messages:Bool,
	can_send_polls:Bool,
	can_add_web_page_previews:Bool,
	until_date:Int
}

/**
	Represents a chat member that isn't currently a member of the chat, but may join it themselves.
**/
typedef ChatMemberLeft = {
	status:String,
	user:User
}

/**
	Represents a chat member that was banned in the chat and can't return to the chat or view chat messages.
**/
typedef ChatMemberBanned = {
	status:String,
	user:User,
	until_date:Int
}

/**
	This object represents changes in the status of a chat member.
**/
typedef ChatMemberUpdated = {
	chat:Chat,
	from:User,
	date:Int,
	old_chat_member:ChatMember,
	new_chat_member:ChatMember,
	?invite_link:ChatInviteLink
}

/**
	Represents a join request sent to a chat.
**/
typedef ChatJoinRequest = {
	chat:Chat,
	from:User,
	date:Int,
	?bio:String,
	?invite_link:ChatInviteLink
}

/**
	Describes actions that a non-administrator user is allowed to take in a chat.
**/
typedef ChatPermissions = {
	?can_send_messages:Bool,
	?can_send_media_messages:Bool,
	?can_send_polls:Bool,
	?can_send_other_messages:Bool,
	?can_add_web_page_previews:Bool,
	?can_change_info:Bool,
	?can_invite_users:Bool,
	?can_pin_messages:Bool,
}

/**
	Represents a location to which a chat is connected.
**/
typedef ChatLocation = {
	location:Location,
	address:String,
}

/**
	This object represents a bot command.
**/
typedef BotCommand = {
	command:String,
	description:String
}

/**
	This object represents the scope to which bot commands are applied.
	Currently, the following 7 scopes are supported:

	- BotCommandScopeDefault
	- BotCommandScopeAllPrivateChats
	- BotCommandScopeAllGroupChats
	- BotCommandScopeAllChatAdministrators
	- BotCommandScopeChat
	- BotCommandScopeChatAdministrators
	- BotCommandScopeChatMember
**/
typedef BotCommandScope = {
	?scope_default:BotCommandScopeDefault,
	?all_private_chats:BotCommandScopeAllPrivateChats,
	?all_group_chats:BotCommandScopeAllGroupChats,
	?all_chat_admins:BotCommandScopeAllChatAdministrators,
	?chat:BotCommandScopeChat,
	?chat_admins:BotCommandScopeChatAdministrators,
	?chat_member:BotCommandScopeChatMember,
}

/**
	Represents the default scope of bot commands.
	Default commands are used if no commands with a narrower scope are specified for the user.
**/
typedef BotCommandScopeDefault = {type:String}

/**
	Represents the scope of bot commands, covering all private chats.
**/
typedef BotCommandScopeAllPrivateChats = {type:String}

/**
	Represents the scope of bot commands, covering all group and supergroup chats.
**/
typedef BotCommandScopeAllGroupChats = {type:String}

/**
	Represents the scope of bot commands, covering all group and supergroup chat administrators.
**/
typedef BotCommandScopeAllChatAdministrators = {type:String}

/**
	Represents the scope of bot commands, covering a specific chat.
**/
typedef BotCommandScopeChat = {type:String}

/**
	Represents the scope of bot commands, covering all administrators of a specific group or supergroup chat.
**/
typedef BotCommandScopeChatAdministrators = {type:String}

/**
	Represents the scope of bot commands, covering a specific member of a group or supergroup chat.
**/
typedef BotCommandScopeChatMember = {type:String}

/**
	This object describes the bot's menu button in a private chat. It should be one of
	- MenuButtonCommands
	- MenuButtonWebApp
	- MenuButtonDefault

	If a menu button other than MenuButtonDefault is set for a private chat, then it is applied in the chat. Otherwise the default menu button is applied. By default, the menu button opens the list of bot commands.
**/
typedef MenuButton = {
	?commands:MenuButtonCommands,
	?web_app:MenuButtonWebApp,
	?button_default:MenuButtonDefault,
}

/**
	Represents a menu button, which opens the bot's list of commands.
**/
typedef MenuButtonCommands = {
	type:String
}

/**
	Represents a menu button, which launches a Web App.
**/
typedef MenuButtonWebApp = {
	type:String,
	text:String,
	web_app:WebAppInfo
}

/**
	Describes that no specific value for the menu button was set.
**/
typedef MenuButtonDefault = {
	type:String
}

/**
	Describes why a request was unsuccessful.
**/
typedef ResponseParameters = {
	?migrate_to_chat_id:Int,
	?retry_after:Int
}

/**
	This object represents the content of a media message to be sent. It should be one of

	- InputMediaAnimation
	- InputMediaDocument
	- InputMediaAudio
	- InputMediaPhoto
	- InputMediaVideo
**/
typedef InputMedia = {
	?animation:InputMediaAnimation,
	?document:InputMediaDocument,
	?audio:InputMediaAudio,
	?photo:InputMediaPhoto,
	?video:InputMediaVideo,
}

/**
	Represents a photo to be sent.
**/
typedef InputMediaPhoto = {
	type:String,
	media:String,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>
}

/**
	Represents a video to be sent.
**/
typedef InputMediaVideo = {
	type:String,
	media:String,
	?thumb:Any,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?width:Int,
	?height:Int,
	?duration:Int,
	?supports_streaming:Bool
}

/**
	Represents an animation file (GIF or H.264/MPEG-4 AVC video without sound) to be sent.
**/
typedef InputMediaAnimation = {
	type:String,
	media:String,
	?thumb:Any,
	?caption:String,
	?parseMode:String,
	?caption_entries:Array<MessageEntity>,
	?width:Int,
	?height:Int,
	?duration:Int
}

/**
	Represents an audio file to be treated as music to be sent.
**/
typedef InputMediaAudio = {
	type:String,
	media:String,
	?thumb:Any,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?duration:Int,
	?performer:String,
	?title:String
}

/**
	Represents a general file to be sent.
**/
typedef InputMediaDocument = {
	type:String,
	media:String,
	?thumb:Any,
	?caption:String,
	?parse_mode:String,
	?caption_entries:Array<MessageEntity>,
	?disable_content_type_detection:Bool
}

/**
	This object represents the contents of a file to be uploaded.
	Must be posted using multipart/form-data in the usual way that files are uploaded via the browser.
**/
typedef InputFile = {
	fileId:Int
}
