*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PURCHASE 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${fileSize}     0.00458
${order}        0
${originFrom}       NONE

*** Test Cases ***


JD-TC-EbableDisableInventoryRX-1

    [Documentation]  Ebable Disable Inventory RX

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[0]}

    ${resp1}=  Enable/Disable Inventory Rx  ${toggle[0]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[1]}

JD-TC-EbableDisableInventoryRX-UH1

    [Documentation]  Ebable Disable Inventory RX - status enable to enable  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[1]}

    ${resp1}=  Enable/Disable Inventory Rx  ${toggle[0]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings      ${resp1.json()}          ${INVTRY_RX_ALREADY_ENABLED}


JD-TC-EbableDisableInventoryRX-2

    [Documentation]  Ebable Disable Inventory RX - enable to disable

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[1]}

    ${resp1}=  Enable/Disable Inventory Rx  ${toggle[1]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[0]}

JD-TC-EbableDisableInventoryRX-UH2

    [Documentation]  Ebable Disable Inventory RX - status disable to disaable  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[0]}

    ${resp1}=  Enable/Disable Inventory Rx  ${toggle[1]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  422
    Should Be Equal As Strings      ${resp1.json()}          ${INVTRY_RX_ALREADY_DISABLED}

JD-TC-EbableDisableInventoryRX-3

    [Documentation]  Ebable Disable Inventory RX - disable to enaable

    ${resp}=  Encrypted Provider Login  ${PUSERNAME108}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[0]}

    ${resp1}=  Enable/Disable Inventory Rx  ${toggle[0]}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableInventoryRx']}  ${bool[1]}