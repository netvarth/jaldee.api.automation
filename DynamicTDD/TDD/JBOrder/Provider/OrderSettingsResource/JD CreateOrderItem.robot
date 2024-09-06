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
${countryCode}   +91
${itemName111}     itemName111
${itemName222}     itemName222
${itemCode111}     itemCode111
${itemCode222}     itemCode222

*** Test Cases ***

JD-TC-Create Item-1

    [Documentation]  Provider Create item taxable is true and false
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']} 
    Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
   
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

    ${itemName2}=   FakerLibrary.name
    Set Suite Variable  ${itemName2}

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

    ${itemCode2}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode2} 
    # ${showPromoPrice}    
    # ${promoLabelType}--    
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}



    ${resp}=   Get Item By Id  ${id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[0]}   isStockAvailable=${bool[0]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[0]}   itemCode=${itemCode1}  
    # #  promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${resp}=   Get Item By Id  ${id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    # # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price1}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1}    promotionalPrcnt=${promotionalPrcnt1}   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   




JD-TC-Create Item-2
    [Documentation]  Provider Create item taxable is true and false
    clear_Item  ${PUSERNAME14}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME14}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   



JD-TC-Create Item-3
    [Documentation]  Provider Create item, another provider also uses same details to create item
    clear_Item  ${PUSERNAME34}
    clear_Item  ${PUSERNAME35}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[0]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P1_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${P1_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[0]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P2_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${P2_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[0]}   promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    

JD-TC-Create Item-4
    [Documentation]  Provider Create item using Promotional_Price_Type as FIXED
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price2float}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1float}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    



JD-TC-Create Item-5
    [Documentation]  Provider Create item using Promotional_Price_Type as PERCENTAGE
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id4}  ${resp.json()}

    ${Prcnt_Price}=   Evaluate   ${price1} * ${promotionalPrcnt1}
    ${Prcnt_Price1}=   Evaluate    ${Prcnt_Price} / 100 
    ${Prcnt_Price2}=   Convert To Number   ${Prcnt_Price1}  2
    ${PromoPrcnt_Price}=  twodigitfloat  ${Prcnt_Price2}

    ${resp}=   Get Item By Id  ${id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[2]}   promotionalPrice=${PromoPrcnt_Price}    promotionalPrcnt=${promotionalPrcnt1}   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
       



JD-TC-Create Item-6
    [Documentation]  Provider Create item Promotional_Label_Type as NONE
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[0]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id5}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[0]}     
    # Should Not Contain   ${resp.json()}  "promotionLabel":"${promoLabel1}"
    # promotionLabel=${promoLabel1} 


JD-TC-Create Item-7
    [Documentation]  Provider Create item Promotional_Label_Type as CLEARANCE
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[1]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[1]}   promotionLabel=${promoLabelType[1]}   



JD-TC-Create Item-8
    [Documentation]  Provider Create item Promotional_Label_Type as ONSALE
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[2]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id7}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id7} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[2]}   promotionLabel=${promoLabelType[2]}   



JD-TC-Create Item-9
    [Documentation]  Provider Create item Promotional_Label_Type as CUSTOM
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id8}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id8} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   



JD-TC-Create Item-10
    [Documentation]  Update all item details, and create another item using previously created item details
    
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemName5}=   FakerLibrary.name
    Set Suite Variable  ${itemName5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  
    ${itemCode5}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode5}  


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemName6}=   FakerLibrary.name
    Set Suite Variable  ${itemName6}
    ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal6}  
    ${itemCode6}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode6}


    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName6}    ${itemNameInLocal6}    ${bool[1]}        ${bool[1]}        ${promotionalPriceType[1]}   ${promoPrice1}   ${promotionalPrcnt1}       ${bool[1]}    ${note1}        ${promotionLabelType[3]}    ${promoLabel1}     ${itemCode6}          
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create Item-11
    [Documentation]  Create item with using ITEM_NAME_IN_LOCAL as EMPTY
    
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${EMPTY}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Create Item-12
    [Documentation]  Provider Create item With same Display_name, but different item_name and item_code
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName111}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode111}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id111}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName222}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode222}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id222}  ${resp.json()}


JD-TC-Create Item-13
    [Documentation]  Create item with using item_code as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${EMPTY}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_MUST}"



JD-TC-Create Item-UH1
    [Documentation]  Provider Create item With same item_name
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"


JD-TC-Create Item-UH2
    [Documentation]  Create item with using DISPLAY_NAME as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${EMPTY}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_DISPLAY_NAME_IS_MUST}"
    

