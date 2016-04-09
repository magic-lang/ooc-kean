use base
use ssl
use unit

import include/ssl

OpenSslTest: class extends Fixture {
	init: func {
		super("OpenSsl")
		this add("version", func {
			expect(OPENSSL_VERSION_NUMBER != 0)
			expect(OPENSSL_VERSION_NUMBER, is equal to(SSLeay()))
		})
		this add("random", func {
			length := 16
			buffer1: Byte[length]
			buffer2: Byte[length]
			for (i in 0 .. 32) {
				expect(RAND_bytes(buffer1[0]&, length), is equal to(1))
				expect(RAND_bytes(buffer2[0]&, length), is equal to(1))
				outputDifferent := false
				for (b in 0 .. length)
					if (buffer1[b] != buffer2[b]) {
						outputDifferent = true
						break
					}
				expect(outputDifferent)
			}
		})
		this add("encrypt / decrypt (text, AES-256)", func {
			keyLengthBits := 256
			keyLength := keyLengthBits / 8
			encryptedLength := AES_BLOCK_SIZE
			password: Byte[keyLength]
			initVector, initVectorDecrypt: Byte[AES_BLOCK_SIZE]
			plainText := ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
			expectedCipher := [ 0x51, 0x40, 0xBC, 0x1A, 0x07, 0x3E, 0xC3, 0x6B, 0xEF, 0x1B, 0x01, 0xBC, 0x92, 0xF5, 0x4E, 0xA9 ]
			cipherText: Byte[encryptedLength]
			decipheredText: Byte[plainText length]
			encryptionKey, decryptionKey: AesKey

			memset(initVector[0]&, 0, AES_BLOCK_SIZE)
			memset(initVectorDecrypt[0]&, 0, AES_BLOCK_SIZE)
			memset(password[0]&, 0, keyLength)
			memcpy(password[0]&, c"secretkey", 9)

			AES_set_encrypt_key(password[0]&, keyLengthBits, encryptionKey&)
			AES_cbc_encrypt(plainText data, cipherText[0]&, plainText length, encryptionKey&, initVector[0]&, AES_ENCRYPT)

			for (i in 0 .. expectedCipher length)
				expect(cipherText[i] as Byte, is equal to(expectedCipher[i] as Byte))

			AES_set_decrypt_key(password[0]&, keyLengthBits, decryptionKey&)
			AES_cbc_encrypt(cipherText[0]&, decipheredText[0]&, expectedCipher length, decryptionKey&, initVectorDecrypt[0]&, AES_DECRYPT)

			expect(memcmp(plainText[0]&, decipheredText[0]&, plainText length), is equal to(0))
			(expectedCipher, plainText) free()
		})
		this add("encrypt / decrypt (random data)", func {
			keyLengthsToTest := [128, 192, 256]
			for (k in 0 .. keyLengthsToTest length) {
				keyLengthBits := keyLengthsToTest[k]
				keyLength := keyLengthBits / 8
				inputLength := 1024
				encryptedLength := 1024
				password: Byte[keyLength]
				initVector, initVectorDecrypt: Byte[AES_BLOCK_SIZE]
				plainText, decipheredText: Byte[inputLength]
				cipherText: Byte[encryptedLength]
				encryptionKey, decryptionKey: AesKey

				expect(RAND_bytes(password[0]&, keyLength), is equal to(1))
				expect(RAND_bytes(plainText[0]&, inputLength), is equal to(1))
				expect(RAND_bytes(initVector[0]&, AES_BLOCK_SIZE), is equal to(1))
				memcpy(initVectorDecrypt[0]&, initVector[0]&, AES_BLOCK_SIZE)

				AES_set_encrypt_key(password[0]&, keyLengthBits, encryptionKey&)
				AES_cbc_encrypt(plainText[0]&, cipherText[0]&, inputLength, encryptionKey&, initVector[0]&, AES_ENCRYPT)

				isEncrypted := false
				for (i in 0 .. inputLength)
					if (plainText[i] != cipherText[i]) {
						isEncrypted = true
						break
					}
				expect(isEncrypted)

				AES_set_decrypt_key(password[0]&, keyLengthBits, decryptionKey&)
				AES_cbc_encrypt(cipherText[0]&, decipheredText[0]&, encryptedLength, decryptionKey&, initVectorDecrypt[0]&, AES_DECRYPT)

				for (i in 0 .. inputLength)
					if (plainText[i] != decipheredText[i])
						expect(false)
			}
			keyLengthsToTest free()
		})
	}
}

OpenSslTest new() run() . free()
