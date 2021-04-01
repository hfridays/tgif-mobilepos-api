%dw 2.0
output application/json
var fullfillmentType = "Delivery"
var payInArray = ["MC", "VI", "DI", "AX", "AZ", "PayInStore"]
fun getPaymentCardType(authSystem) = if ( authSystem == "amazon_rws" ) "RWS" else authSystem
fun getEmployeeObjectNumber(cardType, fullfillmentType) = if(payInArray contains cardType) "98008"
else if (cardType == "GH" and fullfillmentType == "pickup") "96013"
else if (cardType == "GH") "96002"
else if (cardType == "GB") "96008"
else if (cardType == "RWS") "96003"
else if (cardType == "UBE" and fullfillmentType == "pickup") "96012"
else if (cardType == "UBE") "96004"
else if (cardType == "PM") "96009"
else if (cardType == "DD" and fullfillmentType == "pickup") "96011"
else if (cardType == "DD") "96005"
else "98008"
fun getTenderMediaObjectNumberforMicros(cardType)= if(payInArray contains cardType) "58"
else if (["GB", "GH","RWS","UBE","PM","DD"] contains cardType) "12"
else "58"
fun getOrderTypeIDforMicros(cardType) = if(payInArray contains cardType) "5"
else if (["GH","RWS","UBE","PM","DD"] contains cardType) "4"
else "5"
fun getRevenueCenterObjectNumforMicros(cardType) = if(payInArray contains cardType) "5"
else if (["GB", "GH","RWS","UBE","PM","DD"] contains cardType) "6"
else "5"
---
{
	calcTotalsEmployeeObjectNum: getEmployeeObjectNumber(getPaymentCardType(vars.authSystem), fullfillmentType),
	calcTotalsTenderObjectNum: getTenderMediaObjectNumberforMicros(getPaymentCardType(vars.authSystem)),
	calcTotalsOrderTypeID: getOrderTypeIDforMicros(getPaymentCardType(vars.authSystem)),
	calcTotalsRevenueCenterObjectNumber: getRevenueCenterObjectNumforMicros(getPaymentCardType(vars.authSystem)),
}