//
//  DHViewController.m
//  DHMathematicsGame
//
//  Created by DuetHealth on 8/2/14.
//  Copyright (c) 2014 DuetHealth. All rights reserved.
//

#import "DHViewController.h"
#import "DHUtilityMethodsProvider.h"
#import "DHCollectionViewIconCell.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define NUMBER_OF_ITEMS_IN_COLLECTION_VIEW 100
#define DEFAULT_DURATION_FOR_ANIMATION 1.0
#define DEFAULT_DURATION_FOR_REVEAL_IMAGE_ANIMATION 7.0
static NSString* cellIdentifier = @"iconCell";
#define DHOptionNotSelectedKey @"noOptipnSelected"

//Enum to maintain game state
enum gameState { initialGameState,
                 firstInstructionRead,
                 collectionCellSelected,
                 revealButtonPressed,
                 resetButtonPressd };
typedef enum gameState currentGameState;

@interface DHViewController ()
@property (strong, nonatomic) IBOutlet UICollectionView* mainCollectionView;
@property (assign, nonatomic) NSInteger fixedImageNumber;

@property (strong, nonatomic) IBOutlet UIView* instructionView;
@property (strong, nonatomic) IBOutlet UIImageView* instructionImage;
@property (strong, nonatomic) IBOutlet UILabel* instructionText;
@property (strong, nonatomic) NSMutableArray* imageSequenceStorage;
@property (strong, nonatomic) UIView* instructionsNotificationsView;

@property (assign, nonatomic) BOOL didUserSelectOption;
@property (strong, nonatomic) NSIndexPath* selectedRowInPrimaryTable;
@property (strong, nonatomic) NSIndexPath* previousSelectedRowInPrimaryTable;

@property (strong, nonatomic) UILabel* instructionLabel;
@property (strong, nonatomic) UIButton* okButton;
@property (strong, nonatomic) UIButton* wrongAnswerButton;
@property (strong, nonatomic) UIButton* resetButton;
@property (strong, nonatomic) IBOutlet UIButton* proceedButton;
@property (strong, nonatomic) UIImageView* revealationImage;
@property (assign, nonatomic) currentGameState stateOfCurrentGame;
@property (strong, nonatomic) UIView* loadingAnimationHolderView;
@property (strong, nonatomic) UIPanGestureRecognizer* panGestureRecognizer;

@property (assign, nonatomic) float initialX;
@property (assign, nonatomic) float initialY;

- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)proceedButtonPressed:(id)sender;

@end

@implementation DHViewController

- (void)viewDidLoad {
    self.stateOfCurrentGame = initialGameState;
    [super viewDidLoad];
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector (handlePanFrom:)];
    self.initialX = 600;
    self.initialY = 150;
    self.imageSequenceStorage = [[NSMutableArray alloc] initWithCapacity:100];
    [self.proceedButton addTarget:self action:@selector (proceedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self showInstructionViewWithText:@"Select any option to get started" andIsRevealingView:NO];

    [self resetParameters];

    [self showCalculationAnimationWithDuration:3.0f];
}

- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {

        self.initialX = self.instructionsNotificationsView.frame.origin.x + translation.x;
        self.initialY = self.instructionsNotificationsView.frame.origin.y + translation.y;

        //        self.initialX = translation.x + self.initialX;
        //      self.initialY = translation.y + self.initialY;
        DLog (@"Moving With X Value %f and Y Value %f", translation.x, translation.y);

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        //self.initialX = self.instructionsNotificationsView.frame.origin.x;
        //self.initialY = self.instructionsNotificationsView.frame.origin.y;

        [UIView animateWithDuration:.05 delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.instructionsNotificationsView.frame = CGRectMake (self.initialX , self.initialY, self.instructionsNotificationsView.frame.size.width, self.instructionsNotificationsView.frame.size.height);
                         }
                         completion:NULL];

        DLog (@"Movement finished With X Value %f and Y Value %f", translation.x, translation.y);
    }
}

