*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions
Test Teardown     Delete All Sessions
# Force Tags        Fixed
Force Tags        WaitingTimeFixed
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
${SERVICE1}     DelayHLev
${SERVICE2}     DelayHLev2
${start}        110

*** Test Cases ***
JD-TC-High Level Test Case-1
	[Documentation]  Checking the appxWaitingTime when calculation mode as Fixed
    

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME56}  ${PASSWORD}

    clear_queue  ${PUSERNAME156}
    clear_customer   ${PUSERNAME156}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME156}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME156} 
 
    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  02s
    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=8   max=8
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location  ${PUSERNAME156}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  00
    Set Suite Variable   ${sTime}
    ${eTime}=  db.subtract_timezone_time  ${tz}   2  00  
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${sTime}=  db.subtract_timezone_time  ${tz}  1  00
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${q_name}=   FakerLibrary.word
    ${parallel}=   Random Int   min=1    max=1
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue  ${q_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}   ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sId_1}  ${sId_2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${word}=  FakerLibrary.word
    
    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid4}  ${wid[0]}
   
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid6}  ${wid[0]}
    
    Sleep  2s
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    
    Comment  Start 1st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  5s

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  Start 2st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  cancel 5th waitlist
    ${word}=  FakerLibrary.word
    ${resp}=  Waitlist Action Cancel  ${wid5}  ${waitlist_cancl_reasn[0]}  ${word}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  cancel 4th waitlist
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[0]}  ${word}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  canceled waitlist back to queue
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200   
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=0
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

# JD-TC-High Level Test Case-2
# 	[Documentation]  Checking the appxWaitingTime when calculation mode as Fixed and considerpartysize for calculation is true
    
    # ${resp}=   Get File    /ebs/TDD/varfiles/providers.py
    # ${len}=   Split to lines  ${resp}
    # ${length}=  Get Length   ${len}
    # # ${start}  
    # FOR  ${a}  IN RANGE   ${length}
    #     ${resp}=  Encrypted Provider Login  ${PUSERNAME${a}}  ${PASSWORD}
    #     Log  ${resp.content}
    #     Should Be Equal As Strings    ${resp.status_code}    200
    #     ${domain}=   Set Variable    ${resp.json()['sector']}
    #     ${subdomain}=    Set Variable      ${resp.json()['subSector']}
    #     ${resp2}=   Get Sub Domain Settings    ${domain}    ${subdomain}
    #     Should Be Equal As Strings    ${resp.status_code}    200
    #     Log   ${resp2.json()}
    #     Set Test Variable  ${check}  ${resp2.json()['partySizeForCalculation']}
    #     Exit For Loop IF     "${check}"=="True"
    # END
    # clear_service   ${PUSERNAME${a}}

    # clear_waitlist   ${PUSERNAME${a}}

    # Log  ${PUSERNAME${a}}
    # Log  ${domain}
    # Log  ${subdomain}



