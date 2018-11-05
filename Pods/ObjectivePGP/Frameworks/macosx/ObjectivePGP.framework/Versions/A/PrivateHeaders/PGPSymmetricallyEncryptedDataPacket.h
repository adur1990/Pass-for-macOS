//
//  Copyright (c) Marcin Krzyżanowski. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY
//  INTERNATIONAL COPYRIGHT LAW. USAGE IS BOUND TO THE LICENSE AGREEMENT.
//  This notice may not be removed from this file.
//

#import "PGPPacket.h"

NS_ASSUME_NONNULL_BEGIN

@class PGPSecretKeyPacket;

@interface PGPSymmetricallyEncryptedDataPacket : PGPPacket <NSCopying>

@property (nonatomic, copy) NSData *encryptedData;

- (NSArray<PGPPacket *> *)decryptWithSessionKeyAlgorithm:(PGPSymmetricAlgorithm)sessionKeyAlgorithm sessionKeyData:(NSData *)sessionKeyData error:(NSError * __autoreleasing _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
