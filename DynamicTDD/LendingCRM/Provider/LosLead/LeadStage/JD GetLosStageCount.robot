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

JD-TC-GetLeadStageCountByFilter-1

    [Documentation]  Get Lead Stage Count By Filter- with no params

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

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

    ${Sname}=    FakerLibrary.name
    Set Suite Variable  ${Sname}

    ${resp}=    Create Los Lead Stage  ${losProduct[0]}  ${stageType[1]}  ${Sname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid}     ${resp.json()['uid']}

    ${Sname2}=    FakerLibrary.name
    Set Suite Variable  ${Sname2}

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${stageType[1]}  ${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid2}     ${resp.json()['uid']}

    ${Sname3}=    FakerLibrary.name
    Set Suite Variable  ${Sname3}

    ${resp}=    Create Los Lead Stage  ${losProduct[1]}  ${stageType[2]}  ${Sname3}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${stageuid3}     ${resp.json()['uid']}

    ${resp}=    Get Los Stage
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Set Suite Variable      ${id3}  ${resp.json()[0]['id']}
    Set Suite Variable      ${id2}  ${resp.json()[1]['id']}
    Set Suite Variable      ${id1}  ${resp.json()[2]['id']}

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-2

    [Documentation]  Get Lead Stage Count By Filter- by id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-3

    [Documentation]  Get Lead Stage Count By Filter- by account

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   account-eq=${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   account-eq=${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-4

    [Documentation]  Get Lead Stage Count By Filter- by status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   status-eq=${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   status-eq=${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-5

    [Documentation]  Get Lead Stage Count By Filter- by status after changeing one status to disable

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Stage Status  ${stageuid2}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Stage   status-eq=${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   status-eq=${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-6

    [Documentation]  Get Lead Stage Count By Filter- by created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   createdBy-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   createdBy-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-7

    [Documentation]  Get Lead Stage Count By Filter- by created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   createdDate-eq=${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   createdDate-eq=${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-8

    [Documentation]  Get Lead Stage Count By Filter- by losProduct

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   losProduct-eq=${losProduct[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   losProduct-eq=${losProduct[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-9

    [Documentation]  Get Lead Stage Count By Filter- by name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   name-eq=${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   name-eq=${Sname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-10

    [Documentation]  Get Lead Stage Count By Filter- by stageType

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   stageType-eq=${stageType[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   stageType-eq=${stageType[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH1

    [Documentation]  Get Lead Stage Count By Filter- by invalid id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Stage   id-eq=${inv_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   id-eq=${inv_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH2

    [Documentation]  Get Lead Stage Count By Filter- by invalid account_id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_acc_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Stage   account-eq=${inv_acc_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   account-eq=${inv_acc_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH3

    [Documentation]  Get Lead Stage Count By Filter- by invalid created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_creater}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Stage   createdBy-eq=${inv_creater}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   createdBy-eq=${inv_creater}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH4

    [Documentation]  Get Lead Stage Count By Filter- by invalid created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY2}=  db.add_timezone_date  ${tz}  10   

    ${resp}=    Get Los Stage   createdDate-eq=${DAY2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   createdDate-eq=${DAY2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH5

    [Documentation]  Get Lead Stage Count By Filter- without login

    ${resp}=    Get Los Stage Count 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-GetLeadStageCountByFilter-UH6

    [Documentation]  Get Lead Stage Count By Filter- by another provder login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp2}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp2.status_code}  200

    IF  '${resp2.json()['jaldeeLending']}'=='${bool[0]}'

        ${resp}=    Enable Disable Jaldee Lending  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    IF  '${resp2.json()['losLead']}'=='${bool[0]}'

        ${resp}=    Enable Disable Lending Lead  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200

    END

    ${resp}=    Get Los Stage Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


JD-TC-GetLeadStageCountByFilter-UH7

    [Documentation]  Get Lead Stage Count By Filter- by losProduct which is not used

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   losProduct-eq=${losProduct[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   losProduct-eq=${losProduct[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadStageCountByFilter-UH8

    [Documentation]  Get Lead Stage Count By Filter- by stageType which is not used

    ${resp}=   Encrypted Provider Login  ${PUSERNAME35}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Stage   stageType-eq=${stageType[3]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Stage Count   stageType-eq=${stageType[3]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}