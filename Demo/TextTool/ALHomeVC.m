//
//  ALHomeVC.m
//  TextTool
//
//  Created by Sash on 12/24/13.
//  Copyright (c) 2013 Alex Lavrinenko. All rights reserved.
//

#import "ALHomeVC.h"
#import "SATextActions.h"

@interface ALHomeVC () <UITextViewDelegate>
{
    
}
@property (strong,nonatomic) UITextView *tv;
@property (strong, nonatomic) NSLayoutConstraint *tvPosition;
@end

@implementation ALHomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Create Text View
    self.tv = [[UITextView alloc] initWithFrame:CGRectZero];
    self.tv.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tv.contentInset = UIEdgeInsetsZero;
    self.tv.alwaysBounceVertical = YES;
    self.tv.scrollEnabled = YES;
    self.tv.delegate = self;
    [self.view addSubview:_tv];
    
    
    //Position Text View
    
    
    [self.tv setTranslatesAutoresizingMaskIntoConstraints: NO];
    id topGuide = self.topLayoutGuide;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings (_tv,topGuide);
    
    //Top Spacing below status bar
    [self.view addConstraints:
    [NSLayoutConstraint constraintsWithVisualFormat: @"V:[topGuide][_tv]"
                                             options: 0
                                             metrics: nil
                                               views: viewsDictionary] ];
    //Full Width
    [self.view addConstraints:
    [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[_tv]|"
                                             options: 0
                                             metrics: nil
                                               views: viewsDictionary] ];
    
    //Bottom spacing with adjustable constant
    self.tvPosition = [NSLayoutConstraint constraintWithItem: _tv
                                                   attribute: NSLayoutAttributeBottom
                                                   relatedBy: NSLayoutRelationEqual
                                                      toItem: self.view
                                                   attribute: NSLayoutAttributeBottom
                                                  multiplier: 1
                                                    constant: 0];
    [self.view addConstraint:self.tvPosition];
    
    
    [self registerForKeyboardNotifications];
}
- (void) viewDidLayoutSubviews {
  //  CGRect viewBounds = self.view.bounds;
    // CGFloat topBarOffset = self.topLayoutGuide.length;
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard Notifications
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    

    
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    self.tvPosition.constant = -kbSize.height;

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.tvPosition.constant = 0;
}

#pragma mark Text View Delegate
- (void)textViewDidChange:(UITextView *)textView
{
    // Fix i0S7 text view scroll issue for new line
    // http://stackoverflow.com/a/19277383/114446
    
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

@end
