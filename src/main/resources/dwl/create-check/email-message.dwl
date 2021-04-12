%dw 2.0
output text/plain
var cardType = vars.paymentCardType
var cardNumber = vars.createCheckVars.paymentCardNum
var orderId = vars.createCheckVars.orderId
var ppCheckPrintLines = vars.createCheckServiceResponse.response.ppCheckPrintLines.*string
fun getPaymentCardTypeName() = if ( cardType == "MC" ) "MasterCard"
else if ( cardType == "VI" ) "Visa"
else if ( cardType == "DI" ) "Discover"
else if ( cardType == "AX" ) "American Express"
else if ( cardType == "AZ" ) "Amazon Pay"
else if ( cardType == "GB" ) "Grab"
else if ( cardType == "UBE" ) "Uber Eats"
else if ( cardType == "PM" ) "Postmates"
else if ( cardType == "RWS" ) "Amazon Restaurants"
else if ( cardType == "DD" ) "Door Dash"
else if ( cardType == "GH" ) "GrubHub"
else if ( cardType == "PayInStore" ) "PayInStore"
else ""
fun getLastFourDigits() = using ( cardNum = vars.createCheckVars.paymentCardNum ) if ( cardNum != null and !(isEmpty(cardNum)) ) java!com::api::tgif::mobilepos::util::CommonUtil::getPaymentCard(p("key"),cardNum) else ""
fun getAuthCode() = using ( authCode = vars.createCheckVars.authCode ) if ( authCode != null and !(isEmpty(authCode)) and getPaymentCardTypeName() == "AmazonPay" ) trim(authCode splitBy("-")[3]) else if ( getPaymentCardTypeName == "AmazonPay" ) "" else authCode
fun getOnlineOrderStore() = using ( cardTypeName = getPaymentCardTypeName() ) if ( cardTypeName == "Uber Eats" ) "--UBER EATS--"
else if ( ["GrubHub", "Door Dash", "Amazon Restaurants", "Grab","Postmates", "Pay In Store"] contains cardTypeName ) "--" ++ cardTypeName ++ "--"
else if ( cardTypeName == "PayInStore" ) "--Pay In Store--"
else "--ONLINE ORDER--"
fun getOnlineOrderId() = using ( cardTypeName = getPaymentCardTypeName() ) if ( cardTypeName == "Uber Eats" ) "UBER Order Id: " ++ orderId
else if ( cardTypeName == "GrubHub" ) "GrubHub Order Id: " ++ orderId
else if ( cardTypeName == "Door Dash" ) "GrubHub Order Id: " ++ orderId
else ""
fun getPayStatus() = using ( cardTypeName = getPaymentCardTypeName() ) if ( cardTypeName == "PayInStore" or cardTypeName == "Pay In Store" ) "*** NOT PAID ***"
else "*** PAID ***"
fun getCheckDetails() = ((ppCheckPrintLines map (item, index) -> if ( item contains "Chk" ) {
	check: (using ( checkDetails = (item splitBy " " filter ($ != "")) ) {
		checkNumber: checkDetails[0] ++ "#" ++ checkDetails[1],
		checkNumberWithTimestamp: checkDetails[0] ++ " " ++ checkDetails[1] ++ " " ++ (ppCheckPrintLines[index + 1] splitBy " ")[0] ++ " " ++ (ppCheckPrintLines[index + 1] splitBy " ")[1] ++ " " ++ checkDetails[3] ++ " " ++ checkDetails[4]
	})
} else {
}) filter ($ != {
}))[0].check
fun getAmtPaidDetails() = using ( string = ppCheckPrintLines ) using ( amtPaidDetails = string[19] splitBy " " filter ($ != "") ) amtPaidDetails[0] ++ " " ++ amtPaidDetails[1] ++ "(" ++ amtPaidDetails[2] ++ ")"
fun getChkIndex() = ((ppCheckPrintLines map(item, index) -> if ( item contains "Chk" ) {
	index: index
} else {
}) filter ($ != {
}))[0].index
fun getTimestampIndex() = getChkIndex() + 1
fun getTime() = (((trim(ppCheckPrintLines[getTimestampIndex()]) splitBy " ")[1]) splitBy /[A,P,M]/)[0]
fun getTimezone() = (((trim(ppCheckPrintLines[getTimestampIndex()]) splitBy " ")[1]) splitBy /[\d]/)[4]
fun getHour() = (getTime() splitBy ":")[0]
var seconds = using ( sec = now().seconds as String ) if ( sizeOf(sec) == 1 ) (0 ++ sec) else sec
fun getConvertedTime(hour, timezone) = (if ( (["01","02","03","04","05","06","07","08","09","10","11"] contains hour) and (timezone == "PM") ) ((((hour as Number + 12) ++ ":" ++ (getTime() splitBy ":")[1] ++ ":" ++ seconds ++ " " ++ getTimezone()) as LocalTime {
	format: "HH:mm:ss a"
} + |PT20M|) as LocalTime {
	format: "HH:mm:ss a"
}) else (((getTime() ++ ":" ++ seconds ++ " " ++ getTimezone()) as LocalTime {
	format: "HH:mm:ss a"
} + |PT20M|) as LocalTime {
	format: "HH:mm:ss a"
}))
fun getCheckCreatedTime() = getTime() ++ ":" ++ seconds ++ " " ++ getTimezone()
fun getTimeString() = getConvertedTime(getHour(), getTimezone()) as String {
	format: "HH:mm:ss a"
}
fun getPickupTime() = using ( tArr = (getTimeString() splitBy (":")) ) (if ( ["13", "14","15", "16", "17", "18", "19", "20", "21"] contains tArr[0] ) "0" ++ tArr[0] - 12 
else tArr[0]) ++ ":$(tArr[1]):$(tArr[2]) "
fun mailHeaderFooter() = if ( getPaymentCardTypeName() == "PayInStore" ) "################\n################\n!! NOT PAID !!\n################\n################\n" 
else ""
fun getStripeCode() = vars.stripesCode
---
if ( ppCheckPrintLines != null ) mailHeaderFooter() ++ "****************\n" ++ getOnlineOrderStore() ++ "\n" ++ getCheckCreatedTime() ++ "\n\n" ++ vars.fullfillmentOrder ++ "\n****************\nReady for Pickup: " ++ 
getPickupTime() ++ "\n****************" ++ ((ppCheckPrintLines map if ( $$ == getChkIndex() ) getCheckDetails().checkNumberWithTimestamp else if ( $$ == getTimestampIndex() ) getAmtPaidDetails() else if ( $ == null ) "" else $) joinBy "\n") ++ 
"\nCard Type: " ++  getPaymentCardTypeName() ++ "\nCard # " ++ getLastFourDigits() ++ "\nAuthorization Code: " ++ getAuthCode() ++ "\nTransaction Type: Purchase\n" ++ 
"Cardmember acknowledges receipt of goods\nand/or services in the amount of the total\nshown hereon and agrees to perform the\n" ++
"obligations set forth by cardmembers\nagreement with issuer\nX------------------------------------\n" ++ getPayStatus() ++ "\n" ++ vars.createCheckVars.customerName ++
"\n" ++ vars.createCheckVars.customerPhone ++ "\n****************\n" ++ getOnlineOrderStore() ++ "\n" ++ vars.fullfillmentOrder ++ "\n****************\n" ++ 
getCheckDetails().checkNumber ++ "\n" ++ vars.createCheckVars.orderId ++ "\n" ++ 
"QUESTIONS OR COMMENTS?\nPLEASE CONTACT US AT \nWWW.TGIFRIDAYS.COM OR\n1-800-FRIDAYS\n" ++ mailHeaderFooter() ++ "\nREWARDS CODE\n* " ++ getStripeCode() ++ " *\n" ++
"Didn't get your points on \n this visit? Just download the\nFriday's mobile app and scan or\nenter Rewards Code.\nNot a member? Join via\n" ++
"our mobile app or\nwww.tgifridays.com/rewards"
else "Print Check Lines not found"