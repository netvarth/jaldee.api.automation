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

    [Documentation]   Create Inventory Item With Item Options

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

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem1}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem2}   ${resp.json()[1]['spCode']}

    #Create item 2
    ${values2}   Create List   S    M    L
    ${option2}=  Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${itemAttributes2}=  Create List  ${option2} 
    ${name2}=            FakerLibrary.name
    ${resp}=    Create Item Inventory   ${name2}    isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item2}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem21}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem22}   ${resp.json()[1]['spCode']}
    Set Suite Variable     ${singleItem23}   ${resp.json()[2]['spCode']}

    #Create item 3
    ${values3}   Create List   Men    Women
    ${option3}=  Create Dictionary  attribute=type  position=${1}  values=${values3}
    ${itemAttributes3}=  Create List  ${option3} 
    ${name3}=            FakerLibrary.name
    ${resp}=    Create Item Inventory   ${name3}    isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item3}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    #Create inventory catalog and add virtual items(with all of its single items)
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

    ${resp}=   Create Inventory Catalog Item   ${inv_cat_encid1}   ${item}   ${item2}  ${item3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}

    ${resp}=  Get Inventory Catalog By EncId   ${inv_cat_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    
JD-TC-CreateItemWithOptions-2

    [Documentation]   Create Inventory Item With Item Options 2nd case 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

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

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem1}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem2}   ${resp.json()[1]['spCode']}

    #Create item 2
    ${values2}   Create List   S    M    L
    ${option2}=  Create Dictionary  attribute=size  position=${1}  values=${values2}
    ${itemAttributes2}=  Create List  ${option2} 
    ${name2}=            FakerLibrary.name
    ${resp}=    Create Item Inventory   ${name2}    isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes2}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item2}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item2}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200
    Set Suite Variable     ${singleItem21}   ${resp.json()[0]['spCode']}   
    Set Suite Variable     ${singleItem22}   ${resp.json()[1]['spCode']}
    Set Suite Variable     ${singleItem23}   ${resp.json()[2]['spCode']}

    #Create item 3
    ${values3}   Create List   Men    Women
    ${option3}=  Create Dictionary  attribute=type  position=${1}  values=${values3}
    ${itemAttributes3}=  Create List  ${option3} 
    ${name3}=            FakerLibrary.name
    ${resp}=    Create Item Inventory   ${name3}    isBatchApplicable=${boolean[0]}   isInventoryItem=${boolean[1]}   itemNature=${ItemNature[1]}   itemAttributes=${itemAttributes3}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${item3}  ${resp.json()}

    ${resp}=    Get Item Inventory  ${item3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Get Item inv Filter   parentItemSpCode-eq=${item3}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}    200

    #Create inventory catalog and add virtual items with specified single items
    ${resp}=  Create Inventory Catalog   ${Name}  ${store_id}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${inv_cat_encid1}  ${resp.json()}
    ${inv_cat_encid}=  Create List  ${inv_cat_encid1}

    #Create item1- single items
    ${item1}=  Create Dictionary   spCode= ${singleItem1}
    ${item1}=  Create Dictionary   item=${item1}
    ${item12}=  Create Dictionary   spCode=${singleItem2}
    ${item12}=  Create Dictionary   item=${item12}
    ${singleItems}=  Create List   ${item1}   ${item12}

    #Create item2- single items
    ${item21}=  Create Dictionary   spCode=${singleItem21}
    ${item21}=  Create Dictionary   item=${item21}
    ${item22}=  Create Dictionary   spCode=${singleItem22}
    ${item22}=  Create Dictionary   item=${item22}
    ${item23}=  Create Dictionary   spCode=${singleItem23}
    ${item23}=  Create Dictionary   item=${item23}
    ${singleItems2}=  Create List   ${item21}  # ${item22}   ${item23}

    ${item_spcode}=  Create Dictionary   spCode= ${item}
    ${first_dict}=  Create Dictionary   item=${item_spcode}  singleItems=${singleItems}

    ${resp}=   Create Inventory Catalog Item   ${inv_cat_encid1}   ${item}   ${item2}  ${item3}   singleItems=${singleItems}    singleItems=${singleItems2}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${Inv_Cata_Item_Encid1}  ${resp.json()[0]}

    ${resp}=  Get Inventory Catalog By EncId   ${inv_cat_encid1}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200



