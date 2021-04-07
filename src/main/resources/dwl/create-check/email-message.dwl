%dw 2.0
output text/plain
var cardType = vars.paymentCard
var cardNumber = vars.createCheckVars.paymentCardNum
var orderId = vars.createCheckVars.orderId
var ppCheckPrintLines = vars.createCheckServiceResponse.response.ppCheckPrintLines.string
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
fun getLastFourDigits() = ""
fun getAuthCode() = using ( authCode = vars.createCheckVars.authCode ) if ( authCode != null and !(isEmpty(authCode) and getPaymentCardTypeName() == "AmazonPay") ) trim(authCode splitBy("-")[3]) else if ( getPaymentCardTypeName == "AmazonPay" ) "" else authCode
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
fun getAmtPaidDetails() = using ( string = ppCheckPrintLines ) using ( amtPaidDetails = (string filter ($ contains "Amt. Paid"))[0] splitBy " " filter ($ != "") ) amtPaidDetails[0] ++ " " ++ amtPaidDetails[1] ++ "(" ++ amtPaidDetails[2] ++ ")"
fun getChkIndex() = ((ppCheckPrintLines map(item, index) -> if ( item contains "Chk" ) {
	index: index
} else {
}) filter ($ != {
}))[0].index
fun getTimestampIndex() = getChkIndex() + 1
fun getTime() = (((ppCheckPrintLines[getTimestampIndex()] splitBy " ")[1]) splitBy /[A,P,M]/)[0]
fun getTimezone() = (((ppCheckPrintLines[getTimestampIndex()] splitBy " ")[1]) splitBy /[\d]/)[4]
fun getCheckCreatedTime() = getTime() ++ ":" ++ now().seconds ++ " " ++ getTimezone()
fun getPickupTime() = ((getCheckCreatedTime() as LocalTime {
	format: "HH:mm:ss a"
}) + |PT20M|) as LocalTime {
	format: "HH:mm:ss a"
}
fun mailHeaderFooter() = if ( getPaymentCardTypeName() == "PayInStore" ) "################\n################\n!! NOT PAID !!\n################\n################\n" 
else ""
fun getStripeCode() = vars.stripesCode
---
if ( ppCheckPrintLines != null ) mailHeaderFooter() ++ "****************\n" ++ getOnlineOrderStore() ++ "\n" ++ getCheckCreatedTime() ++ "\n\n" ++ vars.fullfillmentOrder ++ "\n****************" ++ 
getPickupTime() ++ "\n****************" ++ ((ppCheckPrintLines map if ( $$ == getChkIndex() ) getCheckDetails().checkNumberWithTimestamp else if ( $$ == getTimestampIndex() ) getAmtPaidDetails() else $) joinBy "\n") ++ 
"\nCard Type: " ++  getPaymentCardTypeName() ++ "\nCard # " ++ getLastFourDigits() ++ "\nAuthorization Code: " + getAuthCode() ++ "Transaction Type: Purchase\n" ++ 
"Cardmember acknowledges receipt of goods\nCardmember acknowledges receipt of goods\nshown hereon and agrees to perform the\n" ++
"obligations set forth by cardmembers\nagreement with issuer\nX------------------------------------\n" ++ getPayStatus() ++ "\n" ++ vars.createCheckVars.customerName ++
"\n" ++ vars.createCheckVars.customerPhone ++ "\n****************\n" ++ getOnlineOrderStore() ++ "\n" ++ vars.fullfillmentOrder ++ "\n****************\n" ++ 
getCheckDetails().checkNumber ++ "\n" ++ vars.createCheckVars.orderId ++ "\n" ++ 
"QUESTIONS OR COMMENTS?\nPLEASE CONTACT US AT \nWWW.TGIFRIDAYS.COM OR\n1-800-FRIDAYS\n" ++ mailHeaderFooter() ++ "\nREWARDS CODE\n* " ++ getStripeCode() ++ " *\n" ++
"Didn't get your points on \n this visit? Just download the\nFriday's mobile app and scan or\nenter Rewards Code.\nNot a member? Join via\n" ++
"our mobile app or\nwww.tgifridays.com/rewards"
else "Print Check Lines not found"
