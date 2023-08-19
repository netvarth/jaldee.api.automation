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
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-Remove_Item_Label-1
	[Documentation]   Remove label from a valid item
    clear_Item  ${PUSERNAME19}
    ${resp}=  ProviderLogin  ${PUSERNAME19}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
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
    ${itemName1}=   FakerLibrary.name
    Set Suite Variable  ${itemName1}   
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
    ${itemCode1}=   FakerLibrary.word 
    Set Suite Variable  ${itemCode1}  
    ${promoLabel1}=   FakerLibrary.word 
    Set Suite Variable  ${promoLabel1}


    ${resp}=  Create Order Item    ${displayName1}    ${shortDesc1}    ${itemDesc1}    ${price1}    ${bool[1]}    ${itemName1}    ${itemNameInLocal1}    ${promotionalPriceType[1]}    ${promoPrice1}   ${promotionalPrcnt1}    ${note1}    ${bool[1]}    ${bool[1]}    ${itemCode1}    ${bool[1]}    ${promotionLabelType[3]}    ${promoLabel1}      
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()}

    ${resp}=   Get Item By Id  ${id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # Verify Response  ${resp}  displayName=${displayName1}  shortDesc=${shortDesc1}   price=${price2float}   taxable=${bool[1]}   status=${status[0]}    itemName=${itemName1}  itemNameInLocal=${itemNameInLocal1}  isShowOnLandingpage=${bool[1]}   isStockAvailable=${bool[1]}   
    # Verify Response  ${resp}  promotionalPriceType=${promotionalPriceType[1]}   promotionalPrice=${promoPrice1float}    promotionalPrcnt=0.0   showPromotionalPrice=${bool[1]}   itemCode=${itemCode1}   promotionLabelType=${promotionLabelType[3]}   promotionLabel=${promoLabel1}   


    clear_Label  ${PUSERNAME19}
    ${Values}=  FakerLibrary.Words  	nb=9
    Set Suite Variable  ${Values}
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${Values[1]}  ${Values[2]}  ${Values[3]}  ${Values[4]}  ${Values[5]}
    Set Suite Variable  ${ValueSet}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Values[6]}  ${Values[2]}  ${Values[7]}  ${Values[4]}  ${Values[8]}
    Set Suite Variable  ${NotificationSet}
    ${l_name}=  FakerLibrary.Words  nb=2
    Set Suite Variable  ${l_name}
    ${l_desc}=  FakerLibrary.Sentence
    Set Suite Variable  ${l_desc}
    ${resp}=  Create Label  ${l_name[0]}  ${l_name[1]}  ${l_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${label_id}  ${resp.json()}
    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}  ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}  ${l_name[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}  ${l_name[1]}
    Should Be Equal As Strings  ${resp.json()['description']}  ${l_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}  ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}  ${Values[3]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}  ${Values[5]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}  ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Values[6]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}  ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Values[7]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}  ${Values[4]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Values[8]}


    ${resp}=   Add Item Label   ${id}    ${l_name[0]}=${Values[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


    ${resp}=   Remove Item Label   ${id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Item By Id  ${id} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 




JD-TC-Remove_Item_Label-UH1
    [Documentation]  Remove a label which is already Removed
    ${resp}=  ProviderLogin  ${PUSERNAME19}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Remove Item Label   ${id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOTFOUND}"


JD-TC-Remove_Item_Label -UH2
    [Documentation]   Remove a label without login  
    ${resp}=   Remove Item Label   ${id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 

JD-TC-Remove_Item_Label -UH3
    [Documentation]   Consumer Remove a label
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Remove Item Label   ${id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-Remove_Item_Label-UH4
    [Documentation]  Remove an invalid label 
    ${resp}=  ProviderLogin  ${PUSERNAME19}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Remove Item Label   ${id}    INVALID_LABEL_NAME
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"


JD-TC-Remove_Item_Label-UH5
    [Documentation]  Remove a Label by item_id which is not exist
    ${resp}=  ProviderLogin  ${PUSERNAME19}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-10   max=0
    ${resp}=   Remove Item Label   ${invalid_id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"


JD-TC-Remove_Item_Label-UH6
    [Documentation]  Remove a Label by id of another provider
    ${resp}=  ProviderLogin  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Remove Item Label   ${id}    ${l_name[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LABEL_NOT_EXIST}"



