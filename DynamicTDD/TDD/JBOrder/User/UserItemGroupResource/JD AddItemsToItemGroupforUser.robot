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

JD-TC-AddItemsToItemGroupforUser-1

    [Documentation]  Create an item and add that item to an item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME150}

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

JD-TC-AddItemsToItemGroupforUser-2

    [Documentation]  Create multiple items and add that items to an item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME151}

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


JD-TC-AddItemsToItemGroupforUser-3

    [Documentation]  Create 4 items and add 3 items in one group and one item in another group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME152}

    ${itemdata}=   FakerLibrary.words    	nb=8
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid1}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName2}=   FakerLibrary.user name    
    ${price2}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   Set Variable     ${itemdata[2]} 
    ${itemCode2}=   Set Variable     ${itemdata[3]}
    ${resp}=  Create Sample Item   ${displayName2}   ${itemName2}  ${itemCode2}  ${price2}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid2}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName3}=   FakerLibrary.user name    
    ${price3}=  Evaluate    random.uniform(50.0,300) 
    ${itemName3}=   Set Variable     ${itemdata[4]} 
    ${itemCode3}=   Set Variable     ${itemdata[5]}
    ${resp}=  Create Sample Item   ${displayName3}   ${itemName3}  ${itemCode3}  ${price3}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName4}=   FakerLibrary.user name    
    ${price4}=  Evaluate    random.uniform(50.0,300) 
    ${itemName4}=   Set Variable     ${itemdata[6]} 
    ${itemCode4}=   Set Variable     ${itemdata[7]}
    ${resp}=  Create Sample Item   ${displayName4}   ${itemName4}  ${itemCode4}  ${price4}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid4} 
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

    ${Items_list}=  Create List   ${itemid1}    ${itemid2}  ${itemid3}
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Items_list1}=  Create List   ${itemid4}  
  
    ${resp}=  Add Items To Item Group   ${item_group_id2}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     3

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

    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=   Get Item By Id  ${itemid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=   Get Item By Id  ${itemid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id2}


JD-TC-AddItemsToItemGroupforUser-4

    [Documentation]  Create 4 items and add 3 items in one group and one item in another group.
    ...   and add all these items to a catalog and verify the group details in catalog

    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Enable Order Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${itemdata}=   FakerLibrary.words    	nb=8
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid1}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName2}=   FakerLibrary.user name    
    ${price2}=  Evaluate    random.uniform(50.0,300) 
    ${itemName2}=   Set Variable     ${itemdata[2]} 
    ${itemCode2}=   Set Variable     ${itemdata[3]}
    ${resp}=  Create Sample Item   ${displayName2}   ${itemName2}  ${itemCode2}  ${price2}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid2}  ${resp.json()}
    
    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName3}=   FakerLibrary.user name    
    ${price3}=  Evaluate    random.uniform(50.0,300) 
    ${itemName3}=   Set Variable     ${itemdata[4]} 
    ${itemCode3}=   Set Variable     ${itemdata[5]}
    ${resp}=  Create Sample Item   ${displayName3}   ${itemName3}  ${itemCode3}  ${price3}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${displayName4}=   FakerLibrary.user name    
    ${price4}=  Evaluate    random.uniform(50.0,300) 
    ${itemName4}=   Set Variable     ${itemdata[6]} 
    ${itemCode4}=   Set Variable     ${itemdata[7]}
    ${resp}=  Create Sample Item   ${displayName4}   ${itemName4}  ${itemCode4}  ${price4}  ${bool[0]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemid4}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemid4} 
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

    ${Items_list}=  Create List   ${itemid1}    ${itemid2}  ${itemid3}
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Items_list1}=  Create List   ${itemid4}  
  
    ${resp}=  Add Items To Item Group   ${item_group_id2}    ${Items_list1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     3

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

    ${resp}=   Get Item By Id  ${itemid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=   Get Item By Id  ${itemid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}

    ${resp}=   Get Item By Id  ${itemid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id2}

    ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}

    ${startDate}=  db.get_date_by_timezone  ${tz}
    ${endDate}=  db.add_timezone_date  ${tz}  10        

    ${startDate1}=  db.get_date_by_timezone  ${tz}
    ${endDate1}=  db.add_timezone_date  ${tz}  15    

    ${startDate2}=  db.add_timezone_date  ${tz}  5  
    ${endDate2}=  db.add_timezone_date  ${tz}  25      
   
    ${noOfOccurance}=  Random Int  min=0   max=0

    ${sTime3}=  add_timezone_time  ${tz}  0  15  
    ${eTime3}=  add_timezone_time  ${tz}  1  00   
    ${list}=  Create List  1  2  3  4  5  6  7
  
    ${deliveryCharge}=  Random Int  min=50   max=100
    ${deliveryCharge3}=  Convert To Number  ${deliveryCharge}  1
 
    ${Title}=  FakerLibrary.Sentence   nb_words=2 
    ${Text}=  FakerLibrary.Sentence   nb_words=4

    ${minQuantity3}=  Random Int  min=1   max=30
    ${maxQuantity3}=  Random Int  min=${minQuantity3}   max=50

    ${catalogDesc}=   FakerLibrary.name 
    ${cancelationPolicy}=  FakerLibrary.Sentence   nb_words=5
    ${terminator}=  Create Dictionary  endDate=${endDate}  noOfOccurance=${noOfOccurance}
    ${terminator1}=  Create Dictionary  endDate=${endDate1}  noOfOccurance=${noOfOccurance}
    ${timeSlots1}=  Create Dictionary  sTime=${sTime3}   eTime=${eTime3}
    ${timeSlots}=  Create List  ${timeSlots1}
    ${catalogSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate}   terminator=${terminator}   timeSlots=${timeSlots}
    ${pickupSchedule}=  Create Dictionary  recurringType=${recurringtype[1]}  repeatIntervals=${list}  startDate=${startDate1}   terminator=${terminator1}   timeSlots=${timeSlots}

    ${pickUp}=  Create Dictionary  orderPickUp=${boolean[1]}   pickUpSchedule=${pickupSchedule}   pickUpOtpVerification=${boolean[1]}   pickUpScheduledAllowed=${boolean[1]}   pickUpAsapAllowed=${boolean[1]}
    ${homeDelivery}=  Create Dictionary  homeDelivery=${boolean[1]}   deliverySchedule=${pickupSchedule}   deliveryOtpVerification=${boolean[1]}   deliveryRadius=5   scheduledHomeDeliveryAllowed=${boolean[1]}   asapHomeDeliveryAllowed=${boolean[1]}   deliveryCharge=${deliveryCharge3}
   
    ${preInfo}=  Create Dictionary  preInfoEnabled=${boolean[1]}   preInfoTitle=${Title}   preInfoText=${Text}   
    ${postInfo}=  Create Dictionary  postInfoEnabled=${boolean[1]}   postInfoTitle=${Title}   postInfoText=${Text}   
    ${StatusList1}=  Create List  ${orderStatuses[0]}  ${orderStatuses[1]}   ${orderStatuses[2]}   ${orderStatuses[3]}  ${orderStatuses[9]}   ${orderStatuses[8]}    ${orderStatuses[11]}   ${orderStatuses[12]}
    
    ${item1_Id}=  Create Dictionary  itemId=${itemid1}
    ${item2_Id}=  Create Dictionary  itemId=${itemid2}
    ${item3_Id}=  Create Dictionary  itemId=${itemid3}
    ${item4_Id}=  Create Dictionary  itemId=${itemid4}
    ${catalogItem1}=  Create Dictionary  item=${item1_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem2}=  Create Dictionary  item=${item2_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3} 
    ${catalogItem3}=  Create Dictionary  item=${item3_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}  
    ${catalogItem4}=  Create Dictionary  item=${item4_Id}    minQuantity=${minQuantity3}   maxQuantity=${maxQuantity3}   
    
    ${catalogItem}=  Create List   ${catalogItem1}  ${catalogItem2}  ${catalogItem3}  ${catalogItem4}
   
    Set Test Variable  ${orderType}       ${OrderTypes[0]}
    Set Test Variable  ${catalogStatus}   ${catalogStatus[0]}
    Set Test Variable  ${paymentType}     ${AdvancedPaymentType[0]}
    
    ${advanceAmount}=  Random Int  min=10   max=50
   
    ${far}=  Random Int  min=14  max=14
    ${soon}=  Random Int  min=0   max=0
    Set Test Variable  ${minNumberItem}   1
    Set Test Variable  ${maxNumberItem}   5
    
    ${catalogName1}=   FakerLibrary.name  

    ${resp}=  Create Catalog For ShoppingCart   ${catalogName1}  ${catalogDesc}   ${catalogSchedule}   ${orderType}   ${paymentType}   ${StatusList1}   ${catalogItem}   ${minNumberItem}   ${maxNumberItem}    ${cancelationPolicy}   catalogStatus=${catalogStatus}   pickUp=${pickUp}   homeDelivery=${homeDelivery}   showPrice=${boolean[1]}   advanceAmount=${advanceAmount}   showContactInfo=${boolean[1]}   howFar=${far}   howSoon=${soon}   preInfo=${preInfo}   postInfo=${postInfo}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${CatalogId1}   ${resp.json()}

    ${resp}=  Get Order Catalog    ${CatalogId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][0]['itemGroupId']}       ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][0]['groupName']}         ${groupName1}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][0]['groupDescription']}  ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][0]['strength']}          3
    
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][1]['itemGroupId']}       ${item_group_id2}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][1]['groupName']}         ${groupName2}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][1]['groupDescription']}  ${groupDesc2}
    Should Be Equal As Strings  ${resp.json()['catalogItemGroups'][1]['strength']}          1

