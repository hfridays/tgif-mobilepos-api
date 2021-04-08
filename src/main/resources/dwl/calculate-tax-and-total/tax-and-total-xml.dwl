%dw 2.0
output application/xml skipNullOn = "everywhere"
ns ns0 http://schemas.xmlsoap.org/soap/envelope/
ns ns1 http://schemas.micros.com/RESPOS
---
{
	ns0#Envelope: {
		ns0#Body: {
			ns1#CalculateTransactionTotals: {
				ns1#ppMenuItems: {
					(payload.calculateTaxAndTotal.menuItems.resposapiMenuItem map ((resposapiMenuItem , indexOfResposapiMenuItem) -> {
						ns1#ResPosAPI_MenuItem: {
							ns1#MenuItem: {
								ns1#MiObjectNum: (resposapiMenuItem.menuItem.miObjectNum replace "a" with "") as Number,
								ns1#MiMenuLevel: resposapiMenuItem.menuItem.miMenuLevel as Number,
								(ns1#ItemDiscount: {
									ns1#DiscReference: resposapiMenuItem.menuItem.lineEntry
								}) if(resposapiMenuItem.menuItem.lineEntry != null)
							},
							(ns1#Condiments: {
								(resposapiMenuItem.condiments.resposapiCondimentMenuItem map ((resposapiCondimentMenuItem , indexOfResposapiCondimentMenuItem) -> {
									ns1#ResPosAPI_MenuItemDefinition: {
										ns1#MiObjectNum: (resposapiCondimentMenuItem.miObjectNum replace "a" with "") as Number,
										ns1#MiMenuLevel: resposapiCondimentMenuItem.miMenuLevel as Number,
										ns1#MiReference: ''
									}
								}))
							}) if(resposapiMenuItem.condiments.resposapiCondimentMenuItem != null)
						}
					}))
				},
				(ns1#pSubtotalDiscount: {
					ns1#DiscObjectNum: payload.calculateTaxAndTotal.orderDiscount.discObjectNum as Number,
					ns1#DiscAmountOrPercent: payload.calculateTaxAndTotal.orderDiscount.discAmountOrPercent as Number {
						format: "###.##"
					}
				}) if(payload.calculateTaxAndTotal.orderDiscount.discObjectNum != null),
				ns1#revenueCenter: vars.tenderId.calcTotalsRevenueCenterObjectNumber as Number,
				ns1#orderType: vars.tenderId.calcTotalsOrderTypeID as Number,
				ns1#employeeNumber: vars.tenderId.calcTotalsEmployeeObjectNum as Number
			}
		}
	}
}