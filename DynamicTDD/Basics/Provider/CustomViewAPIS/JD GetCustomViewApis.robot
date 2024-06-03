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
Variables         /ebs/TDD/varfiles/providers.py


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${type}  Waitlist

***Test Cases***

JD-TC-GetCustomViewApis-1
    [Documentation]  Verifying Customview Details using Get CustomView
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+313339
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}
    ${id}=  get_id  ${PUSERNAME_C}
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
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    
    ${PUSERNAME_CV}=  Evaluate  ${PUSERNAME}+441418
    clear_users  ${PUSERNAME_CV}
    Set Suite Variable  ${PUSERNAME_CV}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_CV}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${countryCodes[0]}  ${PUSERNAME_CV}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

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
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}

    ${q_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id}  ${resp.json()}

    ${dep_id_01}=  Create List  ${dep_id}
    ${s_id_01}=  Create List  ${s_id}
    ${que_id_01}=  Create List  ${que_id}
    ${u_id_01}=  Create List  ${u_id}


    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}
    ${resp}=   Create CustomeView   ${name}  ${bool[1]}  ${dep_id_01}  ${s_id_01}  ${que_id_01}  ${u_id_01}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  

    ${resp}=  Get CustomeView   department-eq=${dep_id}  service-eq=${s_id}  queue-eq=${que_id}  user-eq=${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['merged']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['departments'][0]['departmentId']}  ${dep_id}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['services'][0]['id']}  ${s_id}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['queues'][0]['id']}  ${que_id}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['users'][0]['id']}  ${u_id}
    
JD-TC-GetCustomViewApis-2
    [Documentation]  Verifying more Customview Details using Get CustomView
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_C}=  Evaluate  ${PUSERNAME}+3312499
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_C}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_C}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_C}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_C}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_C}${\n}
    Set Suite Variable  ${PUSERNAME_C}
    ${id}=  get_id  ${PUSERNAME_C}
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
    Set Suite Variable  ${dep_id01}  ${resp.json()}

    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${dep_desc2}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc2}
    ${resp}=  Create Department  ${dep_name2}  ${dep_code2}  ${dep_desc2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id02}  ${resp.json()}
    
    ${PUSERNAME_CV}=  Evaluate  ${PUSERNAME}+431499
    clear_users  ${PUSERNAME_CV}
    Set Suite Variable  ${PUSERNAME_CV}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_CV}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${dep_id01}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_CV}  ${countryCodes[0]}  ${PUSERNAME_CV}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id01}  ${resp.json()}

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
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id01}  ${u_id01}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id01}  ${resp.json()}

    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+341099
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id02}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id02}  ${resp.json()}

    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id02}  ${u_id02}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id02}  ${resp.json()}

    ${q_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id01}  ${s_id01}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id01}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  1  45  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  50  
    Set Suite Variable   ${eTime1}
    ${q_name2}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id02}  ${s_id02}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id02}  ${resp.json()}

    ${dep_id}=  Create List  ${dep_id01}
    ${s_id}=  Create List  ${s_id01}
    ${que_id}=  Create List  ${que_id01}
    ${u_id}=  Create List  ${u_id01}

    ${name}=   FakerLibrary.word
    Set Suite Variable   ${name}
    ${resp}=   Create CustomeView   ${name}  ${bool[1]}  ${dep_id}  ${s_id}  ${que_id}  ${u_id}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    #Set Suite Variable  ${cv_id}  ${resp.json()}

    ${dep_id_A}=  Create List  ${dep_id02}
    ${s_id_A}=  Create List  ${s_id02}
    ${que_id_A}=  Create List  ${que_id02}
    ${u_id_A}=  Create List  ${u_id02}

    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=   Create CustomeView   ${name1}  ${bool[1]}  ${dep_id_A}  ${s_id_A}  ${que_id_A}  ${u_id_A}  ${type}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200  
    #Set Suite Variable  ${cv_id}  ${resp.json()}

    ${resp}=  Get CustomeView   
    Log  ${resp.json()}
    Set Suite Variable  ${id1}  ${resp.json()[0]['id']}
    Set Suite Variable  ${id2}  ${resp.json()[1]['id']}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${id1}
    Should Be Equal As Strings  ${resp.json()[0]['name']}  ${name}
    Should Be Equal As Strings  ${resp.json()[0]['merged']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['departments'][0]['departmentId']}  ${dep_id01}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['services'][0]['id']}  ${s_id01}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['queues'][0]['id']}  ${que_id01}
    Should Be Equal As Strings  ${resp.json()[0]['customViewConditions']['users'][0]['id']}  ${u_id01}

    Should Be Equal As Strings  ${resp.json()[1]['id']}  ${id2}
    Should Be Equal As Strings  ${resp.json()[1]['name']}  ${name1}
    Should Be Equal As Strings  ${resp.json()[1]['merged']}  ${bool[1]}
    Should Be Equal As Strings  ${resp.json()[1]['customViewConditions']['departments'][0]['departmentId']}  ${dep_id02}
    Should Be Equal As Strings  ${resp.json()[1]['customViewConditions']['services'][0]['id']}  ${s_id02}
    Should Be Equal As Strings  ${resp.json()[1]['customViewConditions']['queues'][0]['id']}  ${que_id02}
    Should Be Equal As Strings  ${resp.json()[1]['customViewConditions']['users'][0]['id']}  ${u_id02}


JD-TC-GetCustomViewApis-UH1
    [Documentation]  Checking customview details with different Branch phone number
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+131399
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_Z}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${name}=   FakerLibrary.word
    ${resp}=  Get CustomeView
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"   "${CUSTOM_VIEW_NOT_EXIT}"