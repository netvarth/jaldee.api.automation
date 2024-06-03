*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM GROUP
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***
@{emptylist}

*** Test Cases ***


JD-TC-AddItemsToMultipleItemGroupsforUser-1

    [Documentation]  Create an item and add that item to 2 item groups.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME110}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    clear_Item  ${PUSERNAME110}

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    ${price2float}=   Convert To Number   ${price1}  2
    ${itemName1}=   FakerLibrary.name
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence  
    ${itemCode1}=   FakerLibrary.word    
    ${promoLabel1}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemid1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${groupName2}=    FakerLibrary.word
    ${groupDesc2}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${itemgroup_list}=  Create List   ${item_group_id1}  ${item_group_id2}  
    Set Suite Variable  ${itemgroup_list}
  
    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupIds'][1]}  ${item_group_id2}


JD-TC-AddItemsToMultipleItemGroupsforUser-2

    [Documentation]  Add items to group by passing empty set of group ids.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME111}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    clear_Item  ${PUSERNAME111}

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    ${price2float}=   Convert To Number   ${price1}  2
    ${itemName1}=   FakerLibrary.name
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence  
    ${itemCode1}=   FakerLibrary.word    
    ${promoLabel1}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemgroup_list}=  Create List   
  
    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    

JD-TC-AddItemsToMultipleItemGroupsforUser-3

    [Documentation]  Add items to multiple item groups by user.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME115}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id1}  ${resp.json()['id']}
    Set Test Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Test Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Test Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${PUSERNAME115}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Test Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Item  ${PUSERNAME115}

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    ${price2float}=   Convert To Number   ${price1}  2
    ${itemName1}=   FakerLibrary.name
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence  
    ${itemCode1}=   FakerLibrary.word    
    ${promoLabel1}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${groupName2}=    FakerLibrary.word
    ${groupDesc2}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${itemgroup_list}=  Create List   ${item_group_id1}  ${item_group_id2}  
    Set Suite Variable  ${itemgroup_list}
  
    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupIds'][1]}  ${item_group_id2}

JD-TC-AddItemsToMultipleItemGroupsforUser-UH1

    [Documentation]  add items to item group without login

    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AddItemsToMultipleItemGroupsforUser-UH2

    [Documentation]  Consumer try to add items to an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-AddItemsToMultipleItemGroupsforUser-UH3

    [Documentation]  Add items to another providers item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    clear_Item  ${PUSERNAME112}

    ${displayName1}=   FakerLibrary.name 
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    ${price1}=  Random Int  min=50   max=300 
    ${price1float}=  twodigitfloat  ${price1}
    ${price2float}=   Convert To Number   ${price1}  2
    ${itemName1}=   FakerLibrary.name
    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    ${note1}=  FakerLibrary.Sentence  
    ${itemCode1}=   FakerLibrary.word    
    ${promoLabel1}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemid1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME113}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    IF  ${resp.json()['enableItemGroup']}==${bool[0]}
        ${resp1}=  Enable Disable Item Group  ${Qstate[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableItemGroup']}  ${bool[1]}

    ${groupName1}=    FakerLibrary.word
    ${groupDesc1}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName1}  ${groupDesc1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${groupName2}=    FakerLibrary.word
    ${groupDesc2}=    FakerLibrary.sentence
    
    ${resp}=  Create Item Group   ${groupName2}  ${groupDesc2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME112}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemgroup_list}=  Create List   ${item_group_id1}  ${item_group_id2}  
    Set Suite Variable  ${itemgroup_list}
  
    ${resp}=  Add Items To Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NO_ITEM_GROUP_FOUND}
