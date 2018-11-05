//
//  PGPBigNum.h
//  ObjectivePGP
//
//  Created by Marcin Krzyzanowski on 26/06/2017.
//  Copyright © 2017 Marcin Krzyżanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGPBigNum : NSObject <NSCopying>

@property (nonatomic, readonly) unsigned int bitsCount;
@property (nonatomic, readonly) unsigned int bytesCount;
@property (nonatomic, readonly) NSData *data;

@end

NS_ASSUME_NONNULL_END
