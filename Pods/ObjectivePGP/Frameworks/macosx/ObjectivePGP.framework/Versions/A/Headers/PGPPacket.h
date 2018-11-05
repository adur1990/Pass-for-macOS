//
//  PGPPacket.h
//  ObjectivePGP
//
//  Created by Marcin Krzyzanowski on 06/05/14.
//  Copyright (c) 2014 Marcin Krzyżanowski. All rights reserved.
//

#import "PGPExportableProtocol.h"
#import "PGPPacketProtocol.h"
#import "PGPTypes.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const UInt32 PGPUnknownLength;

@interface PGPPacket : NSObject <PGPPacketProtocol, NSCopying, PGPExportable>
@property (nonatomic) BOOL indeterminateLength; // should not be used, but gpg use it

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHeader:(NSData *)headerData body:(NSData *)bodyData;

+ (nullable NSData *)parsePacketHeader:(NSData *)data headerLength:(UInt32 *)headerLength nextPacketOffset:(nullable NSUInteger *)nextPacketOffset packetTag:(PGPPacketTag *)tag indeterminateLength:(BOOL *)indeterminateLength;
- (NSUInteger)parsePacketBody:(NSData *)packetBody error:(NSError *__autoreleasing *)error;

+ (NSData *)buildPacketOfType:(PGPPacketTag)tag withBody:(PGP_NOESCAPE NSData *(^)(void))body;


@end

NS_ASSUME_NONNULL_END