JD-TC-Create Item-UH3

    [Documentation]  Provider Create item With Promotional_Price_Type as NONE, and Show_Promotional_Price as TRUE
    clear_Item  ${PUSERNAME34} 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[0]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROMOTIONAL_TYPE}"


JD-TC-Create Item-UH4
    [Documentation]  Provider Create item with same item_code
    
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # Log   ${ITEM_CODE_ALREADY_USED}
    ${ITEM_CODE_IS_ALREADY_USED}=  Format String     ${ITEM_CODE_ALREADY_USED}   ${itemCode1}
    Set Suite Variable  ${ITEM_CODE_IS_ALREADY_USED}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id2}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_ALREADY_USED}"



JD-TC-Create Item-UH5
    [Documentation]  Diable item and create another item with same Item_Name
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id3}  ${resp.json()}

    ${resp}=  Disable Item   ${Item_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"



JD-TC-Create Item-UH6
    [Documentation]  Diable item and create another item with same Item_code
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id4}  ${resp.json()}

    ${resp}=  Disable Item   ${Item_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_ALREADY_USED}"



JD-TC-Create Item-UH7
    [Documentation]  Create item with using item_Name as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${EMPTY}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_IS_MUST}"



JD-TC-Create Item-UH8
    [Documentation]  Update item details, except item_name. Again create item with same item_name
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemName5}=   FakerLibrary.name
    Set Suite Variable  ${itemName5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  
    ${itemCode5}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode5}  


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id6}  ${resp.json()}

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


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_NAME_SHOULD_BE_UNIQUE}"



JD-TC-Create Item-UH9
    [Documentation]  Update item details, except item_code. Again create item with same item_code
    
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemName5}=   FakerLibrary.name
    Set Suite Variable  ${itemName5}
    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  
    ${itemCode5}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode5}  


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemName6}=   FakerLibrary.name
    Set Suite Variable  ${itemName6}
    ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal6}  
    ${itemCode6}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode6}


    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName6}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}        ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}    ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode5}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ITEM_CODE_IS_ALREADY_USED}=  Format String     ${ITEM_CODE_ALREADY_USED}   ${itemCode5}
    Set Suite Variable  ${ITEM_CODE_IS_ALREADY_USED}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITEM_CODE_IS_ALREADY_USED}"


    # ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${id2}  ${resp.json()}



JD-TC-Create Item-UH10
    [Documentation]  Create item with using ITEM_PRICE as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_ITEM_PRICE}=  Format String       ${INVALID_PRICE}    item

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${EMPTY}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ITEM_PRICE}"



JD-TC-Create Item-UH11
    [Documentation]  Create item with using ITEM_PROMOTIONAL_PRICE as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_PROMOTIONAL_PRICE}=  Format String       ${INVALID_PRICE}    item promotional

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${EMPTY}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_PROMOTIONAL_PRICE}"



JD-TC-Create Item-UH12
    [Documentation]  Create item with using both ITEM_PRICE and ITEM_PROMOTIONAL_PRICE as EMPTY
    clear_Item  ${PUSERNAME34}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${INVALID_ITEM_PRICE}=  Format String       ${INVALID_PRICE}    item
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${EMPTY}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${EMPTY}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ITEM_PRICE}"



JD-TC-Create Item-UH13
    [Documentation]  Provider Create item With Promotional_Price_Type as PERCENTAGE, and Promotional_Percentage as EMPTY
    clear_Item  ${PUSERNAME34} 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${EMPTY}   ${EMPTY}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROM_PCT_SHOULD_GT_ZERO}"


JD-TC-Create Item-UH14
    [Documentation]  Provider Create item With Promotional_Price greater than item_price
    clear_Item  ${PUSERNAME34} 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${High_promoprice1}=  Random Int  min=${price1+1}   max=1000 
 
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${High_promoprice1}   ${EMPTY}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ITM_PRICE_SHOULD_GT_PROM_PRICE}"



JD-TC-Create Item-UH15
    [Documentation]  Provider Create item With Promotional_Prcnt greater than item_price
    clear_Item  ${PUSERNAME34} 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME34}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${High_promoprcnt1}=  Random Int  min=101   max=200
 
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${EMPTY}   ${High_promoprcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${PROM_PCT_SHOULD_LT_HUNDRED}"



JD-TC-Create Item-UH16
    [Documentation]   Create item Without login
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Create Item-UH17
    [Documentation]   Login as consumer and Create item
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


