*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

@{emptylist} 


*** Test Cases ***





JD-TC-TransferLeadLocation-1

    [Documentation]   change the location of a lead created by a user then verify.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550579
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}
    
    ${p_id}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=   enquiryStatus  ${p_id}
    ${resp}=   leadStatus     ${p_id}
    ${resp}=   categorytype   ${p_id}
    ${resp}=   tasktype       ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}

        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lidname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lidname}  ${resp.json()[0]['place']}
    END

    ${lid1}=  Create Sample Location
    Set Suite Variable  ${lid1}

    ${resp}=   Get Location ById  ${lid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}

    ${lid3}=  Create Sample Location
    Set Suite Variable  ${lid3}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+3366673
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346250
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346350

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3366463
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
  
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346868
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346388

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title1}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title1}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}


    ${resp}=    Transfer Lead Location    ${leUid}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}


JD-TC-TransferLeadLocation-2

    [Documentation]   change the location after update the lead to a location.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title1}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Update Lead    ${leUid}    ${title1}    ${desc}    6      5    ${lid2}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}    ${bool[1]}

    ${resp}=    Transfer Lead Location    ${leUid}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}


JD-TC-TransferLeadLocation-3

    [Documentation]   create multiple leads and assign the same location to all.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title2}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title2}    ${desc}    ${targetPotential}      ${lid3}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${title3}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title3}    ${desc}    ${targetPotential}      ${lid3}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=    Get Leads With Filter    id-eq=${leid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid3}

    ${resp}=    Get Leads With Filter    id-eq=${leid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid3}


# JD-TC-TransferLeadLocation-4

#     [Documentation]   change the location after assign the lead to another user.

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Change Lead Assignee   ${leUid1}  ${u_id1}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${resp}=    Transfer Lead Location    ${leUid1}    ${lid}
#     Log   ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200

#     ${resp}=    Get Leads With Filter    id-eq=${leid1}
#     Log   ${resp.content}
#     Should Be Equal As Strings    ${resp.status_code}    200
#     Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid}


JD-TC-TransferLeadLocation-UH1

    [Documentation]   Create Lead for a branch without giving any location and verify.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${EMPTY}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_REQUIRED}"

JD-TC-TransferLeadLocation-UH2

    [Documentation]   create a lead for user without giving any location and verify.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title1}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title1}    ${desc}    ${targetPotential}      ${EMPTY}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${LOCATION_REQUIRED}"

JD-TC-TransferLeadLocation-UH3

    [Documentation]   change the location with another branch's location id.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Blid}=  Create Sample Location
    Set Suite Variable  ${Blid}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Transfer Lead Location    ${leUid1}    ${Blid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_BUSS_LOC_ID}


JD-TC-TransferLeadLocation-UH4

    [Documentation]   change the location with the same location that already updated.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Transfer Lead Location    ${leUid1}    ${lid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Transfer Lead Location    ${leUid1}    ${lid2}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings    ${resp.json()}    ${ALREADY_UPDATED}

JD-TC-TransferLeadLocation-UH5

    [Documentation]   change the location after completed the lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${p_id}=  get_acc_id  ${PUSERNAME_U1}

    ${resp}=  categorytype  ${p_id}
    ${resp}=  tasktype      ${p_id}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Test Variable  ${status_name1}  ${resp.json()[0]['name']}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word
    # ${status}=  Create Dictionary   id=${status_id1}
    ${status}=  Create Dictionary   id=${status_id}
    ${status1}=  Create Dictionary   id=${status_id1}
    ${status2}=  Create Dictionary   id=${status_id2}
    ${status3}=  Create Dictionary   id=${status_id3}
    ${status4}=  Create Dictionary   id=${status_id4}
    ${status5}=  Create Dictionary   id=${status_id5}
    ${targetPotential}=    FakerLibrary.Building Number

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${lid}    ${pcons_id3}       
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid3}        ${resp.json()['id']}
    Set Suite Variable   ${leUid3}        ${resp.json()['uid']}

    ${resp}=    Change Lead Status    ${leUid3}     ${status_id4}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Transfer Lead Location    ${leUid3}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    id-eq=${leid3}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}

JD-TC-TransferLeadLocation-UH6

    [Documentation]   change the location after canceled the lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Change Lead Status    ${leUid2}     ${status_id3}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Transfer Lead Location    ${leUid2}    ${lid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter    id-eq=${leid2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid1}


JD-TC-TransferLeadLocation-UH7

    [Documentation]   change the location with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Transfer Lead Location    ${leUid3}    ${lid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"

JD-TC-TransferLeadLocation-UH8

    [Documentation]   change the location without login.

    ${resp}=    Transfer Lead Location    ${leUid3}    ${lid}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"




*** comment ***

JD-TC-TransferLeadLocation-8

    [Documentation]   create multiple leads and assign the same location to all.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME80}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200