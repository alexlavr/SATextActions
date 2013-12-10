//
//  SALabelWithActions.m
//
//  Copyright (c) 2013 Alexander Lavrinenko. All rights reserved.
//

#import "SATextActions.h"


@implementation SATextTapAction
@end


@interface SATextActions ()
@property (weak, nonatomic)  SATextTapAction *currentSelectedAction;
@end

@implementation SATextActions

- (void)dealloc {
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLabel];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLabel];
    }
    return self;
}

- (void) setupLabel
{
    //Setup Label initial options
    self.userInteractionEnabled = YES;
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0;
    self.selectable     = YES;
    self.editable       = NO;
    self.scrollEnabled  = NO;
    self.scrollsToTop   = NO;


}

- (void) setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];

}

- (void) setTapActions:(NSArray *)tapActions
{

    
    if (![tapActions isKindOfClass:[NSArray class]] || ![tapActions count]) return;
    
    
    
    NSMutableAttributedString *as = [self.attributedText mutableCopy];
    
    
    [tapActions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SATextTapAction *action = obj;
        if (action.range.location + action.range.length > as.length)
        {
            return;
        }
        //Apply Action Attributes
        [as addAttributes:action.attributesNormal range:action.range];
        [as addAttribute:SALabelActionTypeTap value:action range:action.range];
        
        
    }];
   
    
    self.attributedText = as;
     
    
    
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];

    NSUInteger closestIndex = [self getCharIndexAt:touchLocation];
    
    if (closestIndex == NSNotFound ||  closestIndex >= self.attributedText.string.length)
    {
        return;
    }
    
    //NSLog(@"closest: %@ - %d: %@", NSStringFromCGPoint(touchLocation),  closestIndex, [self.attributedText.string substringWithRange:r]);
    if (closestIndex > 0) closestIndex -= 1;
    NSDictionary *attributesForChar = [self.attributedText attributesAtIndex:closestIndex effectiveRange:NULL];
    SATextTapAction *action = (SATextTapAction *)attributesForChar[SALabelActionTypeTap];
    if (action)
    {
        NSMutableAttributedString *newAttrString = [self.attributedText mutableCopy];
        
        //Clean Normal Atttibutes
        for (id attributeName in _currentSelectedAction.attributesNormal) [newAttrString removeAttribute:attributeName range:_currentSelectedAction.range];
        
        //Add Highlighted Attribules
        
        [newAttrString addAttributes:action.attributesHighlighted range:action.range];
        self.attributedText = newAttrString;
        
        self.currentSelectedAction = action;
    }
    return;
    
   
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_currentSelectedAction) return;
    
    [self deselect];
    
  

    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (!_currentSelectedAction) return;
    
    [self performSelector:@selector(deselect) withObject:nil afterDelay:0.5];
        
    if (_currentSelectedAction && _currentSelectedAction.actionBlock) _currentSelectedAction.actionBlock();
    

    
    
    
}
- (void) deselect
{
    NSMutableAttributedString *newAttrString = [self.attributedText mutableCopy];
    
    //Clean Highlighted Atttibutes
    for (id attributeName in _currentSelectedAction.attributesHighlighted) [newAttrString removeAttribute:attributeName range:_currentSelectedAction.range];
    
    //Add Normal Attribules
    [newAttrString addAttributes:_currentSelectedAction.attributesNormal range:_currentSelectedAction.range];
    self.attributedText = newAttrString;
    
    self.currentSelectedAction = nil;

}


#pragma mark - Helpers

- (NSUInteger) getCharIndexAt: (CGPoint) location
{
    NSLayoutManager *layoutManager = self.layoutManager;
    NSUInteger characterIndex = NSNotFound;
    characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
   
    return characterIndex;
}



@end
