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

    [Documentation]   Create Item With Item Options- Check the single item names based on the attribute position colour-1, size-2 Reset Item With Item Options- attribute position changed to: colour-2, size-1 Check the single item names 


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
    
    ${values1}    Create List  red   black   white
    ${option1}=   Create Dictionary  attribute=color  position=${1}  values=${values1}
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

    ${option1}=   Create Dictionary  attribute=color  position=${2}  values=${values1}
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

    ${values3}    Create List  FakerLibrary.name   FakerLibrary.name
    ${option1}=   Create Dictionary  attribute=color  position=${3}  values=${values1}
    ${option2}=   Create Dictionary  attribute=size  position=${2}  values=${values2}
    ${option3}=   Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${itemAttributes}=  Create List  ${option1}     ${option2}   ${option3}

    ${resp}=   Reset SP Item    ${name}   ${item}    itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200 