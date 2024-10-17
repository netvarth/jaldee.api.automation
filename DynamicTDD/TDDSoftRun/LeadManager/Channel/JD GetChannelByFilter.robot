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

JD-TC-Get_Channel_By_Filter-1

    [Documentation]   Get Channel By Filter

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
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

    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable      ${DAY1}

    ${typeName1}=    FakerLibrary.Name
    Set Suite Variable      ${typeName1}

    ${resp}=    Create Lead Product  ${typeName1}  ${productEnum[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${lpid}     ${resp.json()} 

    ${resp}=    Get Lead Product By Uid  ${lpid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable              ${productId}    ${resp.json()['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable      ${lid}      ${resp.json()[0]['id']}
    Set Suite Variable      ${place}    ${resp.json()[0]['place']}

    ${lid}=     Create Dictionary  id=${lid}
    ${loc_id}=  Create List   ${lid}

    ${ChannelName1}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName1}
    
    ${crmLeadProductTypeDto}=   Create Dictionary   uid=${lpid}

    ${resp}=    Create Lead Channel  ${ChannelName1}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid}     ${resp.json()} 

    ${resp}=    Get Lead Channel By Uid  ${clid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable              ${id1}  ${resp.json()['id']}

    ${ChannelName2}=    FakerLibrary.Name
    Set Suite Variable      ${ChannelName2}
    
    ${crmLeadProductTypeDto}=   Create Dictionary   uid=${lpid}

    ${resp}=    Create Lead Channel  ${ChannelName2}  ${leadchannel[0]}  ${crmLeadProductTypeDto}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Set Suite Variable      ${clid2}     ${resp.json()} 

    ${resp}=    Get Lead Channel By Uid  ${clid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Set Suite Variable              ${id2}  ${resp.json()['id']}

    ${resp}=    Get Lead Channel By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-2

    [Documentation]   Get Channel By Filter - by id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  id-eq=${id1}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-3

    [Documentation]   Get Channel By Filter - by account id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  account-eq=${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}      200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-4

    [Documentation]   Get Lead Channel By Filter - by uid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  uid-eq=${clid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-5

    [Documentation]   Get Lead Channel By Filter - by name

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  name-eq=${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.status_code}      200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}


JD-TC-Get_Channel_By_Filter-6

    [Documentation]   Get Lead Channel By Filter - by channelType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  channelType-eq=${leadchannel[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-7

    [Documentation]   Get Lead Channel By Filter - by crmLeadProductTypeName

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  crmLeadProductTypeName-eq=${typeName1}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-8

    [Documentation]   Get Lead Channel By Filter - by crmStatus

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  crmStatus-eq=${status[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}

JD-TC-Get_Channel_By_Filter-9

    [Documentation]   Get Lead Channel By Filter - by productType

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  productType-eq=${productId}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}


JD-TC-Get_Channel_By_Filter-10

    [Documentation]   Get Lead Channel By Filter - by location

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  location-eq=${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}


JD-TC-Get_Channel_By_Filter-11

    [Documentation]   Get Lead Channel By Filter - by createdDate

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Lead Channel By Filter  createdDate-eq=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             200
    Should Be Equal As Strings      ${resp.json()[0]['uid']}                                   ${clid2}
    Should Be Equal As Strings      ${resp.json()[0]['name']}                                  ${ChannelName2}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[0]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[0]['channelType']}                           ${leadchannel[0]}

    Should Be Equal As Strings      ${resp.json()[1]['uid']}                                   ${clid}
    Should Be Equal As Strings      ${resp.json()[1]['name']}                                  ${ChannelName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['account']}      ${accountId}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['typeName']}     ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['productEnum']}  ${productEnum[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['uid']}          ${lpid}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeDto']['crmStatus']}    ${status[0]}
    Should Be Equal As Strings      ${resp.json()[1]['crmLeadProductTypeName']}                ${typeName1}
    Should Be Equal As Strings      ${resp.json()[1]['channelType']}                           ${leadchannel[0]}


JD-TC-Get_Channel_By_Filter-UH1

    [Documentation]   Get Lead Channel By Filter - without login

    ${resp}=    Get Lead Channel By Filter
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}        419
    Should Be Equal As Strings    ${resp.json()}            ${SESSION_EXPIRED}

JD-TC-Get_Channel_By_Filter-UH2

    [Documentation]   Get Lead Channel By Filter 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD}
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

    ${resp}=    Get Lead Channel By Filter  id-name=${ChannelName2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}             422
    Should Be Equal As Strings    ${resp.json()}         ${CRM_LEAD_DISABLED}

