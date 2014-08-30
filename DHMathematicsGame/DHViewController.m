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
#import "DHColorDefaults.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define NUMBER_OF_ITEMS_IN_COLLECTION_VIEW 100
#define DEFAULT_DURATION_FOR_ANIMATION 2.0
#define DEFAULT_DURATION_FOR_HIDE_SHOW_ANIMATION 2
#define DEFAULT_DURATION_FOR_REVEAL_IMAGE_ANIMATION 7.0
static NSString* cellIdentifier = @"iconCell";
#define DHOptionNotSelectedKey @"noOptipnSelected"

//Enum to maintain game state
enum gameState {
            initialGameState,
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
@property (strong,nonatomic) UILabel* dragToMoveLabel;

@property (strong,nonatomic) UIAlertView* generalAlertView;
@property (assign, nonatomic) float initialX;
@property (assign, nonatomic) float initialY;

- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)proceedButtonPressed:(id)sender;

@end

@implementation DHViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self initalizeAllView];

    self.stateOfCurrentGame = initialGameState;
    
    
    self.initialX = 600;
    self.initialY = 150;
    
    [self resetParameters];

    
}

-(void)initalizeAllView{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector (handlePanFrom:)];
    self.imageSequenceStorage = [[NSMutableArray alloc] initWithCapacity:100];
    
    self.instructionsNotificationsView = [[UIView alloc] initWithFrame:CGRectMake (self.view.center.x-113, self.view.center.y-275, 450, 450)];
    [self.instructionsNotificationsView addGestureRecognizer:self.panGestureRecognizer];
    self.generalAlertView=[[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    self.instructionLabel = [[UILabel alloc] initWithFrame:CGRectMake (10, 10, self.instructionsNotificationsView.frame.size.width - 20, 300)];
    
    
    
    
    
    [self.instructionsNotificationsView addSubview:self.instructionLabel];
    self.dragToMoveLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 450, 30)];
    self.dragToMoveLabel.font=[DHColorDefaults getDefaultInstructionViewFontWithSize:24];
    self.dragToMoveLabel.text=@"Drag To Move";
    [self.instructionsNotificationsView addSubview:self.dragToMoveLabel];
    
                self.revealationImage = [[UIImageView alloc] initWithFrame:                                        CGRectMake ((self.instructionsNotificationsView.frame.size.width/2)-48, 225, 96, 96)];
                                        [self.instructionsNotificationsView addSubview:self.revealationImage];
            self.okButton = [[UIButton alloc] initWithFrame:CGRectMake (30, self.instructionLabel.frame.origin.y + 300, 100, 60)];
    
    [self addBorderDesignToView:self.revealationImage andColor:[DHColorDefaults getLightGreenColor] andBorderWidth:2.0f];
    [self.okButton setBackgroundColor:[DHColorDefaults getLightOrangeColor]];
    
    
    [self.proceedButton addTarget:self action:@selector (proceedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self showInstructionViewWithText:@"Select any option to get started" andIsRevealingView:NO];

    
    [self showCalculationAnimationWithDuration:3.0f];
    [self setupResetButton];
    [self setupWrongAnswerButton];
    
}

