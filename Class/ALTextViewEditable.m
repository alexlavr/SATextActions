//
//  ALTextViewEditable.m
//  TextTool
//
//  Created by Sash on 12/28/13.
//  Copyright (c) 2013 Alex Lavrinenko. All rights reserved.
//

#import "ALTextViewEditable.h"

@implementation ALTextViewEditable


- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    //Setup Label initial options
    self.editable       = YES;
    self.scrollsToTop   = NO;
    self.alwaysBounceVertical = YES;
    self.scrollEnabled = YES;
    self.textContainerInset = UIEdgeInsetsMake(0.0, 0, 0, 0);
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   
    
    
}
- (NSRange) rangeForLinkAtIndex: (NSUInteger) charIndex
{
    __block NSRange linkStartRange;
    __block NSRange linkEndRange;
    
    //Search backward to beginning
    [self.attributedText enumerateAttribute: NSLinkAttributeName
                                    inRange: NSMakeRange(0, charIndex)
                                    options: NSAttributedStringEnumerationReverse
                                 usingBlock: ^(id value, NSRange range, BOOL *stop) {
                                     if (value)
                                     {
                                         linkStartRange = range;
                                     
                                         NSLog(@"START %@", NSStringFromRange(range));
                                         *stop = YES;
                                     }
    }];
    
    //search forward to end
    [self.attributedText enumerateAttribute: NSLinkAttributeName
                                    inRange: NSMakeRange(charIndex, self.attributedText.length - charIndex)
                                    options: 0
                                 usingBlock: ^(id value, NSRange range, BOOL *stop) {
                                     linkEndRange = range;
                                     NSLog(@"END %@", NSStringFromRange(range));
                                     *stop = YES;
                                 }];
    //Combine Ranges
    NSRange linkRange = NSUnionRange(linkStartRange, linkEndRange);
    
    return linkRange;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    

    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    //Get attributes at position
    NSUInteger closestIndex = [self getCharIndexAt:touchLocation];
    if (closestIndex == NSNotFound ||  closestIndex >= self.attributedText.string.length)
    {
        return;
    }
    

    NSDictionary *attributesForChar = [self.attributedText attributesAtIndex:closestIndex effectiveRange:NULL];
    NSURL *link = (NSURL *)attributesForChar[NSLinkAttributeName];
    
    if (link)
    {
        NSRange linkRange = [self rangeForLinkAtIndex:closestIndex];
        self.selectedRange = linkRange;
    }
   
    
    
}

#pragma mark - Helpers

- (NSUInteger) getCharIndexAt: (CGPoint) location
{
    NSLayoutManager *layoutManager = self.layoutManager;
    NSUInteger characterIndex = NSNotFound;
    characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    NSLog(@"characterIndex %d", characterIndex);
    return characterIndex;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
