*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${GoogleMeet_url}    https://meet.google.com/gif-pqrs-abc
@{emptylist}



*** Test Cases ***

JD-TC-CheckDepartment-2

    [Documentation]  Get Bill settings for Multi-User Account

    ${providers}=   Get File    /ebs/TDD/varfiles/musers.py
    ${pro_list}=   Split to lines  ${providers}
    ${length}=  Get Length   ${pro_list}

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =
        # delete_virtual_service  ${pro_num}
        # clear_service  ${pro_num}

        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=  Set Variable  ${decrypted_data['sector']}
        ${subdomain}=  Set Variable  ${decrypted_data['subSector']}
        # ${domain}=  Set Variable  ${resp.json()['sector']}
        # ${subdomain}=  Set Variable  ${resp.json()['subSector']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Features  ${sub_domain}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[0]}
            ${resp}=  Toggle Department Enable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[1]}

        ${resp}=  Get Departments
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    FOR  ${pro}  IN  @{pro_list}
        ${pro}=  Remove String    ${pro}    ${SPACE}
        ${pro} 	${pro_num}=   Split String    ${pro}  =
        delete_virtual_service  ${pro_num}
        clear_service  ${pro_num}
        clear_Department    ${pro_num}
        
        ${resp}=  Encrypted Provider Login  ${pro_num}  ${PASSWORD}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=  Set Variable  ${decrypted_data['sector']}
        ${subdomain}=  Set Variable  ${decrypted_data['subSector']}
        # ${domain}=  Set Variable  ${resp.json()['sector']}
        # ${subdomain}=  Set Variable  ${resp.json()['subSector']}

        ${resp}=   Get License UsageInfo 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Features  ${sub_domain}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  Get Service
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        IF  ${resp.json()['filterByDept']}==${bool[0]}
            ${resp}=  Toggle Department Enable
            Log  ${resp.content}
            Should Be Equal As Strings  ${resp.status_code}  200

        END

        ${resp}=  View Waitlist Settings
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200
        Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[1]}

        ${resp}=  Get Departments
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

*** Comment ***

JD-TC-CreateVirtualService-(Billable Subdomain)-17
    [Documentation]   create virtual service for a user
    
    delete_virtual_service  ${MUSERNAME27}
    clear_service  ${MUSERNAME27}
    # clear_Department    ${MUSERNAME27}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${iscorp_subdomains}=  get_iscorp_subdomains  1

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get License Metadata
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[1]}

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END



    ${u_id1}=  Create Sample User

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${USER_U1}  ${resp.json()['mobileNo']}

    ${resp}=  SendProviderResetMail   ${USER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${USER_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${USER_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${PUSERPH1}=  Evaluate  ${PUSERPH0}+110
    # ${resp}=  Enable Disable Virtual Service  Disable
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Disable Virtual Service  Enable
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ZOOM_id0}=  Format String  ${ZOOM_url}  ${MUSERNAME5}
    Set Suite Variable   ${ZOOM_id0}

    ${instructions1}=   FakerLibrary.sentence
    ${instructions2}=   FakerLibrary.sentence

    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${CallingModes[0]}   value=${ZOOM_id0}   status=ACTIVE    instructions=${instructions1} 
    ${VirtualcallingMode2}=   Create Dictionary   callingMode=${CallingModes[1]}   value=${MUSERNAME5}   countryCode=${countryCodes[0]}  status=ACTIVE    instructions=${instructions2} 
    ${vcm1}=  Create List  ${VirtualcallingMode1}   ${VirtualcallingMode2}

    ${resp}=  Update Virtual Calling Mode   ${vcm1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Virtual Calling Mode
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[0]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${ZOOM_id0}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${instructions1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${USER_U1}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${instructions2}

    ${PUSERPH_id}=  Evaluate  ${USER_U1}+10101
    ${ZOOM_Pid0}=  Format String  ${ZOOM_url}  ${PUSERPH_id0}
    Set Suite Variable   ${ZOOM_Pid0}


    Set Test Variable  ${callingMode1}     ${CallingModes[0]}
    Set Test Variable  ${ModeId1}          ${ZOOM_Pid0}
    Set Test Variable  ${ModeStatus1}      ACTIVE
    ${Desc1}=    FakerLibrary.sentence
    ${VirtualcallingMode1}=   Create Dictionary   callingMode=${callingMode1}   value=${ModeId1}   status=${ModeStatus1}   instructions=${Description1}
    ${virtualCallingModes}=  Create List  ${VirtualcallingMode1}

    ${min_pre1}=   Random Int   min=10   max=50
    ${Total1}=   Random Int   min=100   max=500
    ${min_pre1}=  Convert To Number  ${min_pre1}  1
    ${Total1}=  Convert To Number  ${Total1}  1
    ${SERVICE20}=    FakerLibrary.word
    ${description1}=    FakerLibrary.word
    
    Set Test Variable  ${vstype}  ${vservicetype[1]}
    ${leadTime}=   Random Int   min=1   max=5
    ${resp}=  Create Virtual Service For User  ${SERVICE20}   ${description1}   5   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre1}  ${Total1}  ${bool[1]}   ${bool[0]}   ${vstype}  ${virtualCallingModes}  ${dep_id}  ${u_id1}  leadTime=${leadTime}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${S_id20}  ${resp.json()} 
    ${resp}=   Get Service By Id  ${S_id20}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response  ${resp}  name=${SERVICE20}  description=${description1}  serviceDuration=5   notification=${bool[1]}   notificationType=${notifytype[2]}   minPrePaymentAmount=${min_pre1}  totalAmount=${Total1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[1]}  serviceType=virtualService   virtualServiceType=${vstype}  leadTime=${leadTime}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['callingMode']}     ${CallingModes[2]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][0]['instructions']}    ${Desc1}

    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['callingMode']}     ${CallingModes[1]}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['value']}           ${PUSERPH_id}
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['status']}          ACTIVE
    Should Be Equal As Strings  ${resp.json()['virtualCallingModes'][1]['instructions']}    ${Desc2}


*** Comment ***


JD-TC-CreateVirtualService-(Billable Subdomain)-17
    [Documentation]   create virtual service for a user
    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # delete_virtual_service  ${PUSERNAME26}
    # clear_service  ${PUSERNAME26}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['filterByDept']}  ${bool[1]}