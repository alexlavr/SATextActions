//
//  ALTextStorage.m
//  TextTool
//
//  Created by Sash on 12/24/13.
//  Copyright (c) 2013 Alex Lavrinenko. All rights reserved.
//

#import "ALTextStorage.h"

@interface ALTextStorage()
@property (strong, nonatomic) NSMutableAttributedString *textStore;
@end

@implementation ALTextStorage


- (id)initWithStyle: (NSDictionary *) attributes
{
    self = [super init];
    if (self) {
        self.textStore = [[NSMutableAttributedString alloc] initWithString:@" " attributes:attributes];
    }
    return self;
}

- (NSString *)string
{
    return [_textStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_textStore attributesAtIndex:location effectiveRange:range];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_textStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_textStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    //_dynamicTextNeedsUpdate = YES;
    [self endEditing];
}

@end
