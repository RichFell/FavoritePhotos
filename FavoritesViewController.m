//
//  FavoritesViewController.m
//  FavoritePhotos
//
//  Created by Richard Fellure on 6/2/14.
//  Copyright (c) 2014 Rich. All rights reserved.
//

#import "FavoritesViewController.h"
#import "CollectionViewCell.h"
#import "ImageObject.h"

@interface FavoritesViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation FavoritesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoritesArrayFromSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavoritesCell" forIndexPath:indexPath];
    ImageObject *imageObject = [self.favoritesArrayFromSource objectAtIndex:indexPath.row];

    cell.imageView.image = imageObject.photoImage;

    return cell;

}
- (IBAction)onButtonPressedDelete:(id)sender
{
    

}

@end
