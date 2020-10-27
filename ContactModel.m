//
//  ContactModel.m
//  EverpidaTranslationStick
//
//  Created by suhengxian on 2020/6/19.
//  Copyright © 2020 吕金状. All rights reserved.
//

#import "ContactModel.h"
#import "NSString+Add.h"

@implementation ContactModel

-(instancetype)initWithContact:(CNContact *)contact{
    if (self = [super init]) {
        
        self.namePrefix = contact.namePrefix;
        self.nameSuffix = contact.nameSuffix;
        self.name = [NSString stringWithFormat:@"%@%@%@",contact.familyName,contact.middleName,contact.givenName];
        self.pinYinName = [NSString translateChineseToPinYin:self.name];
        self.nickname = contact.nickname;
//        self.phoneNumbers = contact.phoneNumbers;
        
    }
    return self;
}

-(NSString *)description{
//    NSData *data = [self.name dataUsingEncoding:NSUTF8StringEncoding];
//    self.name = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString *des = [NSString stringWithFormat:@"name==%@\n phoneNumbers==%@\n nickName:%@\n,pinYinName == %@",self.name,self.phoneNumbers,self.nickname,self.pinYinName];
    
    return [des debugDescription];
}

@end
