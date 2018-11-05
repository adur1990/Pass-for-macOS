//
//  PGPSignature.h
//  ObjectivePGP
//
//  Created by Marcin Krzyzanowski on 04/05/14.
//  Copyright (c) 2014 Marcin Krzyżanowski. All rights reserved.
//
//  Tag 2

#import "PGPKeyID.h"
#import "PGPMPI.h"
#import "PGPPacketFactory.h"
#import "PGPSignatureSubpacket.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PGPPartialKey, PGPUser, PGPUserIDPacket, PGPPublicKeyPacket, PGPKey;

@interface PGPSignaturePacket : PGPPacket <NSCopying>

@property (nonatomic) UInt8 version;
@property (nonatomic) PGPSignatureType type;
@property (nonatomic) PGPPublicKeyAlgorithm publicKeyAlgorithm;
@property (nonatomic) PGPHashAlgorithm hashAlgoritm;
@property (nonatomic, copy, readonly) NSArray<PGPSignatureSubpacket *> *hashedSubpackets;
@property (nonatomic, copy, readonly) NSArray<PGPSignatureSubpacket *> *unhashedSubpackets;
/// Two-octet field holding the left 16 bits of the signed hash value.
/// Read from the key or set byt the call to `-[PGPSignaturePacket signData:usingKey:passphrase:userID:error]`
@property (nonatomic, nullable) NSData *signedHashValueData;
@property (nonatomic, copy) NSArray<PGPMPI *> *signatureMPIArray;

@property (nonatomic, readonly) BOOL canBeUsedToSign; // computed
@property (nonatomic, readonly) BOOL canBeUsedToEncrypt; // computed

@property (nonatomic, nullable, readonly) PGPKeyID *issuerKeyID;
@property (nonatomic, copy, readonly) NSArray<PGPSignatureSubpacket *> *subpackets;
@property (nonatomic, nullable, readonly) NSDate *expirationDate; // computed
@property (nonatomic, readonly, readonly, getter=isExpired) BOOL expired; // computed
@property (nonatomic, nullable, readonly) NSDate *creationDate; // computed
@property (nonatomic, readonly, readonly, getter=isPrimaryUserID) BOOL primaryUserID; // computed

/**
 *  Create signature packet for signing. This is convienience constructor.
 *
 *  @param type               example: PGPSignatureBinaryDocument
 *  @param hashAlgorithm      hash algorithm to be used for signature
 *
 *  @return Packet instance ready to call signData:secretKey
 */
+ (PGPSignaturePacket *)signaturePacket:(PGPSignatureType)type hashAlgorithm:(PGPHashAlgorithm)hashAlgorithm;

- (NSArray<PGPSignatureSubpacket *> *)subpacketsOfType:(PGPSignatureSubpacketType)type;
- (NSData *)calculateSignedHashForDataToSign:(NSData *)dataToSign;

/**
 *  Build signature data (signature packet with subpackets).
 *
 *  @param inputData Data to sign.
 *  @param withKey   A key used to create signature.
 *  @param error     error
 *
 *  @return YES on success.
 */
- (BOOL)signData:(nullable NSData *)inputData withKey:(PGPKey *)key subKey:(nullable PGPKey *)subKey passphrase:(nullable NSString *)passphrase userID:(nullable NSString *)userID error:(NSError *__autoreleasing *)error;

- (BOOL)verifyData:(NSData *)inputData withKey:(PGPKey *)publicKey error:(NSError *__autoreleasing *)error;
- (BOOL)verifyData:(NSData *)inputData withKey:(PGPKey *)publicKey userID:(nullable NSString *)userID error:(NSError *__autoreleasing *)error;
- (BOOL)verifyData:(NSData *)inputData withKey:(PGPKey *)publicKey signingKeyPacket:(PGPPublicKeyPacket *)signingKeyPacket userID:(nullable NSString *)userID error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
