%dw 2.0
output application/json
var cardType = vars.paymentCard
var fullfillmentType = vars.createCheckVars.fullfillmentType default "Delivery"
var payInArray = ["MC", "VI", "DI", "AX", "AZ", "PayInStore"]
fun getEmployeeObjectNumber(cardType, fullfillmentType) = if ( cardType == "GH" and fullfillmentType == "pickup" ) "96013"
else if ( cardType == "GH" ) "96002"
else if ( cardType == "GB" ) "96008"
else if ( cardType == "RWS" ) "96003"
else if ( cardType == "UBE" and fullfillmentType == "pickup" ) "96012"
else if ( cardType == "UBE" ) "96004"
else if ( cardType == "PM" ) "96009"
else if ( cardType == "DD" and fullfillmentType == "pickup" ) "96011"
else if ( cardType == "DD" ) "96005"
else "98008"
fun getOrderTypeIdforMicros(cardType) = if ( ["GH","RWS","UBE","PM","DD"] contains cardType ) "4"
else "5"
fun getTenderMediaObjectNumberforMicros(cardType)= if ( ["GB", "GH","RWS","UBE","PM","DD"] contains cardType ) "12"
else "58"
fun getRevenueCenterObjectNumforMicros(cardType) = if ( ["GB", "GH","RWS","UBE","PM","DD"] contains cardType ) "6"
else "5"
fun getDeliveryMessageSubject(cardType) = if ( ["MC", "VI", "DI", "AX", "AZ"] contains cardType ) "Online Orders"
else if ( cardType == "PayInStore" ) "PayInStore"
else if ( cardType == "GH" ) "Grub Hub Delivery"
else if ( cardType == "GB" ) "Grab App"
else if ( cardType == "RWS" ) "Amazon Delivery"
else if ( cardType == "UBE" ) "Uber Eats Delivery"
else if ( cardType == "PM" ) "Postmates Delivery"
else if ( cardType == "DD" ) "Door Dash Delivery"
else "Online Orders"
---
{
	employeeObjectNum: if ( vars.brandId != "NULL" ) getEmployeeObjectNumber(cardType, fullfillmentType) else vars.employeeObjectNumber,
	orderTypeId: if ( (["UBE", "GH", "DD", "PM"] contains cardType) and !(isEmpty(vars.orderType)) ) vars.orderType else getOrderTypeIdforMicros(cardType),
	tenderObjectNum: if ( (["UBE", "GH", "DD", "PM"] contains cardType) and !(isEmpty(vars.tenderMedia)) ) vars.tenderMedia else getTenderMediaObjectNumberforMicros(cardType),
	revenueCenterObjectNumber: getRevenueCenterObjectNumforMicros(cardType),
	messageSubject: getDeliveryMessageSubject(cardType)
}