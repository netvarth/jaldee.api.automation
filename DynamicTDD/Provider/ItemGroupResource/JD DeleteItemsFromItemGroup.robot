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


JD-TC-DeleteItemsFromItemGroup-1

    [Documentation]  Create an item and add that item to an item group, then delete item from that group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME140}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME140}

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
    Set Suite Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${Items_list}=  Create List   ${itemid1}  
    Set Suite Variable  ${Items_list}

    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Not Contain  ${resp.json()}     groupIds


JD-TC-DeleteItemsFromItemGroup-2

    [Documentation]  Create multiple items and add that items to an item group, then delete one item from the group..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME141}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME141}

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

    ${displayName2}=   FakerLibrary.name 
    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3 
    ${price2}=  Random Int  min=50   max=300 
    ${price2float}=  twodigitfloat  ${price2}
    ${price2float}=   Convert To Number   ${price2}  2
    ${itemName2}=   FakerLibrary.name
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2float}=   Convert To Number   ${promoPrice2}  2
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence  
    ${itemCode2}=   FakerLibrary.word    
    ${promoLabel2}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[1]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[0]}    ${bool[0]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid2} 
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


    ${Items_list}=  Create List   ${itemid1}    ${itemid2}
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     2

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${Items_list1}=  Create List   ${itemid1}   

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}     groupIds   

    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}
 

JD-TC-DeleteItemsFromItemGroup-3

    [Documentation]  delete items from the item group by passing empty list of item ids.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME143}

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

    ${Items_list}=  Create List   ${itemid1}   
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${Items_list1}=  Create List    

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}


JD-TC-DeleteItemsFromItemGroup-UH1

    [Documentation]  try to delete items from the item group but that item not added in the group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME142}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME142}

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

    ${displayName2}=   FakerLibrary.name 
    ${shortDesc2}=  FakerLibrary.Sentence   nb_words=2 
    ${itemDesc2}=  FakerLibrary.Sentence   nb_words=3 
    ${price2}=  Random Int  min=50   max=300 
    ${price2float}=  twodigitfloat  ${price2}
    ${price2float}=   Convert To Number   ${price2}  2
    ${itemName2}=   FakerLibrary.name
    ${itemNameInLocal2}=  FakerLibrary.Sentence   nb_words=2   
    ${promoPrice2}=  Random Int  min=10   max=${price2} 
    ${promoPrice2float}=   Convert To Number   ${promoPrice2}  2
    ${promoPrcnt2}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt2}=  twodigitfloat  ${promoPrcnt2}
    ${note2}=  FakerLibrary.Sentence  
    ${itemCode2}=   FakerLibrary.word    
    ${promoLabel2}=   FakerLibrary.word 
  
    ${resp}=  Create Order Item    ${displayName2}    ${shortDesc2}    ${itemDesc2}    ${price2}    ${bool[1]}    ${itemName2}    ${itemNameInLocal2}    ${promotionalPriceType[1]}    ${promoPrice2}   ${promotionalPrcnt2}    ${note2}    ${bool[0]}    ${bool[0]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel2}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid2} 
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


    ${Items_list}=  Create List   ${itemid1}   
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${Items_list1}=  Create List   ${itemid2}   

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-DeleteItemsFromItemGroup-UH2

    [Documentation]  delete items from group using another providers group id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME144}

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

    ${Items_list}=  Create List   ${itemid1}   
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     1

    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME145}  ${PASSWORD}
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
    Set Test Variable  ${item_group_id2}  ${resp.json()}

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME144}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Items_list1}=  Create List   ${itemid1}   

    ${resp}=  Delete Items From Item Group   ${item_group_id2}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NO_ITEM_GROUP_FOUND}

JD-TC-DeleteItemsFromItemGroup-UH3

    [Documentation]  try to delete another providers items from the group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME143}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Item  ${PUSERNAME143}

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

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME146}  ${PASSWORD}
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

    ${Items_list}=  Create List   ${itemid1}   

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}

JD-TC-DeleteItemsFromItemGroup-UH4

    [Documentation]  delete items from item group without login

    ${resp}=  Delete Items From Item Group  ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-DeleteItemsFromItemGroup-UH5

    [Documentation]  Consumer try to delete items from an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Delete Items From Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
 