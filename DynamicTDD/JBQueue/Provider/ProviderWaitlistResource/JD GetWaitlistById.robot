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
JD-TC-GetWaitlistById-1
      [Documentation]  Get Waitlist details for the current day

      clear_location    ${PUSERNAME111}
      clear_service     ${PUSERNAME111}
      clear_queue       ${PUSERNAME111} 
      clear_customer    ${PUSERNAME111}
      ${resp}=  ProviderLogin  ${PUSERNAME111}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=   Get Business Profile
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Update Waitlist Settings  ${calc_mode[0]}  ${EMPTY}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${EMPTY} 
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  AddCustomer  ${CUSERNAME8}  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()}

      ${CUR_DAY}=  get_date
      Set Suite Variable  ${CUR_DAY}
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id2}    ${resp}  
      ${ser_name1}=   FakerLibrary.word
      Set Suite Variable    ${ser_name1} 
      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${strt_time}=   add_time  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_time  3  00 
      Set Suite Variable    ${end_time}  
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity} 
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}    ${loc_id2}  ${ser_id1} 
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}  
      # sleep  2s  
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${CUR_DAY}  ${desc}  ${bool[1]}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}      personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-GetWaitlistById-2
      [Documentation]   Get waitlist details of a future date entry

      ${resp}=  ProviderLogin  ${PUSERNAME111}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY1}=  add_date  2
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid1}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid1} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
JD-TC-GetWaitlistById-3
      [Documentation]   Get Waitlist after disabling waitlist

      ${resp}=  ProviderLogin  ${PUSERNAME111}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}
      ${resp}=  Enable Waitlist
      Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetWaitlistById-4
      [Documentation]   Get Waitlist after disabling location

      ${resp}=  ProviderLogin  ${PUSERNAME111}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Location  ${loc_id2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200  
      sleep  2s   
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${CUR_DAY}  waitlistStatus=${wl_status[4]}  partySize=1  appxWaitingTime=0  waitlistedBy=${waitlistedby}
      Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${ser_name1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${ser_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cid}

JD-TC-GetWaitlistById-UH1
      [Documentation]  Get  Waitlist details of another provider

      ${resp}=  ProviderLogin  ${PUSERNAME126}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${wid}
      # Should Be Equal As Strings  ${resp.status_code}  404
      # Should Be Equal As Strings  "${resp.json()}"    "${INVALID_WAITLIST}"
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
      

JD-TC-GetWaitlistById-UH2
      [Documentation]  Get  Waitlist By Id without login

      ${resp}=  Get Waitlist By Id  ${wid}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
      

JD-TC-GetWaitlistById-UH3
      [Documentation]  Get  Waitlist By Id by consumer login

      ${resp}=  ConsumerLogin  ${CUSERNAME5}  ${PASSWORD}
      ${resp}=  Get Waitlist By Id  ${wid}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

 
*** Comment ***
YNW-TC-GetWaitlistById-4
      Comment   Get Waitlist after disabling queue
      ${resp}=  ProviderLogin  ${PUSERNAME}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Disable Queue  ${qid1}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  1s
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY1}  waitlistStatus=cancelled  partySize=1  appxWaitingTime=0  waitlistedBy=PROVIDER
      Should Be Equal As Strings  ${resp.json()['service']['name']}  ${SERVICE1}
      Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['id']}  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}  ${cid}
      ${resp}=  Enable Queue  ${qid1}
      Should Be Equal As Strings  ${resp.status_code}  200