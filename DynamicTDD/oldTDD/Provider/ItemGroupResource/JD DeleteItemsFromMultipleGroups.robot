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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***


JD-TC-DeleteItemsFromMultipleGroups-1

    [Documentation]  Create an item and add that item to 2 item groups, then delete items from the group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME120}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME120}

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

    ${itemgroup_list}=  Create List   ${item_group_id1}  ${item_group_id2}  
    Set Suite Variable  ${itemgroup_list}
  
    ${resp}=  Delete Items From Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${resp}=  Get Item Group By Id  ${item_group_id2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName2}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Not Contain  ${resp.json()}     groupIds

JD-TC-DeleteItemsFromMultipleGroups-2

    [Documentation]  Create an item and add that item to 2 item groups, then delete items from one group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME121}

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

    ${itemgroup_list}=  Create List   ${item_group_id1} 
    Set Suite Variable  ${itemgroup_list}
  
    ${resp}=  Delete Items From Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

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
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id2}


JD-TC-DeleteItemsFromMultipleGroups-UH1

    [Documentation]  delete items from item group without login

    ${resp}=  Delete Items From Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-DeleteItemsFromMultipleGroups-UH2

    [Documentation]  Consumer try to delete items from an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Items From Multiple Item Group   ${itemid1}    ${itemgroup_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}

