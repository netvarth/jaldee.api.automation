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
Variables         /ebs/TDD/varfiles/providers.py
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

JD-TC-WaitlistForUser-1
     [Documentation]  User taking a waitlist for current day
     ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
     Log  ${iscorp_subdomains}
     Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
     Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
     Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
     ${firstname_A}=  FakerLibrary.first_name
     Set Suite Variable  ${firstname_A}
     ${lastname_A}=  FakerLibrary.last_name
     Set Suite Variable  ${lastname_A}
     ${PUSERNAME_E}=  Evaluate  ${PUSERNAME}+884550
     ${highest_package}=  get_highest_license_pkg
     ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_E}    ${highest_package[0]}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Activation  ${PUSERNAME_E}  0
     Log   ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Account Set Credential  ${PUSERNAME_E}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${PUSERNAME_E}
     Should Be Equal As Strings    ${resp.status_code}    200
     ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
     Log  ${resp.json()}
     Should Be Equal As Strings    ${resp.status_code}    200
     Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/data/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${PUSERNAME_E}${\n}
     Set Suite Variable  ${PUSERNAME_E}
     ${DAY1}=  db.get_date_by_timezone  ${tz}
     Set Suite Variable  ${DAY1}  ${DAY1}
     ${list}=  Create List  1  2  3  4  5  6  7
     Set Suite Variable  ${list}  ${list}
     ${ph1}=  Evaluate  ${PUSERNAME_E}+1000000000
     ${ph2}=  Evaluate  ${PUSERNAME_E}+2000000000
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


     ${id}=  get_id  ${PUSERNAME_E}
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
     ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+58738821
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

      ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${countryCodes[0]}  ${PUSERNAME_U1}  bProfilePermitted  ${boolean[1]}  displayOrder  1  userDisplayName  ${user_dis_name}  employeeId  ${employee_id}
     Log   ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Set Suite Variable  ${u_id}  ${resp.json()}

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
    ${dur1}=  FakerLibrary.Random Int  min=10  max=20
    Set Suite Variable  ${dur1}
    ${resp}=  Create Service For User  ${SERVICE2}  ${description}   ${dur1}  ${status[0]}  ${bType}  ${bool[0]}   ${notifytype[0]}  0  ${amt}  ${bool[0]}  ${bool[0]}  ${dep_id}  ${u_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id2}  ${resp.json()}
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

JD-TC-WaitlistForUser-2
      [Documentation]   Add a consumer to a different user's service on same Queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id2}  ${q_id}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid1}  ${wid[0]}
      ${wait_time}=  Evaluate  (${dur}+${dur1})/2
      # Set Suite Variable  ${wait_time}
      ${wait_time}=  Convert To Integer  ${wait_time}
      Set Suite Variable  ${wait_time}
     ${resp}=  Get Waitlist By Id  ${wid1} 
     Log  ${resp.json()}
     Should Be Equal As Strings  ${resp.status_code}  200
     Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${wait_time}  waitlistedBy=${waitlistedby[1]}   personsAhead=1
     Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
     Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id2}
     Should Be Equal As Strings  ${resp.json()['consumer']['id']}   ${cid}
     Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-WaitlistForUser-3
      [Documentation]   Add a consumer to the waitlist for a future date for the same service of current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-4
      [Documentation]   Add a consumer to the waitlist for a different service in a future date 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-5
    [Documentation]   Add a consumer to a different queue 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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
      
JD-TC-WaitlistForUser-6
      [Documentation]   Add a consumer to same service on same date to a different queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist By User  ${cid}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings   "${resp.json()}"   "${WAITLIST_CUSTOMER_ALREADY_IN}"

JD-TC-WaitlistForUser-7
      [Documentation]   Add to waitlist after disabling online checkin (Walkin checkins possible)

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-8
      [Documentation]   Add family members to the waitlist
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-9
      [Documentation]   Add again to the same queue and service after cancelling the waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
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

JD-TC-WaitlistForUser-UH1
      [Documentation]   Add To Waitlist by Consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
 
JD-TC-WaitlistForUser-UH2
      [Documentation]   Add To Waitlist without login

      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings   ${resp.json()}   ${SESSION_EXPIRED}

JD-TC-WaitlistForUser-UH3
      [Documentation]   Add To Waitlist by using another provider's user details

      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id}  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings   ${resp.json()}   ${NO_PERMISSION}

JD-TC-WaitlistForUser-UH4
      [Documentation]   Add To Waitlist by passing invalid consumer

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Add To Waitlist By User  000  ${s_id3}  ${q_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ID}"

JD-TC-WaitlistForUser-UH5
      [Documentation]   Waitlist for a non family member

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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


