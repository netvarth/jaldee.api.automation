*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Waitlist
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${waitlistedby}           PROVIDER 

*** Test Cases ***
JD-TC-FixedWaitingTime-1
    [Documentation]   Add a consumer to the waitlist for the current day then set fixed waiting time to that waitlist

    clear_queue      ${PUSERNAME27}
    clear_location   ${PUSERNAME27}
    clear_service    ${PUSERNAME27}
    clear_customer   ${PUSERNAME27}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}   
    Should Be Equal As Strings  ${resp.status_code}  200
    ${turn_arnd_time}=   Random Int  min=2   max=10
    Set Suite Variable   ${turn_arnd_time}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${turn_arnd_time}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}   calculationMode=${calc_mode[1]}
    
    ${resp}=  AddCustomer  ${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1} 
    ${resp}=   Create Sample Location
    Set Suite Variable    ${loc_id1}    ${resp}

    ${resp}=   Get Location ById  ${loc_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}  
    ${ser_name1}=   FakerLibrary.word
    Set Suite Variable    ${ser_name1} 
    ${resp}=   Create Sample Service  ${ser_name1}
    Set Suite Variable    ${ser_id1}    ${resp}  
    ${ser_name2}=   FakerLibrary.word
    Set Suite Variable    ${ser_name2} 
    ${resp}=   Create Sample Service  ${ser_name2}
    Set Suite Variable    ${ser_id2}    ${resp}  
    ${ser_name3}=   FakerLibrary.word
    Set Suite Variable    ${ser_name3} 
    ${resp}=   Create Sample Service  ${ser_name3}
    Set Suite Variable    ${ser_id3}    ${resp}      
    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${strt_time}=   db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  0  10   
    Set Suite Variable    ${end_time}  
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}   
    ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}   ${parallel}    ${capacity}    ${loc_id1}  ${ser_id1}  ${ser_id2}  ${ser_id3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}
    ${desc}=   FakerLibrary.word
    Set Suite Variable    ${desc}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}
    ${turn_arnd_time1}=   Random Int  min=2   max=10
    ${resp}=  Set Fixed Waiting Time  ${wid}  ${turn_arnd_time1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time1}  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}
    ${turn_arnd_time2}=   Random Int  min=2   max=10
    ${resp}=  Set Fixed Waiting Time  ${wid}  ${turn_arnd_time2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn _arnd_time2}  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-2
    [Documentation]   Add a consumer to a different service on same Queue and not set fixed waiting time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time}  waitlistedBy=${waitlistedby}   personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-3
    [Documentation]   Add a consumer to the waitlist for a future date for the same service of current day then set fixed waiting time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${turn_arnd_time3}=   Random Int  min=2   max=10
    ${resp}=  Set Fixed Waiting Time  ${wid2}  ${turn_arnd_time3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${turn_arnd_time3}  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-4
    [Documentation]   Add a consumer to the waitlist for a different service in a future date and not set fixed waiting time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${DAY2}=  db.add_timezone_date  ${tz}  2  
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id2}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY2}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${turn_arnd_time}  waitlistedBy=${waitlistedby}   personsAhead=1
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-5
    [Documentation]   Add a consumer to a different queue 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ser_name4}=   FakerLibrary.word
    Set Suite Variable    ${ser_name4} 
    ${resp}=   Create Sample Service  ${ser_name4}
    Set Suite Variable    ${ser_id4}    ${resp}      
    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${strt_time1}=   add_timezone_time  ${tz}   0  11
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}   0  28 
    Set Suite Variable    ${end_time1}     
    ${resp}=  Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}   ${parallel}    ${capacity}    ${loc_id1}  ${ser_id4} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${ser_id4}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}
    ${turn_arnd_time4}=  random Int  min=2   max=4
    Set Suite Variable   ${turn_arnd_time4}
    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time4}  waitlistedBy=${waitlistedby}   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name4}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id4}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-6
      [Documentation]   Add family members to the waitlist

      ${f_name}=  FakerLibrary.first_name
      ${l_name}=  FakerLibrary.last_name
      ${resp}=    get_maxpartysize_subdomain
      Set Test Variable   ${sector}        ${resp['domain']}
      Set Test Variable   ${sub_sector}    ${resp['subdomain']}
      ${PUSERNAME}=  Evaluate  ${PUSERNAME}+56710
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME}${\n}   
      ${pkg_id}=   get_highest_license_pkg
      ${resp}=   Account SignUp  ${f_name}  ${l_name}  ${None}   ${sector}   ${sub_sector}  ${PUSERNAME}  ${pkg_id[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200  
      ${bs1}=  FakerLibrary.word
      Set Suite Variable   ${bs1}
      ${ph1}=  Evaluate  ${PUSERNAME}+70073010
      Set Suite Variable   ${ph1}
      ${ph2}=  Evaluate  ${PUSERNAME}+70073011
      Set Suite Variable   ${ph2}
      ${name1}=  FakerLibrary.name
      Set Suite Variable   ${name1}
      ${name2}=  FakerLibrary.name
      Set Suite Variable   ${name2}
      ${name3}=  FakerLibrary.name
      Set Suite Variable   ${name3}
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  all
      Set Suite Variable  ${ph_nos1} 
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  all  
      Set Suite Variable  ${ph_nos2} 
      ${emails1}=  Emails  ${name3}  Email  ${P_Email}${bs1}.${test_mail}  all
      Set Suite Variable  ${emails1}
      ${bs_name}=  FakerLibrary.bs
      Set Suite Variable   ${bs_name}
      ${bs_desc}=  FakerLibrary.bs
      Set Suite Variable   ${bs_desc}
      ${companySuffix}=  FakerLibrary.companySuffix
      Set Suite Variable   ${companySuffix}
      #   ${city}=   get_place
    #   Set Suite Variable   ${city}
    #   ${latti}=  get_latitude
    #   Set Suite Variable   ${latti}
    #   ${longi}=  get_longitude
    #   Set Suite Variable   ${longi}
    #   ${postcode}=  FakerLibrary.postcode
    #   Set Suite Variable   ${postcode}
    #   ${address}=  get_address
    #   Set Suite Variable   ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
      ${sTime}=  db.subtract_timezone_time  ${tz}  4  15
      Set Suite Variable   ${sTime}
      ${eTime}=  db.subtract_timezone_time  ${tz}  2  50
      Set Suite Variable   ${eTime}
      ${resp}=  Update Business Profile with Schedule   ${bs_name}  ${bs_desc} Desc   ${companySuffix}  ${city}   ${longi}  ${latti}  www.${companySuffix}.com  free  ${bool[0]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      sleep   1s

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${fields}=   Get subDomain level Fields  ${sector}  ${sub_sector}
      Log  ${fields.json()}
      Should Be Equal As Strings    ${fields.status_code}   200

      ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

      ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_sector}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get specializations Sub Domain  ${sector}  ${sub_sector}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${spec}=  get_Specializations  ${resp.json()}
      ${resp}=  Update Specialization  ${spec}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      Set Suite Variable    ${loc_id}   ${resp.json()['baseLocation']['id']}
      ${turn_arnd_time5}=   Random Int  min=2   max=10
      Set Suite Variable   ${turn_arnd_time5}
      ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${turn_arnd_time5}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep   01s
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   
      ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
      
      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()}

      ${ser_name5}=   FakerLibrary.word
      Set Suite Variable    ${ser_name5} 
      ${resp}=   Create Sample Service  ${ser_name5}
      Set Suite Variable    ${ser_id5}    ${resp}  
      ${q_name2}=    FakerLibrary.name
      Set Suite Variable    ${q_name2}
      ${strt_time2}=   db.subtract_timezone_time  ${tz}  2  40
      Set Suite Variable    ${strt_time2}
      ${end_time2}=    add_timezone_time  ${tz}  0  10   
      Set Suite Variable    ${end_time2}   
      ${resp}=  Create Queue    ${q_name2}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time2}  ${end_time2}   ${parallel}   ${capacity}    ${loc_id}  ${ser_id5}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id3}   ${resp.json()}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider   ${id}  ${f_name}  ${l_name}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      ${f_name}=   FakerLibrary.first_name
      ${l_name}=   FakerLibrary.last_name
      ${dob}=      FakerLibrary.date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider   ${id}  ${f_name}  ${l_name}  ${dob}   ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      sleep  2s
      ${resp}=  View Waitlist Settings
      Verify Response  ${resp}  calculationMode=${calc_mode[1]}
      ${resp}=  Add To Waitlist  ${id}  ${ser_id5}  ${que_id3}  ${DAY1}  ${desc}  ${bool[1]}  ${mem_id}  ${mem_id1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}
      Set Test Variable  ${wid2}  ${wid[1]}
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}   personsAhead=0  appxWaitingTime=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}   personsAhead=1  appxWaitingTime=${turn_arnd_time5}
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

      ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${turn_arnd_time6}=   Random Int  min=1   max=5
      Set Suite Variable   ${turn_arnd_time6}
      ${resp}=  Set Fixed Waiting Time  ${wid2}  ${turn_arnd_time6}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${wid1} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby}   personsAhead=0  appxWaitingTime=${turn_arnd_time4}
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id}
      ${resp}=  Get Waitlist By Id  ${wid2} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  waitlistedBy=${waitlistedby}   personsAhead=1  appxWaitingTime=${turn_arnd_time6}
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name5}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id5}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${mem_id1}

