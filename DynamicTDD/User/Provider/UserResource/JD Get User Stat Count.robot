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
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/hl_musers.py
Variables         /ebs/TDD/varfiles/consumermail.py



*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
${waitlistedby}           PROVIDER
@{countryCode}   91  +91  48 



***Test Cases***

JD-TC-UserStatCount-1
    [Documentation]  Assingn waitlist to one user and check user stat count


    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${random_ph}=   Random Int   min=100000   max=200000
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+${random_ph}
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
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
     Set Suite Variable  ${MUSERNAME_E}
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
     ${bs}=  FakerLibrary.bs
     ${companySuffix}=  FakerLibrary.companySuffix
     # ${city}=   get_place
     # ${latti}=  get_latitude
     # ${longi}=  get_longitude
     # ${postcode}=  FakerLibrary.postcode
     # ${address}=  get_address
     ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
     ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
     Set Suite Variable  ${tz}
     ${parking}   Random Element   ${parkingType}
     ${24hours}    Random Element    ${bool}
     ${desc}=   FakerLibrary.sentence
     ${url}=   FakerLibrary.url
     ${sTime}=  add_timezone_time  ${tz}  0  15  
     Set Suite Variable   ${sTime}
     ${eTime}=  add_timezone_time  ${tz}  0  45  
     Set Suite Variable   ${eTime}
     ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200

     ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
     Log  ${fields.json()}
     Should Be Equal As Strings    ${fields.status_code}   200

     ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

     ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200

     ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
     Should Be Equal As Strings    ${resp.status_code}   200

     ${spec}=  get_Specializations  ${resp.json()}
     ${resp}=  Update Specialization  ${spec}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}   200


     ${resp}=  Update Waitlist Settings  ${calc_mode[0]}   ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
     Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePresence']}==${bool[0]}   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=  Get Account Payment Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp1}=   Run Keyword If  ${resp.json()['onlinePayment']}==${bool[0]}   Enable Disable Online Payment   ${toggle[0]}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.content}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200
      
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp2}=   Get Business Profile
    Log  ${resp2.json()}
    Should Be Equal As Strings    ${resp2.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp2.json()['serviceSubSector']['id']}

    ${pid}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=    Get Locations
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    ${resp}=   Create Sample Service  ${SERVICE1}
    Set Suite Variable    ${ser_id}    ${resp}  

    ${q_name}=    FakerLibrary.name
    ${list}=  Create List   1  2  3  4  5  6  7
    ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    ${end_time}=    add_timezone_time  ${tz}  2  00   
    ${parallel}=   FakerLibrary.Random Int  min=1   max=10 
    ${capacity}=   FakerLibrary.Random Int  min=10   max=20 
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}   ${capacity}    ${lid}  ${ser_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}   ${resp.json()}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}
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
    
    ${random_ph}=   Random Int   min=10000   max=20000
    ${ph1}=  Evaluate  ${PUSERNAME}+${random_ph}
    clear_users  ${ph1}
    # ${ph1}=  Evaluate  ${MUSERNAME_E}+4480099
    Set Suite Variable  ${ph1}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    # ${pin}=  get_pincode
     # ${resp}=  Get LocationsByPincode     ${pin}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${whpnum}=  Evaluate  ${MUSERNAME_E}+336245
    ${tlgnum}=  Evaluate  ${MUSERNAME_E}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${ph1}.ynwSuite@netvarth.com   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCode[1]}  ${whpnum}  ${countryCode[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}
    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p1_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p2_id}   ${resp.json()[1]['id']}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable   ${eTime1}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id1}  ${s_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}  ${resp.json()}

    ${random_ph}=   Random Int   min=10000   max=20000
    ${ph2}=  Evaluate  ${PUSERNAME}+${random_ph}
    # ${ph2}=  Evaluate  ${MUSERNAME_E}+100044
    Set Suite Variable  ${ph2}
    clear_users  ${ph2}
    ${firstname1}=  FakerLibrary.name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${pin}=  get_pincode
    
    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${ph2}.ynwSuite@netvarth.com   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}
    ${sTime2}=  add_timezone_time  ${tz}  1  15  
    ${eTime2}=  add_timezone_time  ${tz}  2  00  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id2}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}  ${resp.json()}

    ${random_ph}=   Random Int   min=10000   max=20000
    ${ph3}=  Evaluate  ${PUSERNAME}+${random_ph}
    # ${ph3}=  Evaluate  ${MUSERNAME_E}+1060513
    Set Suite Variable  ${ph3}
    clear_users  ${ph3}
    ${firstname2}=  FakerLibrary.name
    ${lastname2}=  FakerLibrary.last_name
    ${dob2}=  FakerLibrary.Date
    ${pin}=  get_pincode
    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${ph3}.ynwSuite@netvarth.com   ${userType[0]}  ${pin}  ${countryCode[1]}  ${ph3}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id3}  ${resp.json()}
    ${sTime2}=  add_timezone_time  ${tz}  0  15  
    ${eTime2}=  add_timezone_time  ${tz}  1  15  
    ${description}=  FakerLibrary.sentence
    ${dur}=  FakerLibrary.Random Int  min=10  max=20
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id3}  ${resp.json()}
    ${queue_name}=  FakerLibrary.name
    ${resp}=  Create Queue For User  ${queue_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime2}  ${eTime2}  1  5  ${lid}  ${u_id3}  ${s_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id3}  ${resp.json()}

   
    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=1   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=  SendProviderResetMail   ${ph1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=1   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s

    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

JD-TC-UserStatCount-2
    [Documentation]  Assingn waitlist to more users and check user stat count
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid2}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid2}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid2[0]}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid3}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid3}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid3}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid3[0]}

    ${resp}=   Assign provider Waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Assign provider Waitlist   ${wid2}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Assign provider Waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=3  availableUserCount=0  totAssignedCount=3   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   3
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   3
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

