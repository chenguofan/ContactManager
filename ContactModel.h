//
//  ContactModel.h
//  EverpidaTranslationStick
//
//  Created by suhengxian on 2020/6/19.
//  Copyright © 2020 吕金状. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactModel : NSObject

@property(nonatomic,copy) NSString *namePrefix;
@property(nonatomic,copy) NSString *nameSuffix;

//familyName + middelName + givenName
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *nickname;
@property(nonatomic,copy) NSString *pinYinName;

//电话数组
@property(nonatomic,strong) NSArray *phoneNumbers;

-(instancetype)initWithContact:(CNContact *)contact;

-(NSString *)description;

@end

NS_ASSUME_NONNULL_END