- (void)resetParameters {

    NSInteger value = NUMBER_OF_ITEMS_IN_COLLECTION_VIEW;

    if (self.stateOfCurrentGame != initialGameState) {
        self.stateOfCurrentGame = firstInstructionRead;
    }

    self.proceedButton.alpha = 0.0;
    self.wrongAnswerButton.alpha = 0.0;
    self.revealationImage.alpha = 0.0;
    self.resetButton.alpha = 0.0;
    self.okButton.alpha = 1.0;
    self.okButton.frame = CGRectMake (10, self.instructionLabel.frame.origin.y + 330, self.instructionsNotificationsView.frame.size.width - 20, 40);
    self.didUserSelectOption = NO;
    [self.imageSequenceStorage removeAllObjects];
    while (value) {
        [self.imageSequenceStorage addObject:[NSString stringWithFormat:@"%d", [DHUtilityMethodsProvider getRandomNumber]]];
        value--;
    }

    self.previousSelectedRowInPrimaryTable = [NSIndexPath indexPathForRow:-1 inSection:0];
    self.selectedRowInPrimaryTable = [NSIndexPath indexPathForRow:-1 inSection:0];
    self.fixedImageNumber = [DHUtilityMethodsProvider getRandomNumber];

    [self configureInstructionViewWithImage:@"" andInstrcutionTitle:@"Please follow the Instructions View"];
    [self.mainCollectionView reloadData];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {

    //For each cell we will make sure cell falls in pre selected category then just make background colorful. Otherwise just keep it white

    DHCollectionViewIconCell* iconCell = [self.mainCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    if (indexPath.row == self.selectedRowInPrimaryTable.row) {
        [iconCell setBackgroundColor:[UIColor orangeColor]];
    } else {
        [iconCell setBackgroundColor:[UIColor whiteColor]];
    }

    iconCell.label.text = [NSString stringWithFormat:@"%d", indexPath.row];

    if (!iconCell.isImageAssigned) {
        if ([self isNumberDivisibleBy9WithInputNumber:indexPath.row]) {

            [iconCell.image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", self.fixedImageNumber]]];
        } else {

            [iconCell.image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imageSequenceStorage[indexPath.row]]]];
        }
    }

    return iconCell;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {

    return NUMBER_OF_ITEMS_IN_COLLECTION_VIEW;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {

    if (self.stateOfCurrentGame == firstInstructionRead) {

        if (!self.didUserSelectOption) {
            //            [self configureInstructionViewWithImage:@"" andInstrcutionTitle:@"Now Reverse the number and then substract original number from the value of reveresed number"];

            //Update selection indicator for primary table
            self.didUserSelectOption = YES;

            [UIView transitionWithView:nil
                              duration:DEFAULT_DURATION_FOR_ANIMATION
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                        self.proceedButton.alpha=0.8;
                            }
                            completion:NULL];
        }

        self.previousSelectedRowInPrimaryTable = self.selectedRowInPrimaryTable;
        self.selectedRowInPrimaryTable = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];

        if (self.previousSelectedRowInPrimaryTable.row != -1 && self.previousSelectedRowInPrimaryTable.row != self.selectedRowInPrimaryTable.row) {

            [self.mainCollectionView reloadItemsAtIndexPaths:@[ self.selectedRowInPrimaryTable, self.previousSelectedRowInPrimaryTable ]];
        } else {
            [self.mainCollectionView reloadItemsAtIndexPaths:@[ self.selectedRowInPrimaryTable ]];
        }
    } else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

//Source : http://www.geeksforgeeks.org/divisibility-9-using-bitwise-operators/

- (BOOL)isNumberDivisibleBy9WithInputNumber:(NSInteger)inputNumber {
    // Base cases
    if (inputNumber == 0 || inputNumber == 9)
        return true;
    if (inputNumber < 9)
        return false;

    // If n is greater than 9, then recur for [floor(n/9) - n%8]
    return [self isNumberDivisibleBy9WithInputNumber:((int)(inputNumber >> 3) - (int)(inputNumber & 7))];
}

- (void)configureInstructionViewWithImage:(NSString*)imageName andInstrcutionTitle:(NSString*)instructionText {
    self.instructionText.text = instructionText;
}

- (IBAction)resetButtonPressed:(id)sender {
    [self resetParameters];

    [UIView transitionWithView:nil
                      duration:DEFAULT_DURATION_FOR_ANIMATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        [self hideInstructionView];
                    }
                    completion:NULL];
}

- (IBAction)proceedButtonPressed:(id)sender {

    if (self.didUserSelectOption) {

        self.instructionLabel.text = @"Now Reverse the number and then substract original number from the value of reveresed number. After that, press reveal button to reveal image adjacent to that number on screen";
        [self.okButton setTitle:@"Reveal" forState:UIControlStateNormal];

        [self.okButton addTarget:self action:@selector (revealSelectedOption:) forControlEvents:UIControlEventTouchUpInside];

        [UIView transitionWithView:nil
                          duration:DEFAULT_DURATION_FOR_ANIMATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self showInstructionView];
                        }
                        completion:NULL];

    } else {
        UIAlertView* alertForNoOptionSelection = [[UIAlertView alloc] initWithTitle:@"No Option selected" message:@"Please select an option to reveal predication" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

        [alertForNoOptionSelection show];
    }
}

