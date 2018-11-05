//
//  Copyright (c) Marcin Krzyżanowski. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY
//  INTERNATIONAL COPYRIGHT LAW. USAGE IS BOUND TO THE LICENSE AGREEMENT.
//  This notice may not be removed from this file.
//

#import "PGPTypes.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (PGPUtils)

- (UInt16)pgp_Checksum;
- (UInt32)pgp_CRC24;
- (NSData *)pgp_MD5;
- (NSData *)pgp_SHA1;
- (NSData *)pgp_SHA224;
- (NSData *)pgp_SHA256;
- (NSData *)pgp_SHA384;
- (NSData *)pgp_SHA512;
- (NSData *)pgp_RIPEMD160;

// xor up to the last byte of the shorter data
+ (NSData *)xor:(NSData *)d1 d2:(NSData *)d2;

+ (NSData *)dataWithValue:(NSValue *)value;

- (NSData *)pgp_HashedWithAlgorithm:(PGPHashAlgorithm)hashAlgorithm;

@end

NS_ASSUME_NONNULL_END
