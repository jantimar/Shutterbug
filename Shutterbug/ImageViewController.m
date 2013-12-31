//
//  ImageViewController.m
//  Shutterbug
//
//  Created by Jan Timar on 7/18/13.
//  Copyright (c) 2013 Jan Timar. All rights reserved.
//

#import "ImageViewController.h"
#import "AttributedStringViewController.h"
#import "ImageCache.h"

// protokol od UIScrollViewDelegate
@interface ImageViewController () <UIScrollViewDelegate>

//referencia na scrollView
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;

@property (nonatomic,strong) UIPopoverController *urlPopover;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ImageViewController

// obnova obrazku z nastavenej url
-(void)resetImage{
    if(self.scrollView){
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        NSURL *imageURL = self.imageURL;
        
        [self.activityIndicator startAnimating];
        
        dispatch_queue_t imageFetchQueue = dispatch_queue_create("image fetcher", NULL);
        
        dispatch_async(imageFetchQueue, ^{
            
            //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            // stiahnutie obrazka z url
           // NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
           // UIImage *image = [[UIImage alloc] initWithData:imageData];
            UIImage *image = [ImageCache getCachedImage:[imageURL absoluteString] withFileName:[imageURL lastPathComponent]];
            
            //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(self.imageURL == imageURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(image){
                        //resetovanie zumovania obrazku
                        self.scrollView.zoomScale = 1.0;
                        //nstavenie velkosti scrollovacej plochy
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        // zozoomova+t an velkost image
                        [self.scrollView zoomToRect:self.imageView.frame animated:NO];
                    }
                    [self.activityIndicator stopAnimating];
                });
            }
        });
    }
}

-(UIImageView *)imageView{
    //CGRectZero z dovodu ze nemam ziadny obrazok este
    if(!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //nastavenie scroll view jeho pod view
    [self.scrollView addSubview:self.imageView];
    //nastavenie minimalneho a maximalneho zumovania
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    //nastavenie scroll delegate na dany objekt koly zoomovaniu
    self.scrollView.delegate = self;
    self.titleBarButtonItem.title = self.title;
    [self resetImage];
}

// ci sa moze zobrazit popover ak uz je zobrazeny tak nemoze
-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"Show URL"]){
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //  zobrazenie popoveruz z textom url fotky
    if([segue.identifier isEqualToString:@"Show URL"]){
        if([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]){
            AttributedStringViewController *attributedStringViewController =  (AttributedStringViewController *)segue.destinationViewController;
            attributedStringViewController.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            
            if([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
        }
    }
}

-(void)setImageURL:(NSURL *)imageURL{
    _imageURL = imageURL;
    [self resetImage];
}

-(void)setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

@end

