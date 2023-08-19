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
${SERVICE1}               SERVICE1

*** Test Cases ***

JD-TC-WaitlistStateChange-1
      [Documentation]   Get waitlist state change after CHECK_IN

      clear_location    ${PUSERNAME171}
      clear_service     ${PUSERNAME171}
      clear_queue       ${PUSERNAME171}
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
*** comment ***
      ${CUR_DAY}=  db.get_date_by_timezone  ${tz}
      ${list}=  Create List   1  2  3  4  5  6  7
      ${loc_id1}=  Create Sample Location
      ${ser_id1}=  Create Sample Service  ${SERVICE1}
      ${sTime3}=  subtract_timezone_time  ${tz}  4  55
      ${eTime3}=  subtract_timezone_time  ${tz}   3  60
      ${queue1}=    FakerLibrary.name
      ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${sTime3}  ${eTime3}  1  5  ${loc_id1}  ${ser_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}  ${resp.json()}
      ${queue1}=    FakerLibrary.name
      Set Suite Variable    ${queue1}    
      ${strt_time}=   subtract_timezone_time  ${tz}  1  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    add_timezone_time  ${tz}   5  25 
      Set Suite Variable    ${end_time}    
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Update Queue  ${que_id1}  ${queue1}  ${recurringtype[1]}  ${list}  ${CUR_DAY}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}  ${loc_id1}  ${ser_id1}
      Log     ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200     
      ${cid}=  get_id      ${CUSERNAME19}  
      ${pid}=  get_acc_id  ${PUSERNAME171} 
      Set Suite Variable   ${pid}

      ${cons_note}=   FakerLibrary.word
      ${resp}=  Add To Waitlist Consumers  ${pid}  ${que_id1}  ${CUR_DAY}  ${ser_id1}  ${cons_note}  ${bool[0]}  ${self}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      # sleep   6s
      ${resp}=  Consumer Logout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log    ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}

JD-TC-WaitlistStateChange-2
      [Documentation]   Waitlist State change after REPORT

      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  1  waitlistStatus=${wl_status[1]}

JD-TC-WaitlistStateChange-3
      [Documentation]   Waitlist State change after CANCEL

      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[4]}   ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  1s
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  1  waitlistStatus=${wl_status[1]}
      Verify Response List  ${resp}  2  waitlistStatus=${wl_status[4]}

JD-TC-WaitlistStateChange-4
      [Documentation]   Waitlist state change after  CHECK_IN

      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[3]}   ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  1s
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  1  waitlistStatus=${wl_status[1]}
      Verify Response List  ${resp}  2  waitlistStatus=${wl_status[4]}
      Verify Response List  ${resp}  3  waitlistStatus=${wl_status[0]}

JD-TC-WaitlistStateChange-5
      [Documentation]   Waitlist state change after  STARTED

      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  1s
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200     
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  1  waitlistStatus=${wl_status[1]}
      Verify Response List  ${resp}  2  waitlistStatus=${wl_status[4]}
      Verify Response List  ${resp}  3  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  4  waitlistStatus=${wl_status[2]}

JD-TC-WaitlistStateChange-6
      [Documentation]   Waitlist State Change after DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME171}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  1s
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  1  waitlistStatus=${wl_status[1]}
      Verify Response List  ${resp}  2  waitlistStatus=${wl_status[4]}
      Verify Response List  ${resp}  3  waitlistStatus=${wl_status[0]}
      Verify Response List  ${resp}  4  waitlistStatus=${wl_status[2]}
      Verify Response List  ${resp}  5  waitlistStatus=${wl_status[5]}

JD-TC-WaitlistStateChange-UH1
      [Documentation]  waitlist State Change without login

      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 
JD-TC-WaitlistStateChange-UH2
      [Documentation]  waitlist State Change using  consumer login

      ${resp}=  Consumer Login   ${CUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
      
JD-TC-WaitlistStateChange-UH3
      [Documentation]  waitlist State Change of another provider's waitlist

      ${resp}=  Encrypted Provider Login   ${PUSERNAME3}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist State Changes  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION}"
