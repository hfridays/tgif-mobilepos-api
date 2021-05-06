%dw 2.0
output application/json
var cardType = vars.paymentCardType
var payInArray = ["MC", "VI", "DI", "AX", "AZ"]
fun getOrderTypeIdforMicros(cardType) = if ( ["GH","RWS","UBE","PM","DD"] contains cardType ) "4"
else "5"
fun getTenderMediaObjectNumberforMicros(cardType)= if ( ["GB", "GH","RWS","UBE","PM","DD"] contains cardType ) "12"
else "58"
fun getDeliveryMessageSubject(cardType) = if ( cardType == "PayInStore" ) "PayInStore"
else if ( cardType == "GH" ) "Grub Hub Delivery"
else if ( cardType == "GB" ) "Grab App"
else if ( cardType == "RWS" ) "Amazon Delivery"
else if ( cardType == "UBE" ) "Uber Eats Delivery"
else if ( cardType == "PM" ) "Postmates Delivery"
else if ( cardType == "DD" ) "Door Dash Delivery"
else "Online Orders"
---
{
	employeeObjectNum: if ( vars.brandId == "NULL" ) vars.tenderDetails.resultSet1[0].employee_number else vars.employeeObjectNumber,
	orderTypeId: if ( (["UBE", "GH", "DD", "PM"] contains cardType) and !(isEmpty(vars.orderType)) ) vars.orderType else getOrderTypeIdforMicros(cardType),
	tenderObjectNum: if ( (["UBE", "GH", "DD", "PM"] contains cardType) and !(isEmpty(vars.tenderMedia)) ) vars.tenderMedia else  getTenderMediaObjectNumberforMicros(cardType),
	revenueCenterObjectNumber: if(vars.tenderDetails.resultSet1[0].revenue_center_id != null) vars.tenderDetails.resultSet1[0].revenue_center_id else "5",
	messageSubject: getDeliveryMessageSubject(cardType)
}