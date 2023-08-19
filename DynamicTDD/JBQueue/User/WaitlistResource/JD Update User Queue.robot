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

*** Variables ***
${SERVICE1}  Makeup1  
${SERVICE2}  Hairmakeup1 
${SERVICE3}  Facial1
${SERVICE4}  Bridal makeup1 
${SERVICE5}  Hair remove1
${SERVICE6}  Bleach1
${SERVICE7}  Hair cut1

***Test Cases***

JD-TC-UpdateQueueForUser-1
     [Documentation]  Create a queue for user and Update that queue
     ${iscorp_subdomains}=  get_iscorp_subdomains  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+880217
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${MUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${id}=  get_id  ${MUSERNAME_E}
     Set Suite Variable  ${id}
     ${bs}=  FakerLibrary.bs
     Set Suite Variable  ${bs}
     ${resp}=  Toggle Department Enable
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep  2s
     ${resp}=  Get Departments
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+886445
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode

     ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

     ${DAY1}=  get_date
     Set Suite Variable  ${DAY1}
     ${DAY2}=  add_date  10      
     Set Suite Variable  ${DAY2}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}
     ${sTime1}=  add_time  0  15
     Set Suite Variable   ${sTime1}
     ${eTime1}=  add_time   0  30
     Set Suite Variable   ${eTime1}
     ${lid}=  Create Sample Location
     Set Suite Variable  ${lid}
     ${description}=  FakerLibrary.sentence
     Set Suite Variable  ${description}
     ${dur}=  FakerLibrary.Random Int  min=05  max=10
     Set Suite Variable  ${dur}
     ${amt}=  FakerLibrary.Random Int  min=200  max=500
     ${amt}=  Convert To Number  ${amt}  1
     Set Suite Variable  ${amt}
     ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id}  ${resp.json()}
     ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id3}  ${resp.json()}
     ${queue_name}=  FakerLibrary.bs
     Set Suite Variable  ${queue_name}
     ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${q_id}  ${resp.json()}
     ${resp}=  Get Queue ById  ${q_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id}
     ${queue_name1}=  FakerLibrary.bs
     Set Suite Variable  ${queue_name1}
     ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Queue ById  ${q_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name1} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id3}

JD-TC-UpdateQueueForUser-2
     [Documentation]  Update  a  user queue with more service
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Create Service For User  ${SERVICE5}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id5}  ${resp.json()}
     ${resp}=  Create Service For User  ${SERVICE6}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id6}  ${resp.json()}
     ${sTime3}=  add_time  0  50
     ${eTime3}=  add_time   1  15
     ${queue_name}=  FakerLibrary.bs
     ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid}  ${u_id}  ${s_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${q_id5}  ${resp.json()}
     ${resp}=  Get Queue ById  ${q_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id5}
     ${resp}=  Update Queue For User    ${q_id5}  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${lid}  ${u_id}   ${s_id5}   ${s_id6}   
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Queue ById  ${q_id5}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime3}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime3}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id5}
     Should Be Equal As Strings  ${resp.json()['services'][1]['id']}  ${s_id6}


JD-TC-UpdateQueueForUser-UH1
    [Documentation]    Create a queue and update that queue with  same details of another user queue
    ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3236646
    clear_users  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${pin1}=  get_pincode

     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${countryCodes[0]}  ${PUSERNAME_U2}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id1}  ${resp.json()}
    ${resp}=  Get Queue ById  ${q_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
    Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
    Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
    Should Be Equal As Strings  ${resp.json()['capacity']}  5
    Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id1}
    Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id2}

    ${resp}=  Update Queue For User    ${q_id1}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_EXISTS}"

JD-TC-UpdateQueueForUser-UH2
     [Documentation]  Create a queue for a user with branch's service id
     ${resp}=  Provider Login  ${MUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${desc}=   FakerLibrary.sentence
     Set Suite Variable    ${desc}
     ${total_amount}=    Random Int   min=100  max=500
     ${min_prepayment}=  Random Int   min=1    max=50
     ${ser_duratn}=      Random Int   min=10   max=30
     Set Suite Variable   ${ser_duratn}
     ${resp}=  Create Service Department  ${SERVICE4}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${dep_id}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id_B}  ${resp.json()}
     ${PUSERNAME_U3}=  Evaluate  ${PUSERNAME}+3246747
     clear_users  ${PUSERNAME_U3}
     ${firstname1}=  FakerLibrary.name
     ${lastname1}=  FakerLibrary.last_name
     ${dob1}=  FakerLibrary.Date
     ${pin1}=  get_pincode
   
     ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U3}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U3}  ${countryCodes[0]}  ${PUSERNAME_U3}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${u_id4}  ${resp.json()}
     ${resp}=  Create Service For User  ${SERVICE4}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  ${EMPTY}  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${s_id4}  ${resp.json()}
     ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id4}  ${s_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Test Variable  ${q_id4}  ${resp.json()}
     ${resp}=  Get Queue ById  ${q_id4}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['name']}  ${queue_name} 
     Should Be Equal As Strings  ${resp.json()['location']['id']}  ${lid}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['recurringType']}  Weekly
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}  ${sTime1}
     Should Be Equal As Strings  ${resp.json()['queueSchedule']['timeSlots'][0]['eTime']}  ${eTime1}
     Should Be Equal As Strings  ${resp.json()['parallelServing']}  1
     Should Be Equal As Strings  ${resp.json()['capacity']}  5
     Should Be Equal As Strings  ${resp.json()['provider']['id']}  ${u_id4}
     Should Be Equal As Strings  ${resp.json()['services'][0]['id']}  ${s_id4}

     ${queue_name}=  FakerLibrary.bs
     Set Suite Variable  ${queue_name}
     ${resp}=  Update Queue For User    ${q_id4}  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id4}   ${s_id_B}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  422
     Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"


JD-TC-UpdateQueueForUser -UH3
     [Documentation]   Provider Update a queue for  a User without login      
     ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UpdateQueueForUser -UH4
    [Documentation]   Consumer create a queue for user
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Update Queue For User    ${q_id}  ${queue_name1}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}   ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

  