-- INSERT  IGNORE INTO `account_payment_settings_tbl` VALUES (1,2,'2024-10-11 09:23:40.546000',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,B'1',NULL,NULL,NULL,NULL,'8848114996',1,1,'6774522',1,1,'Retail105','JALDEE05204491177899','w5Q@w320v2rsijk%','APPPROD','WEBPROD',0,NULL,NULL,0,NULL,1);
-- UPDATE `ynw`.`account_payment_settings_tbl` SET `razorpay` = '1', `razorpay_merchant_id` = '+aOM0b6Ly5MP1I22/J9W8awjLfKH/oANJUKlTE=', `razorpay_merchant_key` = '+lRLfBAafMCtr4ujYl27SpRjE+1d5kyKC8kTEPLUrrA=', `razorpay_verified` = '1', `razorpay_webhook_merchant_key` = 'h/lRz/1/kZyR9lv2Q0j53Q==' WHERE (`id` = '1');

INSERT IGNORE INTO `account_tbl` VALUES (1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Asia/Kolkata',0,NULL,NULL);

INSERT IGNORE INTO `user_tbl` VALUES (1,'Jaldee Soft Pvt Ltd, 2nd floor, Vellara Bldg, Museum Cross Ln, Chembukavu, Thrissur, Kerala 680020',NULL,NULL,'91',NULL,NULL,'support@jaldee.com','Jaldee Soft',NULL,'Pvt Ltd',NULL,NULL,NULL,NULL,NULL,9645111499,NULL,NULL,NULL,NULL),(2,NULL,NULL,NULL,'91',NULL,NULL,'admin.support@jaldee.com','Jaldee Soft',NULL,'Pvt Ltd',NULL,NULL,NULL,NULL,NULL,7012002615,NULL,NULL,'Jaldee Soft Pvt Ltd',NULL),(3,NULL,NULL,NULL,'91',NULL,NULL,'remesh.support@netvarth.com','Remesh',NULL,'Kuruppath',NULL,NULL,NULL,NULL,NULL,9495988369,NULL,NULL,'remesh.support',NULL);

INSERT IGNORE INTO `login_tbl` VALUES (0,'2024-10-11 09:23:40.444000',0,NULL,1,1,NULL,NULL,NULL,'admin.support@jaldee.com',NULL,NULL,'{}',NULL,'admin.support@jaldee.com',NULL,NULL,'bveU3DPi+d3f8Ak8Lv4Blw==','[]',2),(0,'2024-10-11 09:23:40.579000',0,NULL,1,1,NULL,NULL,NULL,'remesh.support@netvarth.com',NULL,NULL,'{}',NULL,NULL,NULL,NULL,'bveU3DPi+d3f8Ak8Lv4Blw==','[]',3);

INSERT IGNORE INTO `support_tbl` VALUES (2,'2024-10-11 09:23:40.464000',2,NULL,1,NULL,1,0,3,2),(3,'2024-10-11 09:23:40.589000',3,NULL,1,NULL,0,0,3,3);

INSERT IGNORE INTO `account_payment_settings_tbl` VALUES (1,2,'2024-10-11 09:23:40.546000',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,B'1',NULL,NULL,NULL,NULL,'8848114996',1,1,'6774522',1,1,'Retail105','JALDEE05204491177899','w5Q@w320v2rsijk%','APPPROD','WEBPROD',1,'+aOM0b6Ly5MP1I22/J9W8awjLfKH/oANJUKlTE=','+lRLfBAafMCtr4ujYl27SpRjE+1d5kyKC8kTEPLUrrA=',1,'h/lRz/1/kZyR9lv2Q0j53Q==',1);

INSERT IGNORE INTO `maintenance_tbl` VALUES (1,_binary '\0');

INSERT IGNORE INTO `version_tbl` VALUES ('api-1.0.0','config-1.0.0','android-1.0.0','ios-1.0.0','androidpro-1.0.0','iospro-1.0.0');