JD-TC-WaitlistForUser-UH6
      [Documentation]   Add a consumer to the same queue for the same service repeatedly

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
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


JD-TC-WaitlistForUser-UH7
      [Documentation]   Add to waitlist after disabling queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-UH9
      [Documentation]   Add to waitlist after disabling service

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Service  ${s_id4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      #Should Be Equal As Strings  "${resp.json()}"  "${INVALID_SERVICE}"
      ${resp}=  Enable Service  ${s_id4}
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-WaitlistForUser-10
      [Documentation]   Add to waitlist after disabling future checkin

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
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

JD-TC-WaitlistForUser-UH11
      [Documentation]   Add to waitlist after disabling waitlist for current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Waitlist
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  2s
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_NOT_ENABLED}"
      ${resp}=  Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200


JD-TC-WaitlistForUser-UH12
      [Documentation]   Add to waitlist on a holiday
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${strt_time}=  add_timezone_time  ${tz}  0  20
      Set Suite Variable   ${strt_time}
      ${resp}=  Create Holiday For User  ${DAY1}  ${desc}  ${sTime1}  ${eTime1}  ${u_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist By User  ${id2}  ${s_id4}  ${q_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${u_id}  ${id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

*** Comments ***





JD-TC-WaitlistForUser-UH13
      [Documentation]   Add a consumer to a waitlist when partysize number affecting  waiting time and it becomes greater than working time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${Acid}  ${resp.json()[0]['id']}

      ${queue1}=    FakerLibrary.name
      Set Suite Variable    ${queue1}    
      ${strt_time3}=   add_timezone_time  ${tz}  0  35  
      Set Suite Variable    ${strt_time3}
      ${end_time3}=    add_timezone_time  ${tz}  0  38 
      Set Suite Variable    ${end_time3}  
      ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time3}  ${end_time3}  ${parallel}  ${capacity}  ${loc_id3}  ${ser_id7}
      Log     ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id6}   ${resp.json()}
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Add To Waitlist  ${Acid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${CUSERNAME3}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500000
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${Genderlist[0]}  ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+500001
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=    FakerLibrary.last_name
      ${dob}=       FakerLibrary.date
      ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${Acid}  ${f_name}  ${l_name}  ${dob}  ${Genderlist[1]}   ${Familymember_ph}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  Add To Waitlist  ${Acid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

JD-TC-WaitlistForUser-UH14
      [Documentation]   Add a consumer to a waitlist when partysize number affecting  waiting time and it becomes greater than working time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${cons_id3}=  get_id  ${CUSERNAME6}
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${coid}  ${resp.json()[0]['id']}

      ${resp}=  Add To Waitlist  ${coid}  ${ser_id7}  ${que_id6}  ${CUR_DAY}  ${desc}  ${bool[1]}  0
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_TIME_MORE_THAN_BUS_HOURS}"

JD-TC-WaitlistForUser-UH15
      [Documentation]   Add a consumer to a waitlist after working time

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${queue2}=    FakerLibrary.name
      Set Suite Variable    ${queue2} 
      ${stime}=   db.subtract_timezone_time  ${tz}   2   00  
      ${etime}=   db.get_time_by_timezone  ${tz}
      ${resp}=  Create Queue   ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id7}   ${resp.json()}
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${ser_duratn}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${CUSERNAME0}
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${coid1}  ${resp.json()[0]['id']}
      ${resp}=  Add To Waitlist  ${coid1}  ${ser_id1}  ${que_id7}  ${CUR_DAY}  ${desc}  ${bool[1]}  0
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_BUS_HOURS_END}"

JD-TC-WaitlistForUser-UH16
      [Documentation]   Add to waitlist on a non scheduled day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${list}=  Create List  1  2  3  4  5  6
      ${stime}=   db.subtract_timezone_time  ${tz}   2   00  
      Set Suite Variable   ${stime}
      ${etime}=   add_timezone_time  ${tz}  0  15  
      Set Suite Variable   ${etime}
      ${resp}=  Update Queue  ${que_id7}  ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  ${capacity}  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${d}=  get_timezone_weekday  ${tz}
      ${d}=  Evaluate  7-${d}
      ${DAY2}=  db.add_timezone_date  ${tz}  ${d}  
      # ${id}=  get_id  ${PUSERNAME2}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME2}  ${EMPTY}  
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Suite Variable  ${coid3}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME2}${\n}
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  0
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${HOLIDAY_NON_WORKING_DAY}"

