*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        CustomView
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${type}  Waitlist
${type1}  Appointment

***Test Cases***
JD-TC-UpdateCustomViewApis-1
    [Documentation]  Updating a CustomView using DepartmentId, ServicesId, QueuesId and UsersId
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_F}=  Evaluate  ${MUSERNAME}+34349
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_F}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_F}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_F}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_F}${\n}
    Set Suite Variable  ${MUSERNAME_F}
    ${id}=  get_id  ${MUSERNAME_F}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}
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
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id05}  ${resp.json()}

    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id08o}  ${resp.json()}

   
    ${PUSERNAME_CV}=  Evaluate  ${PUSERNAME}+23246
    clear_users  ${PUSERNAME_CV}
    Set Suite Variable  ${PUSERNAME_CV}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_CV}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${dep_id05}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${countryCodes[0]}  ${PUSERNAME_CV}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id01}  ${resp.json()}

    ${PUSERNAME_CV}=  Evaluate  ${PUSERNAME}+45429
    clear_users  ${PUSERNAME_CV}
    Set Suite Variable  ${PUSERNAME_CV}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_CV}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${dep_id08o}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${countryCodes[0]}  ${PUSERNAME_CV}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id02}  ${resp.json()}

    ${lid}=  Create Sample Location

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  1  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${eTime1}
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id05}  ${u_id01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id01}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id01}  ${s_id01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id01}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id08o}  ${u_id02}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id_SA}  ${resp.json()}
    ${queue_name1}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id02}  ${s_id_SA}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id_QAo}  ${resp.json()}
    ${dept_id05}=  Create List  ${dep_id05}
    Set Suite Variable   ${dept_id05}
    ${ser_id01}=  Create List  ${s_id01}
    Set Suite Variable   ${ser_id01}
    ${q_id01}=  Create List  ${que_id01}
    Set Suite Variable   ${q_id01}
    ${user_id01}=  Create List  ${u_id01}
    Set Suite Variable   ${user_id01}
    ${name}=   FakerLibrary.word

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${delta}=  FakerLibrary.Random Int  min=10  max=30
    ${eTime1}=  add_two   ${sTime1}  ${delta}
    ${schedule_name}=  FakerLibrary.bs
    ${parallel}=  FakerLibrary.Random Int  min=1  max=10
    ${maxval}=  Convert To Integer   ${delta/2}
    ${duration}=  FakerLibrary.Random Int  min=1  max=${maxval}
    ${bool1}=  Random Element  ${bool}
    ${resp}=  Create Appointment Schedule  ${schedule_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  ${parallel}    ${parallel}  ${lid}  ${duration}  ${bool1}  ${s_id01} 
    Log  ${resp.json()}
    Set Suite Variable   ${sc_id}   ${resp.json()} 
    ${Schid}=  Create List  ${sc_id}
    Set Suite Variable  ${Schid} 

    ${resp}=   Create CustomeView   ${name}  ${bool[1]}  ${dept_id05}  ${ser_id01}  ${q_id01}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable  ${cv_id}  ${resp.json()}
    
    ${name3}=   FakerLibrary.word
    ${resp}=   Create CustomeView Appointment   ${name3}  ${bool[1]}  ${dept_id05}   ${ser_id01}   ${user_id01}   ${Schid}   ${type1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    Set Suite Variable  ${cv_id1}  ${resp.json()}
    
    ${dep_id08}=  Create List  ${dep_id08o}
    Set Suite Variable   ${dep_id08}

    ${que_id_QA}=  Create List  ${que_id_QAo}
    Set Suite Variable   ${que_id_QA}

    ${name2}=   FakerLibrary.firstname
    ${resp}=  Update CustomeView  ${cv_id}  ${name2}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${name4}=   FakerLibrary.word
    ${resp}=  Update CustomeView Appointment  ${cv_id1}  ${name4}  ${bool[1]}  ${dep_id08}  ${ser_id01}   ${user_id01}   ${Schid}   ${type1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get CustomeView    department-eq=${dep_id08}  service-eq=${ser_id01}  queue-eq=${que_id_QA}  user-eq=${user_id01}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${name2}
    Should Be Equal As Strings  ${resp.json()[0]['merged']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['departments'][0]['departmentId']}  ${dep_id08o}
    #Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['services'][0]['id']}  ${ser_id01}
    #Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['queues'][0]['id']}  ${que_id_QA}
    #Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['users'][0]['id']}  ${user_id01}

JD-TC-UpdateCustomViewApis-UH1
    [Documentation]  Checking Update CustomView details with Wrong CustomView ID 
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name7}=   FakerLibrary.word
    ${CV_id}=  FakerLibrary.Random Int  min=1000  max=2000
    ${resp}=  Update CustomeView  ${CV_id}  ${name7}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CUSTOM_VIEW_NOT_EXIT}"

JD-TC-UpdateCustomViewApis-UH2
    [Documentation]  Checking Update CustomView details with custom name is Empty
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Update CustomeView  ${cv_id}  ${Empty}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CUSTOM_VIEW_NAME_REQUIRED}"

JD-TC-UpdateCustomViewApis-UH3
    [Documentation]  Update CustomView details with different Branch Number
    ${resp}=  Encrypted Provider Login  ${MUSERNAME0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name2}=   FakerLibrary.word
    ${resp}=  Update CustomeView  ${cv_id}  ${name2}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CUSTOM_VIEW_NOT_EXIT}"

JD-TC-UpdateCustomViewApis-UH4
    [Documentation]  Without Login trying to update CustomView details 
    ${name2}=   FakerLibrary.word
    ${resp}=  Update CustomeView  ${cv_id}  ${name2}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateCustomViewApis-UH5
    [Documentation]  Checking Update CustomView details with empty queue_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name6}=   FakerLibrary.word
    #${CV_id}=  FakerLibrary.Random Int  min=1000  max=2000
    ${resp}=  Update CustomeView  ${cv_id}  ${name6}  ${bool[1]}  ${dep_id08}  ${ser_id01}  ${empty}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_REQUIRED}" 


*** comments ***
JD-TC-UpdateCustomViewApis-UH5
    [Documentation]  Checking Update CustomView details with empty Department_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get CustomeView By Id  ${cv_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name4}=   FakerLibrary.word
    #${CV_id}=  FakerLibrary.Random Int  min=1000  max=2000
    ${resp}=  Update CustomeView  ${cv_id}  ${name4}  ${bool[1]}  ${empty}  ${ser_id01}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_DEPARTMENT}"


JD-TC-UpdateCustomViewApis-UH6
    [Documentation]  Checking Update CustomView details with empty service_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get CustomeView By Id  ${cv_id}   
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name5}=   FakerLibrary.word
    #${CV_id}=  FakerLibrary.Random Int  min=1000  max=2000
    ${resp}=  Update CustomeView  ${cv_id}  ${name5}  ${bool[1]}  ${dep_id08}  ${empty}  ${que_id_QA}  ${user_id01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_FOUND}"

JD-TC-UpdateCustomViewApis-UH8
    [Documentation]  Checking Update CustomView details with empty User_id
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_F}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${name9}=   FakerLibrary.word
    #${CV_id}=  FakerLibrary.Random Int  min=1000  max=2000
    ${resp}=  Update CustomeView  ${cv_id}  ${name9}  ${bool[1]}  ${dep_id08}  ${s_id_SA}  ${que_id_QA}  ${empty}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ALERT_USER_NOT_FOUND}"