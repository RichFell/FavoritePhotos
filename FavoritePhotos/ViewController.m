//
//  ViewController.m
//  FavoritePhotos
//
//  Created by Richard Fellure on 6/2/14.
//  Copyright (c) 2014 Rich. All rights reserved.
//

#import "ViewController.h"
#import "ImageObject.h"
#import "CollectionViewCell.h"
#import "FavoritesViewController.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property NSMutableArray *favoritesArray;
@property NSMutableArray *imageObjectArray;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property NSMutableArray *urlStringArray;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imageObjectArray = [[NSMutableArray alloc]init];

    self.favoritesButton.titleLabel.text = [NSString stringWithFormat:@"Favorites(%i)", self.favoritesArray.count];
    self.favoritesArray = [NSMutableArray array];

    self.textField.placeholder = @"Enter Search Here";

    [self load];
    NSLog(@"%@", self.urlStringArray);

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    self.favoritesButton.titleLabel.text = [NSString stringWithFormat:@"Favorites(%i)", self.favoritesArray.count];
}

#pragma mark - UICollectionViewDataSource instance methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return MIN(10,self.imageObjectArray.count);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellID" forIndexPath:indexPath];
    ImageObject *imageObject = [self.imageObjectArray objectAtIndex:indexPath.row];
    NSLog(@"imageObject%@", imageObject);

    cell.imageView.image = imageObject.photoImage;
    cell.backgroundColor = [UIColor whiteColor];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageObject *imageObject = [self.imageObjectArray objectAtIndex:indexPath.row];

    for (ImageObject *object in self.favoritesArray)
    {
        if (imageObject.photoImage != object.photoImage)
        {

            [self.favoritesArray addObject:imageObject];
            [self.urlStringArray addObject:imageObject.imageUrl];

            self.favoritesButton.titleLabel.text = [NSString stringWithFormat:@"Favorites(%i)", self.favoritesArray.count];

            [self save];

        }
        else
        {
            NSLog(@"Already a Favorite");
        }
    }
  


}

#pragma mark - Search Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchImages:self.textField.text];
    [self.textField resignFirstResponder];
    [self.imageObjectArray removeAllObjects];
    return YES;
}

- (IBAction)onButtonPressedSearch:(id)sender
{
    [self searchImages:self.textField.text];
    [self.textField resignFirstResponder];
    [self.imageObjectArray removeAllObjects];

}

  
-(void)searchImages: (NSString *)search
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=fe898b699ffffb7ecbbf26ca3e222275&text=%@&per_page=10&format=json&nojsoncallback=1", search];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        NSArray *array = jsonDictionary[@"photos"][@"photo"];


        for (NSDictionary *dictionary in array)
        {
            NSNumber *farmID = dictionary[@"farm"];
            NSString *serverID = dictionary[@"server"];
            NSString *photoID = dictionary[@"id"];
            NSString *secret = dictionary[@"secret"];
            NSString *imageString = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@.jpg",farmID, serverID, photoID, secret];
            NSURL *imageUrl = [NSURL URLWithString:imageString];
            UIImage *searchImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
            ImageObject *imageObject = [[ImageObject alloc]init];
            imageObject.photoImage = searchImage;
            imageObject.imageUrl = imageString;
            [self.imageObjectArray addObject:imageObject];

        }

        [self.collectionView reloadData];
    }];

}

#pragma mark - Saving and Loading

-(void)save
{
    NSURL *plist = [[self documentsDirectory]URLByAppendingPathComponent:@"favorites.plist"];
    [self.urlStringArray writeToURL:plist atomically:YES];
}

-(void)load
{
    NSURL *plist = [[self documentsDirectory]URLByAppendingPathComponent:@"favorites.plist"];
    self.urlStringArray = [NSMutableArray arrayWithContentsOfURL:plist];

    for (NSString *string in self.urlStringArray)
    {
        NSURL *url = [NSURL URLWithString:string];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        ImageObject *imageObject = [[ImageObject alloc]init];
        imageObject.photoImage = image;
        [self.favoritesArray addObject:imageObject];
        [self.imageObjectArray addObject:imageObject];
    }


    if (!self.urlStringArray)
    {
        self.urlStringArray = [NSMutableArray array];
    }
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]firstObject];
}

#pragma mark - PrepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FavoritesViewController *nextViewController = segue.destinationViewController;
    nextViewController.favoritesArrayFromSource = self.favoritesArray;
}


@end