- (void)showInstructionViewWithText:(NSString*)text andIsRevealingView:(BOOL)isRevealingView {

    if (!self.instructionsNotificationsView) {
        self.instructionsNotificationsView = [[UIView alloc] initWithFrame:CGRectMake (600, 150, 450, 450)];
        [self.instructionsNotificationsView addGestureRecognizer:self.panGestureRecognizer];
    }
    //    self.revealView.center = self.mainCollectionView.center;

    [self.instructionsNotificationsView setBackgroundColor:[UIColor grayColor]];

    UIFont* defaultFontForInstructionviews = [UIFont fontWithName:@"HelveticaNeue-Light" size:24.0f];

    if (!self.instructionLabel) {
        self.instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake (10, 10, self.instructionsNotificationsView.frame.size.width - 20, 300)];
        [self.instructionsNotificationsView addSubview:self.instructionLabel];
    }

    self.instructionLabel.backgroundColor = [UIColor grayColor];
    self.instructionLabel.numberOfLines = 8;
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.font = defaultFontForInstructionviews;
    self.instructionLabel.text = text;

    [self addCircularCornerToView:self.instructionLabel WithRadius:30.0f];

    if (isRevealingView) {

        self.loadingAnimationHolderView.alpha = 1.0;
        if (!self.revealationImage) {
            self.revealationImage = [[UIImageView alloc] initWithFrame:CGRectMake (self.instructionsNotificationsView.frame.size.width / 2 + 150, 225, 96, 96)];
        }

        [self.revealationImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", self.fixedImageNumber]]];
        self.revealationImage.alpha = 0.0;

        [self.instructionsNotificationsView addSubview:self.revealationImage];
        self.okButton = [[UIButton alloc] initWithFrame:CGRectMake (30, self.instructionLabel.frame.origin.y + 300, 100, 40)];

        if (!self.wrongAnswerButton) {
            self.wrongAnswerButton = [[UIButton alloc] initWithFrame:CGRectMake (90 + self.okButton.frame.size.width, self.instructionLabel.frame.origin.y + 250, 200, 40)];
        }

        [self.wrongAnswerButton setTitle:@"Wrong Answer" forState:UIControlStateNormal];
        self.wrongAnswerButton.alpha = 1.0;
        [self.wrongAnswerButton.titleLabel setFont:defaultFontForInstructionviews];
        [self.wrongAnswerButton addTarget:self action:@selector (userSaidWrongAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.instructionsNotificationsView addSubview:self.wrongAnswerButton];

        if (!self.resetButton) {
            self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake (self.okButton.frame.size.width, self.instructionLabel.frame.origin.y + 250, 100, 40)];
        }

        [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self.resetButton.titleLabel setFont:defaultFontForInstructionviews];
        [self.resetButton addTarget:self action:@selector (resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.instructionsNotificationsView addSubview:self.resetButton];
        self.instructionsNotificationsView.frame = CGRectMake (self.mainCollectionView.center.x - 200, 150, 450, 450);
        self.instructionLabel.frame = CGRectMake (10, 10, self.instructionsNotificationsView.frame.size.width - 20, 300);

        [UIView transitionWithView:nil
                          duration:DEFAULT_DURATION_FOR_REVEAL_IMAGE_ANIMATION
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                                                    self.loadingAnimationHolderView.alpha = 0.0;
                                self.revealationImage.alpha = 1.0;
                        }
                        completion:NULL];

    } else {
        self.okButton = [[UIButton alloc] initWithFrame:CGRectMake (10, self.instructionLabel.frame.origin.y + 330, self.instructionsNotificationsView.frame.size.width - 20, 40)];
        [self.okButton setTitle:@"Ok" forState:UIControlStateNormal];
        [self.okButton addTarget:self action:@selector (okButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    //Ok Button
    //Button with okay or got it text on it.

    [self.okButton.titleLabel setFont:defaultFontForInstructionviews];

    [self.instructionsNotificationsView addSubview:self.okButton];

    //Circular round border to view
    [self addCircularCornerToView:self.instructionsNotificationsView WithRadius:30.0f];

    //Border to View
    [self addBorderDesignToView:self.instructionsNotificationsView andColor:[UIColor lightGrayColor] andBorderWidth:1.5f];

    // drop shadow
    [self addShadowToView:self.instructionsNotificationsView withColor:[UIColor blackColor] andOpacity:0.8 andRadius:3.0f andOffset:CGSizeMake (2.0f, 2.0f)];

    [self.view addSubview:self.instructionsNotificationsView];

    [UIView transitionWithView:nil
                      duration:DEFAULT_DURATION_FOR_ANIMATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.instructionsNotificationsView.alpha=0.9;
                    }
                    completion:NULL];
}

- (IBAction)userSaidWrongAnswer:(UIButton*)sender {
    [self performSelector:@selector (resetButtonPressed:) withObject:sender];
}

- (void)addCircularCornerToView:(UIView*)inputView WithRadius:(float)borderRadius {
    [inputView.layer setCornerRadius:borderRadius];
}

- (void)addBorderDesignToView:(UIView*)inputView andColor:(UIColor*)inputColor andBorderWidth:(float)borderWidth {
    [self.instructionsNotificationsView.layer setBorderColor:inputColor.CGColor];
    [self.instructionsNotificationsView.layer setBorderWidth:borderWidth];
}

- (void)addShadowToView:(UIView*)inputView withColor:(UIColor*)shadowColor andOpacity:(float)shadowOpacity andRadius:(float)shadowRadius andOffset:(CGSize)shadowOffset {
    [self.instructionsNotificationsView.layer setShadowColor:shadowColor.CGColor];
    [self.instructionsNotificationsView.layer setShadowOpacity:shadowOpacity];
    [self.instructionsNotificationsView.layer setShadowRadius:shadowRadius];
    [self.instructionsNotificationsView.layer setShadowOffset:shadowOffset];
}

- (IBAction)okButtonPressed:(id)sender {
    self.stateOfCurrentGame = firstInstructionRead;

    [UIView transitionWithView:nil
                      duration:DEFAULT_DURATION_FOR_ANIMATION
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{

                        [self hideInstructionView];
                    }
                    completion:NULL];
}

- (IBAction)revealSelectedOption:(id)sender {

    self.okButton.alpha = 0.0;
    [self showInstructionViewWithText:@"Image corresponding to your answer is" andIsRevealingView:YES];
}

- (void)showCalculationAnimationWithDuration:(float)waitingAnimationDuration {
    __block float positionToGo = 200;
    __block float triangleSideLength = 200;
    __block float triangleHeight = 300.0f;
    __block float initialYPositionOfAnimationBalls = 0;

    if (!self.loadingAnimationHolderView) {
        self.loadingAnimationHolderView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, 400, 450)];
    }

    self.loadingAnimationHolderView.alpha = 0.0;
    [self.loadingAnimationHolderView setBackgroundColor:[UIColor whiteColor]];

    UIImageView* greenLoadingCircle = [[UIImageView alloc] initWithFrame:CGRectMake (positionToGo, initialYPositionOfAnimationBalls, 48, 48)];
    [greenLoadingCircle setImage:[UIImage imageNamed:@"circle1.jpeg"]];
    [self.loadingAnimationHolderView addSubview:greenLoadingCircle];
    //Green

    UIImageView* redLoadingCircle = [[UIImageView alloc] initWithFrame:CGRectMake (positionToGo - triangleSideLength, initialYPositionOfAnimationBalls + triangleHeight, 48, 48)];
    [redLoadingCircle setImage:[UIImage imageNamed:@"circle2.jpeg"]];
    //RED
    [self.loadingAnimationHolderView addSubview:redLoadingCircle];

    UILabel* loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake (140, 200, 170, 60)];
    loadingLabel.font = [UIFont boldSystemFontOfSize:20];
    loadingLabel.numberOfLines = 3;
    loadingLabel.text = @"Calculating your chosen Number..";
    loadingLabel.alpha = 1.0f;

    UILabel* secondLoadingLabel = [[UILabel alloc] initWithFrame:CGRectMake (150, 200, 150, 60)];
    secondLoadingLabel.font = [UIFont boldSystemFontOfSize:20];
    secondLoadingLabel.numberOfLines = 3;
    secondLoadingLabel.text = @"Almost There..";
    secondLoadingLabel.alpha = 0.0f;

    UILabel* randomNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake (200, 270, 40, 40)];
    randomNumberLabel.font = [UIFont boldSystemFontOfSize:20];

    randomNumberLabel.text = @"0";
    randomNumberLabel.alpha = 1.0f;

    [NSTimer scheduledTimerWithTimeInterval:0.15
                                     target:self
                                   selector:@selector (showNumbers:)
                                   userInfo:@{ @"numberLabel" : randomNumberLabel }
                                    repeats:YES];

    UIImageView* blueLoadingCircle = [[UIImageView alloc] initWithFrame:CGRectMake (positionToGo + triangleSideLength, initialYPositionOfAnimationBalls + triangleHeight, 48, 48)];
    [blueLoadingCircle setImage:[UIImage imageNamed:@"circle3.jpeg"]];
    [self.loadingAnimationHolderView addSubview:blueLoadingCircle];

    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{

                        greenLoadingCircle.frame=CGRectMake(positionToGo-triangleSideLength, initialYPositionOfAnimationBalls+triangleHeight, 48, 48);
                        redLoadingCircle.frame=CGRectMake(positionToGo+triangleSideLength,initialYPositionOfAnimationBalls+triangleHeight, 48, 48);
                        blueLoadingCircle.frame=CGRectMake(positionToGo, initialYPositionOfAnimationBalls, 48, 48);
            
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{

            greenLoadingCircle.frame=CGRectMake(positionToGo+triangleSideLength, initialYPositionOfAnimationBalls+triangleHeight, 48, 48);
            redLoadingCircle.frame=CGRectMake(positionToGo, initialYPositionOfAnimationBalls, 48, 48);
            blueLoadingCircle.frame=CGRectMake(positionToGo-triangleSideLength, initialYPositionOfAnimationBalls+triangleHeight, 48, 48);
            
        }];
    } completion:nil];

    [UIView animateKeyframesWithDuration:3.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            
          
            loadingLabel.alpha=0.0;
            secondLoadingLabel.alpha=1.0;
            
        }];
        [UIView addKeyframeWithRelativeStartTime:4.0 relativeDuration:0.5 animations:^{
            
          
            loadingLabel.alpha=1.0;
            secondLoadingLabel.alpha=0.0;
        }];
    } completion:nil];

    [self.loadingAnimationHolderView addSubview:loadingLabel];
    [self.loadingAnimationHolderView addSubview:secondLoadingLabel];
    [self.loadingAnimationHolderView addSubview:randomNumberLabel];
    [self.instructionsNotificationsView addSubview:self.loadingAnimationHolderView];
    [self.instructionsNotificationsView bringSubviewToFront:self.loadingAnimationHolderView];
}

