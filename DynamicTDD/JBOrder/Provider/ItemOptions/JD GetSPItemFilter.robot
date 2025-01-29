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

JD-TC-GetSPItemFilter-1

    [Documentation]   Create Inventory Item and then get sp item filter with itemNature

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ......... Create Store .........

    ${TypeName}=    FakerLibrary.name
    Set Test Variable  ${TypeName}

    ${resp}=  Create Store Type   ${TypeName}    ${storeNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable    ${St_Id}    ${resp.json()}

    ${resp}=  Get Store Type By EncId   ${St_Id}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${licid}  ${licname}=  get_highest_license_pkg
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERNAME_B}=  Provider Signup without Profile  LicenseId=${licid}
    Set Suite Variable  ${PUSERNAME_B}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
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

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Test Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Test Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${SName}=    FakerLibrary.last name
    ${PhoneNumber}=  Evaluate  ${PUSERNAME}+100187748
    Set Test Variable  ${email_id}  ${SName}${PhoneNumber}.${test_mail}
    ${email}=  Create List  ${email_id}
    Set Test Variable      ${SName}

    ${resp}=  Create Store   ${SName}   ${St_Id}    ${locId1}   ${email}     ${PhoneNumber}   ${countryCodes[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable            ${store_id}           ${resp.json()} 

    # Create item 1
    ${values1}   Create List  Black   Red   White
    ${option1}=  Create Dictionary  attribute=color  position=${1}  values=${values1}
    ${itemAttributes}=  Create List  ${option1} 
    ${name}=            FakerLibrary.name
    ${shortDesc}=       FakerLibrary.sentence
    ${internalDesc}=    FakerLibrary.sentence
    ${resp}=    Create Item Inventory   ${name}   shortDesc=${shortDesc}   internalDesc=${internalDesc}   isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   itemNature-eq=${ItemNature[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['itemNature']}    ${ItemNature[1]}
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['attribute']}    color
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['position']}        1
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][0]}    Black
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][1]}    Red
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][2]}    White

JD-TC-GetSPItemFilter-2

    [Documentation]   Create Inventory Item and then get sp item filter with itemSellingType


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    #Create item 2
    ${values2}   Create List   S    M    L
    ${option2}=  Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${itemAttributes2}=  Create List  ${option2} 
    ${name2}=            FakerLibrary.name
    ${resp}=    Create Item Inventory   ${name2}    isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item2}  ${resp.json()}

    ${resp}=    Get Item inv Filter   itemSellingType-eq=${ItemSellingType[2]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['itemNature']}    ${ItemNature[1]}
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['attribute']}    size
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['position']}        1
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][0]}    S
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][1]}    M
    Should Be Equal As Strings    ${resp.json()[0]['itemAttributes'][0]['values'][2]}    L

JD-TC-GetSPItemFilter-UH1

    [Documentation]   Create Inventory Item and then get sp item filter with itemSellingType as bundled_item


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Item inv Filter   itemSellingType-eq=${ItemSellingType[1]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}   []

JD-TC-GetSPItemFilter-UH2

    [Documentation]   Create Inventory Item and then get sp item filter with itemSellingType as INDIVIDUAL_ITEM


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Item inv Filter   itemSellingType-eq=${ItemSellingType[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}   []

JD-TC-GetSPItemFilter-UH3

    [Documentation]   Create Inventory Item and then get sp item filter with ItemNature as single item


    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Item inv Filter   itemNature-eq=${ItemNature[0]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}   []

JD-TC-GetSPItemFilter-UH4

    [Documentation]   Create Inventory Item and then get sp item filter with ItemNature as service

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=    Get Item inv Filter   itemNature-eq=${ItemNature[2]}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}   []
