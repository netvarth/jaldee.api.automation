*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Task
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py


*** Variables ***

@{emptylist} 
${count}       ${5}

*** Test Cases ***


JD-TC-TaskReport-1

    [Documentation]  Generate Task Report For Location Filter

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME7}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}   ${resp.json()[0]['name']}

    ${resp}=    Get Task Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id1}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_name1}  ${resp.json()[0]['name']}
    Set Suite Variable  ${status_id2}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[1]['name']}
    Set Suite Variable  ${status_id3}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_name3}  ${resp.json()[2]['name']}
    Set Suite Variable  ${status_id4}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_name4}  ${resp.json()[3]['name']}
    Set Suite Variable  ${status_id5}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_name5}  ${resp.json()[4]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_id1} =  Convert To String  ${category_id1} 
    Set Suite Variable            ${category_id1} 

    ${locId}=  Convert To String  ${locId}
    Set Suite Variable            ${locId}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   location-eq=${locId}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  02s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['date']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['reportHeader']['Location']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-2

    [Documentation]  Generate Task Report For Title Filter

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME7}

    ${title1}=  FakerLibrary.user name
    Set Suite Variable  ${title1}

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title1}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   title-eq=${title1} 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-3

    [Documentation]  Generate Task Report For Assignee Filter

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME7}

    ${title2}=  FakerLibrary.user name
    Set Suite variable      ${title2}

    ${resp}=    Get User
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title2}    ${resp.json()['title']}

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   assignee-eq=${uid}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${title2}           ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}
    
JD-TC-TaskReport-4

    [Documentation]     Generate Task Report For Users Having Multiple Location

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_id}=  get_acc_id            ${HLPUSERNAME7}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}


    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}  ${resp.json()[0]['name']} 

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId2}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId4}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[4]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[4]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[4]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[4]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[4]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[4]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid4}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid4}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   location-eq=${locId1},${locId2},${locId3},${locId4}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place2}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place2}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][3]['1']}
    Should Be Equal As Strings  ${place4}            ${resp.json()['reportContent']['data'][3]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][3]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][3]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][3]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}


    ${filter}=  Create Dictionary   location-eq=${locId1},${locId4}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place4}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}


    ${filter}=  Create Dictionary   location-eq=${locId3}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}


JD-TC-TaskReport-5

    [Documentation]     Generate Task Report  By multiple Title

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idA}=  get_acc_id            ${HLPUSERNAME8}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdA}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdA}  ${resp.json()[0]['id']}
    END

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    ${titleC}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    Set Test Variable   ${titleC}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idA}
    ${resp}=  tasktype              ${p_idA}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameA}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_idA} =  Convert To String  ${category_idA} 
    Set Suite Variable            ${category_idA} 

    ${locIdA}=  Convert To String  ${locIdA}
    Set Suite Variable            ${locIdA}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleC}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME8}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   title-eq=${titleA},${titleB},${titleC}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleC}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][3]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][3]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][3]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][3]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][3]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleA}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleB}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}


