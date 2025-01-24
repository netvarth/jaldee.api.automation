*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ITEM 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-CreateItemWithOptions-1

    [Documentation]   Create Item With Item Options

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_A}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_A}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  ${resp.json()['enableInventory']}==${bool[0]}
        ${resp1}=  Enable Disable Inventory  ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${values1}   Create List  Black   Red   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
    ${itemAttributes}=  Create List  ${option1} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

JD-TC-CreateItemWithOptions-2

    [Documentation]   Create Item With Item Options-Giving more than 5 attributes 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${colour1}=   FakerLibrary.name
    ${colour2}=   FakerLibrary.word
    ${values1}    Create List  ${colour1}   ${colour2}
    ${option1}=   Create Dictionary  attribute=color  position=${2}  values=${values1}
    ${size1}=     FakerLibrary.name
    ${size2}=     FakerLibrary.word
    ${values2}    Create List  ${size1}   ${size2}
    ${option2}=   Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${attributeValue3}=    FakerLibrary.name
    ${attributeValue31}=   FakerLibrary.word
    ${values3}    Create List  ${attributeValue3}   ${attributeValue31}
    ${option3}=   Create Dictionary  attribute=attribute3  position=${2}  values=${values3}  
    ${attributeValue4}=    FakerLibrary.name
    ${attributeValue41}=   FakerLibrary.word
    ${values4}    Create List  ${attributeValue4}   ${attributeValue41}
    ${option4}=   Create Dictionary  attribute=attribute4  position=${5}  values=${values4}  
    ${attributeValue5}=    FakerLibrary.name
    ${attributeValue51}=   FakerLibrary.word
    ${values5}    Create List  ${attributeValue5}   ${attributeValue51}
    ${option5}=   Create Dictionary  attribute=attribute5  position=${3}  values=${values5} 
    ${attributeValue6}=   FakerLibrary.name
    ${attributeValue61}=   FakerLibrary.word
    ${values6}    Create List  ${attributeValue6}   ${attributeValue61}
    ${option6}=   Create Dictionary  attribute=attribute6  position=${4}  values=${values6} 
    ${itemAttributes}=   Create List  ${option1}   ${option2}   ${option3}   ${option4}   ${option5}   ${option6}  
    ${name}=             FakerLibrary.name
    ${shortDesc}=        FakerLibrary.sentence
    ${internalDesc}=     FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${MAX_SPITEM_ATTRIBUTE_NUM}

JD-TC-CreateItemWithOptions-3

    [Documentation]   Create Item With Item Options- Giving repeated attribute name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attributeValue1}=    FakerLibrary.name
    ${attributeValue11}=   FakerLibrary.word
    ${values1}   Create List  ${attributeValue1}   ${attributeValue1}
    ${option1}=  Create Dictionary  attribute=attribute1  position=${2}  values=${values1} 
     ${attributeValue2}=   FakerLibrary.name
    ${attributeValue21}=   FakerLibrary.word
    ${values2}    Create List  ${attributeValue2}   ${attributeValue21}
    ${option2}=   Create Dictionary  attribute=attribute1  position=${3}  values=${values2} 
    ${attributeValue3}=    FakerLibrary.name
    ${attributeValue31}=   FakerLibrary.word
    ${values3}    Create List  ${attributeValue3}   ${attributeValue31}
    ${option3}=   Create Dictionary  attribute=attribute6  position=${4}  values=${values3}  
    ${attributeValue4}=    FakerLibrary.name
    ${attributeValue41}=   FakerLibrary.word
    ${values4}    Create List  ${attributeValue4}   ${attributeValue41}
    ${option4}=   Create Dictionary  attribute=attribute4  position=${5}  values=${values4}  
   
    ${itemAttributes}=   Create List  ${option1}   ${option2}   ${option3}   ${option4}  
    ${name}=             FakerLibrary.name
    ${shortDesc}=        FakerLibrary.sentence
    ${internalDesc}=     FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${ATTRIBUTES_CANT_REPEAT}

