%dw 2.0
output application/xml skipNullOn = "everywhere"
type currency = Number {
	format: "###.##"
}
ns soapenv http://schemas.xmlsoap.org/soap/envelope/
ns respos http://schemas.micros.com/RESPOS
---
{
	soapenv#Envelope: {
		soapenv#Body: {
			respos#CalculateTransactionTotals: {
				respos#ppMenuItems: {
					(payload.calculateTaxAndTotal.menuItems.resposapiMenuItem map ((resposapiMenuItem , indexOfResposapiMenuItem) -> {
						respos#ResPosAPI_MenuItem: {
							respos#MenuItem: {
								respos#MiObjectNum: (resposapiMenuItem.menuItem.miObjectNum replace "a" with "") as Number,
								respos#MiMenuLevel: resposapiMenuItem.menuItem.miMenuLevel as Number,
								(respos#ItemDiscount: {
									respos#DiscReference: resposapiMenuItem.menuItem.lineEntry
								}) if(resposapiMenuItem.menuItem.lineEntry != null)
							},
							(respos#Condiments: {
								(resposapiMenuItem.condiments.resposapiCondimentMenuItem map ((resposapiCondimentMenuItem , indexOfResposapiCondimentMenuItem) -> {
									respos#ResPosAPI_MenuItemDefinition: {
										respos#MiObjectNum: (resposapiCondimentMenuItem.miObjectNum replace "a" with "") as Number,
										respos#MiMenuLevel: resposapiCondimentMenuItem.miMenuLevel as Number,
										respos#MiReference: ''
									}
								}))
							}) if(resposapiMenuItem.condiments.resposapiCondimentMenuItem != null)
						}
					}))
				},
				(respos#pSubtotalDiscount: {
					respos#DiscObjectNum: payload.calculateTaxAndTotal.orderDiscount.discObjectNum as Number,
					respos#DiscAmountOrPercent: payload.calculateTaxAndTotal.orderDiscount.discAmountOrPercent as Currency
				}) if(payload.calculateTaxAndTotal.orderDiscount.discObjectNum != null),
				respos#revenueCenter: vars.tenderId.calcTotalsRevenueCenterObjectNumber as Number,
				respos#orderType: vars.tenderId.calcTotalsOrderTypeID as Number,
				respos#employeeNumber: vars.tenderId.calcTotalsEmployeeObjectNum as Number
			}
		}
	}
}