JD-TC-TaskReport-6

    [Documentation]     Generate Task Report multiple Assignee

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME9}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    END

    ${titleB}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${locIdB}=  Convert To String  ${locIdB}
    Set Suite Variable            ${locIdB}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME9}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidA},${uidB},${uidC}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname2}${SPACE}${lname2}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId2}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidB},${uidC}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname2}${SPACE}${lname2}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId2}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-7

    [Documentation]  Generate Task Report For Account Level With EMPTY

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME10}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_id1} =  Convert To String  ${category_id1} 
    Set Suite Variable            ${category_id1} 

    ${locId}=  Convert To String  ${locId}
    Set Suite Variable            ${locId}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=  Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-8

    [Documentation]  Generate Task Report For Account Level With EMPTY For Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME11}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END
    
    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}   ${resp.json()[0]['name']}
    

    ${titleABC}=  FakerLibrary.user name
    Set Suite Variable      ${titleABC}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_id1} =  Convert To String  ${category_id1} 
    Set Suite Variable            ${category_id1} 

    ${locId}=  Convert To String  ${locId}
    Set Suite Variable            ${locId}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${resp}=    Create Task         ${titleABC}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-9

    [Documentation]  Generate Task Report For Account Level With Location Filter In Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Create Task         ${titleABC}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   location-eq=${locId}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleABC}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-10

    [Documentation]  Generate Task Report For Account Level With Title Filter In Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME11}

    ${title2}=  FakerLibrary.user name
    Set Suite Variable  ${title2}

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid1}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title1}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   title-eq=${title1}        dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title2}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-11

    [Documentation]  Generate Task Report For Account Level With Assignee Filter In Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME11}

    ${title2}=  FakerLibrary.user name
    Set Suite variable      ${title2}

    ${resp}=    Get User
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid2}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title2}    ${resp.json()['title']}

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   assignee-eq=${uid}     dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][3]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][3]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][3]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][3]['4']}
    Should Be Equal As Strings  ${title2}           ${resp.json()['reportContent']['data'][3]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-12

    [Documentation]     Generate Task Report For User Using Location In Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_id}=  get_acc_id            ${HLPUSERNAME11}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}


    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}  ${resp.json()[0]['name']} 

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId1}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId2}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId4}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[4]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[4]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[4]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[4]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[4]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[4]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${title1}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId3}  dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid4}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid4}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${DAY}=  db.get_date_by_timezone  ${tz}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   location-eq=${locId1},${locId2},${locId3},${locId4}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place2}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place2}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][3]['1']}
    Should Be Equal As Strings  ${place4}            ${resp.json()['reportContent']['data'][3]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][3]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][3]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][3]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}


    ${filter}=  Create Dictionary   location-eq=${locId1},${locId4}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place4}            ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}


    ${filter}=  Create Dictionary   location-eq=${locId3}      dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title1}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}



JD-TC-TaskReport-13

    [Documentation]     Generate Task Report For User Using title In Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idA}=  get_acc_id            ${HLPUSERNAME12}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdA}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdA}  ${resp.json()[0]['id']}
    END

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    ${titleC}=  FakerLibrary.user name
    ${titleD}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    Set Test Variable   ${titleC}
    Set Test Variable   ${titleD}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idA}
    ${resp}=  tasktype              ${p_idA}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameA}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_idA} =  Convert To String  ${category_idA} 
    Set Suite Variable            ${category_idA} 
 
    ${locIdA}=  Convert To String  ${locIdA}
    Set Suite Variable            ${locIdA}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleC}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleD}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locIdA}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME12}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   title-eq=${titleA},${titleB},${titleC}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${titleC}                       ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleD}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleD}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleB},${titleD}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleD}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']} 

