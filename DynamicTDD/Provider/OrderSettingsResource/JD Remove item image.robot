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


JD-TC-Remove item Image-1
    [Documentation]  Provider check to remove item image
    clear_Item  ${PUSERNAME13}
    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
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

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   uploadItemImages   ${id}   ${boolean[1]}   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    ${resp}=   Get Item By Id   ${id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Be Equal As Strings  ${resp.json()['itemImages']}   ${EMPTY}
    Should Be Equal As Strings    ${resp.json()['itemImages'][0]['displayImage']}   ${bool[1]}
    Set Suite Variable  ${imgName}   ${resp.json()['itemImages'][0]['keyName']}


    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  DeleteItemImages    ${id}  ${imgName}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME13}  ${PASSWORD}
    ${resp}=   Get Item By Id   ${id}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Not Contain   ${resp.json()}   itemImages


JD-TC-Remove item Image-UH1
    [Documentation]  Provider check to remove item image with another provider itemid
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME50}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  DeleteItemImages    ${id}  ${imgName}  ${cookie}
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}   "${NO_PERMISSION}"


JD-TC-Remove item Image-UH2
    [Documentation]  Provider check to delete item with invalid itemid
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  DeleteItemImages    0  ${imgName}  ${cookie}
    Log  ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}    "${NO_ITEM_FOUND}"


JD-TC-Remove item Image-UH3
    [Documentation]  Provider check to delete item with invalid image_Name
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  DeleteItemImages    ${id}  INVALID_IMAGE_NAME  ${cookie}
    Log   ${resp.content} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.content}  "${IMAGE_NOT_FOUND_IN_ITEM}"


JD-TC-Remove item Image-UH4
    [Documentation]  Consumer check to remove item image 
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  DeleteItemImages    ${id}  ${imgName}  ${cookie}
    Log  ${resp.content}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}    "${LOGIN_NO_ACCESS_FOR_URL}"


JD-TC-Remove item Image-UH5 
    [Documentation]   Provider check to delete item image without login 
    ${empty_cookie}=  Create Dictionary
    ${resp}=  DeleteItemImages    ${id}  ${imgName}  ${empty_cookie}
    Log  ${resp.content}   
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}    "${SESSION_EXPIRED}"


