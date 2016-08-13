//
//  YQAssetOperator.m
//  Photo_Example
//
//  Created by YiMan on 16/5/9.
//  Copyright © 2016年 Ecar. All rights reserved.
//

#import "YQAssetOperator.h"
#import <Photos/Photos.h>

@interface YQAssetOperator ()

@property (nonatomic, copy) NSString *plistName;
@property (nonatomic, copy) NSString *folderName;

@end

@implementation YQAssetOperator

- (instancetype)initWithFolderName:(NSString *)folderName {
    self = [self init];
    if (self) {
        self.plistName = @"Asset";
        self.folderName = folderName;
    }
    return self;
}

- (void)saveImagePath:(NSString *)imagePath{
    NSURL *url = [NSURL fileURLWithPath:imagePath];
    
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    
    //首先获取相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //Camera Roll是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:_folderName])  {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加照片
                [collectonRequest addAssets:@[placeHolder]];
                
                localIdentifier = placeHolder.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"保存图片成功!");
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self readFromPlist]];
                    [dict setObject:localIdentifier forKey:[self showFileNameFromPath:imagePath]];
                    [self writeDicToPlist:dict];
                } else {
                    NSLog(@"保存图片失败:%@", error);
                }
            }];
        }
    }];
}

- (void)saveVideoPath:(NSString *)videoPath {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    
    //首先获取相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:_folderName])  {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                //相册中添加视频
                [collectonRequest addAssets:@[placeHolder]];
                
                localIdentifier = placeHolder.localIdentifier;
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    NSLog(@"保存视频成功!");
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self readFromPlist]];
                    [dict setObject:localIdentifier forKey:[self showFileNameFromPath:videoPath]];
                    [self writeDicToPlist:dict];
                } else {
                    NSLog(@"保存视频失败:%@", error);
                }
            }];
        }
    }];
}

- (void)deleteFile:(NSString *)filePath {
    if ([self isExistFolder:_folderName]) {
        //获取需要删除文件的localIdentifier
        NSDictionary *dict = [self readFromPlist];
        NSString *localIdentifier = [dict valueForKey:[self showFileNameFromPath:filePath]];
        
        PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PHAssetCollection *assetCollection = obj;
            if ([assetCollection.localizedTitle isEqualToString:_folderName])  {
                PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
                [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    PHAsset *asset = obj;
                    if ([localIdentifier isEqualToString:asset.localIdentifier]) {
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            [PHAssetChangeRequest deleteAssets:@[obj]];
                        } completionHandler:^(BOOL success, NSError *error) {
                            if (success) {
                                NSLog(@"删除成功!");
                                NSMutableDictionary *updateDic = [NSMutableDictionary dictionaryWithDictionary:dict];
                                [updateDic removeObjectForKey:[self showFileNameFromPath:filePath]];
                                [self writeDicToPlist:updateDic];
                            } else {
                                NSLog(@"删除失败:%@", error);
                            }
                        }];
                    }
                }];
            }
        }];
    }
    
}

- (BOOL)isExistFolder:(NSString *)folderName {
    //首先获取用户手动创建相册的集合
    PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    __block BOOL isExisted = NO;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //folderName是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:folderName])  {
            isExisted = YES;
        }
    }];
    
    return isExisted;
}

- (void)createFolder:(NSString *)folderName {
    if (![self isExistFolder:folderName]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //添加HUD文件夹
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:folderName];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"创建相册文件夹成功!");
            } else {
                NSLog(@"创建相册文件夹失败:%@", error);
            }
        }];
    }
}

#pragma mark - setters和getters
- (void)setFolderName:(NSString *)folderName {
    if (!_folderName) {
        _folderName = folderName;
        [self createFolder:folderName];
    }
}

- (void)setPlistName:(NSString *)plistName {
    if (!_plistName) {
        _plistName = plistName;
        
        //创建plist文件，记录path和localIdentifier的对应关系
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", plistName]];
        NSLog(@"plist路径:%@", filePath);
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:filePath]) {
            BOOL success = [fm createFileAtPath:filePath contents:nil attributes:nil];
            if (!success) {
                NSLog(@"创建plist文件失败!");
            } else {
                NSLog(@"创建plist文件成功!");
            }
        } else {
            NSLog(@"沙盒中已有该plist文件，无需创建!");
        }
    }
}

#pragma mark - 写入plist文件
- (void)writeDicToPlist:(NSDictionary *)dict {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", _plistName]];
    [dict writeToFile:filePath atomically:YES];
}

#pragma mark - 读取plist文件
- (NSDictionary *)readFromPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", _plistName]];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

#pragma mark - 根据路径获取文件名
- (NSString *)showFileNameFromPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@", [[path componentsSeparatedByString:@"/"] lastObject]];
}

@end
