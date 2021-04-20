%dw 2.0
output application/xml
ns ns0 http://www.w3.org/2003/05/soap-envelope
ns ns1 http://schemas.micros.com/RESPOS
---
{
	ns0#Envelope: {
		ns0#Body: {
			ns1#PostTransactionEx: {
				ns1#pGuestCheck: {
					ns1#CheckRevenueCenterObjectNum: (vars.tenderId.revenueCenterObjectNumber),
					ns1#CheckOrderType: (vars.tenderId.orderTypeId),
					ns1#CheckEmployeeObjectNum: (vars.tenderId.employeeObjectNum),
					ns1#CheckID: if (sizeOf(payload.createcheck.customerInfo.customerFirstName) > 8) payload.createcheck.customerInfo.customerFirstName[0 to 7] ++ "_" ++ payload.createcheck.payment.referenceNumber[-3 to -1]  
						else if (payload.createcheck.deliveryPartner.name != null) (payload.createcheck.customerInfo.customerFirstName ++ "_" ++ payload.createcheck.payment.referenceNumber[-3 to -1])  
						else payload.createcheck.customerInfo.customerFirstName ++ "_" ++ payload.createcheck.cartId
					 as String default "",
					ns1#pCheckInfoLines : {
					    ns1#string: if(payload.createcheck.deliveryPartner.name== null) "******* GRAB ORDER *******"  else "******* " ++ upper(payload.createcheck.fulfillmentType) ++ " ORDER  *******" default "******* DELIVERY ORDER  *******", 
						ns1#string: if(payload.createcheck.pickupTime== null) "" else "*** PICKUP *** " ++ ((payload.createcheck.pickupTime as DateTime) as Time as String {format: "hh:mm a"}) default "",
						ns1#string: "Name: " ++ (payload.createcheck.customerInfo.customerFirstName ++ " " ++ payload.createcheck.customerInfo.customerLastName ) as String default "",
						ns1#string: "",
						ns1#string: if(payload.createcheck.deliveryPartner.name== null) "Grab Order" else (payload.createcheck.deliveryPartner.name ++ " Order " ++ payload.createcheck.payment.referenceNumber ) as String default "",
						ns1#string: if(payload.createcheck.deliveryPartner == null) "-" else ("Support Phone " ++ (payload.createcheck.deliveryPartner.supportPhone )) as String default "",
						ns1#string: if(payload.createcheck.deliveryPartner.name == "Door Dash " or payload.createcheck.deliveryPartner == null) "-" else ("Email " ++ (payload.createcheck.deliveryPartner.supportEmail) as String ) default ""
					}
				},
				ns1#ppMenuItems: {
					(payload.createcheck.menuItems.resposapiMenuItem map ((value , index) -> {
						ns1#ResPosAPI_MenuItem: {
							ns1#MenuItem: {
								ns1#MiObjectNum: value.menuItem.miObjectNum,
								ns1#MiMenuLevel: value.menuItem.miMenuLevel,
								ns1#MiReference: value.menuItem.miReference,
								(ns1#ItemDiscount: {
									ns1#DiscReference: value.menuItem.lineEntry
								}) if(value.menuItem.lineEntry != null)
							},
							(ns1#Condiments: {
								(value.condiments.resposapiCondimentMenuItem map ((value , index) -> {
									ns1#ResPosAPI_MenuItemDefinition: {
										ns1#MiObjectNum: value.miObjectNum,
										ns1#MiMenuLevel: value.miMenuLevel,
										ns1#MiReference: "",
										(ns1#ItemDiscount: {
											ns1#DiscObjectNum: value.miDiscount.discObjectNum,
											ns1#DiscAmountOrPercent: value.miDiscount.discAmountOrPercent
										}) if(value.miDiscount.discObjectNum != null)
									}
								}))
							}) if (value.condiments.resposapiCondimentMenuItem != null)
						}
					}))
				},
				ns1#pServiceChg: {
					ns1#SvcChgObjectNum: "1",
					ns1#SvcChgAmountOrPercent: if(payload.createcheck.payment.tipAmount == "") "0.00"  else payload.createcheck.payment.tipAmount
				},
				(ns1#pSubTotalDiscount: {
					ns1#DiscObjectNum: payload.createcheck.orderDiscount.discObjectNum,
					ns1#DiscAmountOrPercent: payload.createcheck.orderDiscount.discAmountOrPercent
				}) if (payload.createcheck.orderDiscount.discObjectNum != null),
//				(ns1#pSubTotalDiscount: {
//					ns1#DiscObjectNum: "vars.varCouponDiscObjectNum",
//					ns1#DiscAmountOrPercent: "vars.varCouponDiscAmount"
//				}) if (payload.createcheck.orderDiscount.discObjectNum == null and payload.createcheck.serializedCoupon.couponCode != null),
				ns1#pTmedDetail: {
					ns1#TmedObjectNum: (vars.tenderId.tenderObjectNum),
					ns1#TmedPartialPayment: payload.createcheck.payment.tenderAmount,
					ns1#TmedReference: payload.createcheck.payment.referenceNumber,
					ns1#TmedEPayment: {
					}
				},
				ns1#ppCheckPrintLines: {
				},
				ns1#ppVoucherOutput: {
				}
			}
		}
	}
}