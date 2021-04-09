%dw 2.0
output application/json
---
{
	calculateTaxAndTotal: {
		result: {
			status: "Success",
			message: "Success"
		},
		totals: {
			subTotal: vars.calculateTotalServiceResponse.response.pTotalsResponse.TotalsSubTotal as String,
			taxTotal: vars.calculateTotalServiceResponse.response.pTotalsResponse.TotalsTaxTotals as String,
			totalDue: vars.calculateTotalServiceResponse.response.pTotalsResponse.TotalsTotalDue as String
		},
		(orderDiscount: {
			discObjectNum: vars.calculateTotalServiceResponse.response.pSubtotalDiscount.DiscObjectNum as String,
			discAmountOrPercent: vars.calculateTotalServiceResponse.response.pSubtotalDiscount.DiscAmountOrPercent as String
		}) if(vars.calculateTotalServiceResponse.response.pSubtotalDiscount.DiscAmountOrPercent != null),
		(menuItems: vars.calculateTotalServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem map ((value , index) -> {
			miObjectNum: value.MenuItem.MiObjectNum as String,
			menuQty: 1,
			menuAmount: value.MenuItem.MiOverridePrice as String,
			lineEntry: value.MenuItem.ItemDiscount.DiscReference as String,
			// condimentcount: (sizeOf value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel),
			(condiments: value.Condiments.ResPosAPI_MenuItemDefinition map ((value , index) -> {
				miObjectNum: value.MiObjectNum as String,
				menuQty: 1,
				menuAmount: value.MiOverridePrice as String
			})) if (value.Condiments != null and value.Condiments != "" and ((sizeOf(value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel)) > 1)),
			(condiments: value.Condiments.*ResPosAPI_MenuItemDefinition default [] map {
				miObjectNum: $.MiObjectNum as String,
				menuQty: 1,
				menuAmount: $.MiOverridePrice as String
			}) if (value.Condiments != null and value.Condiments != "" and ((sizeOf(value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel)) == 1))
		})) if ((sizeOf(vars.calculateTotalServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) > 1),
		(menuItems: (vars.calculateTotalServiceResponse.response.ppMenuItems.*ResPosAPI_MenuItem default []) map  {
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
		}) if ((sizeOf(vars.calculateTotalServiceResponse.response.ppMenuItems.ResPosAPI_MenuItem.*MenuItem)) == 1)
	}
}