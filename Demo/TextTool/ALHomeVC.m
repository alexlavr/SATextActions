//
//  ALHomeVC.m
//  TextTool
//
//  Created by Sash on 12/24/13.
//  Copyright (c) 2013 Alex Lavrinenko. All rights reserved.
//

#import "ALHomeVC.h"
//import "SATextActions.h"
#import "ALTextStorage.h"
#import "ALTextViewEditable.h"
#import "ALPickerListVC.h"

@interface ALHomeVC () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    float _pickerHeight;            // height of the table that displays list of user picks
    NSRange _pickerPositionInText;  // position in text where the pick should be placed
}
@property (strong, nonatomic) ALTextViewEditable *tv;
@property (strong, nonatomic) NSLayoutConstraint *tvPosition;
@property (strong, nonatomic) NSArray *dataUsers;
@property (strong, nonatomic) UITableView *pickerTable;
@property (strong, nonatomic) NSDictionary *textStyle;

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

    _pickerHeight = 100.0;
    
    //Database
    self.dataUsers = @[
                       @{@"id":@"1", @"n":@"Bob"},
                       @{@"id":@"2", @"n":@"Tom"},
                       @{@"id":@"3", @"n":@"Dog"}
                       ];

    //TextKit
    NSParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    self.textStyle = @{
                                NSParagraphStyleAttributeName: paragraphStyle,
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]
                                };
    
    NSDictionary *linkStyle = @{
                                NSForegroundColorAttributeName : [UIColor blackColor],
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]
                                };
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeMake(320, CGFLOAT_MAX)];
    container.widthTracksTextView = YES;
    [layoutManager addTextContainer:container];

    ALTextStorage *textStorage = [[ALTextStorage alloc] initWithStyle:_textStyle];
    [textStorage addLayoutManager:layoutManager];
    
    //Create Text View
    self.tv = [[ALTextViewEditable alloc] initWithFrame:CGRectZero textContainer:container];
    //_tv.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tv.delegate = self;
    _tv.linkTextAttributes = linkStyle;
    _tv.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_tv];
    
    
    //Position Text View using AutoLayout
    
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
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self registerForKeyboardNotifications];
}
- (void) viewDidLayoutSubviews {
  //  CGRect viewBounds = self.view.bounds;
    // CGFloat topBarOffset = self.topLayoutGuide.length;
    
    //NSLog(@"%@", self.tv);
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
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //Do not allow to edit link
    // It can be only selected to be removed
    for (NSUInteger c = range.location; c<= range.location+range.length; c++)
    {
        if (c >= textView.attributedText.length) break;
        NSRange linkRange = [self.tv rangeForLinkAtIndex:c];
        if (linkRange.location != NSNotFound)
        {
                
            if (self.tv.selectedRange.location == linkRange.location && self.tv.selectedRange.length == linkRange.length && [text isEqualToString:@""]) {
                return YES;
            } else {
                self.tv.selectedRange = linkRange;
                return NO;
            }
        }
    }
    
    
    //Check if user is getting mentioned
    if ([text isEqualToString:@"@"])
    {
        
        _pickerPositionInText = (NSRange){range.location, 1};
        [self updateMentionPicker];
    }
    
    return YES;
}

- (void) updateMentionPicker
{
    
    self.tvPosition.constant += _pickerHeight;
    [self.view addSubview:self.pickerTable];
    
}
- (void) pickerSelected: (NSDictionary *) userData
{
    
    //Add Link text to @ position
    NSString *userName = userData[@"n"];
    NSDictionary *linkData = @{NSLinkAttributeName:[NSString stringWithFormat:@"appID://user/%@", userData[@"id"]]};
    
    NSMutableAttributedString *pickedText = [[NSMutableAttributedString alloc] initWithString:userName];
    [pickedText setAttributes:linkData range:(NSRange){0, [userData[@"n"] length]}];
    
    NSMutableAttributedString *textCurrent = [self.tv.attributedText mutableCopy];
    [textCurrent replaceCharactersInRange:_pickerPositionInText withAttributedString:pickedText];
    
    //Add space after link
    NSAttributedString *space  = [[NSAttributedString alloc] initWithString:@" " attributes:self.textStyle];
    [textCurrent appendAttributedString:space];
    
    self.tv.attributedText = textCurrent;
    
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
     NSLog(@"%@", URL);
    if ([[URL scheme] isEqualToString:@"username"]) {
       
        // ...
        return NO;
    }
    return YES; // let the system open this URL
}
// Finding the word under a touch
/*- (void) getWordAt: (CGPoint) location
{
    NSLayoutManager *layoutManager = _tv.layoutManager;
    CGPoint location = [touch locationInView:_tv];
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:_tv.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    if (characterIndex < _tv.textStorage.length)
    {
        // valid index
        // Find the word range here
        // using -enumerateSubstringsInRange:options:usingBlock:
    }
}*/

#pragma mark Picker Table
- (UITableView* ) pickerTable
{
    if (!_pickerTable) {
        
        //Position picker at the bottom, above keyboard
        //float pickerHeight = 220.0;
        float pickerWidth  = CGRectGetMaxX(self.tv.frame);
        float pickerBottom = CGRectGetMaxY(self.tv.frame);
        float pickerTop    = pickerBottom - _pickerHeight;
        
        CGRect pickerPosition = (CGRect){0, pickerTop, pickerWidth, _pickerHeight};
        
        UITableView *table = [[UITableView alloc] initWithFrame:pickerPosition style:UITableViewStylePlain];
        table.dataSource = self;
        table.delegate   = self;

        _pickerTable = table;
    }
    return _pickerTable;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    // Configure the cell...
    NSDictionary *userData = self.dataUsers[indexPath.row];
    cell.textLabel.text = userData[@"n"];
    
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@", indexPath);
    
    [self pickerSelected:self.dataUsers[indexPath.row]];
}



@end
