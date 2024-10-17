*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Test Cases ***

JD-TC-Update_Channel-1

    [Documentation]   Update Channel - channel name is updated

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${accountId}        ${resp.json()['id']}

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${typeName1}=    FakerLibrary.Name
    Set Suite Variable      ${typeName1}

    ${resp}=    Create Lead Product  ${typeName1}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200

    ${ChannelName1}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName1}
    
    ${crmLeadProductTypeDto}=   Create Dictionary   uid=${lpid}

    ${resp}=    Create Lead Channel  ${ChannelName1}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid}     ${resp.json()} 

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}                                     200
    Should Be Equal As Strings      ${resp.json()['name']}                                  ${ChannelName1}

    ${ChannelName2}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName2}

    ${resp}=    Update Lead Channel  ${clid}  ${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings      ${resp.json()['name']}  ${ChannelName2}

JD-TC-Update_Channel-2

    [Documentation]   Update Channel - update with same name 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Channel  ${clid}  ${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200

JD-TC-Update_Channel-UH1

    [Documentation]   Update Channel - channel name is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead Channel  ${clid}  ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      422
    Should Be Equal As Strings    ${resp.json()}             ${CHANNEL_NAME_SIZE}

JD-TC-Update_Channel-UH2

    [Documentation]   Update Channel - uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1111  max=9999
    ${ChannelName3}=    FakerLibrary.Name

    ${resp}=    Update Lead Channel  ${inv}  ${ChannelName3}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      422
    Should Be Equal As Strings    ${resp.json()}            ${INVALID_CHANNEL_ID}

JD-TC-Update_Channel-UH3

    [Documentation]   Update Channel - without login

    ${resp}=    Update Lead Channel  ${clid}  ${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

JD-TC-Update_Channel-UH4

    [Documentation]   Update Channel - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME33}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[0]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${resp}=    Update Lead Channel  ${clid}  ${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      401
    Should Be Equal As Strings    ${resp.json()}            ${NO_PERMISSION}

JD-TC-Update_Channel-UH5

    [Documentation]   Update Channel - create a channel and updating it with an existing channel name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME105}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${ChannelName_n}=    FakerLibrary.Name
    
    ${crmLeadProductTypeDto}=   Create Dictionary   uid=${lpid}

    ${resp}=    Create Lead Channel  ${ChannelName_n}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid_n}     ${resp.json()} 

    ${resp}=    Get Lead Channel By Uid  ${clid_n}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}                                     200
    Should Be Equal As Strings      ${resp.json()['name']}                                  ${ChannelName_n}

    ${resp}=    Update Lead Channel  ${clid_n}  ${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      422
    Should Be Equal As Strings    ${resp.json()}            ${CHANNEL_NAME_CANT_BE_SAME}


JD-TC-Update_Product-UH6

    [Documentation]   Update Product - where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME58}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    IF  '${resp.json()['enableCrmLead']}'=='${bool[1]}'

        ${resp}=    Enable Disable CRM Lead  ${toggle[1]}
        Log  ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END

    ${ChannelName3}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName3}

    ${resp}=    Update Lead Channel  ${clid}  ${ChannelName3}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CRM_LEAD_DISABLED}