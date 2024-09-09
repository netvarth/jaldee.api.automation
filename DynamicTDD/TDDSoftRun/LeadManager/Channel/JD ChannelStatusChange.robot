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

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
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

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}   200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}    ${status[1]}

JD-TC-Lead_Channel_Status_change-2

    [Documentation]   Lead Channel status Chnage - inactive to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

JD-TC-Lead_Channel_Status_change-UH1

    [Documentation]   Lead Channel status Chnage - inactive to inactive

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[1]}

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CHANNEL_STATUS_INACTIVE}

JD-TC-Lead_Channel_Status_change-UH2

    [Documentation]   Lead Channel status Chnage - active to active

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()['crmStatus']}     ${status[0]}

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}            ${CHANNEL_STATUS_ACTIVE}

JD-TC-Lead_Channel_Status_change-UH3

    [Documentation]   Lead Channel status Chnage - where uid is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=1  max=999

    ${resp}=    Lead Channel Status Change  ${inv}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200
    Should Be Equal As Strings    ${resp.json()}            ${bool[0]}

JD-TC-Lead_Channel_Status_change-UH4

    [Documentation]   Lead Channel status Chnage - without login

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

    
JD-TC-Lead_Channel_Status_change-UH5

    [Documentation]   Lead Channel status Chnage - trying to change status by another provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME39}  ${PASSWORD}
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

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     401
    Should Be Equal As Strings    ${resp.json()}         ${NO_PERMISSION}

JD-TC-Lead_Channel_Status_change-UH6

    [Documentation]   Lead Channel status Chnage - trying to change status where crm lead is disabled

    ${resp}=  Encrypted Provider Login  ${PUSERNAME104}  ${PASSWORD}
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

    ${resp}=    Lead Channel Status Change  ${clid}  ${status[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}