-(void)setupResetButton{
    
    
    
                self.resetButton = [[UIButton alloc] initWithFrame:CGRectMake (20, self.instructionLabel.frame.origin.y + 350, 150, 60)];
    self.resetButton.alpha=0.0;
    [self.resetButton setBackgroundColor:[DHColorDefaults getLightOrangeColor]];
    
    [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [self.resetButton.titleLabel setFont:[DHColorDefaults getDefaultInstructionViewFontWithSize:24.0f]];
    [self.resetButton addTarget:self action:@selector (resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.instructionsNotificationsView addSubview:self.resetButton];
}

-(void)setupWrongAnswerButton{
     self.wrongAnswerButton = [[UIButton alloc] initWithFrame:CGRectMake (220, self.instructionLabel.frame.origin.y + 350, 200, 60)];
    self.wrongAnswerButton.alpha=0.0;
    [self.wrongAnswerButton setBackgroundColor:[DHColorDefaults getLightOrangeColor]];
    [self.wrongAnswerButton setTitle:@"Wrong Answer" forState:UIControlStateNormal];
    [self.wrongAnswerButton.titleLabel setFont:[DHColorDefaults getDefaultInstructionViewFontWithSize:24.0f]];
    [self.wrongAnswerButton addTarget:self action:@selector (userSaidWrongAnswer:) forControlEvents:UIControlEventTouchUpInside];
    [self.instructionsNotificationsView addSubview:self.wrongAnswerButton];
    
}

- (void)handlePanFrom:(UIPanGestureRecognizer*)recognizer {

    CGPoint translation = [recognizer translationInView:recognizer.view];

    if (recognizer.state == UIGestureRecognizerStateBegan) {

    } else if (recognizer.state == UIGestureRecognizerStateChanged) {

      //Current way
        self.initialX = self.instructionsNotificationsView.frame.origin.x + translation.x;
        self.initialY = self.instructionsNotificationsView.frame.origin.y + translation.y;

        //Alternate way to make movement immediately on drag
//        self.instructionsNotificationsView.frame = CGRectMake (self.initialX+ translation.x , self.initialY+translation.y, self.instructionsNotificationsView.frame.size.width, self.instructionsNotificationsView.frame.size.height);
        
        
        
        DLog (@"Moving With X Value %f and Y Value %f", self.initialX, self.initialY);

    } else if (recognizer.state == UIGestureRecognizerStateEnded) {


        [UIView animateWithDuration:DEFAULT_DURATION_FOR_ANIMATION delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
                             //Current way
                             self.instructionsNotificationsView.frame = CGRectMake (self.initialX , self.initialY, self.instructionsNotificationsView.frame.size.width, self.instructionsNotificationsView.frame.size.height);
                             
                             //Alternative way
                             //Comment out above line of code
                             
                         }
                         completion:NULL];

        DLog (@"Movement finished With X Value %f and Y Value %f", translation.x, translation.y);
    }
}

- (void)resetParameters {

    NSInteger numberOfTotalImagesOnCollectionView = NUMBER_OF_ITEMS_IN_COLLECTION_VIEW;

    if (self.stateOfCurrentGame != initialGameState) {
        self.stateOfCurrentGame = firstInstructionRead;
    }

    self.proceedButton.alpha = 0.0;
    self.wrongAnswerButton.alpha = 0.0;
    self.revealationImage.alpha = 0.0;
    self.resetButton.alpha = 0.0;
    self.okButton.alpha = 1.0;
    self.okButton.frame = CGRectMake (10, self.instructionLabel.frame.origin.y + 330, self.instructionsNotificationsView.frame.size.width - 20, 60);
    self.didUserSelectOption = NO;
    [self.imageSequenceStorage removeAllObjects];
    
    //Total number of images to display on the screen

    while (numberOfTotalImagesOnCollectionView) {
        [self.imageSequenceStorage addObject:[NSString stringWithFormat:@"%d", [DHUtilityMethodsProvider getRandomNumber]]];
        numberOfTotalImagesOnCollectionView--;
    }

    //Initializing index paths
    self.previousSelectedRowInPrimaryTable = [NSIndexPath indexPathForRow:-1 inSection:0];
    self.selectedRowInPrimaryTable = [NSIndexPath indexPathForRow:-1 inSection:0];
    //Decide, which image to show up when revealed - Gets reset each time and is selected randomely
    self.fixedImageNumber = [DHUtilityMethodsProvider getRandomNumber];

    [self configureInstructionViewWithImage:@"" andInstrcutionTitle:@"Please follow the Instructions View"];
    [self.mainCollectionView reloadData];
}

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {

    //For each cell we will make sure cell falls in pre selected category then just make background colorful. Otherwise just keep it white

    DHCollectionViewIconCell* iconCell = [self.mainCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    if (indexPath.row == self.selectedRowInPrimaryTable.row) {
        [iconCell setBackgroundColor:[DHColorDefaults getLightOrangeColor]];
    } else {
        [iconCell setBackgroundColor:[UIColor whiteColor]];
    }

    iconCell.label.text = [NSString stringWithFormat:@"%d", indexPath.row];


        if ([self isNumberDivisibleBy9WithInputNumber:indexPath.row]) {

            [iconCell.image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", self.fixedImageNumber]]];
        } else {

            [iconCell.image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imageSequenceStorage[indexPath.row]]]];
        }


    return iconCell;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {

    return NUMBER_OF_ITEMS_IN_COLLECTION_VIEW;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath*)indexPath {

    if(self.stateOfCurrentGame==revealButtonPressed){
        return;
    }
    
    if (self.stateOfCurrentGame == firstInstructionRead) {

        self.stateOfCurrentGame=collectionCellSelected;
        
        if (!self.didUserSelectOption) {
            

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
    }
    
    else {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

//Source : http://www.geeksforgeeks.org/divisibility-9-using-bitwise-operators/

- (BOOL)isNumberDivisibleBy9WithInputNumber:(NSInteger)inputNumber {
    
    // Base cases
    if (inputNumber == 0 || inputNumber == 9){
        return true;
    }
    if (inputNumber < 9){
        return false;
    }

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


        [self showGeneralAlertViewWithTitle:@"No Option selected" andMessage:@"Please select an option to reveal predication"];
    }
}

-(void)showGeneralAlertViewWithTitle:(NSString*)alertTitle andMessage:(NSString*)message{
    [self.generalAlertView setTitle:alertTitle];
    [self.generalAlertView setMessage:message];
    [self.generalAlertView show];
}

- (void)showInstructionViewWithText:(NSString*)text andIsRevealingView:(BOOL)isRevealingView {


    [self.instructionsNotificationsView setBackgroundColor:[DHColorDefaults getLightVioletColor]];




    self.instructionLabel.backgroundColor = self.instructionsNotificationsView.backgroundColor;
    self.instructionLabel.numberOfLines = 8;
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.font = [DHColorDefaults getDefaultInstructionViewFontWithSize:24.0f];
    self.instructionLabel.text = text;

    [self addCircularCornerToView:self.instructionLabel WithRadius:30.0f];

    if (isRevealingView) {

        self.loadingAnimationHolderView.alpha = 1.0;


        [self.revealationImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", self.fixedImageNumber]]];
        self.revealationImage.alpha = 0.0;

        [self.instructionsNotificationsView addSubview:self.revealationImage];





        self.wrongAnswerButton.alpha = 1.0;
        self.resetButton.alpha=1.0;
       
       
        
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
        self.okButton.frame = CGRectMake (10, self.instructionLabel.frame.origin.y + 330, self.instructionsNotificationsView.frame.size.width - 20, 60);
        [self.okButton setTitle:@"Ok" forState:UIControlStateNormal];
        [self.okButton addTarget:self action:@selector (okButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    //Ok Button
    //Button with okay or got it text on it.

    [self.okButton.titleLabel setFont:[DHColorDefaults getDefaultInstructionViewFontWithSize:24.0f]];

    [self.instructionsNotificationsView addSubview:self.okButton];

    //Circular round border to view
    [self addCircularCornerToView:self.instructionsNotificationsView WithRadius:30.0f];

    //Border to View
    [self addBorderDesignToView:self.instructionsNotificationsView andColor:[DHColorDefaults getLightVioletColor] andBorderWidth:2.0f];

    // drop shadow
    [self addShadowToView:self.instructionsNotificationsView withColor:[DHColorDefaults getLightVioletColor] andOpacity:1.0 andRadius:3.0f andOffset:CGSizeMake (3.0f, 3.0f)];

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
    [self showGeneralAlertViewWithTitle:@"Cheater" andMessage:@"You are lying or are really bad at basic mathematical operators. Image revealed by algorithm is indeed the image you evaluated. Please be careful next time and again check for correctness"];
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
    self.stateOfCurrentGame=revealButtonPressed;
    [self showInstructionView];
    self.okButton.alpha = 0.0;
    [self showInstructionViewWithText:@"Image corresponding to your answer is" andIsRevealingView:YES];
}

- (void)showCalculationAnimationWithDuration:(float)waitingAnimationDuration {
    __block float positionToGo = 200;
    __block float triangleSideLength = 200;
    __block float triangleHeight = 300.0f;
    __block float initialYPositionOfAnimationBalls = 0;
    
    
    self.loadingAnimationHolderView = [[UIView alloc] initWithFrame:CGRectMake (0, 0, 450, 450)];
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
        [self addCircularCornerToView:self.loadingAnimationHolderView WithRadius:30.0f];
    [self.instructionsNotificationsView addSubview:self.loadingAnimationHolderView];
    [self.instructionsNotificationsView bringSubviewToFront:self.loadingAnimationHolderView];
}

- (void)showNumbers:(NSTimer*)timer {

    NSDictionary* dictionaryWithLabel = [timer userInfo];
    UILabel* randomNumberLabel = dictionaryWithLabel[@"numberLabel"];
    randomNumberLabel.text = [NSString stringWithFormat:@"%d", arc4random () % 100];
}

- (void)hideInstructionView {
    
    

    
    self.instructionsNotificationsView.transform = CGAffineTransformMakeScale(1, 1);
        self.instructionLabel.transform = CGAffineTransformMakeScale(1, 1);
        self.okButton.transform = CGAffineTransformMakeScale(1, 1);
    

    [UIView animateWithDuration:DEFAULT_DURATION_FOR_ANIMATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
     
                     animations:^(){
                         self.instructionsNotificationsView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         //self.instructionsNotificationsView.center = self.view.center;
                         self.instructionLabel.transform = CGAffineTransformMakeScale(0.0, 0.0);
                        // self.instructionLabel.center = self.view.center;
                         self.okButton.transform = CGAffineTransformMakeScale(0.0, 0.0);
                         //self.okButton.center = self.view.center;
                     }
                     completion:nil];
    
}

- (void)showInstructionView {

    
    self.instructionsNotificationsView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.instructionLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.okButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    
    [UIView animateWithDuration:DEFAULT_DURATION_FOR_HIDE_SHOW_ANIMATION
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
     
                     animations:^(){
                         self.instructionsNotificationsView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         //self.instructionsNotificationsView.center = self.view.center;
                         self.instructionLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         // self.instructionLabel.center = self.view.center;
                         self.okButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         //self.okButton.center = self.view.center;
                     }
                     completion:nil];
    
}
@end
