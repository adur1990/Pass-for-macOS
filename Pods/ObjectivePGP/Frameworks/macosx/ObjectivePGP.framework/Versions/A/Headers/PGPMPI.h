//
//  OpenPGPMPI.h
//  ObjectivePGP
//
//  Created by Marcin Krzyzanowski on 04/05/14.
//  Copyright (c) 2014 Marcin Krzyżanowski. All rights reserved.
//

#import <ObjectivePGP/PGPBigNum.h>
#import <ObjectivePGP/PGPMacros.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString * const PGPMPI_N;
OBJC_EXTERN NSString * const PGPMPI_E;
OBJC_EXTERN NSString * const PGPMPI_P;
OBJC_EXTERN NSString * const PGPMPI_G;
OBJC_EXTERN NSString * const PGPMPI_Q;
OBJC_EXTERN NSString * const PGPMPI_D;
OBJC_EXTERN NSString * const PGPMPI_U;
OBJC_EXTERN NSString * const PGPMPI_X;
OBJC_EXTERN NSString * const PGPMPI_R;
OBJC_EXTERN NSString * const PGPMPI_S;
OBJC_EXTERN NSString * const PGPMPI_Y;
OBJC_EXTERN NSString * const PGPMPI_M;

@interface PGPMPI : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, readonly) PGPBigNum *bigNum;
/**
 *  Total bytes, header + body
 */
@property (nonatomic, readonly) NSUInteger packetLength;

PGP_EMPTY_INIT_UNAVAILABLE;

- (instancetype)initWithData:(NSData *)dataToMPI identifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithBigNum:(PGPBigNum *)bigNum identifier:(NSString *)identifier;
- (instancetype)initWithMPIData:(NSData *)mpiData identifier:(NSString *)identifier atPosition:(NSUInteger)position;
- (nullable NSData *)exportMPI;
- (nullable NSData *)bodyData;

@end

NS_ASSUME_NONNULL_END