JD-TC-TaskReport-14

    [Documentation]     Generate Task Report For User Using Assignee

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME13}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    END

    ${titleB}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${locIdB}=  Convert To String  ${locIdB}
    Set Suite Variable            ${locIdB}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME13}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidA},${uidB},${uidC}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname2}${SPACE}${lname2}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId2}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][2]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][2]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][2]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][2]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][2]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidB},${uidC}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname2}${SPACE}${lname2}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId2}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][1]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][1]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][1]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][1]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][1]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-15

    [Documentation]     Generate Task Report For User with loc and title where datecategory in TODAY

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idA}=  get_acc_id            ${HLPUSERNAME14}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    ${titleC}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    Set Test Variable   ${titleC}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${resp}=  categorytype          ${p_idA}
    ${resp}=  tasktype              ${p_idA}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameA}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_idA} =  Convert To String  ${category_idA} 
    Set Suite Variable            ${category_idA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId1}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId1}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleC}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME14}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   title-eq=${titleB}     location-eq=${locId1} 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleB}     location-eq=${locId2} 
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-16

    [Documentation]     Generate Task Report For User with loc and assignee where datecategory in TODAY

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME15}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${titleB}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}        location-eq=${locId3}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidC}   location-eq=${locId2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-17

    [Documentation]     Generate Task Report For User using title and assignee where datecategory in TODAY

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME16}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    END

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${locIdB}=  Convert To String  ${locIdB}
    Set Suite Variable            ${locIdB}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidC}      title-eq=${titleB}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidA}      title-eq=${titleA}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-18

    [Documentation]     Generate Task Report For User by location id, item and assignee where datecategory in TODAY

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME17}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${title1}=  FakerLibrary.user name
    ${title2}=  FakerLibrary.user name
    ${title3}=  FakerLibrary.user name
    ${title4}=  FakerLibrary.user name
    Set Test Variable   ${title1}
    Set Test Variable   ${title2}
    Set Test Variable   ${title3}
    Set Test Variable   ${title4}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${title3}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}        location-eq=${locId3}    title-eq=${title3}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title3}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidC}   location-eq=${locId2}    title-eq=${title2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title2}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-19

    [Documentation]     Generate Task Report For User with loc and title where datecategory in Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idA}=  get_acc_id            ${HLPUSERNAME18}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    ${titleC}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    Set Test Variable   ${titleC}

    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${resp}=  categorytype          ${p_idA}
    ${resp}=  tasktype              ${p_idA}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameA}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_idA} =  Convert To String  ${category_idA} 
    Set Suite Variable            ${category_idA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId1}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId1}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[3]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[3]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[3]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[3]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[3]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[3]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Task         ${titleC}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid3}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid3}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME18}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   title-eq=${titleB}     location-eq=${locId1}      dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place1}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   title-eq=${titleB}     location-eq=${locId2}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}


JD-TC-TaskReport-20

    [Documentation]     Generate Task Report For User with loc and assignee where datecategory in Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME19}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${titleB}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME19}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}        location-eq=${locId3}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidC}   location-eq=${locId2}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}


