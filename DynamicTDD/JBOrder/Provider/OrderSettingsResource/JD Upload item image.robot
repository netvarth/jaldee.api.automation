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
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Test Cases ***

JD-TC-Upload item Image-1
    [Documentation]   Provider check to upload item image when displayImage is true
    clear_Item  ${PUSERNAME12}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   ${id}   ${boolean[1]}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    ${resp}=   Get Item By Id   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[1]}    
    # Should Contain  ${resp.json()['itemImages']}  /item/${id}/ 



JD-TC-Upload item Image-2
    [Documentation]   Provider check to again upload item image when displayImage is false
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   ${id}   ${boolean[0]}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME12}  ${PASSWORD}
    ${resp}=   Get Item By Id   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[0]} 
    Should Be Equal As Strings    ${resp.json()['itemImages'][1]['displayImage']}   ${bool[1]}



JD-TC-Upload item Image-UH1

    [Documentation]  Provider check to upload item image with another provider itemid
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   ${id}   ${boolean[1]}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    


JD-TC-Upload item Image-UH2

    [Documentation]  Provider check to upload item image with invalid itemid
    
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   0   ${boolean[1]}   ${cookie}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${NO_ITEM_FOUND}"


JD-TC-Upload item Image-UH3

    [Documentation]  Consumer check to upload item image  
    
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadItemImages    ${id}   ${boolean[1]}    ${cookie}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Upload item Image-UH4

    [Documentation]  delete item upload without login 
    ${empty_cookie}=  Create Dictionary
    ${resp}=  uploadItemImages    ${id}   ${boolean[1]}  ${empty_cookie} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  
   
 
 