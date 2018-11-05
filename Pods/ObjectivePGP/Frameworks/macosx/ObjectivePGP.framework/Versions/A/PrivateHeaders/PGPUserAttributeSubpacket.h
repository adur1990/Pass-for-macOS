//
//  Copyright (c) Marcin Krzyżanowski. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY
//  INTERNATIONAL COPYRIGHT LAW. USAGE IS BOUND TO THE LICENSE AGREEMENT.
//  This notice may not be removed from this file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PGPUserAttributeSubpacket : NSObject <NSCopying>

// Subpacket types 100 through 110 are reserved for private or experimental use.
@property (nonatomic) UInt8 type;
// Value
@property (nonatomic, copy) NSData *valueData;

@end

NS_ASSUME_NONNULL_END