JD-TC-AddItemsToItemGroupforUser-5

    [Documentation]  add items to item group with empty list of item ids.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME150}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME150}

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

    ${Items_list}=  Create List    
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    Should Be Equal As Strings  ${resp.json()['strength']}     0

JD-TC-AddItemsToItemGroupforUser-6

    [Documentation]  add a disabled item to a group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME122}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME122}

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

    ${resp}=  Disable Item  ${itemid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Items_list}=  Create List   ${itemid1}  
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_ITEMS_FOUND}


    # ${resp}=  Get Item Group By Id  ${item_group_id1}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()['itemGroupId']}  ${item_group_id1}
    # Should Be Equal As Strings  ${resp.json()['groupName']}    ${groupName1}
    # Should Be Equal As Strings  ${resp.json()['groupDesc']}    ${groupDesc1}
    # Should Be Equal As Strings  ${resp.json()['strength']}     1

    # ${resp}=   Get Item By Id  ${itemid1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200   
    # Should Be Equal As Strings  ${resp.json()['groupIds'][0]}  ${item_group_id1}


JD-TC-AddItemsToItemGroupforUser-7

    [Documentation]  Add items to item group by user.

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
            IF   not '${user_phone}' == '${PUSERNAME140}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User  admin=${bool[0]}
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200


    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

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
    Set Test Variable  ${item_group_id1}  ${resp.json()}

    ${resp}=  Get Item Group   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['itemGroupId']}  ${item_group_id1}
    Should Be Equal As Strings  ${resp.json()[0]['groupName']}    ${groupName1}
    Should Be Equal As Strings  ${resp.json()[0]['groupDesc']}    ${groupDesc1}

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


