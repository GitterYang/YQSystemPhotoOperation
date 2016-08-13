//
//  ViewController.m
//  Photo_Example
//
//  Created by YiMan on 16/5/9.
//  Copyright © 2016年 Ecar. All rights reserved.
//

#import "ViewController.h"
#import "YQAssetOperator.h"

@interface ViewController (){
    YQAssetOperator *_assetOperator;
}

- (IBAction)deleteFile:(UIButton *)sender;
- (IBAction)addFiles:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    _assetOperator = [[YQAssetOperator alloc] initWithFolderName:@"LOVE"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteFile:(UIButton *)sender {
    NSString *videoPath =[[NSBundle mainBundle] pathForResource:@"0425_103546" ofType:@"mp4"];
    [_assetOperator deleteFile:videoPath];
}

- (IBAction)addFiles:(UIButton *)sender {
    //保存图片
    NSString *imagePath =[[NSBundle mainBundle] pathForResource:@"scanner" ofType:@"png"];
    [_assetOperator saveImagePath:imagePath];
    
    //保存视频
    NSString *videoPath =[[NSBundle mainBundle] pathForResource:@"0425_103546" ofType:@"mp4"];
    [_assetOperator saveVideoPath:videoPath];
}

@end
