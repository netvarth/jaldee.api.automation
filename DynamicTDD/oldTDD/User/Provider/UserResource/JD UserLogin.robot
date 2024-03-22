***Settings***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        User
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_musers.py


*** Variables ***
${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facial
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
@{emptylist} 

***Test Cases***

JD-TC-UserLoginwithEmail-1

    [Documentation]  Create an user and user  login with email

    ${resp}=   Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${p_id1}=  get_acc_id  ${HLMUSERNAME4}
    Set Suite Variable   ${p_id1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId1}=  Create Sample Location
        Set Suite Variable  ${locId1}
        ${resp}=   Get Location ById  ${locId1}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId1}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id      ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${PUSERNAME_U1}     ${resp.json()['mobileNo']}
    Set Suite Variable      ${email}     ${resp.json()['email']}

    


    ${resp}=  SendProviderResetMail   ${email}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${email}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${email}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable     ${lid}  ${resp.json()[0]['id']}

JD-TC-UserLoginwithEmail-UH1

    [Documentation]  user try to login with invalid password two times.

    
    ${resp}=  Encrypted Provider Login  ${email}  ${SPASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings    ${resp.json()}     ${LOGIN_INVALID_USERID_PASSWORD}

    ${resp}=  Encrypted Provider Login  ${email}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401

    ${resp}=  Encrypted Provider Login  ${email}  ${SPASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401

    ${resp}=  Encrypted Provider Login  ${email}  asdfghj123
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401