- (void)showNumbers:(NSTimer*)timer {

    NSDictionary* dictionaryWithLabel = [timer userInfo];
    UILabel* randomNumberLabel = dictionaryWithLabel[@"numberLabel"];
    randomNumberLabel.text = [NSString stringWithFormat:@"%d", arc4random () % 100];
}

- (void)hideInstructionView {
    self.instructionsNotificationsView.frame = CGRectMake (0, 134, 0, 0);
    self.instructionLabel.frame = self.instructionsNotificationsView.frame;
    self.okButton.frame = CGRectMake (self.instructionsNotificationsView.frame.origin.x, self.instructionsNotificationsView.frame.origin.y, 0, 0);
}

- (void)showInstructionView {
    self.instructionsNotificationsView.frame = CGRectMake (self.mainCollectionView.center.x - 200, 150, 400, 450);
    self.instructionLabel.frame = CGRectMake (10, 10, self.instructionsNotificationsView.frame.size.width - 20, 300);
    self.okButton.frame = CGRectMake (150, 300, 100, 50);
}

- (void)addGestureRecognizerToInstructionsView {

    // UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.instructionsNotificationsView action:@selector (handlePan:)];
    //[self.instructionsNotificationsView addGestureRecognizer:recognizer];
}
/*
- (IBAction)handlePan:(UIPanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:self.instructionsNotificationsView];

    recognizer.view.center = CGPointMake (recognizer.view.center.x + translation.x,
                                          recognizer.view.center.y + translation.y);

    if (recognizer.state == UIGestureRecognizerStateEnded) {

        // Check here for the position of the view when the user stops touching the screen

        // Set "CGFloat finalX" and "CGFloat finalY", depending on the last position of the touch

        // Use this to animate the position of your view to where you want
        [UIView animateWithDuration:2.0f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGPoint finalPoint = CGPointMake(finalX, finalY);
                             recognizer.view.center = finalPoint; }
                         completion:nil];
    }

    [recognizer setTranslation:CGPointMake (0, 0) inView:self.instructionsNotificationsView];
}*/
@end