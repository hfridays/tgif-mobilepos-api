%dw 2.0
output application/json
---
{
	createcheck: {
		result: {
			status: "failed",
			message: if ( vars.errorCode == "Bad response" ) "Unable to find check Bad Response returned from micros" else vars.errorDescription
		}
	}
}