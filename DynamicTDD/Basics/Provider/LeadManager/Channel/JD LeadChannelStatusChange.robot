*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Test Cases ***

JD-TC-Lead_Channel_Status_change-1

    [Documentation]   Lead Channel status Chnage

    ${resp}=  Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD}
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

 