//
//  Note.m
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import "Note.h"

@implementation Note
//Core Data 中屬性必須要使用＠dynamic，表示getxxx, setxxx等方法會動態產生，由Core Data負責產生，compiler無需實作
@dynamic noteID;
@dynamic text;
@dynamic imageName;

//物件到檔案：把物件狀態存到aCoder encoder=編碼
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
    [aCoder encodeObject:self.text forKey:@"text"];
    [aCoder encodeObject:self.imageName forKey:@"imageName"];
    [aCoder encodeObject:self.noteID forKey:@"noteID"];
}
//檔案到物件，把檔案狀態從aCoder中取出來
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    
    if ( self = [super init]){
        self.text = [aDecoder decodeObjectForKey:@"text"];
        self.imageName = [aDecoder decodeObjectForKey:@"imageName"];
        self.noteID = [aDecoder decodeObjectForKey:@"noteID"];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //NSUUID可以用來產生唯一的key值，而且不會重複
        self.noteID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

-(UIImage *) image{
    //從檔案載入原圖
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //圖片放在Documents下，路徑 = Documents/xxxx.jpg
    NSString *imagePath = [docPath stringByAppendingPathComponent:self.imageName];
    //透過路徑方式載入圖片
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(UIImage *)thumbnailImage{
    UIImage *image = [self image];
    if ( !image ){
        return nil;
    }
    CGSize thumbnailSize = CGSizeMake(50, 50);
    CGFloat scale = [UIScreen mainScreen].scale;
    
    //產生畫布，第一個參數指定大小,第二個參數YES:不透明(黑色底), false表示透明背景,scale為螢幕scale
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, scale);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSaveGState(context); // 可以不需要
    
    /*圓形或方形的控制
    //for student if have time, create a circle
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
    [circlePath addClip];
    */
    
    //計算長寬要縮圖比例，取最大值MAX會變成UIViewContentModeScaleAspectFill
    //最小值MIN會變成UIViewContentModeScaleAspectFit
    //0.03 30/1000
    CGFloat widthRatio = thumbnailSize.width / image.size.width;
    //0.03 30/5000
    CGFloat heightRadio = thumbnailSize.height / image.size.height;
    CGFloat ratio = MAX(widthRatio,heightRadio);
    CGSize imageSize = CGSizeMake(image.size.width*ratio, image.size.height*ratio);
    [image drawInRect:CGRectMake(-(imageSize.width-thumbnailSize.width)/2.0, -(imageSize.height-thumbnailSize.height)/2.0, imageSize.width, imageSize.height)];
    
    //CGContextRestoreGState(context); //可以不用
    //取得畫布上的縮圖
    image = UIGraphicsGetImageFromCurrentImageContext();
    //關掉畫布
    UIGraphicsEndImageContext();
    
    return image;
}

@end

