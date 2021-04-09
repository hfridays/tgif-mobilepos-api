%dw 2.0
output application/json
---
{
	calculatetotals: {
		result: {
			status: "Success",
			message: "Success"
		},
		totals: {
			subTotal: payload.pTotalsResponse.TotalsSubTotal as String,
			taxTotal: payload.pTotalsResponse.TotalsTaxTotals as String,
			totalDue: payload.pTotalsResponse.TotalsTotalDue as String
		},
		(orderDiscount: {
			discObjectNum: payload.pSubtotalDiscount.DiscObjectNum as String,
			discAmountOrPercent: payload.pSubtotalDiscount.DiscAmountOrPercent as String
		}) if (payload.pSubtotalDiscount.DiscAmountOrPercent != null) ,
		(menuItems: payload.ppMenuItems.ResPosAPI_MenuItem  map ((value , index) -> {
			miObjectNum: value.MenuItem.MiObjectNum as String,
			miAltItemId: value.MenuItem.MiObjectNum as String,
			menuQty: 1,
			menuAmount: value.MenuItem.MiOverridePrice as String,
			lineEntry : value.MenuItem.ItemDiscount.DiscReference as String,
			//condimentcount: (sizeOf value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel),
			(condiments: value.Condiments.ResPosAPI_MenuItemDefinition  map ((value , index) -> {
				miObjectNum: value.MiObjectNum as String,
				menuQty: 1,
				menuAmount: value.MiOverridePrice as String
			})) if ( value.Condiments != null and value.Condiments != "" and ((sizeOf (value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel) > 1))),
			(condiments: value.Condiments.*ResPosAPI_MenuItemDefinition default [] map {
				miObjectNum: $.MiObjectNum as String,
				menuQty: 1,
				menuAmount: $.MiOverridePrice as String
			}) if ( value.Condiments != null and value.Condiments != "" and ((sizeOf(value.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel) == 1)))
		})) if (sizeOf (payload.ppMenuItems.ResPosAPI_MenuItem.*MenuItem) > 1) ,
		(menuItems: (payload.ppMenuItems.*ResPosAPI_MenuItem default []) map  {
				miObjectNum: $.MenuItem.MiObjectNum as String,
				miAltItemId: $.MenuItem.MiObjectNum as String,
				menuQty: 1,
				menuAmount: $.MenuItem.MiOverridePrice as String,
				lineEntry : $.MenuItem.ItemDiscount.DiscReference as String,
				(condiments: $.Condiments.ResPosAPI_MenuItemDefinition  map ((value , index) -> {
				miObjectNum: value.MiObjectNum as String,
				menuQty: 1,
				menuAmount: value.MiOverridePrice as String
				})) if ( $.Condiments != null and $.Condiments != "" and ((sizeOf ($.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel) > 1))),
				(condiments: $.Condiments.*ResPosAPI_MenuItemDefinition default [] map {
					miObjectNum: $.MiObjectNum as String,
					menuQty: 1,
					menuAmount: $.MiOverridePrice as String
				}) if( $.Condiments != null and $.Condiments != "" and ((sizeOf ($.Condiments.ResPosAPI_MenuItemDefinition.*MiMenuLevel) == 1)))
		}) if((sizeOf (payload.ppMenuItems.ResPosAPI_MenuItem.*MenuItem) == 1))
	}
}