//
//  DHUtilityMethodsProvider.m
//  DHMathematicsGame
//
//  Created by DuetHealth on 8/2/14.
//  Copyright (c) 2014 DuetHealth. All rights reserved.
//

#import "DHUtilityMethodsProvider.h"

@implementation DHUtilityMethodsProvider

+ (NSInteger)getRandomNumber {
    return (arc4random () % 27) + 1;
}

@end
