//
//  ContactManager.h
//  ContactTest
//
//  Created by suhengxian on 2020/6/18.
//  Copyright © 2020 suhengxian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import "ContactModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactManager : NSObject

+(instancetype)manager;

-(CNAuthorizationStatus)getContactStatus;

-(void)requestContactStatusWithCompletionHandler:(void(^)(BOOL granted,CNAuthorizationStatus status))handler;

-(void)getTelWithName:(NSString *)name completeblock:(void(^)(ContactModel *model))completeBlock;

-(void)getTelWithSubTel:(NSString *)subTel completeBlock:(void(^)(NSArray <ContactModel *> *contactModels))completeBlock;


@end

NS_ASSUME_NONNULL_END
