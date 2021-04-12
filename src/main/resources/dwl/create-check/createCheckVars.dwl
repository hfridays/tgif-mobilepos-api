%dw 2.0
output application/json
---
{
	customerPhone: payload.createcheck.customerInfo.customerPhone,
	customerName: (payload.createcheck.customerInfo.customerFirstName) ++ ' ' ++ (payload.createcheck.customerInfo.customerLastName),
	orderDiscountNum: payload.createcheck.orderDiscount.discObjectNum,
	serializedCouponCode: payload.createcheck.serializedCoupon.couponCode,
	paymentCardType: payload.createcheck.payment.paymentCardType,
	paymentCardNum: payload.createcheck.payment.paymentCardNum,
	authCode: payload.createcheck.payment.authorizationCode,
	orderId: payload.createcheck.payment.referenceNumber,
	cartId: payload.createcheck.payment.referenceNumber,
	fullfillmentType: payload.createcheck.fulfillmentType,
	posFlag: "Micros"
}