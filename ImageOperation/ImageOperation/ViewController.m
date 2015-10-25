//
//  ViewController.m
//  ImageOperation
//
//  Created by ding on 15/10/22.
//  Copyright (c) 2015年 aoyolo.com. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import "CustomCell.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    CIContext *ct;
    CIFilter *filter;
}
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionV;
@property (nonatomic,strong)  NSMutableArray *photoTypes;

@property(nonatomic,strong) CIImage *inputCIImage;
@end

@implementation ViewController
- (IBAction)save:(id)sender {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *docDir = [paths objectAtIndex:0];
//    NSString *subPath=[docDir stringByAppendingPathComponent:@"8.png"];
//    NSData *data=UIImagePNGRepresentation(self.imageView.image);
//    [data writeToFile:subPath atomically:YES];
    UIImagePickerController *controller=[[UIImagePickerController alloc] init];
    controller.delegate=self;
    controller.allowsEditing=YES;
    controller.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:controller animated:YES completion:NULL];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _photoTypes=[NSMutableArray array];
    NSArray *array=[CIFilter filterNamesInCategory:kCICategoryColorEffect];
    for (NSString *str in array) {
        if ([str rangeOfString:@"CIPhoto"].location!=NSNotFound) {
            [_photoTypes addObject:str];
        }
       // CIFilter *filter=[CIFilter filterWithName:str];
        //NSLog(@"======%@\n",filter.attributes);
    }

    EAGLContext *eagc=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ct=[CIContext contextWithEAGLContext:eagc options:@{kCIContextWorkingColorSpace:[NSNull null]}];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[[info objectForKey:UIImagePickerControllerEditedImage] copy];
    self.imageView.image=image;
    self.inputCIImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark-
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoTypes.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell=(CustomCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"collectIdentify" forIndexPath:indexPath];
    cell.lb.text=_photoTypes[indexPath.row];
    cell.imgV.image=[UIImage imageNamed:[NSString stringWithFormat:@"%d",indexPath.row+1]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    filter=[CIFilter filterWithName:_photoTypes[indexPath.row]];
    [filter setValue:self.inputCIImage forKey:kCIInputImageKey];
    CIImage *ciimage=[filter outputImage];
    CGImageRef cgimg=[ct createCGImage:ciimage fromRect:[ciimage extent]];
    UIImage *uiimage=[UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    self.imageView.image=uiimage;
}
@end
