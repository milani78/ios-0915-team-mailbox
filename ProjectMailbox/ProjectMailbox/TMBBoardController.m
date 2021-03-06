
//
//  RWTCollectionViewController.m
//  RWPinterest
//
//  Created by Joel Bell on 11/23/15.
//  Copyright © 2015 Joel Bell. All rights reserved.
//

#import "TMBBoardController.h"
#import "TMBBoardCell.h"
#import "Parse/Parse.h"
#import "TMBImageCardViewController.h"
#import "TMBSharedBoardID.h"
#import "TMBDoodleViewController.h"

//#import "TMBSharedBoard.h" joel copy over - singleton not set up

// drawer controller
#import <MMDrawerController/MMDrawerVisualState.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>
#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>

static NSInteger const kNumberOfSections = 1;
static NSInteger const kItemsPerPage = 20;

@interface TMBBoardController () <TMBImageCardViewControllerDelegate, TMBDoodleViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *boardContent;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSString *queriedBoardID;
@property (nonatomic, strong) NSMutableArray *collection;
@property (nonatomic) NSUInteger queryCount;

@property (nonatomic, strong) NSString *boardID;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIImage *imageSelectedForOtherView;
@property (nonatomic, strong) NSMutableArray *pfObjects;

@end

@implementation TMBBoardController

static NSString * const reuseIdentifier = @"MediaCell";

#pragma mark - view did load

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarTintColor:[UIColor colorWithRed:28/255.0 green:78/255.0 blue:157/255.0 alpha:1.0]];
    [navigationBar setTintColor:[UIColor whiteColor]];
    navigationBar.translucent = NO;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
    
//    self.refreshControl = [[UIRefreshControl alloc] init];
//    self.refreshControl.tintColor = [UIColor colorWithRed:28/255.0 green:78/255.0 blue:157/255.0 alpha:1.0];
//    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
//    [self.collectionView addSubview:self.refreshControl];
//    self.collectionView.alwaysBounceVertical = YES;
    
    self.boardID = [TMBSharedBoardID sharedBoardID].boardID;
    
    [self setupLeftMenuButton];
    
    self.pfObjects = [NSMutableArray new];
    self.collection = [NSMutableArray new];
    self.boardContent = [NSMutableArray new];
    [self buildThemeColorsArray];
    [self buildEmptyCollection];
    
    [self queryParseForContent:self.boardID];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return kNumberOfSections;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.collection.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TMBBoardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([self.collection[indexPath.row] isKindOfClass:[UIImage class]]) {
        
        cell.boardImageView.image = self.collection[indexPath.row];
        
    } else if ([self.collection[indexPath.row] isKindOfClass:[PFFile class]]) {
        
        cell.boardImageView.image = [UIImage imageNamed:@"placeholderForBoardCell"];
        cell.boardImageView.file = (PFFile *)self.collection[indexPath.row];
        [cell.boardImageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
            
            if (!error) {
                cell.boardImageView.alpha = 0.0;
                [UIView beginAnimations:@"fade in" context:nil];
                [UIView setAnimationDuration:1.0];
                cell.boardImageView.alpha = 1.0;
                [UIView commitAnimations];
            }
            
            
        }];
        
    }
    
    cell.backgroundColor = [self colorForDummyCellAtRow:indexPath.row];
    
    return cell;
}


-(void)buildEmptyCollection
{
    if (self.collection.count == 0) {
        for (int i = 0; i < kItemsPerPage; i++) {
            [self.collection addObject:[UIImage imageNamed:@"placeholderForBoardCell"]];
        }
    }
    
}
-(UIColor *)colorForDummyCellAtRow:(NSUInteger)row
{
    NSUInteger colorIndex = row % self.colors.count;
    return self.colors[colorIndex];
}
-(void)buildThemeColorsArray
{
    
    UIColor *c1 = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1.0];
    UIColor *c2 = [UIColor colorWithRed:189/255.0 green:189/255.0 blue:189/255.0 alpha:1.0];
    UIColor *c3 = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    UIColor *c4 = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
    UIColor *c5 = [UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1.0];
    
    self.colors = @[c1, c2, c3, c4, c5, c3, c3, c2, c5, c2];
    
}

#pragma mark - refresh collection


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  
    
//    if (scrollView.contentOffset.x < -50 && ![self.refreshControl isRefreshing]) {
//        NSLog(@"\n\n\n\nscrollview offset\n\n\n\n");
//                [self.refreshControl beginRefreshing];
//                [self.collection removeAllObjects];
//                NSLog(@"\n\n\n\n\nself.collection:\n%@\n\n\n\n\n",self.collection);
//                [self refresh];
//    }

}

