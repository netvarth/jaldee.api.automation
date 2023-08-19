*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Vacation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py



*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009
${waitlistedby}           PROVIDER



***Test Cases***

JD-TC-UnAssignproviderWaitlist-1
    [Documentation]  Un Assingn waitlist from user
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    clear_queue      ${HLMUSERNAME4}
    clear_service    ${HLMUSERNAME4}
    clear_customer   ${HLMUSERNAME4}

    ${pid}=  get_acc_id  ${HLMUSERNAME4}

    

    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[1]}
        ${resp}=   Toggle Department Disable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END


    ${resp}=   Get License UsageInfo 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Test Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    # ${list}=  Create List  1  2  3  4  5  6  7
    # Set Suite Variable  ${list}  ${list}
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


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
     
    ${ph1}=  Evaluate  ${MUSERNAME60}+1000470000
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    


    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${ph2}=  Evaluate  ${MUSERNAME60}+1000470001
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${address1}=  get_address
    ${dob1}=  FakerLibrary.Date
    ${pin1}=  get_pincode
   
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${ph2}.ynwtest@netvarth.com   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  3  15  
    ${eTime2}=  add_timezone_time  ${tz}  4  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}


    ${ph3}=  Evaluate  ${MUSERNAME60}+1000470003
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph3}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${ph3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id3}  ${resp.json()}
    
    # ${sTime2}=  db.get_time_by_timezone   ${tz}
    # ${eTime2}=  add_timezone_time  ${tz}  1  00  

    # ${queue}=    FakerLibrary.word
    # ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime2}  ${eTime2}  ${lid}  ${u_id3}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${p1_q3}  ${resp.json()}
    
    # ${resp}=  Is Available Queue Now ByProviderId    ${u_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id3}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname2}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname2}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    # ${resp}=  Terminate Availability Queue    ${p1_q3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  Is Available Queue Now ByProviderId    ${u_id3}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

  
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id3}


JD-TC-UnAssignproviderWaitlist-2
    [Documentation]  User take checkin and unassign
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLMUSERNAME4}
    clear_service    ${HLMUSERNAME4}
    clear_customer   ${HLMUSERNAME4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}
    Set Test Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${ph1}=  Evaluate  ${HLMUSERNAME4}+1000470011
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME7}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable    ${CUR_DAY}
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${ph2}=  Evaluate  ${HLMUSERNAME4}+1000470004
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
    
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}
    ${queue_name2}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${queue_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${que_id1}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${sTime1}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${eTime1}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id1}

JD-TC-UnAssignproviderWaitlist-3
    [Documentation]  Assingn waitlist to user and then it again assign to another user then unassign
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLMUSERNAME4}
    clear_service    ${HLMUSERNAME4}
    clear_customer   ${HLMUSERNAME4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${ph1}=  Evaluate  ${HLMUSERNAME4}+1000440005
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
   
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${ph2}=  Evaluate  ${HLMUSERNAME4}+1000400006
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
   
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    
     
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id1}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id2}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname2}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname2}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0


    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          ${u_id2}


JD-TC-UnAssignproviderWaitlist-UH1
    [Documentation]  unassign waitlist after cancel the waitlist
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLMUSERNAME4}
    clear_service    ${HLMUSERNAME4}
    clear_customer   ${HLMUSERNAME4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph1}=  Evaluate  ${HLMUSERNAME4}+1000470015
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${ph2}=  Evaluate  ${HLMUSERNAME4}+1000470016
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${address2}=  get_address
    ${dob2}=  FakerLibrary.Date
    ${pin2}=  get_pincode
  
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph2}.ynwtest@netvarth.com   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${u_id2}  ${resp.json()}
    
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id2}  ${resp.json()}

    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id2}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id1}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${desc}=   FakerLibrary.word
    ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
    ${resp}=  Waitlist Action Cancel  ${wid}  ${cncl_resn}  ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200
  
    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-UnAssignproviderWaitlist-UH2
    [Documentation]  unassign waitlist with consumer login
    
    ${resp}=  Encrypted Provider Login  ${HLMUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    clear_queue      ${HLMUSERNAME4}
    clear_service    ${HLMUSERNAME4}
    clear_customer   ${HLMUSERNAME4}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500
    ${ser_duratn}=      Random Int   min=10   max=30
    ${resp}=  Create Service Department  ${SERVICE1}  ${desc}   ${ser_duratn}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  ${dep_id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id}  ${resp.json()}

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    # ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  6  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=1   max=10 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${ph1}=  Evaluate  ${HLMUSERNAME4}+1000470023
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  get_address
    ${dob}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id6}  ${resp.json()}
    
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}

     
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id6}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${s_id1}  ${resp.json()}

    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    ${eTime1}=  add_timezone_time  ${tz}  1  00 
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id6}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${que_id1}  ${resp.json()}

    ${resp}=   Assign provider Waitlist   ${wid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid6} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1    waitlistedBy=${waitlistedby}  personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id}
    Should Be Equal As Strings  ${resp.json()['provider']['id']}                   ${u_id6}
    Should Be Equal As Strings  ${resp.json()['provider']['firstName']}            ${firstname}
    Should Be Equal As Strings  ${resp.json()['provider']['lastName']}             ${lastname}
    Should Be Equal As Strings  ${resp.json()['provider']['mobileNo']}             ${ph1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
    Should Be Equal As Strings  ${resp.json()['queue']['name']}                 ${q_name}
    Should Be Equal As Strings  ${resp.json()['queue']['id']}                   ${q_id}
    Should Be Equal As Strings  ${resp.json()['queue']['location']['id']}       ${lid}
    Should Be Equal As Strings  ${resp.json()['queue']['queueStartTime']}       ${strt_time}
    Should Be Equal As Strings  ${resp.json()['queue']['queueEndTime']}         ${end_time}
    Should Be Equal As Strings  ${resp.json()['queue']['availabilityQueue']}    ${bool[0]}   
    Should Be Equal As Strings  ${resp.json()['prevAssignedProvider']}          0

    ${resp}=   Consumer Login  ${CUSERNAME8}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Un Assign provider waitlist   ${wid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UnAssignproviderWaitlist-UH3
    [Documentation]   Assingn appointment without login
    
    ${resp}=   Un Assign provider waitlist    ${wid6}   ${u_id6}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"
