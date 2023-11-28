
-- Reshma 17-05-2022
-- Editted by Archana - 08/06/2022

-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE ynw.crm_status_tbl;
-- SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO ynw.crm_status_tbl(created_by,created_date,modified_by,updated_date,account,is_blocked,is_canceled,is_closed,is_default,is_editable,is_verified,is_done,is_rejected,is_pending,name,status,type_enum,is_transferred,is_salesfieldverified,is_documentverified,is_creditscoregenerated,is_kycupdated,is_assigned,is_documentuploaded ,is_creditrecommended,is_loansaction,is_loandisbursement)
VALUES
('1', now(), '0', NULL, '0', 0, 0, 0, 1, 1, 0, 0, 0, 0, 'New', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 1, 0, 0, 0, 0, 'Assigned', 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 1, 0, 0, 0, 0, 'In Progress', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 1, 0, 0, 0, 0, 0, 0, 0, 'Canceled', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 1, 0, 0, 0, 0, 0, 0, 'Completed', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Suspended', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 1, 0, 0, 0, 1, 'Pending', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 1, 0, 0, 1, 0, 'Rejected', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 1, 0, 1, 0, 0, 'Proceed', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('1', now(), '0', NULL, '0', 0, 0, 0, 0, 0, 1, 0, 0, 0, 'Verified', 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

-- insert into crm_priority_tbl(account,name,type_enum,status,created_by,is_default,created_date,modified_by)
-- values(0,'Low',1,0,1,1,now(),0),
-- (0,'Normal',1,0,1,0,now(),0),
-- (0,'High',1,0,1,0,now(),0),
-- (0,'Urgent',1,0,1,0,now(),0),
-- (0,'Low',2,0,1,1,now(),0),
-- (0,'Normal',2,0,1,0,now(),0),
-- (0,'High',2,0,1,0,now(),0),
-- (0,'Urgent',2,0,1,0,now(),0);

INSERT INTO ynw.crm_priority_tbl(account,name,type_enum,status,created_by,is_default,created_date,modified_by)
VALUES
(0,'Low',1,0,1,1,now(),0),
(0,'Normal',1,0,1,0,now(),0),
(0,'High',1,0,1,0,now(),0),
(0,'Urgent',1,0,1,0,now(),0),
(0,'Low',2,0,1,1,now(),0),
(0,'Normal',2,0,1,0,now(),0),
(0,'High',2,0,1,0,now(),0),
(0,'Urgent',2,0,1,0,now(),0),
(0,'Low',3,0,1,1,now(),0),
(0,'Normal',3,0,1,0,now(),0),
(0,'High',3,0,1,0,now(),0),
(0,'Urgent',3,0,1,0,now(),0);

-- update ynw.crm_status_tbl set is_documentuploaded = 1,is_documentverified=0 where name = 'Login';
-- update crm_status_tbl set name = 'New' where account = 0 and type_enum = 1 and name = 'Unassigned';
-- update crm_status_tbl set name = 'Completed' where account = 0 and type_enum = 1 and name = 'Done';

-- update crm_status_tbl set is_closed = 1 where account = 0  and (name = 'Done' or name='Completed' or name='Success');

-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='4';
-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='5';
-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='6';
-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='9';
-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='10';
-- UPDATE ynw.crm_status_tbl SET is_editable=0 WHERE id='12';

-- Reshma 06-07-2022

-- ALTER TABLE ynw.access_key_tbl 
-- CHANGE COLUMN credentials credentials VARCHAR(600) NULL DEFAULT NULL ;

-- Archana 14-11-2022

-- ALTER TABLE ynw.consumer_tbl DROP FOREIGN KEY `FKsw5v9kk37k58i5ghb7a926g0h` ;

UPDATE  ynw.consumer_tbl consumer,ynw.user_tbl user SET  consumer.address=user.address, consumer.city=user.city,consumer.dob=user.dob,
consumer.first_name=user.first_name,consumer.gender=user.gender,consumer.last_name=user.last_name, 
consumer.pincode=user.pincode, consumer.state=user.state, consumer.country_code=user.country_code, 
consumer.email=user.email,consumer.primary_mobile_no=user.primary_mobile_no,
consumer.alternative_phone_no=user.alternative_phone_no,consumer.longitude=user.longitude,
consumer.lattitude=user.lattitude,consumer.location_name=user.location_name where consumer.id =user.id ;

-- ALTER TABLE ynw.local_user_tbl DROP FOREIGN KEY `FK1wok7d7c1evncnds9x4ryx84` ;

UPDATE ynw.local_user_tbl local_user,ynw.user_tbl user SET  local_user.address=user.address, local_user.city=user.city,local_user.dob=user.dob,local_user.first_name=user.first_name,local_user.gender=user.gender,local_user.last_name=user.last_name, local_user.pincode=user.pincode, local_user.state=user.state, local_user.country_code=user.country_code, local_user.email=user.email,local_user.primary_mobile_no=user.primary_mobile_no,local_user.alternative_phone_no=user.alternative_phone_no,local_user.longitude=user.longitude,local_user.lattitude=user.lattitude,local_user.location_name=user.location_name where local_user.id =user.id ;

-- Archana 22-11-2022

UPDATE ynw.local_user_tbl localuser_tbl, ynw.user_profile_tbl profile_tbl SET localuser_tbl.sub_domain_virtual_fields = profile_tbl.sub_domain_virtual_fields where localuser_tbl.user_search_profile = profile_tbl.id;


-- Archana 11-03-2023
-- ALTER TABLE `ynw`.`provider_consumer_tbl` DROP column groups;

-- Archana 06-05-2023
-- ALTER TABLE `ynw`.`acc_coupon_tbl CHANGE COLUMN` `max_consumer_consume_limit` `max_consumer_consume_limit` BIGINT(20) NULL DEFAULT NULL ;

-- Archana 26-10-2023
UPDATE ynw.account_tbl SET timezone = 'Asia/Kolkata' WHERE (id = '1');


