//
//  XPYVideosSplicingViewController.m
//  XPYVideoProcessingDemo
//
//  Created by 项林平 on 2021/9/16.
//

#import "XPYVideosSplicingViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface XPYVideosSplicingViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *chooseVideoButton1;
@property (weak, nonatomic) IBOutlet UIButton *chooseVideoButton2;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (nonatomic, strong) NSURL *videoURL1;
@property (nonatomic, strong) NSURL *videoURL2;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation XPYVideosSplicingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (IBAction)chooseVideoAction:(id)sender {
    _selectedIndex = (UIButton *)sender == self.chooseVideoButton1 ? 0 : 1;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (IBAction)startAction:(id)sender {
    if (!self.videoURL1 || !self.videoURL2) {
        NSLog(@"⭐️需要选择两个视频！");
        return;
    }
    [self spliceWithVideoURL1:self.videoURL1 videoURL2:self.videoURL2];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    if (!videoURL) {
        return;
    }
    if (_selectedIndex == 0) {
        [self.chooseVideoButton1 setBackgroundImage:[self firstImageFromVideoURL:videoURL] forState:UIControlStateNormal];
        self.videoURL1 = videoURL;
    } else {
        [self.chooseVideoButton2 setBackgroundImage:[self firstImageFromVideoURL:videoURL] forState:UIControlStateNormal];
        self.videoURL2 = videoURL;
    }
}


/// 获取视频封面图
- (UIImage *)firstImageFromVideoURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CMTime time = CMTimeMakeWithSeconds(0, 600);
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *resultImage = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return resultImage;
}
    
    
- (void)spliceWithVideoURL1:(NSURL *)url1 videoURL2:(NSURL *)url2 {
    AVAsset *asset1 = [AVAsset assetWithURL:url1];
    AVAsset *asset2 = [AVAsset assetWithURL:url2];
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    AVMutableCompositionTrack *track = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:[asset1 tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:asset1.duration error:nil];
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *resultPathString = [documentsDirectory stringByAppendingPathComponent:@"splicingResult.mov"];
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    export.outputURL = [NSURL fileURLWithPath:resultPathString];
    export.outputFileType = AVFileTypeQuickTimeMovie;
    export.shouldOptimizeForNetworkUse = YES;
    [export exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *outputURL = export.outputURL;
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path)) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    // 相册变动请求
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        NSLog(@"⭐️拼接视频保存成功");
                    } else {
                        NSLog(@"⭐️拼接视频保存失败");
                    }
                }];
            }
        });
    }];
    
}
    
@end
