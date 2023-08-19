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



*** Variables ***

${itemName2}   ITEM Name 2
${itemName3}   ITEM Name 3
${itemName4}   ITEM Name 4
${itemName5}   ITEM Name 5
${itemName6}   ITEM Name 6
${itemName7}   ITEM Name 7
${itemName8}   ITEM Name 8
    
${itemCode2}   ITEM Code 2
${itemCode3}   ITEM Code 3
${itemCode4}   ITEM Code 4
${itemCode5}   ITEM Code 5
${itemCode6}   ITEM Code 6
${itemCode7}   ITEM Code 7
${itemCode8}   ITEM Code 8 

@{Percentage_list}   5  12  18  28
${INVALID}     INVALID
@{EMPTY_list}

*** Test Cases ***

JD-TC-Get_Item_By_Criteria-1

    [Documentation]  Provider Get item 
    clear_Item  ${PUSERNAME44}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    
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
    ${price2float}=   Convert To Number   ${price1}  2
    Set Suite Variable  ${price2float}

    # ${pricefloat}=   Evaluate    random.uniform(50.0,300)
    # ${price1float}=  twodigitfloat  ${pricefloat} 
    # Set Suite Variable  ${price1float}  
    # ${taxable}    
    ${itemName1}=   FakerLibrary.name
    Set Suite Variable  ${itemName1}   


    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal1}  
    # ${promoPriceType}--   
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1}

    # ${promoPrice1float}=  twodigitfloat  ${promoPrice1}
    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Suite Variable  ${promoPrice1float}

    # ${promo1}=   Evaluate    random.uniform(0.0,50)
    # ${promotionalPrice1}=  twodigitfloat  ${promo1}
    # Set Suite Variable  ${promotionalPrice1}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}    
    # ${stockAvailable}    
    # ${showOnLandingpage}    
    ${itemCode1}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode1}  
 
    # ${showPromoPrice}    
    # ${promoLabelType}--    
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}


    clear_Item  ${PUSERNAME44}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

     ${resp}=   Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id1}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName3}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode3}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id3}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName4}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode4}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id4}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName5}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id5}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName6}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode6}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id6}  ${resp.json()}


    

    ${resp}=   Get Item By Criteria   id-eq=${id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   displayName-eq=${displayName1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   shortDesc-eq=${shortDesc1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=   Get Item By Criteria   price-eq=${price2float} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=   Get Item By Criteria   taxable-eq=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



    ${resp}=   Get Item By Criteria   itemStatus-eq=${status[0]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Criteria   itemName-eq=${itemName2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Criteria   itemNameInLocal-eq=${itemNameInLocal1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   showOnLandingpage-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Criteria   isStockAvailable-eq=${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Criteria   promotionalPriceType-eq=${promotionalPriceType[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   promotionalPrice-eq=${promoPrice1float} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   promotionalPrcnt-eq=0.0 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   showPromotionalPrice-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   itemCode-eq=${itemCode2} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   promotionLabelType-eq=${promotionLabelType[3]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   promotionLabel-eq=${promoLabel1}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${TODAY}=  db.get_date_by_timezone  ${tz}
    ${resp}=   Get Item By Criteria   createdDate-eq=${TODAY}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    



JD-TC-Get_Item_By_Criteria-2

    [Documentation]  Provider Create item, another provider also uses same details to create item

    clear_Item  ${PUSERNAME45}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Items 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P2_id1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName7}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode7}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${P2_id2}  ${resp.json()}


    ${resp}=   Get Item By Id  ${P2_id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${P2_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   itemName-eq=${itemName1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   itemCode-eq=${itemCode1} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Get_Item_By_Criteria-3

    [Documentation]  Provider Get item
    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Items 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Criteria   promotionalPrice-ge=10   promotionalPrice-le=10000
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   promotionalPrcnt-ge=0.0   promotionalPrcnt-le=90
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    

JD-TC-Get_Item_By_Criteria-UH1
    [Documentation]   Get item Without login

    ${resp}=   Get Item By Criteria   itemCode-eq=${itemCode1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Get_Item_By_Criteria-UH2
    [Documentation]   Login as consumer and Get item
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   itemCode-eq=${itemCode1}   itemName-eq=${itemName1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 
   



JD-TC-Get_Item_By_Criteria-UH3
    [Documentation]  Diable item and Get item
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME45}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Items 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   id-eq=${P2_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
 
    ${resp}=  Disable Item   ${P2_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Criteria   id-eq=${P2_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Get_Item_By_Criteria-UH4
    [Documentation]  Get item using invalid item_id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=50   max=300 

    ${resp}=   Get Item By Id  000
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"

    # -----------------------------------------------------

    ${resp}=   Get Item By Criteria   id-eq=${Invalid_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


# JD-TC-Get_Item_By_Criteria-UH5
#     [Documentation]  Get item using invalid item_display_Name

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200


#     ${resp}=   Get Item By Criteria   displayName-eq=${INVALID} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


# JD-TC-Get_Item_By_Criteria-UH6
#     [Documentation]  Get item using invalid item_description

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get Item By Criteria   shortDesc-eq=${INVALID} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


JD-TC-Get_Item_By_Criteria-UH7
    [Documentation]  Get item using invalid item_Price

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_price}=  Random Int  min=5000   max=10000
    ${resp}=   Get Item By Criteria   price-eq=${Invalid_price} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


JD-TC-Get_Item_By_Criteria-UH8
    [Documentation]  Get item using invalid item_Name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Item By Criteria   itemName-eq=${INVALID} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


JD-TC-Get_Item_By_Criteria-UH9
    [Documentation]  Get item using invalid item_local_name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Item By Criteria   itemNameInLocal-eq=${INVALID}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


JD-TC-Get_Item_By_Criteria-UH10
    [Documentation]  Get item using invalid promotionalPrcnt

    ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_prcnt}=  Random Int  min=5000   max=10000
    ${resp}=   Get Item By Criteria   promotionalPrcnt-eq=${Invalid_prcnt} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


# JD-TC-Get_Item_By_Criteria-UH11
#     [Documentation]  Get item using invalid itemCode

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get Item By Criteria   itemCode-eq=${INVALID} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


# JD-TC-Get_Item_By_Criteria-UH12
#     [Documentation]  Get item using invalid promotionLabel

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=   Get Item By Criteria   promotionLabel-eq=${INVALID}  
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Should Be Equal As Strings  ${resp.json()}    ${EMPTY_list}


# JD-TC-Get_Item_By_Criteria-UH13
#     [Documentation]  Get item using invalid id

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME44}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Get Item By Criteria   taxable-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   itemStatus-eq=${status[0]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   showOnLandingpage-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   isStockAvailable-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   promotionalPriceType-eq=${promotionalPriceType[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   promotionalPrice-eq=${promoPrice1float} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=   Get Item By Criteria   showPromotionalPrice-eq=${bool[1]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${resp}=   Get Item By Criteria   promotionLabelType-eq=${promotionLabelType[3]} 
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${TODAY}=  db.get_date_by_timezone  ${tz}
    # ${resp}=   Get Item By Criteria   createdDate-eq=${TODAY}  
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

