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
Variables          /ebs/TDD/messagesapi.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-WaitlistAction-1
      [Documentation]   Waitlist Action CHECK_IN after STARTED

      clear_customer    ${PUSERNAME216}

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
    
      ${highest_package}=  get_highest_license_pkg
      Log  ${highest_package}
      Set Suite variable  ${lic2}  ${highest_package[0]}

      ${resp}=   Change License Package  ${highest_package[0]}
      Log  ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  AddCustomer  ${CUSERNAME1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cons_id}  ${resp.json()}
    
      ${resp}=   Create Sample Location
      Set Suite Variable    ${loc_id1}    ${resp}  
      ${resp}=   Get Location ById  ${loc_id1}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      ${ser_name1}=   generate_service_name
      Set Suite Variable    ${ser_name1} 
      ${resp}=   Create Sample Service  ${ser_name1}
      Set Suite Variable    ${ser_id1}    ${resp}  
      ${ser_name2}=   generate_service_name
      Set Suite Variable    ${ser_name2} 
      ${resp}=   Create Sample Service  ${ser_name2}
      Set Suite Variable    ${ser_id2}    ${resp}
      ${ser_name3}=   generate_service_name
      Set Suite Variable    ${ser_name3} 
      ${resp}=   Create Sample Service  ${ser_name3}
      Set Suite Variable    ${ser_id3}    ${resp}  

      ${q_name}=    FakerLibrary.name
      Set Suite Variable    ${q_name}
      ${list}=  Create List   1  2  3  4  5  6  7
      Set Suite Variable    ${list}
      ${DAY1}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${DAY1}
      ${strt_time}=   db.subtract_timezone_time   ${tz}  3  00
      Set Suite Variable    ${strt_time}
      ${end_time}=    db.add_timezone_time  ${tz}  0  30 
      Set Suite Variable    ${end_time}   
      ${parallel}=   Random Int  min=1   max=2
      Set Suite Variable   ${parallel}
      ${capacity}=  Random Int   min=10   max=20
      Set Suite Variable   ${capacity}
      ${resp}=  Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}   ${loc_id1}  ${ser_id1}  ${ser_id2}    ${ser_id3}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${que_id1}   ${resp.json()}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[1]}
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}    ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[2]}
      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}      waitlistStatus=${wl_status[0]}

JD-TC-WaitlistAction-2
      [Documentation]   Waitlist Action CHECK_IN after  REPORT

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

#JD-TC-WaitlistAction-3
 #     [Documentation]   Waitlist CHECK_IN after  REPORT

  #    ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
   #   Should Be Equal As Strings  ${resp.status_code}  200
    #    ${desc}=   FakerLibrary.word
   
   #     ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id}
    #  Should Be Equal As Strings  ${resp.status_code}  200
      
    #  ${wid}=  Get Dictionary Values  ${resp.json()}
     # Set Suite Variable  ${waitlist_id1}  ${wid[0]}
    
   #   ${resp}=  Get Waitlist By Id  ${waitlist_id1}
   #   Should Be Equal As Strings  ${resp.status_code}  200
    
    #  ${resp}=  Waitlist Action  ${waitlist_actions[0]}   ${waitlist_id1}
     # Log   ${resp.json()}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # ${resp}=  Get Waitlist By Id  ${waitlist_id1}
     # Should Be Equal As Strings  ${resp.status_code}  200
     # Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-WaitlistAction-4
      [Documentation]   Waitlist Action DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}   ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[5]}

JD-TC-WaitlistAction-5
      [Documentation]   Waitlist Action CHECK_IN after STARTED

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id1}  ${wid[0]}
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}   ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[2]}
      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}

JD-TC-WaitlistAction-6
      [Documentation]   Waitlist Action STARTED

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
   
      sleep  2s
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[2]}

JD-TC-WaitlistAction-7
      [Documentation]   Waitlist Action CANCEL

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[3]}   ${waitlist_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[2]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}


JD-TC-WaitlistAction-8
      [Documentation]   Waitlist Action cancel for a future waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${DAY2}=  db.add_timezone_date  ${tz}  2
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id1}  ${que_id1}  ${DAY2}  ${desc}  ${bool[1]}  ${cons_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id2}  ${wid[0]}
      ${resp}=  Waitlist Action Cancel  ${waitlist_id2}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[4]}

