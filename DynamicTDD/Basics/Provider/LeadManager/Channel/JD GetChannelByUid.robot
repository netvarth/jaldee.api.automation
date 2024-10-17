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

JD-TC-Get_Channel-1

    [Documentation]   Get Channel 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
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
    Should Be Equal As Strings      ${resp.json()['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel-2

    [Documentation]   Get Channel By Uid - where uid is empty

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Uid  ${empty}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200

JD-TC-Get_Channel-3

    [Documentation]   Get Channel By Uid - after updating product which added in crm crmLeadProductTypeDto

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${typeName_z}=    FakerLibrary.Name

    ${resp}=    Update Lead Product  ${lpid}  ${typeName_z}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['typeName']}     ${typeName_z}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()['crmLeadProductTypeName']}                ${typeName_z}
    Should Be Equal As Strings      ${resp.json()['channelType']}                           ${leadchannel[0]}


JD-TC-Get_Channel-UH1

    [Documentation]   Get Channel By Uid - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME103}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Get Lead Channel By Uid  ${inv}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${INVALID_CHANNEL_ID}

JD-TC-Get_Channel-UH2

    [Documentation]   Get Channel By Uid - without login

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-Get_Channel-UH3

    [Documentation]   Get Channel By Uid - with another provider login

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
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

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}        ${NO_PERMISSION}