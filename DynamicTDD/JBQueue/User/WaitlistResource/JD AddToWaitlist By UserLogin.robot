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
${SERVICE1}  Makeup  
${SERVICE2}  Hairmakeup 
${SERVICE3}  Facialmakeup 
${SERVICE4}  Bridal makeup 
${SERVICE5}  Hair remove
${SERVICE6}  Bleach
${SERVICE7}  Hair cut
${country_code}   +91

***Test Cases***

JD-TC-WaitlistByUserLogin-1
     [Documentation]  User taking a waitlist for current day by user login
     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+9908813
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

     
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${MUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${MUSERNAME_E}+2000000000
     ${views}=  Random Element    ${Views}
     ${name1}=  FakerLibrary.name
     ${name2}=  FakerLibrary.name
     ${name3}=  FakerLibrary.name
     ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
     ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
     ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.ynwtest@netvarth.com  ${views}
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
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
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
     
     ${resp}=  Enable Waitlist
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     sleep   01s
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]} 

     ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get jaldeeIntegration Settings
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

     ${resp}=  View Waitlist Settings
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200


     ${id}=  get_id  ${MUSERNAME_E}
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
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+577810
     clear_users  ${PUSERNAME_U1}
     Set Suite Variable  ${PUSERNAME_U1}
     ${firstname}=  FakerLibrary.name
     Set Suite Variable  ${firstname}
     ${lastname}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname}
     ${dob}=  FakerLibrary.Date
     Set Suite Variable  ${dob}
     ${pin}=  get_pincode
     ${user_dis_name}=  FakerLibrary.last_name
     Set Suite Variable  ${user_dis_name}
     ${employee_id}=  FakerLibrary.last_name
     Set Suite Variable  ${employee_id}
      ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${EMPTY}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[1]}  ${NULL}  ${NULL}  ${NULL}  ${NULL}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${u_id}  ${resp.json()}
    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200
    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_specs  ${resp.json()}
    Log  ${spec}

    ${resp}=  Get Spoke Languages
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${Languages}=  get_Languagespoken  ${resp.json()}
    Log  ${Languages}

    ${bs}=  FakerLibrary.bs
    ${bs_des}=  FakerLibrary.word

    ${resp}=  User Profile Updation  ${bs}  ${bs_des}  ${spec}  ${Languages}  ${sub_domain_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${u_p_id}  ${resp.json()['profileId']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10        
    Set Suite Variable  ${DAY2}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime1}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime1}
    ${eTime1}=  add_timezone_time  ${tz}  2  30  
    Set Suite Variable   ${eTime1}

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable  ${description}
    ${dur}=  FakerLibrary.Random Int  min=05  max=10
    Set Suite Variable  ${dur}
    ${amt}=  FakerLibrary.Random Int  min=200  max=500
    ${amt}=  Convert To Number  ${amt}  1
    Set Suite Variable  ${amt}
    ${resp}=  Create Service For User  ${SERVICE1}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    Set Suite Variable  ${dur1}
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
    ${resp}=   Get Service By Id  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${queue_name}=  FakerLibrary.bs
    Set Suite Variable  ${queue_name}
    ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${u_id}  ${s_id}  ${s_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${q_id}  ${resp.json()}

     ${resp}=  Update User Search Status  ${toggle[0]}  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get User Search Status  ${u_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Should Be Equal As Strings  ${resp.json()}  True

      ${resp}=  AddCustomer  ${CUSERNAME1}  countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid}  ${resp.json()}

     ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${cons_id}=  get_id  ${CUSERNAME1} 
    ${desc}=   FakerLibrary.word
    ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-WaitlistByUserLogin-2
      [Documentation]   Add a consumer to a  user's another service on same Queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid1}  ${wid[0]}
      ${wait_time}=  Evaluate  (${dur}+${dur1})/2
      ${wait_time}    Convert To Integer  ${wait_time}
      Set Suite Variable  ${wait_time}
     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${wait_time}  waitlistedBy=${waitlistedby[1]}   personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-WaitlistByUserLogin-3
      [Documentation]   Add a consumer to the waitlist for a future date for the same service of current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${FUT_DAY}=  db.add_timezone_date  ${tz}  2  
      Set Suite Variable   ${FUT_DAY}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id2}  ${q_id}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid1}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-WaitlistByUserLogin-4
      [Documentation]   Add a consumer to the waitlist for a different service in a future date 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id}  ${q_id}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid1}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${wait_time}  waitlistedBy=${waitlistedby[1]}   personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-WaitlistByUserLogin-5
    [Documentation]   Add a consumer to a different queue 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Service For User  ${SERVICE3}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${s_id3}  ${resp.json()}
      ${queue_name}=  FakerLibrary.bs
      Set Suite Variable  ${queue_name}
      ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${u_id}  ${s_id3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q_id2}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid4}  ${wid[0]}

     ${resp}=  Get Waitlist By Id  ${wid4} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby[1]}   personsAhead=0
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
      
JD-TC-WaitlistByUserLogin-6
      [Documentation]   Add a consumer to same service on same date to a different queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings   "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"

