//
//  Note.h
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;
@import UIKit;  //#import <UIKit/UIKit.h>

//@interface Note : NSObject <NSCoding>

//Core Data should use NSManagedObject
@interface Note : NSManagedObject

//@property (nonatomic) UIImage* image;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *noteID;
@property (nonatomic) NSString *imageName;
-(UIImage*)image;   //取得原圖，NoteViewController使用
-(UIImage *)thumbnailImage; //縮圖，ListController使用
@end
