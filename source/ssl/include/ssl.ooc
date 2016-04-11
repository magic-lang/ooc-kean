/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

include openssl/aes, openssl/crypto, openssl/evp, openssl/rand

AesKey: cover from AES_KEY

EvpMessageDigestContext: cover from EVP_MD_CTX
EvpMessageDigest: cover from EVP_MD

AES_BLOCK_SIZE,
AES_ENCRYPT,
AES_DECRYPT: extern const Int

OPENSSL_VERSION_NUMBER: extern const Long

SSLEAY_VERSION,
SSLEAY_CFLAGS,
SSLEAY_BUILT_ON,
SSLEAY_PLATFORM,
SSLEAY_DIR: extern const Int

AES_set_encrypt_key: extern func (keyData: Byte*, keyLength: Int, aesKey: AesKey*)
AES_set_decrypt_key: extern func (keyData: Byte*, keyLength: Int, aesKey: AesKey*)
AES_cbc_encrypt: extern func (input: const Byte*, output: Byte*, inputLength: SizeT, key: AesKey*, initVector: Byte*, mode: Int)

EVP_MD_CTX_create: extern func -> EvpMessageDigestContext*
EVP_MD_CTX_destroy: extern func (context: EvpMessageDigestContext*)
EVP_DigestInit: extern func (context: EvpMessageDigestContext*, type: EvpMessageDigest*) -> Int
EVP_DigestUpdate: extern func (context: EvpMessageDigestContext*, data: Void*, size: SizeT) -> Int
EVP_DigestFinal: extern func (context: EvpMessageDigestContext*, output: Byte*, bytesWritten: UInt*) -> Int

EVP_md5: extern func -> EvpMessageDigest*
EVP_sha1: extern func -> EvpMessageDigest*
EVP_sha256: extern func -> EvpMessageDigest*
EVP_sha512: extern func -> EvpMessageDigest*

RAND_bytes: extern func (output: Byte*, length: Int) -> Int
SSLeay: extern func -> Long
SSLeay_version: extern func (type: Int) -> CString