- (void)refresh
{
    NSLog(@"entered refresh");
    
//    [self.refreshControl endRefreshing];
    
//    [self queryParseToUpdateCollection:self.boardID successBlock:^(BOOL success) {
//        
//        if (success) {
//            
//            [self.refreshControl endRefreshing];
//        }
//        
//    }];
    
}


#pragma mark - side menu selection


- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - alert and segue


- (IBAction)addButtonTapped:(id)sender {
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Add to your Mosaic"
                                 message:@"Select your choice"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* picture = [UIAlertAction
                              actionWithTitle:@"Picture"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  UIStoryboard *imageCardStoryboard = [UIStoryboard storyboardWithName:@"ImageCard" bundle:nil];
                                  TMBImageCardViewController *pictureVC = [imageCardStoryboard instantiateViewControllerWithIdentifier:@"TMBImageCardViewController"];
                                  pictureVC.delegate = self;
                                  [self presentViewController:pictureVC animated:YES completion:nil];
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    
    UIAlertAction* text = [UIAlertAction
                           actionWithTitle:@"Text"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               UIViewController *textVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBTextCardViewController"];
                               
                               [self presentViewController:textVC animated:YES completion:nil];
                               
                               [view dismissViewControllerAnimated:YES completion:nil];
                               
                           }];
    
    UIAlertAction* doodle = [UIAlertAction
                             actionWithTitle:@"Doodle"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 
                                 TMBDoodleViewController *doodleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TMBDoodleViewController"];
                                 doodleVC.delegate = self;
                                 [self presentViewController:doodleVC animated:YES completion:nil];
                                 
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:picture];
//    [view addAction:text];
    [view addAction:doodle];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    

    NSArray *indexPathsOfSelectedCell = self.collectionView.indexPathsForSelectedItems;
    NSIndexPath *selectedIndexPath = indexPathsOfSelectedCell.firstObject;
    self.imageSelectedForOtherView = self.collection[selectedIndexPath.row];
    if (selectedIndexPath.row < self.pfObjects.count){
        return YES;
    }else{

        return NO;
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        
    TMBCommentViewController *destVC = segue.destinationViewController;
    NSArray *indexPathsOfSelectedCell = self.collectionView.indexPathsForSelectedItems;
    NSIndexPath *selectedIndexPath = indexPathsOfSelectedCell.firstObject;
//    self.imageSelectedForOtherView = self.collection[selectedIndexPath.row];
    PFObject *selectedOBJ = self.pfObjects[selectedIndexPath.row];
    
    destVC.parseObjSelected = selectedOBJ;
    
    destVC.selectedFile = self.collection[selectedIndexPath.row];
}


#pragma mark - queries

-(void)imageCardViewController:(TMBImageCardViewController *)viewController passBoardIDforQuery:(NSString *)boardID
{
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self queryParseForContent:boardID];
}

-(void)doodleViewController:(TMBDoodleViewController *)viewController passBoardIDforQuery:(NSString *)boardID
{
    NSIndexPath *ip = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:ip atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self queryParseForContent:boardID];
}

- (void)queryParseForContent:(NSString *)boardID {
    
    PFQuery *boardQuery = [PFQuery queryWithClassName:@"Board"];
    [boardQuery whereKey:@"objectId" equalTo:boardID];
    
    PFQuery *contentQuery = [PFQuery queryWithClassName:@"Photo"];
    [contentQuery whereKey:@"board" matchesQuery:boardQuery];
    [contentQuery orderByDescending:@"updatedAt"];
    [contentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        
        if (self.pfObjects.count > 0) {
            [self.pfObjects removeAllObjects];
        }
        
        if (objects.count > kItemsPerPage) {
            
            NSUInteger totalItems;
            NSUInteger numberOfDummyItemsForUpdate;
            
            if ((objects.count % 20) == 0) {
                totalItems = objects.count;
            } else {
                totalItems = objects.count + (kItemsPerPage - (objects.count % kItemsPerPage));
            }
            numberOfDummyItemsForUpdate = totalItems - self.collection.count;
            
            for (int i = 0; i < numberOfDummyItemsForUpdate; i++) {
                [self.collection addObject:[UIImage imageNamed:@"placeholderForBoardCell"]];
            }
            
        }
        
        NSUInteger objectIndex = 0;
        for (PFObject *object in objects) {
            
            PFFile *imageFile = object[@"thumbnail"];
            
            if (imageFile) {
                [self.collection replaceObjectAtIndex:objectIndex withObject:imageFile];
                [self.pfObjects addObject:object];
            }
            objectIndex++;
        }
        
        [self.collectionView reloadData];
        
    }];
    
    
    
}




@end