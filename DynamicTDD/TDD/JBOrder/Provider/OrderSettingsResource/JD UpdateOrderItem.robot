*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ORDER ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Test Cases ***

JD-TC-Update Item-1

    [Documentation]  Provider Update item
    clear_Item  ${PUSERNAME78}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${displayName1}=   FakerLibrary.name 
    Set Suite Variable  ${displayName1}  
    ${shortDesc1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${shortDesc1}   
    ${itemDesc1}=  FakerLibrary.Sentence   nb_words=3 
    Set Suite Variable  ${itemDesc1}   
    ${price1}=  Random Int  min=50   max=300 
    Set Suite Variable  ${price1}
    ${price1float}=  twodigitfloat  ${price1}
    Set Suite Variable  ${price1float}

    
    ${itemName1}=   FakerLibrary.name
    Set Suite Variable  ${itemName1}   

    ${itemName2}=   FakerLibrary.name
    Set Suite Variable  ${itemName2}

    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal1}  
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    Set Suite Variable  ${promoPrice1float}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}    
    ${itemCode1}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode1}  

    ${itemCode2}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode2}  
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}


    ${itemName5}=   FakerLibrary.name
    Set Suite Variable  ${itemName5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  
    ${itemCode5}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode5}  


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Item_id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemName6}=   FakerLibrary.name
    Set Suite Variable  ${itemName6}
    ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal6}  
    ${itemCode6}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode6}

    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Update Item-UH1
    [Documentation]   Update item Without login

    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Update Item-UH2
    [Documentation]   Login as consumer and Update item
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Update Item-UH3
    [Documentation]   A provider try to Update another providers item
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Item_id30}  ${resp.json()}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Order Item    ${Item_id30}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

    

JD-TC-Update Item-UH4
    [Documentation]   A provider try to Update item using Display_Name as EMPTY
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Item_id31}  ${resp.json()}

    ${resp}=  Update Order Item    ${Item_id31}   ${EMPTY}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_DISPLAY_NAME_IS_MUST}"

    



# JD-TC-Create Item-UH1

#     [Documentation]  Provider Create item With same item_name
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     # ${ITEM_CODE_IS_ALREADY_USED}=  Format String       ${ITEM_CODE_ALREADY_USED}   ${itemName1}

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id1}  ${resp.json()}

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"


# JD-TC-Create Item-UH2
#     [Documentation]  Provider Create item with same item_code
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     # Log   ${ITEM_CODE_ALREADY_USED}
#     ${ITEM_CODE_IS_ALREADY_USED}=  Format String     ${ITEM_CODE_ALREADY_USED}   ${itemCode1}
#     Set Suite Variable  ${ITEM_CODE_IS_ALREADY_USED}


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id2}  ${resp.json()}

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_ALREADY_USED}"



# JD-TC-Create Item-UH3

#     [Documentation]  Diable item and create another item with same Item_Name
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id3}  ${resp.json()}

#     ${resp}=  Disable Item   ${Item_id3}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"


# JD-TC-Create Item-UH4
#     [Documentation]  Diable item and create another item with same Item_code
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id4}  ${resp.json()}

#     ${resp}=  Disable Item   ${Item_id4}
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_ALREADY_USED}"


# JD-TC-Create Item-UH5
#     [Documentation]  Create item with using item_code as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${EMPTY}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_MUST}"



# JD-TC-Create Item-UH6
#     [Documentation]  Update item details, except item_name. Again create item with same item_name
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${itemName5}=   FakerLibrary.name
#     Set Suite Variable  ${itemName5}
#     ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
#     Set Suite Variable  ${itemNameInLocal5}  
#     ${itemCode5}=   FakerLibrary.word 
#     Set Suite Variable  ${itemCode5}  


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id6}  ${resp.json()}

#     ${resp}=   Get Item By Id  ${Item_id6} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${itemName6}=   FakerLibrary.name
#     Set Suite Variable  ${itemName6}
#     ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
#     Set Suite Variable  ${itemNameInLocal6}  
#     ${itemCode6}=   FakerLibrary.word 
#     Set Suite Variable  ${itemCode6}

#     ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Item By Id  ${Item_id6} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422




# JD-TC-Create Item-UH7
#     [Documentation]  Update item details, except item_code. Again create item with same item_code
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${itemName5}=   FakerLibrary.name
#     Set Suite Variable  ${itemName5}
#     ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
#     Set Suite Variable  ${itemNameInLocal5}  
#     ${itemCode5}=   FakerLibrary.word 
#     Set Suite Variable  ${itemCode5}  


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id6}  ${resp.json()}

#     ${resp}=   Get Item By Id  ${Item_id6} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${itemName6}=   FakerLibrary.name
#     Set Suite Variable  ${itemName6}
#     ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
#     Set Suite Variable  ${itemNameInLocal6}  
#     ${itemCode6}=   FakerLibrary.word 
#     Set Suite Variable  ${itemCode6}

#     ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName6}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode5}      
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=   Get Item By Id  ${Item_id6} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200


#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422



#     # ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     # Should Be Equal As Strings  ${resp.status_code}  200
#     # Set Test Variable  ${id2}  ${resp.json()}


# JD-TC-Create Item-UH8
#     [Documentation]  Create item with using DISPLAY_NAME as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${EMPTY}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  422


# JD-TC-Create Item-UH9
#     [Documentation]  Create item with using ITEM_PRICE as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${EMPTY}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRICE}"


# JD-TC-Create Item-UH10
#     [Documentation]  Create item with using ITEM_PROMOTIONAL_PRICE as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${EMPTY}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRICE}"


# JD-TC-Create Item-UH11
#     [Documentation]  Create item with using both ITEM_PRICE and ITEM_PROMOTIONAL_PRICE as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${EMPTY}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${EMPTY}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRICE}"


# JD-TC-Create Item-UH12
#     [Documentation]  Create item with using ITEM_NAME_IN_LOCAL as EMPTY
    
#     clear_Item  ${PUSERNAME78}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${EMPTY}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  422
#     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PRICE}"

