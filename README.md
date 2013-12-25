SATextActions
=============

UITextView subclass for adding conditional formatting tap and actions.

<<<<<<< HEAD
=======
Coming soon:

1. Set rule based on range or regex
2. Set formatting rules
3. Set tap action block for rules
4. Set type action block for rules
5. Save/restore range data using JSON


Example:
`````Objective-c


>>>>>>> b7cfb112d165e114ccc584e2b2e5560619b246b0

//Create attributed string to display
NSAttributedString *attributedStatusString = [[NSAttributedString alloc] initWithString:string attributes:attributes];

//Style attributes for hashtags links
NSDictionary *linkHashNormal = @{
							NSForegroundColorAttributeName: UIColorFromRGB(0x9AD025),
							};
NSDictionary *linkHashHighlighted = @{
							NSForegroundColorAttributeName: UIColorFromRGB(0x669933),
							};
                                
//Find hashtags
NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:NULL];

NSArray *hashtagMatches  = [regex matchesInString:string
								  options:0
									range:NSMakeRange(0, [string length])];
									
									
// Iterate across the string matches from our regular expressions, find the range
// of each match, add new attributes to that range
NSMutableArray *actions = [@[] mutableCopy];
__typeof (&*self) __weak weakSelf = self;

for (NSTextCheckingResult *match in hashtagMatches) {
        
		NSRange range = [match range];
		if( range.location != NSNotFound ) {
			// Add custom attribute of LinkMatch to indicate where our URLs are found. Could be blue
			// or any other color.
            
            NSString *hashtagMatchedString = [statusString substringWithRange:[match rangeAtIndex:1]];
            
            SATextTapAction *hashtagtap = [[SATextTapAction alloc] init];
            hashtagtap.range = range;
            hashtagtap.attributesNormal 	 = linkHashNormal;
            hashtagtap.attributesHighlighted = linkHashHighlighted;
            hashtagtap.actionBlock = ^{
                NSLog (@"tapped %@", hashtagMatchedString);
               // [weakSelf hashtagTapped:hashtagMatchedString];
            };

            [actions addObject:hashtagtap];
			
		}
	}

//Set attributed string and tap actions to a SATextActions text view.
self.textView.attributedText = attributedStatusString;
<<<<<<< HEAD
[self.textView setTapActions:actions]; 									
=======
[self.textView setTapActions:actions]; 		

`````
>>>>>>> b7cfb112d165e114ccc584e2b2e5560619b246b0