JD-TC-FixedWaitingTime-UH1
    [Documentation]   Set Fixed waiting time to invalid waitlist id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${invalid_id}=   Random Int   min=-499   max=-1
    ${resp}=  Set Fixed Waiting Time  ${invalid_id}  ${turn_arnd_time4}
    Should Be Equal As Strings  ${resp.status_code}  404
    Should Be Equal As Strings  "${resp.json()}"  "${INVALID_WAITLIST}"

JD-TC-FixedWaitingTime-UH2
    [Documentation]   Set Fixed waiting time to invalid amount

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set Fixed Waiting Time  ${wid1}  -${turn_arnd_time4}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${ENTER_VALID_WATINGTIME}"

JD-TC-FixedWaitingTime-UH3
    [Documentation]   Set Fixed waiting time to a canceled waitlist

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  Add To Waitlist  ${cid}  ${ser_id3}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time}  waitlistedBy=${waitlistedby}   personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

    ${resp}=  Waitlist Action Cancel  ${wid1}  ${waitlist_cancl_reasn[2]}   ${desc}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_UPDATE_WAITING_TIME_FOR_THIS_STATUS}"

    ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  03s
    ${resp}=  Get Waitlist By Id  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=${turn_arnd_time4}  waitlistedBy=${waitlistedby}   personsAhead=2
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name3}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id3}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${cid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${cid}

JD-TC-FixedWaitingTime-UH4
    [Documentation]   Add a Provider  to the waitlist then set fixed waiting time after start and done waitlist operation

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${pid}=  get_id  ${PUSERNAME30}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    # ${ph2}=  Evaluate  ${PUSERNAME30}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddCustomer without email   ${firstname}  ${lastname}  ${EMPTY}  ${gender}  ${dob}  ${PUSERNAME30}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Suite Variable  ${pid}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME30}${\n}
    ${resp}=  Add To Waitlist  ${pid}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time}  waitlistedBy=${waitlistedby}   personsAhead=3
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id2}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${pid}
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_UPDATE_WAITING_TIME_FOR_THIS_STATUS}"


    ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${CANNOT_UPDATE_WAITING_TIME_FOR_THIS_STATUS}"

JD-TC-FixedWaitingTime-UH5
      [Documentation]   Set fixed waiting time  by Consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
 
JD-TC-FixedWaitingTime-UH6
      [Documentation]   Set fixed waiting time without login

      ${resp}=  Set Fixed Waiting Time  ${wid1}  ${turn_arnd_time}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-FixedWaitingTime-UH7
    [Documentation]   Set a waiting time which is larger than buiness hours time

    ${resp}=  Encrypted Provider Login  ${PUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${pid}=  get_id  ${PUSERNAME30}
    ${resp}=  Add To Waitlist  ${pid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=${turn_arnd_time}  waitlistedBy=${waitlistedby}   personsAhead=3
    Should Be Equal As Strings  ${resp.json()['service']['name']}                   ${ser_name1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                     ${ser_id1}
    Should Be Equal As Strings  ${resp.json()['consumer']['id']}                    ${pid}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}           ${pid}
    ${larger_time}=   Random Int   min=100  max=1000
    ${resp}=  Set Fixed Waiting Time  ${wid1}  ${larger_time}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${WAITING_TIME_MORE_THAN_BUS_HOURS}"