JD-TC-TaskReport-21

    [Documentation]     Generate Task Report For User using title and assignee where datecategory in Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME20}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    ELSE
        Set Suite Variable          ${locIdB}  ${resp.json()[0]['id']}
    END

    ${titleA}=  FakerLibrary.user name
    ${titleB}=  FakerLibrary.user name
    Set Test Variable   ${titleA}
    Set Test Variable   ${titleB}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${locIdB}=  Convert To String  ${locIdB}
    Set Suite Variable            ${locIdB}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${titleA}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${titleB}  ${desc}   ${userType[0]}  ${category_idA}  ${type_idAA}   ${locIdB}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}    

    ${filter}=  Create Dictionary   assignee-eq=${uidC}      title-eq=${titleB}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleB}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidA}      title-eq=${titleA}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${titleA}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-22

    [Documentation]     Generate Task Report For User by location id, item and assignee where datecategory in Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${p_idB}=  get_acc_id            ${HLPUSERNAME21}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    sleep  2s

    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${locId1}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz1}  ${resp.json()['timezone']}
    ${locId2}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz2}  ${resp.json()['timezone']}
    ${locId3}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz3}  ${resp.json()['timezone']}
    ${locId4}=  Create Sample Location
    ${resp}=   Get Location ById  ${locId4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz4}  ${resp.json()['timezone']}
    ${locId1}=  Convert To String  ${locId1}
    ${locId2}=  Convert To String  ${locId2}
    ${locId3}=  Convert To String  ${locId3}
    ${locId4}=  Convert To String  ${locId4}
    Set Suite variable      ${locId1}
    Set Suite variable      ${locId2}
    Set Suite variable      ${locId3}
    Set Suite variable      ${locId4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${place1}       ${resp.json()[1]['place']}
    Set Suite Variable      ${place2}       ${resp.json()[2]['place']}
    Set Suite Variable      ${place3}       ${resp.json()[3]['place']}
    Set Suite Variable      ${place4}       ${resp.json()[4]['place']}

    ${title1}=  FakerLibrary.user name
    ${title2}=  FakerLibrary.user name
    ${title3}=  FakerLibrary.user name
    ${title4}=  FakerLibrary.user name
    Set Test Variable   ${title1}
    Set Test Variable   ${title2}
    Set Test Variable   ${title3}
    Set Test Variable   ${title4}
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${resp}=  categorytype          ${p_idB}
    ${resp}=  tasktype              ${p_idB}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_idAA}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_nameAA}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_idAA}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_nameAA}   ${resp.json()[0]['name']}

    ${category_idAA} =  Convert To String  ${category_idAA} 
    Set Suite Variable            ${category_idAA} 

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${assigneduserA}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduserA}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${usr_id}=  Create List
    Set Suite Variable   ${usr_id}

    ${PUsrNm}=  Create List 
    Set Suite Variable  ${PUsrNm}

    FOR   ${a}  IN RANGE   ${count}

        ${userid}=  Create Sample User
        Set Test Variable  ${userid${a}}  ${userid}

        ${resp}=  Get User By Id        ${userid${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings      ${resp.status_code}  200
        Set Suite Variable      ${PUSERNAME_${a}}     ${resp.json()['mobileNo']}

        Append To List   ${usr_id}  ${userid${a}}
        Append To List   ${PUsrNm}  ${PUSERNAME_${a}}
    END

    Log  ${PUsrNm}

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[0]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[0]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[0]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[0]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[0]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[0]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idA}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidA}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname1}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname1}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId1}   ${resp.json()['employeeId']}
    

    ${assigneduserAA}=  Create Dictionary  id=${uidA}

    ${resp}=    Create Task         ${title3}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId3}  dueDate=${DAY}  assignee=${assigneduserAA}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[1]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[1]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[1]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[1]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[1]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[1]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable      ${u_idB}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidB}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname2}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname2}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId2}   ${resp.json()['employeeId']}

    ${assigneduserAB}=  Create Dictionary  id=${uidB}

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAB}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid1}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid1}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=    Reset LoginId  ${usr_id}  ${PUsrNm[2]}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Forgot Password   loginId=${PUsrNm[2]}  password=${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${resp}=    Account Activation  ${PUsrNm[2]}  ${OtpPurpose['ProviderResetPassword']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${key} =   db.Verify Accnt   ${PUsrNm[2]}    ${OtpPurpose['ProviderResetPassword']}
    Set Suite Variable   ${key}

    ${resp}=    Forgot Password     otp=${key}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #... linking user to the provider 1 and get linked lists

    ${resp}=    Connect with other login  ${PUsrNm[2]}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    # --------------------------------------------------

    ${resp}=  Encrypted Provider Login  ${PUsrNm[2]}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable      ${u_idC}     ${resp.json()['id']}

    ${resp}=    Get User By Id      ${uidC}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname3}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname3}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId3}   ${resp.json()['employeeId']}

    ${assigneduserAC}=  Create Dictionary  id=${uidC}

    ${resp}=    Create Task         ${title2}  ${desc}   ${userType[0]}  ${category_idAA}  ${type_idAA}   ${locId2}  dueDate=${DAY}  assignee=${assigneduserAC}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid2}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid2}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}     200

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME21}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${uidA} =  Convert To String  ${u_idA} 
    ${uidB} =  Convert To String  ${u_idB} 
    ${uidC} =  Convert To String  ${u_idC} 

    ${filter}=  Create Dictionary   assignee-eq=${uidA}        location-eq=${locId3}    title-eq=${title3}    dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place3}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname1}${SPACE}${lname1}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId1}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title3}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

    ${filter}=  Create Dictionary   assignee-eq=${uidC}   location-eq=${locId2}    title-eq=${title2}     dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s

    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${DAY}                          ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place2}                        ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname3}${SPACE}${lname3}        ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId3}                   ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title2}                       ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${reportType}                   ${resp.json()['reportType']}

JD-TC-TaskReport-23

    [Documentation]  Generate Task Report with Location Area

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME3}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${area}=     FakerLibrary.City
    
    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_id1} =  Convert To String  ${category_id1} 
    Set Suite Variable            ${category_id1} 

    ${area}=  Convert To String  ${area}
    Set Suite Variable            ${area}

    ${locId}=  Convert To String  ${locId}
    Set Suite Variable            ${locId}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}    locationArea=${area}    dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        TODAY

    ${filter}=  Create Dictionary   location-eq=${locId}  
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${area}           ${resp.json()['reportContent']['data'][0]['8']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}

