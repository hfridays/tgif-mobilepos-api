%dw 2.0
output application/json
var fullfillmentType = "Delivery"
fun getPaymentCardType(authSystem) = authSystem
fun getOrderTypeIDforMicros(cardType) =  if ( ["GH","RWS","UBE","PM","DD"] contains cardType ) "4"
else "5"
fun getTenderMediaObjectNumberforMicros(cardType)= if ( ["GB", "GH","RWS","UBE","PM","DD"] contains cardType ) "12"
else "58"
---
{
	calcTotalsEmployeeObjectNum: if(vars.tenderDetails.resultSet1[0].employee_number != null) vars.tenderDetails.resultSet1[0].employee_number else "98008",
	calcTotalsTenderObjectNum:  getTenderMediaObjectNumberforMicros(getPaymentCardType(vars.authSystem)),
	calcTotalsOrderTypeID: getOrderTypeIDforMicros(getPaymentCardType(vars.authSystem)),
	calcTotalsRevenueCenterObjectNumber: if(vars.tenderDetails.resultSet1[0].revenue_center_id != null) vars.tenderDetails.resultSet1[0].revenue_center_id else "5"
}