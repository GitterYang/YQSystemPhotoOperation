//
//  YQAssetOperator.h
//  Photo_Example
//
//  Created by YiMan on 16/5/9.
//  Copyright © 2016年 Ecar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YQAssetOperator : NSObject

/**
 *  初始化方法
 *
 *  @param folderName 操作的目录文件
 *
 *  @return 操作对象
 */
- (instancetype)initWithFolderName:(NSString *)folderName;

/**
 *  保存图片到系统相册
 *
 *  @param imagePath  保存的图片路径
 *  @param folderName 目的文件的路径
 */
- (void)saveImagePath:(NSString *)imagePath;

/**
 *  保存视频到系统相册
 *
 *  @param videoPath  保存的视频路径
 *  @param folderName 目的文件的路径
 */
- (void)saveVideoPath:(NSString *)videoPath;

/**
 *  删除系统相册中的文件
 *
 *  @param filePath   文件的路径
 *  @param folderName 文件夹的名字
 */
- (void)deleteFile:(NSString *)filePath;

@end