JD-TC-WaitlistByUserLogin-7
      [Documentation]   Add to waitlist after disabling online checkin (Walkin checkins possible)

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Online Checkin
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME2}  countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid2}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()[0]['id']}
      Set Suite Variable  ${wait_time}  ${dur}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid4}  ${wid[0]}
     ${resp}=  Get Waitlist By Id  ${wid4} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${wait_time}  waitlistedBy=${waitlistedby[1]}   personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${id}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${id}

JD-TC-WaitlistByUserLogin-8
      [Documentation]   Add family members to the waitlist
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${wait_time1}=  Evaluate  ${wait_time}+${wait_time}
      Set Suite Variable  ${wait_time1}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${Genderlist[0]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${f_name}  ${l_name}  ${dob}  ${Genderlist[1]}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${mem_id}  ${mem_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid4}  ${wid[0]}
      Set Suite Variable  ${wid5}  ${wid[1]}
      ${wait_time2}=  Evaluate  ${wait_time1}+${wait_time}
      Set Suite Variable   ${wait_time2}
      
     ${resp}=  Get Waitlist By Id  ${wid4} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${wait_time1}  waitlistedBy=${waitlistedby[1]}   personsAhead=2
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${id}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
     ${resp}=  Get Waitlist By Id  ${wid5} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${wait_time2}  waitlistedBy=${waitlistedby[1]}   personsAhead=3
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE3}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id3}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${id}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

JD-TC-WaitlistByUserLogin-9
      [Documentation]   Add again to the same queue and service after cancelling the waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${pid}=  get_id  ${PUSERNAME151}
      # Set Suite Variable   ${pid}
      ${resp}=  AddCustomer  ${CUSERNAME12}  countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid12}  ${resp.json()}
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME12}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()[0]['id']}
      ${wait_time3}=  Evaluate  ${wait_time2}+${wait_time}
      ${desc}=   FakerLibrary.word
      Set Suite Variable    ${desc}
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      ${cncl_resn}=   Random Element     ${waitlist_cancl_reasn}
      ${resp}=  Waitlist Action Cancel  ${wid1}  ${cncl_resn}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wait_id3}  ${wid[0]}

JD-TC-WaitlistByUserLogin-UH1
      [Documentation]   Add To Waitlist by Consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
 
JD-TC-WaitlistByUserLogin-UH2
      [Documentation]   Add To Waitlist without login

      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-WaitlistByUserLogin-UH3
      [Documentation]   Add To Waitlist by passing invalid consumer

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Add To Waitlist By User  000  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ID}"

JD-TC-WaitlistByUserLogin-UH4
      [Documentation]   Waitlist for a non family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME4}   countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid4}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid7}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  404
      Should Be Equal As Strings  "${resp.json()}"  "${NOT_A_Familiy_Member}"


JD-TC-WaitlistByUserLogin-UH5
      [Documentation]   Add a consumer to the same queue for the same service repeatedly

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${CUSERNAME15}
      ${resp}=  AddCustomer  ${CUSERNAME15}   countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid15}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid8}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist By User  ${cid8}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid8}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${cid8}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid8}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CUSTOMER_ALREADY_IN}"


JD-TC-WaitlistByUserLogin-UH6
      [Documentation]   Add to waitlist after disabling queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Create Service For User  ${SERVICE4}  ${description}   ${dur}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${s_id4}  ${resp.json()}
      ${queue_name}=  FakerLibrary.bs
      Set Suite Variable  ${queue_name}
      ${resp}=  Create Queue For User  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  10  ${lid}  ${u_id}  ${s_id4}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${q_id3}  ${resp.json()}
      ${resp}=  Disable Queue  ${q_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  AddCustomer  ${CUSERNAME3}  countryCode=${country_code}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${pcid3}  ${resp.json()}

      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id2}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id2}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${QUEUE_DISABLED}"
      ${resp}=  Enable Queue  ${q_id3}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-WaitlistByUserLogin-UH7
      [Documentation]   Add to waitlist after disabling service

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Service  ${s_id4}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${CUSERNAME5}
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      #Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"
      ${resp}=  Enable Service  ${s_id4}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-WaitlistByUserLogin-10
      [Documentation]   Add to waitlist after disabling future checkin

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200 
      ${resp}=   Disable Future Checkin
      Log  ${resp.json()}
       Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  View Waitlist Settings
      Verify Response  ${resp}  futureDateWaitlist=False
      sleep  2s

      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${FUT_DAY}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Enable Future Checkin
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-WaitlistByUserLogin-UH8
      [Documentation]   Add to waitlist after disabling waitlist for current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Waitlist
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  2s
      # ${id}=  get_id  ${CUSERNAME3}
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_NOT_ENABLED}"
      ${resp}=  Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-WaitlistByUserLogin-UH9
      [Documentation]   Add to waitlist on a holiday
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${strt_time}=  add_timezone_time  ${tz}  0  20
      Set Suite Variable   ${strt_time}
      ${resp}=  Create Holiday For User  ${DAY1}  ${desc}  ${sTime1}  ${eTime1}  ${u_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

