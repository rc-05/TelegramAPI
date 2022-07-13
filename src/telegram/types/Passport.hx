/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

/**
	Describes Telegram Passport data shared with the bot by the user.
**/
typedef PassportData = {
	data:Array<EncryptedPassportElement>,
	credentials:EncryptedCredentials
}

/**
	This object represents a file uploaded to Telegram Passport.
	Currently all Telegram Passport files are in JPEG format when decrypted and don't exceed 10MB.
**/
typedef PassportFile = {
	fileId:String,
	fileUniqueId:String,
	fileSize:Int,
	fileDate:Int
}

/**
	Describes documents or other Telegram Passport elements shared with the bot by the user.
**/
typedef EncryptedPassportElement = {
	type:String,
	?data:String,
	?phoneNumber:String,
	?email:String,
	?files:Array<PassportFile>,
	?frontSide:PassportFile,
	?reverseSide:PassportFile,
	?selfie:PassportFile,
	?translation:Array<PassportFile>,
	hash:String
}

/**
	Describes data required for decrypting and authenticating EncryptedPassportElement.
	See the Telegram Passport Documentation for a complete description of the data decryption and authentication processes.
**/
typedef EncryptedCredentials = {
	data:String,
	hash:String,
	secret:String
}

/**
	This object represents an error in the Telegram Passport element which was submitted that should be resolved by the user. It should be one of:

	- PassportElementErrorDataField
	- PassportElementErrorFrontSide
	- PassportElementErrorReverseSide
	- PassportElementErrorSelfie
	- PassportElementErrorFile
	- PassportElementErrorFiles
	- PassportElementErrorTranslationFile
	- PassportElementErrorTranslationFiles
	- PassportElementErrorUnspecified
**/
typedef PassportElementError = {
	?data_field:PassportElementErrorDataField,
	?front_side:PassportElementErrorFrontSide,
	?reverse_side:PassportElementErrorReverseSide,
	?selfie:PassportElementErrorSelfie,
	?file:PassportElementErrorFile,
	?files:PassportElementErrorFiles,
	?translation_file:PassportElementErrorTranslationFile,
	?translation_files:PassportElementErrorTranslationFiles,
	?unspecified:PassportElementErrorUnspecified
}

/**
	Represents an issue in one of the data fields that was provided by the user.

	The error is considered resolved when the field's value changes.
**/
typedef PassportElementErrorDataField = {
	source:String,
	type:String,
	field_name:String,
	data_hash:String,
	message:String
}

/**
	Represents an issue with the front side of a document.

	The error is considered resolved when the file with the front side of the document changes.
**/
typedef PassportElementErrorFrontSide = {
	source:String,
	type:String,
	file_hash:String,
	message:String
}

/**
	Represents an issue with the reverse side of a document.

	The error is considered resolved when the file with reverse side of the document changes.
**/
typedef PassportElementErrorReverseSide = {
	source:String,
	type:String,
	file_hash:String,
	message:String
}

/**
	Represents an issue with the selfie with a document.

	The error is considered resolved when the file with the selfie changes.
**/
typedef PassportElementErrorSelfie = {
	source:String,
	type:String,
	file_hash:String,
	message:String
}

/**
	Represents an issue with a document scan.

	The error is considered resolved when the file with the document scan changes.
**/
typedef PassportElementErrorFile = {
	source:String,
	type:String,
	file_hash:String,
	message:String
}

/**
	Represents an issue with a list of scans.

	The error is considered resolved when the list of files containing the scans changes.
**/
typedef PassportElementErrorFiles = {
	source:String,
	type:String,
	file_hashes:String,
	message:String
}

/**
	Represents an issue with one of the files that constitute the translation of a document.

	The error is considered resolved when the file changes.
**/
typedef PassportElementErrorTranslationFile = {
	source:String,
	type:String,
	file_hash:String,
	message:String
}

/**
	Represents an issue with the translated version of a document.

	The error is considered resolved when a file with the document translation change.
**/
typedef PassportElementErrorTranslationFiles = {
	source:String,
	type:String,
	file_hashes:String,
	message:String
}

/**
	Represents an issue in an unspecified place.

	The error is considered resolved when new data is added.
**/
typedef PassportElementErrorUnspecified = {
	source:String,
	type:String,
	element_hash:String,
	message:String
}