JD-TC-WaitlistAction-9
      [Documentation]   Waitlist Action CHECK_IN for a future waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[3]}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  waitlistStatus=${wl_status[0]}


JD-TC-WaitlistAction-UH1
      [Documentation]   Waitlist Action Arrived after  Done

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}   ${waitlist_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${STATUS_NOT_CHANGE}"


JD-TC-WaitlistAction-UH2
      [Documentation]   STARTED after CANCEL

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[1]}  ${waitlist_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[4]}   ${wl_status[2]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"
     
JD-TC-WaitlistAction-UH3
      [Documentation]   STARTED after DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[1]}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[5]}   ${wl_status[2]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"





JD-TC-WaitlistAction-UH4
      [Documentation]   Waitlist DONE  after CANCEL

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[4]}  ${waitlist_id1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[4]}   ${wl_status[5]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH5
      [Documentation]   Cancel already cancelled id

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id1}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}"



JD-TC-WaitlistAction-UH6
      [Documentation]   Waitlist DONE  for a cancell id

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
   
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[4]}   ${wl_status[5]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH7
      [Documentation]   Waitlist Report After Cancell

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id1}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[4]}   ${wl_status[1]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH8
      [Documentation]   cancel a waitlist after DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      ${resp}=  Waitlist Action Cancel  ${waitlist_id}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}" 

JD-TC-WaitlistAction-UH9
      [Documentation]   Waitlist REPORT for already Reported id

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cons_id}  ${ser_id2}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${cons_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${waitlist_id3}  ${wid[0]}

      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id3}    
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${ALREADY_ARRIVED}"

JD-TC-WaitlistAction-UH10
      [Documentation]  cancel a waitlist after STARTED

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${desc}=   FakerLibrary.word
      Set Suite Variable    ${desc}
      ${resp}=  Waitlist Action Cancel  ${waitlist_id3}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_CANCEL_STATUS}" 

JD-TC-WaitlistAction-UH11
      [Documentation]   Waitlist STARTED for already started id

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      # ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id3}
      # Log  ${resp.json()}
      # Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id3}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STARTED}"

JD-TC-WaitlistAction-UH12
      [Documentation]   Waitlist REPORT after STARTED

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id3}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[2]}   ${wl_status[1]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH13
      [Documentation]   Waitlist REPORT after CANCEL

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action   ${waitlist_actions[3]}  ${waitlist_id3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action Cancel  ${waitlist_id3}  ${waitlist_cancl_reasn[3]}  ${desc}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  3s
      ${resp}=  Waitlist Action   ${waitlist_actions[0]}  ${waitlist_id3}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[4]}   ${wl_status[1]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH14
      [Documentation]   Waitlist REPORT after DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[5]}   ${wl_status[1]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH15
      [Documentation]   Waitlist DONE for already DONE id

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_STATUS_NOT_CHANGEABLE}     ${wl_status[5]}   ${wl_status[5]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH16
      [Documentation]   Waitlist Started after DONE

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Get Waitlist By Id  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  200
     
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_STATUS_CANNOT_CHANGE}"

JD-TC-WaitlistAction-UH17
      [Documentation]   Waitlist Action REPORT for a future waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[0]}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}    ${wl_status[0]}   ${wl_status[1]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH18
      [Documentation]   Waitlist Action STARTED for a future waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[1]}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}    ${wl_status[0]}   ${wl_status[2]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}"

JD-TC-WaitlistAction-UH19
      [Documentation]   Waitlist Action DONE for a future waitlist

      ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[4]}  ${waitlist_id2}
      Should Be Equal As Strings  ${resp.status_code}  422
      ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}=   Format String    ${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}    ${wl_status[0]}   ${wl_status[5]}
      Should Be Equal As Strings  "${resp.json()}"  "${WAITLIST_FUTURE_STATUS_NOT_CHANGEABLE}"


JD-TC-WaitlistAction-UH20
      [Documentation]  waitlist Action without login

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"
 
