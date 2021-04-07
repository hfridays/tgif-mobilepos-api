package com.api.tgif.mobilepos.util;

public class CommonUtil {
	public static String StripesCode(int storeNumber, String subTotal, int month, int day, String checkNumber) {
		int intSubTotal = Integer.parseInt(subTotal);
		String monthBase36Encoded = Integer.toString(month, 36).toUpperCase();
		String dayBase36Encoded = Integer.toString(day, 36).toUpperCase();
		String subtotalBase36Encoded = Integer.toString(intSubTotal, 36).toUpperCase();
		String paddedSubtotalBase36Encoded = leftPad(subtotalBase36Encoded, 5, '0');
		String storeNumberBase36Encoded = Integer.toString(storeNumber, 36).toUpperCase();
		String paddedStoreNumberBase36Encoded = leftPad(storeNumberBase36Encoded, 3, '0');
		int intCheckNumber = Integer.parseInt(checkNumber);
		String checkNumberBase36Encoded = Integer.toString(intCheckNumber, 36).toUpperCase();
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