JD-TC-High Level Test Case-2
	[Documentation]  Checking the appxWaitingTime when calculation mode as Fixed and considerpartysize for calculation is true
    
    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+10901
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
    Set Suite Variable   ${PUSERPH2}
    
    ${max_party}=  get_maxpartysize_subdomain
    Log    ${max_party}
    Set Suite Variable  ${d1}  ${max_party['domain']}
    Set Suite Variable  ${sd1}  ${max_party['subdomain']}

    ${pkg_id}=   get_highest_license_pkg

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}

    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH2}    ${pkg_id[0]}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERPH2}  0
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    
    ${list}=  Create List  1  2  3  4  5  6  7
    ${PUSERPH4}=  Evaluate  ${PUSERNAME}+305
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH4}${\n}
    ${PUSERPH5}=  Evaluate  ${PUSERNAME}+306
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH5}${\n}
    ${PUSERMAIL3}=   Set Variable  ${P_Email}${PUSERPH4}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${PUSERPH4}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${PUSERPH5}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${PUSERMAIL3}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
    # ${sTime}=  db.get_time_by_timezone   ${tz}
    ${sTime}=  db.get_time_by_timezone  ${tz}
    ${eTime}=  add_timezone_time  ${tz}  4  15  
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${resp}=  Update Business Profile with schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${lid}  ${resp.json()['baseLocation']['id']}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH2}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}  ${lastname}   ${email_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Enable Waitlist
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s

    ${trnTime}=   Random Int   min=10   max=10
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   5
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s

    ${description}=  FakerLibrary.sentence
    ${ser_dutratn}=   Random Int   min=8   max=8
    ${total_amount1}=  Random Int   min=100  max=500
    ${min_prepayment}=   Random Int   min=10  max=50
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${ser_dutratn}  ${status[0]}  ${bType}  ${bool[0]}  ${notifytype[0]}  ${EMPTY}  ${total_amount1}  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    clear_location   ${PUSERPH2}
    # ${city}=   get_place
    # Set Suite Variable  ${city}
    # ${latti}=  get_latitude
    # Set Suite Variable  ${latti}
    # ${longi}=  get_longitude
    # Set Suite Variable  ${longi}
    # ${postcode}=  FakerLibrary.postcode
    # Set Suite Variable  ${postcode}
    # ${address}=  get_address
    # Set Suite Variable  ${address}
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    Set Suite Variable  ${city}
    Set Suite Variable  ${latti}
    Set Suite Variable  ${longi}
    Set Suite Variable  ${postcode}
    Set Suite Variable  ${address}
    ${parking}    Random Element   ${parkingType}
    Set Suite Variable  ${parking}
    ${24hours}    Random Element    ${bool}
    Set Suite Variable  ${24hours}
    ${DAY}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY}
	${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}
    ${sTime}=  db.subtract_timezone_time  ${tz}  4  00
    Set Suite Variable   ${sTime}
    ${eTime}=  db.subtract_timezone_time  ${tz}   3  00
    Set Suite Variable   ${eTime}
    ${resp}=  Create Location  ${city}  ${longi}  ${latti}  www.${city}.com  ${postcode}  ${address}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${sTime}=  db.subtract_timezone_time  ${tz}  2  00
    ${eTime}=  add_timezone_time  ${tz}  5  00  
    ${q_name}=   FakerLibrary.word
    ${parallel}=   Random Int   min=1    max=1
    ${capacity}=   Random Int   min=10   max=20
    ${resp}=  Create Queue  ${q_name}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}   ${eTime}  ${parallel}  ${capacity}  ${lid}  ${sId_1}  ${sId_2} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid}  ${resp.json()}
    ${trnTime}=   Random Int   min=10   max=10


    # ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${trnTime}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${bool[0]}   5
    # Should Be Equal As Strings  ${resp.status_code}  200

    # sleep  5s


    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${word}=  FakerLibrary.word
    # ${cid}=  get_id  ${CUSERNAME1}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id2}  ${resp.json()}

    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${mem_id1}  ${mem_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}

    ${resp}=  Add To Waitlist  ${cid}  ${sId_2}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${mem_id1}  ${mem_id2}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid3}  ${wid[0]}
    Set Test Variable  ${wid4}  ${wid[1]}

    # ${cid}=  get_id  ${CUSERNAME2}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id3}  ${resp.json()}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id4}  ${resp.json()}
    ${resp}=  Add To Waitlist  ${cid}  ${sId_1}  ${qid}  ${DAY}  ${word}  ${bool[1]}  ${mem_id3}  ${mem_id4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid5}  ${wid[0]}
    Set Test Variable  ${wid6}  ${wid[1]}
    Sleep  3s
    Comment  Check waiting time of every waitlist
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=10
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    Comment  Start 1st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.content}

    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  Start 2st waitlist
    ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10
    ${word}=  FakerLibrary.word
    Comment  cancel 5th waitlist
    ${resp}=  Waitlist Action Cancel  ${wid5}  ${waitlist_cancl_reasn[0]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200


    sleep  5s


    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  cancel 4th waitlist
    ${resp}=  Waitlist Action Cancel  ${wid4}  ${waitlist_cancl_reasn[0]}  ${word}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=0  waitlistStatus=${wl_status[4]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10

    Comment  canceled waitlist back to queue
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200   
    sleep  2s
    ${resp}=  Get Waitlist Today  queue-eq=${qid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  ynwUuid=${wid1}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  1  ynwUuid=${wid2}  appxWaitingTime=0  waitlistStatus=${wl_status[2]}
    Verify Response List  ${resp}  2  ynwUuid=${wid3}  appxWaitingTime=10
    Verify Response List  ${resp}  3  ynwUuid=${wid4}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  4  ynwUuid=${wid5}  appxWaitingTime=10  waitlistStatus=${wl_status[0]}
    Verify Response List  ${resp}  5  ynwUuid=${wid6}  appxWaitingTime=10





