*** Settings ***
Suite Teardown    Delete All Sessions 
Test Teardown     Delete All Sessions
Force Tags        Waitlist Settings
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

       
*** Variables ***
${SERVICE1} 	   stuff
${SERVICE2} 	   SerUpdSett1
${SERVICE3} 	   SerUpdSett2
${SERVICE5} 	   SerUpdSett3
${loc}             EFGH
${queue1}          MorningQueue
${queue2}          AfternoonQueue
${queue3}          EveningQueue
@{service_duration}  5  10  15   
${parallel}     1

*** Test Cases ***

JD-TC-UpdateWaitlistSettings-1
    [Documentation]  Update wailist settings using calculationMode as Fixed
  
    ${resp}=  ProviderLogin  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${resp}=  View Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}    maxPartySize=1
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${resp}=  View Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[0]}  trnArndTime=0   futureDateWaitlist=${bool[1]}  showTokenId=${bool[0]}  onlineCheckIns=${bool[1]}    maxPartySize=1
    

JD-TC-UpdateWaitlistSettings-2

    [Documentation]  Show token id to true and verify
    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_service   ${PUSERNAME2}
    clear_location  ${PUSERNAME2}
    clear_queue  ${PUSERNAME2}
    clear_customer   ${PUSERNAME2}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  showTokenId=${bool[1]}
    ${cid}=  get_id  ${CUSERNAME1}
    Set Suite Variable  ${cid}  ${cid}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${description}=  FakerLibrary.sentence
    Set Suite Variable   ${description}
    
    clear_location  ${PUSERNAME2}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid16}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Waitlist By Id  ${wid} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  token=1



JD-TC-UpdateWaitlistSettings-3
    [Documentation]  Set futureDateWaitlist to true and verify
    ${resp}=  ProviderLogin  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME2}
    clear_location  ${PUSERNAME2}
    clear_queue  ${PUSERNAME2}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  futureDateWaitlist=True
    
    clear_location  ${PUSERNAME2}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${DAY2}=  add_date  2
    Set Suite Variable  ${DAY2}  ${DAY2}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id1}  ${qid1}  ${DAY2}  ${desc}  ${bool[1]}   ${cid}
    
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist Future  queue-eq=${qid1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  checkedIn
    

JD-TC-UpdateWaitlistSettings-4
    [Documentation]  Set OnlineCheckin to true and verify
    ${resp}=  ProviderLogin  ${PUSERNAME28}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME28}
    clear_location  ${PUSERNAME28}
    clear_queue  ${PUSERNAME28}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}  futureDateWaitlist=${bool[1]}

    clear_location  ${PUSERNAME28}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid2}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid01}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${DAY2}=  add_date  2
    Set Suite Variable  ${DAY2}  ${DAY2}
    
    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id2}  ${qid2}  ${DAY2}  ${desc}  ${bool[1]}  ${cid}

    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist Future  queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  checkedIn


JD-TC-UpdateWaitlistSettings-5
    [Documentation]  Set OnlineCheckin to true and verify consumer can take waitlist by online
    ${resp}=  ProviderLogin  ${PUSERNAME26}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME26}
    clear_service   ${PUSERNAME26}
    clear_location  ${PUSERNAME26}
    clear_queue  ${PUSERNAME26}

    Set Suite Variable  ${pid}  ${pid}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}   ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  onlineCheckIns=${bool[1]}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}

    clear_location  ${PUSERNAME26}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid1}   ${resp['queue_id']}
    Set Suite Variable  ${s_id1}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  ConsumerLogin  ${CUSERNAME7}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${cid}=  get_id  ${CUSERNAME7}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}
 
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid1}  ${DAY1}  ${s_id1}  ${description}  ${bool[0]}  ${cidfor}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}


JD-TC-UpdateWaitlistSettings-6
    [Documentation]  Set OnlineCheckin to false and verify provider can take waitlist for future
    ${resp}=  ProviderLogin  ${PUSERNAME30}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    
    
    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}   ${bool[0]}   ${bool[1]}   ${bool[0]}  ${bool[0]}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=     Disable Online Checkin

    ${resp}=  View Waitlist Settings
    Log     ${resp.json()}
    Verify Response  ${resp}  onlineCheckIns=${bool[0]}  futureDateWaitlist=${bool[1]}
    clear_service   ${PUSERNAME30}
    clear_location  ${PUSERNAME30}
    clear_queue  ${PUSERNAME30}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid2}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${DAY2}=  add_date  3
    Set Suite Variable  ${DAY2}  ${DAY2}

    ${resp}=  AddCustomer  ${CUSERNAME16}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid16}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME16}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id2}  ${qid2}  ${DAY2}  ${desc}  ${bool[1]}   ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Waitlist Future  queue-eq=${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['date']}  ${DAY2}
    Should Be Equal As Strings  ${resp.json()[0]['waitlistStatus']}  ${wl_status[0]}


