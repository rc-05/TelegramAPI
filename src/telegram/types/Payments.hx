/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package telegram.types;

import telegram.types.Core.User;

/**
	This object represents a portion of the price for goods or services.
**/
typedef LabeledPrice = {
	label:String,
	amount:Int
}

/**
	This object contains basic information about an invoice.
**/
typedef Invoice = {
	title:String,
	description:String,
	startParameter:String,
	currency:String,
	totalAmount:Int
}

/**
	This object represents a shipping address.
**/
typedef ShippingAddress = {
	countryCode:String,
	state:String,
	city:String,
	streetLine1:String,
	streetLine2:String,
	postCode:String
}

/**
	This object represents information about an order.
**/
typedef OrderInfo = {
	name:String,
	phoneNumber:String,
	email:String,
	shippingAddress:ShippingAddress
}

/**
	This object represents one shipping option.
**/
typedef ShippingOption = {
	id:String,
	title:String,
	prices:Array<LabeledPrice>
}

/**
	This object contains basic information about a successful payment.
**/
typedef SuccesfulPayment = {
	currency:String,
	totalAmount:Int,
	invoicePayload:String,
	shippingOptionId:String,
	orderInfo:OrderInfo,
	telegramPaymentChargeId:String,
	providerPaymentChargeId:String
}

/**
	This object contains information about an incoming shipping query.
**/
typedef ShippingQuery = {
	id:String,
	from:User,
	invoicePayload:String,
	shippingAddress:ShippingAddress
}

/**
	This object contains information about an incoming pre-checkout query.
**/
typedef PreCheckoutQuery = {
	id:String,
	from:User,
	currency:String,
	totalAmount:Int,
	invoicePayload:String,
	?shippingOrderId:String,
	?orderInfo:OrderInfo
}
