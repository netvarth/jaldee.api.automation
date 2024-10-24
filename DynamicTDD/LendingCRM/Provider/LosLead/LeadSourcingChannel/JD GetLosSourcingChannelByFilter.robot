*** Settings ***

Suite Teardown     Delete All Sessions
Test Teardown      Delete All Sessions
Force Tags         LOS Lead
Library            Collections
Library            String
Library            json
Library            FakerLibrary
Library            /ebs/TDD/db.py
Library            /ebs/TDD/excelfuncs.py
Resource           /ebs/TDD/ProviderKeywords.robot
Resource           /ebs/TDD/ConsumerKeywords.robot
Resource           /ebs/TDD/ProviderConsumerKeywords.robot
Resource           /ebs/TDD/ProviderPartnerKeywords.robot
Variables          /ebs/TDD/varfiles/providers.py
Variables          /ebs/TDD/varfiles/consumerlist.py 
Variables          /ebs/TDD/varfiles/hl_providers.py

*** Test Cases ***

JD-TC-GetLeadSourcingChannelByFilter-1

    [Documentation]  Get Lead Sourcing Channel By Filter- with no params

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings            ${resp.status_code}  200
    Set Suite Variable                    ${account_id}       ${resp.json()['id']}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable      ${lid}  ${resp.json()[0]['id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${SCname}=    FakerLibrary.name
    Set Suite Variable  ${SCname}

    ${resp}=    Create Los Lead Sourcing Channel  ${SCname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid}     ${resp.json()['uid']}

    ${SCname2}=    FakerLibrary.name
    Set Suite Variable  ${SCname2}


    ${resp}=    Create Los Lead Sourcing Channel  ${SCname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${sourcinguid2}     ${resp.json()['uid']}

    ${resp}=    Get Los Sourcing Channel
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Set Suite Variable      ${id2}  ${resp.json()[0]['id']}
    Set Suite Variable      ${id1}  ${resp.json()[1]['id']}
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[1]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[1]['status']}   ${toggle[0]}

JD-TC-GetLeadSourcingChannelByFilter-2

    [Documentation]  Get Lead Sourcing Channel By Filter- by id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel   id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[0]}


JD-TC-GetLeadSourcingChannelByFilter-3

    [Documentation]  Get Lead Sourcing Channel By Filter- by account

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel   account-eq=${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[1]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[1]['status']}   ${toggle[0]}


JD-TC-GetLeadSourcingChannelByFilter-4

    [Documentation]  Get Lead Sourcing Channel By Filter- by status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel   status-eq=${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[0]}
    Should Be Equal As Strings    ${resp.json()[1]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[1]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[1]['status']}   ${toggle[0]}


JD-TC-GetLeadSourcingChannelByFilter-5

    [Documentation]  Get Lead Sourcing Channel By Filter- by status after changeing one status to disable

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Channel Status  ${sourcinguid2}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Sourcing Channel   status-eq=${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[1]}


JD-TC-GetLeadSourcingChannelByFilter-6

    [Documentation]  Get Lead Sourcing Channel By Filter- by created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel   createdBy-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()[1]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[1]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[1]['status']}   ${toggle[0]}


JD-TC-GetLeadSourcingChannelByFilter-7

    [Documentation]  Get Lead Sourcing Channel By Filter- by created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel   createdDate-eq=${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}      ${sourcinguid2}
    Should Be Equal As Strings    ${resp.json()[0]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[0]['name']}     ${SCname2}
    Should Be Equal As Strings    ${resp.json()[0]['status']}   ${toggle[1]}
    Should Be Equal As Strings    ${resp.json()[1]['uid']}      ${sourcinguid}
    Should Be Equal As Strings    ${resp.json()[1]['account']}  ${account_id}
    Should Be Equal As Strings    ${resp.json()[1]['name']}     ${SCname}
    Should Be Equal As Strings    ${resp.json()[1]['status']}   ${toggle[0]}


JD-TC-GetLeadSourcingChannelByFilter-UH1

    [Documentation]  Get Lead Sourcing Channel By Filter- by invalid id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Sourcing Channel   id-eq=${inv_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        []


JD-TC-GetLeadSourcingChannelByFilter-UH2

    [Documentation]  Get Lead Sourcing Channel By Filter- by invalid account_id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_acc_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Sourcing Channel   account-eq=${inv_acc_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        []


JD-TC-GetLeadSourcingChannelByFilter-UH3

    [Documentation]  Get Lead Sourcing Channel By Filter- by invalid created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_creater}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Sourcing Channel   createdBy-eq=${inv_creater}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        []


JD-TC-GetLeadSourcingChannelByFilter-UH4

    [Documentation]  Get Lead Sourcing Channel By Filter- by invalid created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY2}=  db.add_timezone_date  ${tz}  10   

    ${resp}=    Get Los Sourcing Channel   createdDate-eq=${DAY2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        []


JD-TC-GetLeadSourcingChannelByFilter-UH5

    [Documentation]  Get Lead Sourcing Channel By Filter- without login

    ${resp}=    Get Los Sourcing Channel  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-GetLeadSourcingChannelByFilter-UH6

    [Documentation]  Get Lead Sourcing Channel By Filter- by another provder login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Sourcing Channel
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        []