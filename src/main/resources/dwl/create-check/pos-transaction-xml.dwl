%dw 2.0
output application/xml
ns soapenv http://www.w3.org/2003/05/soap-envelope
ns respos http://schemas.micros.com/RESPOS
---
{
	soapenv#Envelope: {
		soapenv#Body: {
			respos#PostTransactionEx: {
				respos#pGuestCheck: {
					respos#CheckRevenueCenterObjectNum: (vars.tenderId.revenueCenterObjectNumber),
					respos#CheckOrderType: (vars.tenderId.orderTypeId),
					respos#CheckEmployeeObjectNum: (vars.tenderId.employeeObjectNum),
					respos#CheckID: if (sizeOf(payload.createcheck.customerInfo.customerFirstName) > 8) payload.createcheck.customerInfo.customerFirstName[0 to 7] ++ "_" ++ payload.createcheck.payment.referenceNumber[-3 to -1]  
						else if (payload.createcheck.deliveryPartner.name != null) (payload.createcheck.customerInfo.customerFirstName ++ "_" ++ payload.createcheck.payment.referenceNumber[-3 to -1])  
						else payload.createcheck.customerInfo.customerFirstName ++ "_" ++ payload.createcheck.cartId
					 as String default "",
					respos#pCheckInfoLines : {
						respos#string: if(payload.createcheck.deliveryPartner.name== null) "******* GRAB ORDER *******" else "******* DELIVERY ORDER  *******",
						respos#string: if(payload.createcheck.pickupTime== null) "" else "*** PICKUP *** " ++ ((payload.createcheck.pickupTime as DateTime) as Time as String {format: "hh:mm a"}) default "",
						respos#string: "Name: " ++ (payload.createcheck.customerInfo.customerFirstName ++ " " ++ payload.createcheck.customerInfo.customerLastName ) as String default "",
						respos#string: "",
						respos#string: if(payload.createcheck.deliveryPartner.name== null) "Grab Order" else (payload.createcheck.deliveryPartner.name ++ " Order " ++ payload.createcheck.payment.referenceNumber ) as String default "",
						respos#string: if(payload.createcheck.deliveryPartner == null) "-" else ("Support Phone " ++ (payload.createcheck.deliveryPartner.supportPhone )) as String default "",
						respos#string: if(payload.createcheck.deliveryPartner.name == "Door Dash " or payload.createcheck.deliveryPartner == null) "-" else ("Email " ++ (payload.createcheck.deliveryPartner.supportEmail) as String ) default ""
					}
				},
				respos#ppMenuItems: {
					(payload.createcheck.menuItems.resposapiMenuItem map ((value , index) -> {
						respos#ResPosAPI_MenuItem: {
							respos#MenuItem: {
								respos#MiObjectNum: value.menuItem.miObjectNum,
								respos#MiMenuLevel: value.menuItem.miMenuLevel,
								respos#MiReference: value.menuItem.miReference,
								(respos#ItemDiscount: {
									respos#DiscReference: value.menuItem.lineEntry
								}) if(value.menuItem.lineEntry != null)
							},
							(respos#Condiments: {
								(value.condiments.resposapiCondimentMenuItem map ((value , index) -> {
									respos#ResPosAPI_MenuItemDefinition: {
										respos#MiObjectNum: value.miObjectNum,
										respos#MiMenuLevel: value.miMenuLevel,
										respos#MiReference: "",
										(respos#ItemDiscount: {
											respos#DiscObjectNum: value.miDiscount.discObjectNum,
											respos#DiscAmountOrPercent: value.miDiscount.discAmountOrPercent
										}) if(value.miDiscount.discObjectNum != null)
									}
								}))
							}) if (value.condiments.resposapiCondimentMenuItem != null)
						}
					}))
				},
				respos#pServiceChg: {
					respos#SvcChgObjectNum: "1",
					respos#SvcChgAmountOrPercent: if(payload.createcheck.payment.tipAmount == "") "0.00"  else payload.createcheck.payment.tipAmount
				},
				(respos#pSubTotalDiscount: {
					respos#DiscObjectNum: payload.createcheck.orderDiscount.discObjectNum,
					respos#DiscAmountOrPercent: payload.createcheck.orderDiscount.discAmountOrPercent
				}) if (payload.createcheck.orderDiscount.discObjectNum != null),
//				(respos#pSubTotalDiscount: {
//					respos#DiscObjectNum: "vars.varCouponDiscObjectNum",
//					respos#DiscAmountOrPercent: "vars.varCouponDiscAmount"
//				}) if (payload.createcheck.orderDiscount.discObjectNum == null and payload.createcheck.serializedCoupon.couponCode != null),
				respos#pTmedDetail: {
					respos#TmedObjectNum: (vars.tenderId.tenderObjectNum),
					respos#TmedPartialPayment: payload.createcheck.payment.tenderAmount,
					respos#TmedReference: payload.createcheck.payment.referenceNumber,
					respos#TmedEPayment: {
					}
				},
				respos#ppCheckPrintLines: {
				},
				respos#ppVoucherOutput: {
				}
			}
		}
	}
}