JD-TC-UserStatCount-3
    [Documentation]  Assingn and Unassign more waitlist to same users and check user stat count
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME17}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid4}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid4}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid4}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid4[0]}

    ${resp}=  AddCustomer  ${CUSERNAME18}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid5}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid5}  ${ser_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${cid5} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid5}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid5[0]}

    ${resp}=   Assign provider Waitlist   ${wid4}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Assign provider Waitlist   ${wid5}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=3  availableUserCount=0  totAssignedCount=5   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   5
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   3
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Un Assign provider waitlist   ${wid4}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Un Assign provider waitlist   ${wid5}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=3  availableUserCount=0  totAssignedCount=3   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   3
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   3
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Un Assign provider waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=2  availableUserCount=0  totAssignedCount=2   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Un Assign provider waitlist   ${wid2}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=1   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Assign provider Waitlist   ${wid4}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=2   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

    ${resp}=   Un Assign provider waitlist   ${wid4}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Un Assign provider waitlist   ${wid}   ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

JD-TC-UserStatCount-4
    [Documentation]  Assingn and Unassign more waitlist to users by user in PROVIDER type and check user stat count
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Assign provider Waitlist   ${wid4}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=1   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0
    ${resp}=   Assign provider Waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=2  availableUserCount=0  totAssignedCount=2   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0
    ${resp}=   Un Assign provider waitlist   ${wid4}   ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Un Assign provider waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0
    ${resp}=   Assign provider Waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User Stat Count  date-eq=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=1  availableUserCount=0  totAssignedCount=1   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   1
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0
    ${resp}=   Un Assign provider waitlist   ${wid3}   ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

JD-TC-UserStatCount-5
    [Documentation]  Taking waitlist to users queue by user login and check user stat count
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=0  totAssignedCount=0   totAvailabletime=0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   0

JD-TC-UserStatCount-6
    [Documentation]  Done make available by user login and check user stat count
    ${resp}=  Encrypted Provider Login  ${ph1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List   1  2  3  4  5  6  7
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q1}  ${resp.json()}
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q1} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}
    
    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=1  totAssignedCount=0   totAvailabletime=60
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   60
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   1

    ${resp}=  Terminate Availability Queue    ${p1_q1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  3s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=1  totAssignedCount=0   totAvailabletime=2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   2
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   1

JD-TC-UserStatCount-7
    [Documentation]  Done make available by account level and check user stat count
    ${resp}=  SendProviderResetMail   ${ph2}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List   1  2  3  4  5  6  7
    ${eTime1}=  add_timezone_time  ${tz}  00  30  
    Set Suite Variable   ${eTime1}
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}2   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q2} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}

    ${resp}=  Get User Stat Count  date-eq=${DAY1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=2  totAssignedCount=0   totAvailabletime=33
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   33
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   2

    ${resp}=  Terminate Availability Queue    ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=2  totAssignedCount=0   totAvailabletime=4
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   4
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   2

    ${resp}=  SendProviderResetMail   ${ph3}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${ph3}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${ph3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${queue}=    FakerLibrary.word
    ${eTime1}=  add_timezone_time  ${tz}  2  00  
    Set Suite Variable   ${eTime1}
    ${resp}=  Make Available   ${queue}3   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q3}  ${resp.json()}
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q3} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}

    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=3  totAssignedCount=0   totAvailabletime=125
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   125
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   3

    ${resp}=  Terminate Availability Queue    ${p1_q3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=3  totAssignedCount=0   totAvailabletime=6
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   6
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   3

JD-TC-UserStatCount-8
    [Documentation]  Done make available by account level and check user stat count
    ${resp}=  Encrypted Provider Login  ${ph2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${list}=  Create List   1  2  3  4  5  6  7
    ${eTime1}=  add_timezone_time  ${tz}  00  45  
    Set Suite Variable   ${eTime1}
    ${queue}=    FakerLibrary.word
    ${resp}=  Make Available   ${queue}2   ${recurringtype[4]}  ${list}  ${DAY1}  ${EMPTY}  ${sTime1}  ${eTime1}  ${lid}  ${u_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${p1_q2}  ${resp.json()}
    ${resp}=  Is Available Queue Now ByProviderId    ${u_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    Verify Response    ${resp}   availableNow=${bool[1]}  holiday=${bool[0]}   instanceQueueId=${p1_q2} 
    Should Be Equal As Strings   ${resp.json()['timeRange']['sTime']}             ${sTime1}  
    Should Be Equal As Strings   ${resp.json()['timeRange']['eTime']}             ${eTime1}

    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=3  totAssignedCount=0   totAvailabletime=52
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   52
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   3


    ${resp}=  Terminate Availability Queue    ${p1_q2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  2s
    ${resp}=  Get User Stat Count
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  assignedUserCount=0  availableUserCount=3  totAssignedCount=0   totAvailabletime=8
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['date']}   ${DAY1}
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availabletime']}   8
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['assignedUserCount']}   0
    Should Be Equal As Strings  ${resp.json()[0]['statsPerDay'][0]['availableUserCount']}   3

JD-TC-UserStatCount -UH1
     [Documentation]   Provider get User stat count without login      
     ${resp}=  Get User Stat Count
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
 
JD-TC-UserStatCount -UH2
    [Documentation]   Consumer get users
    ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get User Stat Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
