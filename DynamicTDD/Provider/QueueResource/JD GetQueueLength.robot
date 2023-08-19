*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Queue
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
${SERVICE1}  Makeup  
${SERVICE2}  Hair makeup
${self}      0

*** Test Cases ***

JD-TC-GetQueueLength-1
      [Documentation]   Get queue length

      ${multilocdoms}=  get_mutilocation_domains
      Log  ${multilocdoms}
      Set Suite Variable  ${dom}  ${multilocdoms[0]['domain']}
      Set Suite Variable  ${sub_dom}  ${multilocdoms[0]['subdomains'][0]}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${PUSERNAME_F}=  Evaluate  ${PUSERNAME}+55102030
      ${highest_package}=  get_highest_license_pkg
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_F}    ${highest_package[0]}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERNAME_F}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERNAME_F}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_F}${\n}
      Set Suite Variable  ${PUSERNAME_F}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      ${list}=  Create List  1  2  3  4  5  6  7
      ${ph1}=  Evaluate  ${PUSERNAME_F}+15566124
      ${ph2}=  Evaluate  ${PUSERNAME_F}+25566128
      ${views}=  Random Element    ${Views}
      ${name1}=  FakerLibrary.name
      ${name2}=  FakerLibrary.name
      ${name3}=  FakerLibrary.name
      ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
      ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
      ${emails1}=  Emails  ${name3}  Email  ${P_Email}${PUSERNAME_F}.ynwtest@netvarth.com  ${views}
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
      ${parking}   Random Element   ${parkingType}
      ${24hours}    Random Element    ${bool}
      ${desc}=   FakerLibrary.sentence
      ${url}=   FakerLibrary.url
      ${sTime}=  add_timezone_time  ${tz}  0  15  
      ${eTime}=  add_timezone_time  ${tz}  0  45  
      ${resp}=  Update Business Profile with Schedule   ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=  Get Business Profile
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${fields}=   Get subDomain level Fields  ${dom}  ${sub_dom}
      Log  ${fields.json()}
      Should Be Equal As Strings    ${fields.status_code}   200

      ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

      ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_dom}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get specializations Sub Domain  ${dom}  ${sub_dom}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${spec}=  get_Specializations  ${resp.json()}
      ${resp}=  Update Specialization  ${spec}
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Enable Waitlist
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[0]}  ${boolean[0]}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get jaldeeIntegration Settings
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}  ${DAY1}
      ${DAY2}=  db.add_timezone_date  ${tz}  10        
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}  ${list}
      ${sTime1}=  subtract_timezone_time  ${tz}  1  15
      Set Suite Variable   ${sTime1}
      ${eTime1}=  add_timezone_time  ${tz}  0  30  
      Set Suite Variable   ${eTime1}
      ${lid}=  Create Sample Location
      Set Suite Variable  ${lid}
      ${s_id1}=  Create Sample Service  ${SERVICE1}
      Set Suite Variable  ${s_id1}
      ${queue_name}=  FakerLibrary.bs
      ${resp}=  Create Queue  ${queue_name}  Weekly  ${list}  ${DAY1}  ${DAY2}  ${EMPTY}  ${sTime1}  ${eTime1}  1  5  ${lid}  ${s_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${qid1}  ${resp.json()}
      
      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid1}  ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${cid}=  get_id  ${CUSERNAME2}
      ${desc}=   FakerLibrary.word

      ${resp}=  AddCustomer  ${CUSERNAME2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid2}  ${resp.json()}

      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid2}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.json()}  2
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  noshowup  hi
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  noshowup  hi
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetQueueLength-2
      [Documentation]   Get queue length after STARTED
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action  STARTED  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0


JD-TC-GetQueueLength-3
      [Documentation]   Get Queue length after CANCEL
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2
      ${msg}=  FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[4]}  ${msg}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${msg}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      
JD-TC-GetQueueLength-4
      [Documentation]   Get Queue length after CHECK_IN
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2
      ${msg}=  FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[4]}  ${msg}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${msg}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetQueueLength-5
      [Documentation]   Get future queue length after STARTED
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  1  
      Set Suite Variable  ${DAY2}  ${DAY2}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0


JD-TC-GetQueueLength-6
      [Documentation]   Get future queue length after CANCEL
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      
JD-TC-GetQueueLength-7
      [Documentation]   Get future queue length after CHECK_IN
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid1}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id}  ${wid[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid2}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}  ${cid2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  0
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  1
      ${resp}=  Waitlist Action  CHECK_IN  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  2

JD-TC-GetQueueLength-UH1
      [Documentation]   Get Queue length by Consumer login
      ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-GetQueueLength-UH2
      [Documentation]   Get Queue length without login
      ${resp}=  Get Queue Length  ${qid1}  ${DAY1}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"
      

*** Comment ***
JD-TC-GetQueueLength-3
      [Documentation]   Get Queue length after DONE
      ${resp}=  Encrypted Provider Login  ${PUSERNAME_F}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME}
      ${resp}=  Add To Waitlist  ${id}  ${serviceId2}  1  sample note
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${waitlist_id}  ${resp.json()}
      ${id}=  get_id  ${CUSERNAME1}
      ${resp}=  Add To Waitlist  ${id}  ${serviceId2}  1  sample note
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${waitlist_id1}  ${resp.json()}
      ${resp}=  Waitlist Count
      Should Be Equal As Strings  ${resp.json()}  2
      ${wlists}=  Create List  ${waitlist_id}
      ${resp}=  Apply Action  DONE  ${wlists}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Count
      Should Be Equal As Strings  ${resp.json()}  1
      ${wlists}=  Create List  ${waitlist_id1}
      ${resp}=  Apply Action  DONE  ${wlists}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Count
      Should Be Equal As Strings  ${resp.json()}  0

