//
//  DHColorDefaults.m
//  DHMathematicsGame
//
//  Created by Jayesh Kawli on 8/30/14.
//  Copyright (c) 2014 DuetHealth. All rights reserved.
//

#import "DHColorDefaults.h"

@implementation DHColorDefaults

+(UIFont*)getDefaultInstructionViewFontWithSize:(float)fontSize{
       return [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
}

+(UIColor*)getLightVioletColor{
    
    return [UIColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0f];
}
+(UIColor*)getLightGreenColor{
    return [UIColor colorWithRed:0.4 green:1.0 blue:0.7 alpha:1.0f];
}
+(UIColor*)getAquaBlueColor{
        return [UIColor colorWithRed:0.6 green:1.0 blue:1.0 alpha:1.0f];
    
}
+(UIColor*)getLightOrangeColor{
        return [UIColor colorWithRed:0.96 green:0.7 blue:0.235 alpha:1.0f];
    
}
@end