JD-TC-WaitlistForUser-UH17
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Update Queue  ${que_id7}  ${queue2}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  ${parallel}  2  ${loc_id1}  ${ser_id1}  ${ser_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  1  
      # ${id}=  get_id  ${PUSERNAME2}
      ${resp}=  Add To Waitlist  ${coid3}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  0
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${PUSERNAME3}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      # ${ph2}=  Evaluate  ${PUSERNAME3}
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME3}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid4}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
      ${resp}=  Add To Waitlist  ${cid4}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  0
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${PUSERNAME4}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      # ${ph2}=  Evaluate  ${PUSERNAME4}
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME4}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Set Test Variable  ${cid5}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME4}${\n}
     
      ${resp}=  Add To Waitlist  ${cid5}  ${ser_id1}  ${que_id7}  ${DAY2}  ${desc}  ${bool[1]}  0
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"


JD-TC-WaitlistForUser-UH18
      [Documentation]  update maximum capacity and check

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${queue4}=    FakerLibrary.name
      Set Suite Variable    ${queue4}    
      ${DAY1}=  db.add_timezone_date  ${tz}  1  
      ${resp}=  Create Queue  ${queue4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  50  ${loc_id1}  ${ser_id3}   ${ser_id4}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id8}  ${resp.json()}
      # ${id}=  get_id  ${PUSERNAME1}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      # ${ph2}=  Evaluate  ${PUSERNAME1}
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME1}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid0}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME1}${\n}
      
      ${resp}=  Add To Waitlist  ${cid0}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  0
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Update Queue  ${que_id8}  ${queue4}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${stime}  ${etime}  1  4  ${loc_id1}  ${ser_id3}  ${ser_id4}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${PUSERNAME7}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      # ${ph2}=  Evaluate  ${PUSERNAME3}
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME7}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid1}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME3}${\n}
     
      ${resp}=  Add To Waitlist  ${cid1}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${PUSERNAME6}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      # ${ph2}=  Evaluate  ${PUSERNAME6}
      ${dob}=  FakerLibrary.Date
      ${Genderlist}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${Genderlist}  ${dob}  ${PUSERNAME6}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid2}  ${resp.json()}
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME6}${\n}
      
      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id3}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${id}=  get_id  ${PUSERNAME3}

     
      ${resp}=  Add To Waitlist  ${cid1}   ${ser_id4}   ${que_id8}   ${DAY1}   ${desc}  ${bool[1]}  0
      Should Be Equal As Strings  ${resp.status_code}  200 
      # ${id}=  get_id  ${PUSERNAME6}

     
      ${resp}=  Add To Waitlist  ${cid2}  ${ser_id4}  ${que_id8}  ${DAY1}  ${desc}  ${bool[1]}  0
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WATLIST_MAX_LIMIT_REACHED}"

      # sleep   2s
JD-TC-Verify WaitlistForUser-2
      [Documentation]   Verify Add a consumer to a different service on same Queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${cid}
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0

JD-TC-Verify WaitlistForUser-3
      [Documentation]   Verify Add a consumer to the waitlist for a future date for the same service of current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0
JD-TC-Verify WaitlistForUser-4
      [Documentation]   Verify Add a consumer to the waitlist for a different service in a future date 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0

JD-TC-Verify WaitlistForUser-5
    [Documentation]   Verify Add a consumer to a different queue 

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid4} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE4}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id4}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0

JD-TC-Verify WaitlistForUser-6
      [Documentation]   Verify Add a consumer to same service on same date to a different queue

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid5} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time}  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${c_id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         0

JD-TC-Verify WaitlistForUser-7
      [Documentation]   Verify Add a consumer to a waitlist who is already added to another provider's waitlist for the current day

      ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid11} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid1}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         0

JD-TC-Verify WaitlistForUser-8
    [Documentation]   Verify Add a consumer to a waitlist, who is already added to another provider's waitlist for a future date

      ${resp}=  Encrypted Provider Login  ${PUSERNAME151}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid12} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${FUT_DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0   waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid1}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0

JD-TC-Verify WaitlistForUser-9
    [Documentation]   Verify Add a provider to the waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid6} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${app_wait_time1}  waitlistedBy=${waitlistedby}  personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0

JD-TC-Verify WaitlistForUser-11
      [Documentation]   Verify Add family members to the waitlist
      
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_A}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200  
      ${resp}=  Get Waitlist By Id  ${wait_id1}
      Log  ${resp.json()} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
      ${resp}=  Get Waitlist By Id  ${wait_id2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=1
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id7}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

JD-TC-Verify WaitlistForUser-12
      [Documentation]   Verify Add again to the same queue and service after cancelling the waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_E}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wait_id3} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}  personsAhead=3
      Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           0