JD-TC-UpdateWaitlistSettings-7
    [Documentation]  Update wailist settings using calculationMode as Non calculation Mode then check queue waiting time and trnarndtime as zero
    ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    clear_service   ${PUSERNAME8}
    clear_location  ${PUSERNAME8}
    clear_queue  ${PUSERNAME8}    
    clear_customer  ${PUSERNAME8}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}   0  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  2s
    ${resp}=  View Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[2]}  trnArndTime=0   futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}

    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid11}   ${resp['queue_id']}
    Set Suite Variable  ${s_id11}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid4}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id11}  ${qid11}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid11}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid11} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=0   queueWaitingTime=0

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid5}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id11}  ${qid11}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid11}  ${wid[0]}
    ${resp}=  Get Waitlist By Id  ${wid11} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Queue ById  ${qid11}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=0   queueWaitingTime=0


JD-TC-UpdateWaitlistSettings-8
    [Documentation]  Update wailist settings using calculationMode as Fixed and check queueWaittingTime and TrnarndTime
    ${resp}=  ProviderLogin  ${PUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s
    ${resp}=  View Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=5   futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    
    clear_location  ${PUSERNAME5}
    clear_service   ${PUSERNAME5}
    clear_customer  ${PUSERNAME5}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid8}   ${resp['queue_id']}
    Set Suite Variable  ${s_id8}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid4}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id8}  ${qid8}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}   turnAroundTime=5   queueWaitingTime=5
    ${resp}=  Get Waitlist By Id  ${wid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=0

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id8}  ${qid8}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=5
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=5

    ${resp}=  AddCustomer  ${CUSERNAME1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid11}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id8}  ${qid8}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}

    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Get Queue ById  ${qid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5   queueWaitingTime=5
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=5


JD-TC-UpdateWaitlistSettings-9
    [Documentation]  verify Queue waiting time and TrnArndTime when maxPartySize is greater than 1
    
    ${iscorp_subdomains}=  get_iscorp_subdomains_with_maxpartysize  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${numbers}=     Random Int   min=1000   max=1000000
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${numbers}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${PUSERNAME_A}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME_A}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${PUSERNAME_A}${\n}
    Set Suite Variable  ${PUSERNAME_A}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list} 
    ${ph1}=  Evaluate  ${PUSERNAME_A}+1000000000
    ${ph2}=  Evaluate  ${PUSERNAME_A}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}183.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${city}=   get_place
    ${latti}=  get_latitude
    ${longi}=  get_longitude
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${sTime}=  add_time  0  15
    Set Suite Variable   ${sTime}
    ${eTime}=  add_time   0  45
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile With Schedule  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()['baseLocation']['id']}  

    ${P1SERVICE1}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE1}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id9}  ${resp.json()}

    ${P1SERVICE2}=    FakerLibrary.word
    Set Suite Variable  ${P1SERVICE2}
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${servicecharge}=   Random Int  min=100  max=500
    ${resp}=  Create Service  ${P1SERVICE2}  ${desc}   ${service_duration[0]}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge}  ${bool[0]}  ${bool[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id10}  ${resp.json()}

    ${DAY}=  db.get_date    
    Set Suite Variable  ${DAY} 
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}

    ${sTime1}=  add_time  1  00
    ${eTime1}=  add_time  2  00
    ${p1queue1}=    FakerLibrary.word
    Set Suite Variable   ${p1queue1}
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${parallel}=  FakerLibrary.Numerify  %
    ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  1  ${capacity}  ${lid}  ${s_id9}  ${s_id10}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid9}  ${resp.json()}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  1s

    ${notification}    Random Element     ${bool}
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  5  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${notification}  100
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${resp}=   Disable Future Checkin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  

    ${resp}=  View Waitlist Settings
    Log  ${resp.json()}
    Verify Response  ${resp}    maxPartySize=100
    
    ${DAY1}=  get_date
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable   ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable   ${gender}

    ${resp}=  AddCustomer  ${CUSERNAME2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid12}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}

    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id9}  ${qid9}  ${DAY1}  ${desc}  ${bool[1]}   ${mem_id}   ${mem_id1}   ${cid}

    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}
    
    ${resp}=  Get Waitlist By Id  ${wid1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=0
    ${resp}=  Get Waitlist By Id  ${wid2} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=5
    ${resp}=  Get Waitlist By Id  ${wid3} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  appxWaitingTime=5
    ${resp}=  Get Queue ById  ${qid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=5  queueWaitingTime=5
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[2]}  0  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${EMPTY} 
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  3s
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}   calculationMode=${calc_mode[2]}   trnArndTime=0  futureDateWaitlist=${bool[0]}  showTokenId=${bool[0]}  onlineCheckIns=${bool[1]}    maxPartySize=100

    
    ${resp}=  Get Queue ById  ${qid9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  turnAroundTime=0  queueWaitingTime=0

    ${DAY1}=  get_date
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable   ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable   ${gender}

    ${resp}=  AddCustomer  ${CUSERNAME5}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid5}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME5}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid5}  ${resp.json()[0]['id']}

    ${resp}=  AddFamilyMemberByProvider  ${cid5}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id}  ${resp.json()}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable   ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable   ${lastname}

    ${resp}=  AddFamilyMemberByProvider  ${cid5}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id1}  ${resp.json()}

    ${resp}=  Provider Login  ${PUSERNAME_A}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid5}  ${s_id10}  ${qid9}  ${DAY1}  ${desc}  ${bool[1]}   ${mem_id}  ${mem_id1}   ${cid5}

    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}
    Set Test Variable  ${wid2}  ${wid[1]}
    Set Test Variable  ${wid3}  ${wid[2]}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid3}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid1}  ${resp.json()[0]['id']}

    ${resp}=  AddFamilyMemberByProvider  ${cid1}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid1}  ${s_id9}  ${qid9}  ${DAY1}  ${desc}  ${bool[1]}   ${mem_id}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  AddCustomer  ${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid14}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid2}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid2}  ${s_id9}  ${qid9}  ${DAY1}  ${desc}  ${bool[1]}    ${cid2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
JD-TC-UpdateWaitlistSettings-UH1
    [Documentation]  Set futureDateWaitlist to false and verify
    ${resp}=  ProviderLogin  ${PUSERNAME168}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   5  ${bool[0]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Disable Future Checkin
    Log   ${resp.json()}
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Verify Response  ${resp}  futureDateWaitlist=${bool[0]}
    clear_queue    ${PUSERNAME168}
    clear_location  ${PUSERNAME168}
    clear_service   ${PUSERNAME168}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid10}   ${resp['queue_id']}
    Set Suite Variable  ${s_id10}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${pid}=  get_acc_id   ${PUSERNAME168}
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${DAY1}=  add_date  1
    Set Suite Variable  ${DAY1}  ${DAY1}

    ${description}=   FakerLibrary.word
    ${resp}=  Add To Waitlist Consumers  ${pid}  ${qid10}  ${DAY1}  ${s_id10}  ${description}  ${bool[0]}  ${cidfor}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${FUTURE_CHECKIN_DISABLED}"

JD-TC-UpdateWaitlistSettings-UH2
    [Documentation]  Set OnlineCheckin to false and verify consumer can not take waitlist by online
    ${resp}=  ProviderLogin  ${PUSERNAME40}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location    ${PUSERNAME40}
    clear_service    ${PUSERNAME40}
    clear_queue    ${PUSERNAME40}
    ${pid}=  get_acc_id  ${PUSERNAME40}
    Log   ${pid}
    Set Suite Variable  ${pid}  ${pid}    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   5  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=   Disable Online Checkin
    Log   ${resp.json()}
        
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Verify Response  ${resp}   onlineCheckIns=${bool[0]}  
    
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid15}   ${resp['queue_id']}
    Set Suite Variable  ${s_id15}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin   ${CUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${cidfor}   ${resp.json()}

    ${DAY1} =  get_date    
    ${resp}=  Add To Waitlist Consumers   ${pid}   ${qid15}   ${DAY1}   ${s_id15}   ${description}   ${bool[0]}   ${cidfor}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"  "${ONLINE_CHECKIN_OFF}" 

JD-TC-UpdateWaitlistSettings-UH3
    [Documentation]  Update wailist settings using enabledWaitlist as false and check addtowaitlist is possible or not
    ${resp}=  ProviderLogin  ${PUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_service   ${PUSERNAME17}
    clear_location  ${PUSERNAME17}
    clear_queue  ${PUSERNAME17}
    ${resp}=   Enable Waitlist
    ${resp}=   Disable Waitlist
    Log    ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  enabledWaitlist=${bool[0]}

    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid12}   ${resp['queue_id']}
    Set Suite Variable  ${s_id12}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid03}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id12}  ${qid12}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"    "${WAITLIST_NOT_ENABLED}"
    ${resp}=   Enable Waitlist
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}  enabledWaitlist=${bool[1]}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id12}  ${qid12}  ${DAY1}  ${desc}  ${bool[1]}   ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-UpdateWaitlistSettings-UH4
    [Documentation]  Update wailist settings by login as a consumer
    ${resp}=  ConsumerLogin  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-UpdateWaitlistSettings-UH5
    [Documentation]  Update wailist settings without login
    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateWaitlistSettings-UH6
    [Documentation]  Set maxPartySize to 3 and verify more party size is not possible
    ${resp}=  ProviderLogin  ${PUSERNAME1}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME1}

    ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  30  false  false  true  false  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Create Service  ${SERVICE1}  Description   5  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id9}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  Description   5  ACTIVE  Waitlist  True  email  45  500  True  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id10}  ${resp.json()}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${city}=  FakerLibrary.state
    ${companySuffix}=  FakerLibrary.companySuffix
    ${postcode}=  FakerLibrary.postcode
    ${address}=  get_address
    ${sTime1}=  add_time  0  5
    ${eTime1}=  add_time  0  15
    ${latti1}=  get_latitude
    ${longi1}=  get_longitude
    ${resp}=  Create Location  ${city}  ${longi1}  ${latti1}  www.${companySuffix}.com  ${postcode}  ${address}  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()}
    ${DAY1}=  get_date
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  add_time  0  30
    ${eTime}=  add_time   2  00
    
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  20  100  ${lid}  ${s_id9}  ${s_id10}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid9}  ${resp.json()}


    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  30  false  false  ${bool[1]}  false  3
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Disable Future Checkin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep  1s
    ${resp}=  View Waitlist Settings
    Verify Response  ${resp}   calculationMode=${calc_mode[1]}  trnArndTime=30  futureDateWaitlist=False  showTokenId=False  onlineCheckIns=True    maxPartySize=1

    ${resp}=  AddCustomer  ${CUSERNAME15}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid21}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME15}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    ${DAY1}=  get_date
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname}  ${lastname}  ${dob}   ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}

    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id9}  ${qid9}  ${DAY1}  ${desc}  ${bool[1]}   ${mem_id}  ${mem_id1}  ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   "${resp.json()}"    "${PARTY_SIZE_GREATER}"

