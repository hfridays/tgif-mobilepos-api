%dw 2.0
output application/json
---
{
	createcheck: {
		result: {
			status: "Success",
			message: "Success"
		},
		check: {
			checkSeq: payload.pGuestCheck.CheckSeq,
			checkId: payload.pGuestCheck.CheckNum as String,
			tableNumber: payload.pGuestCheck.CheckTableObjectNum,
			employeeNumber: payload.pGuestCheck.CheckEmployeeObjectNum,
			(menuItems: payload.ppMenuItems.ResPosAPI_MenuItem map ((value , index) -> {
				miObjectNum: value.MenuItem.MiObjectNum as String,
				miAltItemId: value.MenuItem.MiObjectNum as String,
				menuQty: 1,
				menuAmount: value.MenuItem.MiOverridePrice as String,
				lineEntry: value.MenuItem.ItemDiscount.DiscReference as String,
				(condiments: value.Condiments.ResPosAPI_MenuItemDefinition map ((value , index) -> {
					miObjectNum: value.MiObjectNum as String,
					menuQty: 1,
					menuAmount: value.MiOverridePrice as String
				})) if (value.Condiments != null and value.Condiments != "" and ((sizeOf(value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel)) > 1)),
				(condiments: value.Condiments.*ResPosAPI_MenuItemDefinition default [] map {
					miObjectNum: $.MiObjectNum as String,
					menuQty: 1,
					menuAmount: $.MiOverridePrice as String
				}) if (value.Condiments != null and value.Condiments != "" and (sizeOf(value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel) == 1))
			})) if ((sizeOf(payload.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) > 1),
			(menuItems: (payload.ppMenuItems.*ResPosAPI_MenuItem default []) map  {
				miObjectNum: $.MenuItem.MiObjectNum as String,
				menuQty: 1,
				menuAmount: $.MenuItem.MiOverridePrice as String,
				lineEntry: $.MenuItem.ItemDiscount.DiscReference as String,
				(condiments: $.Condiments.ResPosAPI_MenuItemDefinition map ((value , index) -> {
					miObjectNum: value.MiObjectNum as String,
					menuQty: 1,
					menuAmount: value.MiOverridePrice as String
				})) if ($.Condiments != null and $.Condiments != "" and ((sizeOf($.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel)) > 1)),
				(condiments: $.Condiments.*ResPosAPI_MenuItemDefinition default [] map {
					miObjectNum: $.MiObjectNum as String,
					menuQty: 1,
					menuAmount: $.MiOverridePrice as String
				}) if ($.Condiments != null and $.Condiments != "" and ((sizeOf($.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel)) == 1))
			}) if ((sizeOf(payload.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) == 1),
			(orderDiscount: {
				discObjectNum: payload.pSubTotalDiscount.DiscObjectNum as String,
				discAmountOrPercent: payload.pSubTotalDiscount.DiscAmountOrPercent
			}) if (payload.pSubTotalDiscount.DiscObjectNum != 0),
			payments: {
				paymentReference: payload.pTmedDetail.TmedReference,
				paymentAmount: payload.pTmedDetail.TmedPartialPayment
			},
			totals: {
				subTotal: payload.pTotalsResponse.TotalsSubTotal,
				taxTotal: payload.pTotalsResponse.TotalsTaxTotals as String,
				tipTotal: payload.pTotalsResponse.TotalsOtherTotals,
				amtPaid: payload.pTmedDetail.TmedPartialPayment,
				totalDue: payload.pTotalsResponse.TotalsTotalDue
			},
			checkPrintLines: {
				printLines: payload.ppCheckPrintLines.string
			},
			dayOfBusiness: vars.dayOfBusiness,
			stripesCode: vars.stripesCode
		}
	}
}