JD-TC-WaitlistAction-UH21
      [Documentation]  waitlist Action using  consumer login

      ${resp}=  Encrypted Provider Login  ${HLPUSERNAME25}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${account_id}=  get_acc_id  ${HLPUSERNAME25}

      ${PH_Number}=  FakerLibrary.Numerify  %#####
      ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
      Log  ${PH_Number}
      Set Suite Variable  ${PCPHONENO}  555${PH_Number}

      ${fname}=  generate_firstname
      ${lname}=  FakerLibrary.last_name
      Set Test Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

      ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
      Log   ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      
      ${resp}=  Send Otp For Login    ${PCPHONENO}    ${account_id}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${jsessionynw_value}=   Get Cookie from Header  ${resp}
      ${resp}=  Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}     JSESSIONYNW=${jsessionynw_value}
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200
      Set Suite Variable  ${token}  ${resp.json()['token']}
      
      ${resp}=  Provider Logout
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200

      ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
      Log   ${resp.content}
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-WaitlistAction-UH22
      [Documentation]  waitlist Action for another provider's waitlist

      ${resp}=  Encrypted Provider Login   ${PUSERNAME17}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Waitlist Action  ${waitlist_actions[3]}  ${waitlist_id1}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"      "${WAITLIST_TOKEN_NOT_EXIST}"
    

JD-TC-WaitlistAction-UH23
      [Documentation]   add to waitlist when capacity is full and checkins are changed to arrived status

      ${resp}=   Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD} 
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200
      
      clear_queue  ${PUSERNAME216}
      clear_customer    ${PUSERNAME216}
      
      ${resp}=    Get Locations
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${lid}   ${resp.json()[0]['id']}
      Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}

      ${resp}=   Get Service
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable   ${p1_s1}   ${resp.json()[0]['id']}
      
      
      ${list}=  Create List  1  2  3  4  5  6  7
      Set Suite Variable  ${list}
      ${today}=  db.get_date_by_timezone  ${tz}
      Set Suite Variable  ${today}
      ${stime1}=  db.add_timezone_time  ${tz}  0  45
      ${etime1}=  db.add_timezone_time  ${tz}  1  0
      ${p1queue1}=    FakerLibrary.word
      ${capacity}=  Random Int  min=3   max=3
      ${parallel}=  Random Int  min=1   max=1
      ${resp}=  Create Queue  ${p1queue1}  ${recurringtype[1]}  ${list}  ${today}  ${EMPTY}  10  ${sTime1}  ${eTime1}  ${parallel}  ${capacity}  ${lid}  ${p1_s1}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${p1_q1}  ${resp.json()}
      
      ${resp}=  Get Queue ById  ${p1_q1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()['parallelServing']}   ${parallel}
      Should Be Equal As Strings  ${resp.json()['capacity']}   ${capacity}

      # ${count}=  Evaluate  ${parallel} * 3
      FOR  ${i}  IN RANGE   1   ${capacity+1}
            
            ${resp}=  AddCustomer  ${CUSERNAME${i}}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            Set Test Variable  ${cid}  ${resp.json()}

            ${desc}=   FakerLibrary.word
            ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
            Log   ${resp.json()}
            Should Be Equal As Strings  ${resp.status_code}  200
            ${wid}=  Get Dictionary Values  ${resp.json()}
            Set Test Variable  ${wid${i}}  ${wid[0]}

            ${resp}=  Get Waitlist By Id  ${wid${i}}
            Should Be Equal As Strings  ${resp.status_code}  200
            Verify Response  ${resp}      waitlistStatus=${wl_status[1]}
      END

      # FOR  ${i}  IN RANGE   1   ${capacity+1}
            
      #       ${resp}=  Waitlist Action  ${waitlist_actions[0]}    ${wid${i}}
      #       Log   ${resp.json()}
      #       Should Be Equal As Strings  ${resp.status_code}  200

      #       ${resp}=  Get Waitlist By Id  ${wid${i}}
      #       Should Be Equal As Strings  ${resp.status_code}  200
      #       Verify Response  ${resp}      waitlistStatus=${wl_status[1]}

      # END

      ${resp}=  AddCustomer  ${CUSERNAME6}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${cid}  ${resp.json()}

      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${p1_s1}  ${p1_q1}  ${today}  ${desc}  ${bool[1]}  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"    "${WATLIST_MAX_LIMIT_REACHED}"

      
      