*** Comment ***
JD-TC-UpdateWaitlistSettings-7
    [Documentation]  Set SendNotification  to true and verify
    ${resp}=  ProviderLogin  ${PUSERNAME214}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location   ${PUSERNAME214}
    clear_queue     ${PUSERNAME214}
    clear_service       ${PUSERNAME214}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bname}  ${resp.json()['businessName']}


    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}  ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log    ${resp.json()}
    Verify Response  ${resp}  sendNotification=${bool[1]}
    

    clear_location  ${PUSERNAME214}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid2}   ${resp['queue_id']}
    Set Suite Variable  ${s_id2}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}

    ${cid}=  get_id  ${CUSERNAME2}
    Set Suite Variable  ${cid}  ${cid}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id2}  ${qid2}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${waitlist_id3}  ${wid[0]}
 

    clear_Consumermsg  ${CUSERNAME2}
    ${delay_time}=   Random Int  min=5   max=15 
    
    
    ${resp}=  Add Delay  ${qid2}  ${delay_time}  ${None}  ${bool[1]} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Sleep  3s
    ${resp}=  Get Delay  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=${delay_time}
    ${resp}=  Get Waitlist By Id  ${waitlist_id3}
    Log  ${resp.json()}   
    
    ${appx_Waiting_Time}=   evaluate   ${duration}+${delay_time}
    Log   ${appx_Waiting_Time}
    Verify Response  ${resp}   appxWaitingTime=${appx_Waiting_Time}

    ${resp}=  Get Waitlist By Id  ${waitlist_id3} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Queue ById   ${qid2}
    Log  ${resp.json()}
    Should be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${sTime}        ${resp.json()['queueSchedule']['timeSlots'][0]['sTime']}

    ${resp}=   Get Service By Id   ${s_id2}
    Log  ${resp.json()}
    Should be Equal As Strings   ${resp.status_code}   200
    Set Suite Variable  ${Service_name}     ${resp.json()['name']}
    

    ${resp}=   ProviderLogout

    ${pid}=  get_acc_id  ${PUSERNAME214}
    Should Be Equal As Strings    ${resp.status_code}    200
    Sleep  2s
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
   
    
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${date}=  Convert Date  ${DAY1}  result_format=%d-%m-%Y
    ${delay_time}=   Convert To String  ${delay_time}
    
    ${addtwo}=   add_two    ${sTime}     ${appx_Waiting_Time}
    Log   ${addtwo}

    
    ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
    ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
    ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
    ${msg}=  Replace String  ${msg}  [time]  ${addtwo}
    
    Log  ${msg}

    Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${Service_name} on ${date}  accountId=${pid}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername} 

    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  ProviderLogin  ${PUSERNAME214}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${resp}=  Add Delay  ${qid2}  0  ${None}  ${bool[1]} 
    Should Be Equal As Strings  ${resp.status_code}   200
    ${resp}=  Get Delay  ${qid2}
    Should Be Equal As Strings  ${resp.status_code}   200
    Verify Response  ${resp}  delayDuration=0
    
   

    ${resp}=   ProviderLogout

    ${pid}=  get_acc_id  ${PUSERNAME214}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${consumername}  ${resp.json()['userName']}
    

    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    ${delay_time}=   Convert To String  ${delay_time}

    ${addtwo}=   add_two    ${sTime}     ${appx_Waiting_Time}
    Log   ${addtwo}

    #${subtwo}=   sub_two    ${addtwo}     ${delay_time}
    #Log   ${subtwo}
    
    ${msg}=  Replace String    ${Add_delay}  [username]  ${consumername}
    ${msg}=  Replace String  ${msg}  [provider name]  ${bname}
    ${msg}=  Replace String  ${msg}  [service]  ${Service_name}
    ${msg}=  Replace String  ${msg}  [minutes]  ${delay_time}
    ${msg}=  Replace String  ${msg}  [time]  ${addtwo}

    Log  ${msg}

    Verify Response List  ${resp}  0  waitlistId=${waitlist_id3}  service=${Service_name} on ${date}  accountId=${pid}  msg=${msg}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}  ${pid}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['userName']}  ${bname} 
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}  ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['userName']}  ${consumername}