JD-TC-TaskReport-24

    [Documentation]  Generate Task Report with Location Area in Date Range

    ${resp}=  Encrypted Provider Login        ${HLPUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}    200
    
    ${p_id}=  get_acc_id            ${HLPUSERNAME4}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable          ${place}  ${resp.json()[0]['place']}
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['timezone']}
    ELSE
        Set Suite Variable          ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    END

    ${area}=     FakerLibrary.City
    
    ${resp}=  categorytype          ${p_id}
    ${resp}=  tasktype              ${p_id}
    ${resp}=    Get Task Category Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${category_id1}    ${resp.json()[0]['id']}
    Set Test Variable               ${category_name1}  ${resp.json()[0]['name']}

    ${resp}=    Get Task Type
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable              ${type_id1}     ${resp.json()[0]['id']}
    Set Test Variable               ${type_name1}   ${resp.json()[0]['name']}
    

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    Set Suite Variable      ${desc}

    ${category_id1} =  Convert To String  ${category_id1} 
    Set Suite Variable            ${category_id1} 

    ${area}=  Convert To String  ${area}
    Set Suite Variable            ${area}

    ${locId}=  Convert To String  ${locId}
    Set Suite Variable            ${locId}

    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=    Toggle Department Enable
        Log   ${resp.content}
        Should Be Equal As Strings      ${resp.status_code}  200

    END

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}

    ${uid}=    Create Sample User
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${uid}=     Convert To String  ${uid}
    Set Suite Variable      ${uid}

    ${resp}=    Get User By Id      ${uid}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    
    Set Suite Variable      ${fname}  ${resp.json()['firstName']}
    Set Suite Variable      ${lname}  ${resp.json()['lastName']}
    Set Suite Variable      ${employeeId}   ${resp.json()['employeeId']}

    ${assigneduser}=  Create Dictionary  id=${uid}
    Set Suite Variable      ${assigneduser}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}

    ${resp}=    Create Task         ${title}  ${desc}   ${userType[0]}  ${category_id1}  ${type_id1}   ${locId}    locationArea=${area}    dueDate=${DAY}  assignee=${assigneduser}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${task_uid}     ${resp.json()['uid']}

    ${resp}=    Change Task Status   ${task_uid}  ${status_id5}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Task By Id    ${task_uid}
    Log  ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable      ${title}    ${resp.json()['title']}

    ${Date} =	Convert Date	    ${DAY}	result_format=%d/%m/%Y

    Set Test Variable               ${reportType}                CRM_TASK
    Set Test Variable               ${reportDateCategory}        DATE_RANGE

    ${d1} =  db.subtract_timezone_date  ${tz}   10
    ${d2} =  db.get_date_by_timezone  ${tz}

    ${filter}=  Create Dictionary   location-eq=${locId}   dueDate-ge=${d1}  dueDate-le=${d2}
    ${resp}=  Generate Report REST details  ${reportType}  ${reportDateCategory}  ${filter}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${token_id}   ${resp.json()}

    sleep  2s
    
    ${resp}=  Get Report Status By Token Id  ${token_id}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${DAY}              ${resp.json()['reportContent']['data'][0]['1']}
    Should Be Equal As Strings  ${place}            ${resp.json()['reportContent']['data'][0]['2']}
    Should Be Equal As Strings  ${fname}${SPACE}${lname}            ${resp.json()['reportContent']['data'][0]['3']}
    Should Be Equal As Strings  ${employeeId}           ${resp.json()['reportContent']['data'][0]['4']}
    Should Be Equal As Strings  ${title}           ${resp.json()['reportContent']['data'][0]['5']}
    Should Be Equal As Strings  ${area}           ${resp.json()['reportContent']['data'][0]['8']}
    Should Be Equal As Strings  ${reportType}          ${resp.json()['reportType']}