JD-TC-CreateItemWithOptions-4

    [Documentation]   Create Item With Item Options- Giving repeated values for an attribute

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attributeValue1}=   FakerLibrary.name
    ${attributeValue11}=  FakerLibrary.word
    ${values1}   Create List  ${attributeValue1}   ${attributeValue11}
    ${option1}=  Create Dictionary  attribute=attribute1  position=${2}  values=${values1} 
     ${attributeValue2}=   FakerLibrary.name
    ${attributeValue21}=   FakerLibrary.word
    ${values2}   Create List  ${attributeValue2}   ${attributeValue21}   ${attributeValue21}   ${attributeValue2}
    ${option2}=  Create Dictionary  attribute=attribute2  position=${3}  values=${values2} 
    ${attributeValue3}=   FakerLibrary.name
    ${attributeValue31}=  FakerLibrary.word
    ${values3}   Create List  ${attributeValue3}   ${attributeValue31}
    ${option3}=  Create Dictionary  attribute=attribute6  position=${4}  values=${values3}  
  
    ${itemAttributes}=  Create List  ${option1}   ${option2}   ${option3}   
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    ${ATTRIBUTES_VALUES_CANT_REPEAT}=  format String   ${ATTRIBUTES_VALUES_CANT_REPEAT}  attribute2 
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${ATTRIBUTES_VALUES_CANT_REPEAT}  

JD-TC-CreateItemWithOptions-5

    [Documentation]   Create Item With Item Options- Giving empty array as values for an attribute

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${attributeValue1}=   FakerLibrary.name
    ${attributeValue11}=  FakerLibrary.word
    ${values1}   Create List  ${attributeValue1}   ${attributeValue11}
    ${option1}=  Create Dictionary  attribute=attribute1  position=${2}  values=${values1} 
     ${attributeValue2}=   FakerLibrary.name
    ${attributeValue21}=   FakerLibrary.word
    ${values2}   Create List  
    ${option2}=  Create Dictionary  attribute=attribute2  position=${3}  values=${values2} 
    ${attributeValue3}=    FakerLibrary.name
    ${attributeValue31}=   FakerLibrary.word
    ${values3}   Create List  ${attributeValue3}   ${attributeValue31}
    ${option3}=  Create Dictionary  attribute=attribute6  position=${4}  values=${values3}  
  
    ${itemAttributes}=  Create List  ${option1}   ${option2}   ${option3}   
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    ${VALUES_CANT_BE_EMPTY}=  format String   ${VALUES_CANT_BE_EMPTY}  attribute2 
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${VALUES_CANT_BE_EMPTY}  

JD-TC-CreateItemWithOptions-6

    [Documentation]   Create Item With Item Options- Giving empty array for item attribute

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${itemAttributes}=  Create List     
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    ${GIVEN_FIELD_CANT_BE_EMPTY}=  format String   ${GIVEN_FIELD_CANT_BE_EMPTY}  attributes 
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${GIVEN_FIELD_CANT_BE_EMPTY}  

JD-TC-CreateItemWithOptions-7

    [Documentation]   Create Item With Item Options- Giving empty for item attribute name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${values1}   Create List  Black   Red   White
    ${option1}=  Create Dictionary  attribute=    position=${1}   values=${values1}
    ${itemAttributes}=  Create List  ${option1} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    ${INVALID_FIELD}=  format String   ${INVALID_FIELD}   attribute name 
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FIELD}

JD-TC-CreateItemWithOptionsReset-8

    [Documentation]   Create Item With Item Options- Check the single item names based on the attribute position colour-1, size-2 Reset Item With Item Options- attribute position changed to: colour-2, size-1 Check the single item names 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${values1}   Create List  Black   Red   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
    ${values2}    Create List  S   M
    ${option2}=   Create Dictionary  attribute=size  position=${2}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}   ${option2} 
    ${name}=            FakerLibrary.name
    Set Suite Variable      ${name}
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[0]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 

    ${option1}=  Create Dictionary  attribute=color  position=${2}  values=${values1}
    ${option2}=   Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}     ${option2} 

    ${resp}=   Reset SP Item    ${name}   ${item}    itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 