JD-TC-UpdateWaitlistSettings-UH3
    [Documentation]  Set SendNotification  to false and verify
    clear_Consumermsg  ${CUSERNAME8}
    ${resp}=  ProviderLogin  ${PUSERNAME11}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_location    ${PUSERNAME11}
    clear_service    ${PUSERNAME11}
    clear_queue    ${PUSERNAME11}
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   10   ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[0]}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}
    Verify Response  ${resp}   sendNotification=${bool[0]}
    ${resp}=  Create Sample Queue  
    Set Suite Variable  ${qid6}   ${resp['queue_id']}
    Set Suite Variable  ${s_id6}   ${resp['service_id']}
    Set Suite Variable  ${lid}   ${resp['location_id']}
    ${resp}=   Get Queue ById   ${qid6}
    Log   ${resp}
    ${resp}=    Get Queues Counts
    Log   ${resp}
    ${resp}=    Get Service By Id   ${s_id6}
    Log    ${resp}
    ${resp}=   Get Service
    Log    ${resp}
    
    # ${cid}=  get_id  ${CUSERNAME8}
    # Set Suite Variable  ${cid}  ${cid}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
    
    ${DAY1}=   get_date

    ${desc}=   FakerLibrary.word
    Set Suite Variable  ${desc}
    ${resp}=  Add To Waitlist   ${cid}  ${s_id6}  ${qid6}  ${DAY1}  ${desc}  ${bool[1]}   0


    #${resp}=  Add To Waitlist  ${cid}  ${s_id6}  ${qid6}  ${DAY1}  ${description}  ${bool[1]}  ${cid}
    Log    ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Delay  ${qid6}  5   ${description}   ${bool[0]}
    Log   ${resp}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ConsumerLogin  ${CUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  [] 
    ${resp}=  Consumer Logout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderLogin     ${PUSERNAME11}     ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Delay  ${qid6}  0  ${description}  ${bool[1]}     
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Delay  ${qid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  delayDuration=0
