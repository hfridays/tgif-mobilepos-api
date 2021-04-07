%dw 2.0
output application/json
---
if (vars.createCheckServiceResponse.response == "Store server not reachable, able to reach Firewall" ) {
	createcheck: {
		result: {
			status: "failure",
			message: "Store server not reachable, able to reach Firewall"
		}
	}
}
else if (vars.createCheckServiceResponse.response == "Store network unreachable at Firewall" ) {
	createcheck: {
		result: {
			status: "failure",
			message: "Store network unreachable at Firewall"
		}
	}
}

else if (vars.createCheckServiceResponse.response == "Bad response" ) {
	createcheck: {
		result: {
			status: "failure",
			message: "Unable to find check Bad Response returned from micros"
		}
	}
} else {
	"createcheck": {
		"result": {
			"status": "failed",
			"message": vars.errorDescription as String
		}
	}
}