JD-TC-AddItemsToItemGroupforUser-UH1

    [Documentation]  add a deleted item to a group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME123}

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

    ${resp}=  Delete Item  ${itemid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Items_list}=  Create List   ${itemid1}  
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-AddItemsToItemGroupforUser-UH2

    [Documentation]  add another providers item to a group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Item  ${PUSERNAME123}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
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
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}  ${NO_PERMISSION}


JD-TC-AddItemsToItemGroupforUser-UH3

    [Documentation]  try to add items to a group with another providers item group id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_Item  ${PUSERNAME123}

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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
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

    ${resp}=  ProviderLogout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME123}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Items_list}=  Create List   ${itemid1}  
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NO_ITEM_GROUP_FOUND}


JD-TC-AddItemsToItemGroupforUser-UH4

    [Documentation]  add items to item group without login

    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-AddItemsToItemGroupforUser-UH5

    [Documentation]  Consumer try to add items to an Item group

    ${resp}=  Consumer Login    ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-AddItemsToItemGroupforUser-UH6

    [Documentation]  Add same items multiple times to a group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME124}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME124}

    ${itemdata}=   FakerLibrary.words    	nb=2
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
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

    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422


JD-TC-AddItemsToItemGroupforUser-UH7

    [Documentation]  try to add items to a deleted item group.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
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

    clear_Item  ${PUSERNAME151}

    ${itemdata}=   FakerLibrary.words    	nb=2
    ${itemdata}=    Remove Duplicates    ${itemdata}

    ${displayName1}=   FakerLibrary.user name    
    ${price1}=  Evaluate    random.uniform(50.0,300) 
    ${itemName1}=   Set Variable     ${itemdata[0]} 
    ${itemCode1}=   Set Variable     ${itemdata[1]}
    ${resp}=  Create Sample Item   ${displayName1}   ${itemName1}  ${itemCode1}  ${price1}  ${bool[0]}     
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

    ${resp}=  Delete Item Group By Id  ${item_group_id1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${Items_list}=  Create List   ${itemid1}   
  
    ${resp}=  Add Items To Item Group   ${item_group_id1}    ${Items_list}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  ${NO_ITEM_GROUP_FOUND}