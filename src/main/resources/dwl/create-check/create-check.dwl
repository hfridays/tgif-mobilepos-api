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
			checkSeq: vars.createCheckServiceResponse.response.pGuestCheck.CheckSeq as Number,
			checkId: vars.createCheckServiceResponse.response.pGuestCheck.CheckNum as String,
			tableNumber: vars.createCheckServiceResponse.response.pGuestCheck.CheckTableObjectNum as Number,
			employeeNumber: vars.createCheckServiceResponse.response.pGuestCheck.CheckEmployeeObjectNum as Number,
			(menuItems: vars.createCheckServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem map ((value , index) -> {
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
			})) if ((sizeOf(vars.createCheckServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) > 1),
			(menuItems: (vars.createCheckServiceResponse.response.ppMenuItems.*ResPosAPI_MenuItem default []) map  {
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
			}) if ((sizeOf(vars.createCheckServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) == 1),
			(orderDiscount: {
				discObjectNum: vars.createCheckServiceResponse.response.pSubTotalDiscount.DiscObjectNum as String,
				discAmountOrPercent: vars.createCheckServiceResponse.response.pSubTotalDiscount.DiscAmountOrPercent
			}) if (vars.createCheckServiceResponse.response.pSubTotalDiscount.DiscObjectNum != 0),
			payments: {
				paymentReference: vars.createCheckServiceResponse.response.pTmedDetail.TmedReference,
				paymentAmount: vars.createCheckServiceResponse.response.pTmedDetail.TmedPartialPayment as Number
			},
			totals: {
				subTotal: vars.createCheckServiceResponse.response.pTotalsResponse.TotalsSubTotal as Number,
				taxTotal: vars.createCheckServiceResponse.response.pTotalsResponse.TotalsTaxTotals as String,
				tipTotal: vars.createCheckServiceResponse.response.pTotalsResponse.TotalsOtherTotals,
				amtPaid: vars.createCheckServiceResponse.response.pTmedDetail.TmedPartialPayment as Number,
				totalDue: vars.createCheckServiceResponse.response.pTotalsResponse.TotalsTotalDue
			},
			checkPrintLines: {
				printLines: vars.createCheckServiceResponse.response.ppCheckPrintLines.*string map if ( $ == null ) "" else trim($)
			}
		},
		dayOfBusiness: vars.dayOfBusiness as Date,
		stripesCode: vars.stripesCode
	}
}