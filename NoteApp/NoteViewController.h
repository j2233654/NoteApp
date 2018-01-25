//
//  NoteViewController.h
//  NoteApp
//
//  Created by 鍾哲允 on 2017/12/14.
//  Copyright © 2017年 Jimmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "ListViewController.h"

//協定中要有規定的方法didFinishUpdateNote
//有實作協定就等於有didFinishNote方法
@protocol NoteViewControllerDelegate
-(void)didFinishUpdateNote:(Note*)note;
@end

@interface NoteViewController : UIViewController

@property(nonatomic) Note *note;
@property(nonatomic,weak) id<NoteViewControllerDelegate> delegate; //任何物件
@end
