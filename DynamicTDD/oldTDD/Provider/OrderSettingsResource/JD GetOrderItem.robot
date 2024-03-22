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

JD-TC-Get_Item_By_Id-1

    [Documentation]  Provider Create item taxable is true and false
    clear_Item  ${PUSERNAME30}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
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
    ${price2float}=   Convert To Number   ${price1}  2
    Set Suite Variable  ${price2float}



    ${itemNameInLocal1}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal1}  
 
    ${promoPrice1}=  Random Int  min=10   max=${price1} 
    Set Suite Variable  ${promoPrice1}

    ${promoPrice1float}=   Convert To Number   ${promoPrice1}  2
    Set Suite Variable  ${promoPrice1float}

    ${promoPrcnt1}=   Evaluate    random.uniform(0.0,80)
    ${promotionalPrcnt1}=  twodigitfloat  ${promoPrcnt1}
    Set Suite Variable  ${promotionalPrcnt1}
    ${note1}=  FakerLibrary.Sentence
    Set Suite Variable  ${note1}   
 
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}
    
    ${itemName1}=   FakerLibrary.word 
    Set Suite Variable  ${itemName1}
    
    ${itemName2}=   FakerLibrary.name 
    Set Suite Variable  ${itemName2}

    ${itemCode1}=   FakerLibrary.name 
    Set Suite Variable  ${itemCode1}

    ${itemCode2}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode2}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[0]}    ${bool[0]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id1}  ${resp.json()}

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[0]}   isStockAvailable=${bool[0]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[0]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

    ${resp}=   Get Item By Id  ${id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   

JD-TC-Get_Item_By_Id-2
    [Documentation]  Provider Create item taxable is true and false
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Item By Criteria   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName2}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode2}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName2}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode2}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    
    ${resp}=   Get Item By Criteria  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-Get_Item_By_Id-3

    [Documentation]  Provider Create item, another provider also uses same details to create item
    clear_Item  ${PUSERNAME30}
    clear_Item  ${PUSERNAME35}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Item By Criteria  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P1_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${P1_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    sleep   2s
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Get Item By Criteria  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${P2_id2}  ${resp.json()}

    ${resp}=   Get Item By Id  ${P2_id2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[0]}   promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    
*** Comments ***
JD-TC-Get_Item_By_Id-4

    [Documentation]  Provider Create item using Promotional_Price_Type as FIXED
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price2float}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1float}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id3}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    


JD-TC-Get_Item_By_Id-5

    [Documentation]  Provider Create item using Promotional_Price_Type as PERCENTAGE
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[2]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id4}  ${resp.json()}

    ${Prcnt_Price}=   Evaluate   ${price1} * ${promotionalPrcnt1}
    ${Prcnt_Price1}=   Evaluate    ${Prcnt_Price} / 100 
    ${PromoPrcnt_Price}=   Convert To Number   ${Prcnt_Price1}  2
    # ${PromoPrcnt_Price}=  twodigitfloat  ${Prcnt_Price2}


    ${resp}=   Get Item By Id  ${id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[2]}   promotionalPrice=${PromoPrcnt_Price}    promotionalPrcnt=${promotionalPrcnt1}   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
       



JD-TC-Get_Item_By_Id-6

    [Documentation]  Provider Create item Promotional_Label_Type as NONE
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
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
  


JD-TC-Get_Item_By_Id-7

    [Documentation]  Provider Create item Promotional_Label_Type as CLEARANCE
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[1]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[1]}   promotionLabel=${promoLabelType[1]}   



JD-TC-Get_Item_By_Id-8

    [Documentation]  Provider Create item Promotional_Label_Type as ONSALE
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[2]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id7}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id7} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[2]}   promotionLabel=${promoLabelType[2]}   



JD-TC-Get_Item_By_Id-9

    [Documentation]  Provider Create item Promotional_Label_Type as CUSTOM
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${id8}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id8} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   



JD-TC-Get_Item_By_Id-10
    [Documentation]  Update all item details, and create another item using previously created item details
    
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  

    ${itemName5}=   FakerLibrary.word 
    Set Suite Variable  ${itemName5}

    ${itemCode5}=   FakerLibrary.firstname 
    Set Suite Variable  ${itemCode5}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal6}  

    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName6}    ${itemNameInLocal6}    ${bool[1]}        ${bool[1]}        ${promotionalPriceType[1]}   ${promoPrice1}   ${promotionalPrcnt1}       ${bool[1]}    ${note1}        ${promotionLabelType[3]}    ${promoLabel1}     ${itemCode6}          
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName6}    ${itemNameInLocal6}    ${bool[1]}        ${bool[1]}        ${promotionalPriceType[1]}   ${promoPrice1}   ${promotionalPrcnt1}       ${bool[1]}    ${note1}        ${promotionLabelType[3]}    ${promoLabel1}     ${itemCode6}          
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200



JD-TC-Get_Item_By_Id-11
    [Documentation]  Create item with using ITEM_NAME_IN_LOCAL as EMPTY
    
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${EMPTY}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id12}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id12} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName5}  itemNameInLocal=${EMPTY}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode5}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   



JD-TC-Get_Item_By_Id-12
    [Documentation]  Diable item and Get item
    
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Item_id4}  ${resp.json()}

    ${resp}=  Disable Item   ${Item_id4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Get_Item_By_Id-13
    [Documentation]  Update item details and get item
    
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${itemNameInLocal5}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal5}  
  


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${Item_id6}  ${resp.json()}

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${itemNameInLocal6}=  FakerLibrary.Sentence   nb_words=2 
    Set Suite Variable  ${itemNameInLocal6}  


    ${resp}=  Update Order Item    ${Item_id6}   ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${status[0]}   ${itemName5}    ${itemNameInLocal6}    ${bool[1]}    ${bool[1]}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${bool[1]}   ${note1}    ${promotionLabelType[3]}    ${promoLabel1}    ${itemCode6}      
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id6} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200




JD-TC-Get_Item_By_Id-UH1

    [Documentation]  Get item using invalid id
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Invalid_id}=  Random Int  min=50   max=300 

    ${resp}=   Get Item By Id  ${Invalid_id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"



JD-TC-Get_Item_By_Id-UH2
    [Documentation]   Create item Without login

    ${resp}=   Get Item By Id  ${Item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Get_Item_By_Id-UH3
    [Documentation]   Login as consumer and Get item
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



JD-TC-Get_Item_By_Id-UH4
    [Documentation]   A provider try to Get another providers item
    clear_Item  ${PUSERNAME30}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[0]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Item_id30}  ${resp.json()}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${Item_id30} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"



# JD-TC-Get_Item_By_Id-11
#     [Documentation]  Create item with using DISPLAY_NAME as EMPTY
    
#     clear_Item  ${PUSERNAME30}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME30}  ${PASSWORD}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=  Create Order Item    ${EMPTY}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[0]}    ${itemName5}    ${itemNameInLocal5}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode5}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
#     Should Be Equal As Strings  ${resp.status_code}  200
#     Set Test Variable  ${Item_id11}  ${resp.json()}

#     ${resp}=   Get Item By Id  ${Item_id11} 
#     Log   ${resp.json()}
#     Should Be Equal As Strings  ${resp.status_code}  200
#     # Verify Response  ${resp}  displayName=${EMPTY}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[0]}   status=${status[0]}    itemName=${itemName5}  itemNameInLocal=${itemNameInLocal5}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
#     # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode5}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   


    