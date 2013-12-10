//
//  SALabelWithActions.h
//
//  Copyright (c) 2013 Alexander Lavrinenko. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const SALabelActionTypeTap    =  @"SALabelActionTypeTap";

@interface SATextActions : UITextView

- (void) setTapActions:(NSArray *)tapActions;

@end

//Properties for a Tap Action:
@interface SATextTapAction : NSObject

@property (nonatomic, copy) void (^actionBlock)(void);
@property (strong, nonatomic) NSDictionary *attributesNormal;
@property (strong, nonatomic) NSDictionary *attributesHighlighted;
@property (readwrite, nonatomic) NSRange range;

@end