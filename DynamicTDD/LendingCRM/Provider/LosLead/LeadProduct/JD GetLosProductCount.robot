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

JD-TC-GetLeadProductCountByFilter-1

    [Documentation]  Get Lead Product Count By Filter- with no params

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

    ${Pname}=    FakerLibrary.name
    Set Suite Variable  ${Pname}

    ${resp}=    Create Los Lead Product  ${losProduct[0]}  ${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid}     ${resp.json()['uid']}

    ${Pname2}=    FakerLibrary.name
    Set Suite Variable  ${Pname2}


    ${resp}=    Create Los Lead Product  ${losProduct[1]}  ${Pname2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${productuid2}     ${resp.json()['uid']}

    ${resp}=    Get Los Product
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Set Suite Variable      ${id2}  ${resp.json()[0]['id']}
    Set Suite Variable      ${id1}  ${resp.json()[1]['id']}
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadProductCountByFilter-2

    [Documentation]  Get Lead Product Count By Filter- by id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   id-eq=${id2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-3

    [Documentation]  Get Lead Product Count By Filter- by account

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   account-eq=${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   account-eq=${account_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-4

    [Documentation]  Get Lead Product Count By Filter- by status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   status-eq=${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   status-eq=${toggle[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}

JD-TC-GetLeadProductCountByFilter-5

    [Documentation]  Get Lead Product Count By Filter- by status after changeing one status to disable

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Update Los Lead Product Status  ${productuid2}  ${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200

    ${resp}=    Get Los Product   status-eq=${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   status-eq=${toggle[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-6

    [Documentation]  Get Lead Product Count By Filter- by created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   createdBy-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   createdBy-eq=${pid}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-7

    [Documentation]  Get Lead Product Count By Filter- by created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   createdDate-eq=${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   createdDate-eq=${DAY}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-8

    [Documentation]  Get Lead Product Count By Filter- by losProduct

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   losProduct-eq=${losProduct[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}          ${productuid2}
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   losProduct-eq=${losProduct[1]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-9

    [Documentation]  Get Lead Product Count By Filter- by name

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product   name-eq=${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()[0]['uid']}          ${productuid2}
    
    ${length}=   Get Length  ${resp.json()}

    ${resp}=    Get Los Product Count   name-eq=${Pname}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}        200
    Should Be Equal As Strings    ${resp.json()}        ${length}


JD-TC-GetLeadProductCountByFilter-UH1

    [Documentation]  Get Lead Product Count By Filter- by invalid id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Product Count   id-eq=${inv_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0


JD-TC-GetLeadProductCountByFilter-UH2

    [Documentation]  Get Lead Product Count By Filter- by invalid account_id

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_acc_id}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Product Count   account-eq=${inv_acc_id}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0


JD-TC-GetLeadProductCountByFilter-UH3

    [Documentation]  Get Lead Product Count By Filter- by invalid created by

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${inv_creater}=      Random int  min=9999  max=99999

    ${resp}=    Get Los Product Count   createdBy-eq=${inv_creater}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0


JD-TC-GetLeadProductCountByFilter-UH4

    [Documentation]  Get Lead Product Count By Filter- by invalid created date

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${DAY2}=  db.add_timezone_date  ${tz}  10   

    ${resp}=    Get Los Product Count   createdDate-eq=${DAY2}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0


JD-TC-GetLeadProductCountByFilter-UH5

    [Documentation]  Get Lead Product Count By Filter- without login

    ${resp}=    Get Los Product Count  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   419
    Should Be Equal As Strings    ${resp.json()}        ${SESSION_EXPIRED}

JD-TC-GetLeadProductCountByFilter-UH6

    [Documentation]  Get Lead Product Count By Filter- by another provder login

    ${resp}=   Encrypted Provider Login  ${PUSERNAME100}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product Count
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0


JD-TC-GetLeadProductCountByFilter-UH7

    [Documentation]  Get Lead Product Count By Filter- by losProduct which is not used

    ${resp}=   Encrypted Provider Login  ${PUSERNAME9}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Los Product Count   losProduct-eq=${losProduct[2]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings    ${resp.json()}        0