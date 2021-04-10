package com.api.tgif.mobilepos.util;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.UnknownHostException;

import org.apache.commons.lang3.StringUtils;

public class CommonUtil {

	public static String checkConnectivity(String ipAddress, String port) throws Exception {
		String jsonstg = "";

		int flag = 0;
		Socket socket = new Socket();

		if (port != null) {
			try {
				int intport = Integer.parseInt(port);
				socket.connect(new InetSocketAddress(ipAddress, intport));
				jsonstg = "Host is reachable";
			} catch (Exception e) {
				String errorMsg = e.toString();
				jsonstg = errorMsg.toString().trim();

			}

		} else {
			try {
				do {
					InetAddress inet = InetAddress.getByName(ipAddress);

					boolean status = inet.isReachable(10000); // Timeout = 5000 milli seconds

					if (status) {
						jsonstg = "Host is reachable";
						break;

					} else {
						flag = flag + 1;

						if (flag == 3) {
							jsonstg = "Host is not reachable";
						}

					}
				} while (flag < 3);
			} catch (Exception ex) {
				String[] errorMessageArray = StringUtils.split(ex.toString(), ":");
				String errorMessage = errorMessageArray[2];
				jsonstg = errorMessage.toString().trim();
			}
		}
		socket.close();
		return jsonstg;
	}

	public static boolean pingGatewayServer(String ipAddress) {
		InetAddress inetfirewall;
		try {
			inetfirewall = InetAddress.getByName(ipAddress);
			return inetfirewall.isReachable(2000);
		} catch (UnknownHostException e) {
			e.printStackTrace();
			return false;
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
	}

	public static String StripesCode(Integer storeNumber, Integer subTotal, Integer month, Integer day,
			Integer checkNumber) {
		String monthBase36Encoded = Integer.toString(month, 36).toUpperCase();
		String dayBase36Encoded = Integer.toString(day, 36).toUpperCase();
		String subtotalBase36Encoded = Integer.toString(subTotal, 36).toUpperCase();
		String paddedSubtotalBase36Encoded = leftPad(subtotalBase36Encoded, 5, '0');
		String storeNumberBase36Encoded = Integer.toString(storeNumber, 36).toUpperCase();
		String paddedStoreNumberBase36Encoded = leftPad(storeNumberBase36Encoded, 3, '0');
		String checkNumberBase36Encoded = Integer.toString(checkNumber, 36).toUpperCase();
		String paddedCheckNumberBase36Encoded = leftPad(checkNumberBase36Encoded, 3, '0');

		String stripesCode = paddedStoreNumberBase36Encoded + paddedCheckNumberBase36Encoded + monthBase36Encoded
				+ dayBase36Encoded + paddedSubtotalBase36Encoded;
		return stripesCode;
	}

	public static String leftPad(String originalString, int length, char padCharacter) {
		String paddedString = originalString;
		while (paddedString.length() < length) {
			paddedString = padCharacter + paddedString;
		}
		return paddedString;
	}
}
