*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FamilyMember
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***
      
JD-TC-RemoveFamilyMember-1
      [Documentation]    Delete a familymember by consumer login

      clear_FamilyMember  ${CUSERNAME20} 
      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id}
      ${resp}=  DeleteFamilyMember  ${mem_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Should Not Contain  ${resp.json()}  id=${mem_id}

JD-TC-RemoveFamilyMember-2

      [Documentation]  Delete a family member after waitlisted in a queue in consumer side then check that family member in provider side
      ${resp}=   Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${pid0}=  get_acc_id  ${PUSERNAME83}
      Should Be Equal As Strings    ${resp.status_code}   200

      clear_location  ${PUSERNAME83}
      clear_queue  ${PUSERNAME83}
      Clear_service  ${PUSERNAME83}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id6}  ${resp.json()}

      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${cnote}=   FakerLibrary.word
      ${resp}=  Add To Waitlist Consumers  ${pid0}  ${qid}  ${DAY}  ${s_id}  ${cnote}  ${bool[0]}  ${mem_id6} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}

      ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1  appxWaitingTime=0  waitlistedBy=CONSUMER
      Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
      # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeConsumer']}  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${mem_id6}
      Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}
      Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}

      ${resp}=   Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()[1]['id']}

      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${cfid}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

      ${resp}=  Consumer Login  ${CUSERNAME21}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  DeleteFamilyMember  ${mem_id6}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Should Not Contain  ${resp.json()}  id=${mem_id6}

      ${resp}=   Encrypted Provider Login  ${PUSERNAME83}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${cfid}
      ${resp}=  DeleteFamilymemberByprovidercustomer  ${cfid}  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Log  ${resp.json()}
      Should Not Contain   ${resp.json()}  "id":"${cfid}"



JD-TC-RemoveFamilyMember-UH1
      [Documentation]  consumer remove provider side Waitlisted family member    
      ${resp}=   Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${pid0}=  get_acc_id  ${PUSERNAME25}
      clear_customer   ${PUSERNAME25}

      Set Suite Variable   ${pid0} 
      ${resp}=  Get Queues
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  Create Sample Queue
      Set Suite Variable  ${qid1}   ${resp['queue_id']}
      Set Suite Variable  ${lid}   ${resp['location_id']}
      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}

      ${resp}=  AddCustomer  ${CUSERNAME22}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()}

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${note}=  FakerLibrary.word
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${fid}  ${resp.json()}
      ${resp}=  Get Queue ById  ${qid1}
      Log  ${resp.json()}
      ${s_id1}=  Set Variable  ${resp.json()['services'][0]['id']}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Add To Waitlist  ${id}  ${s_id1}  ${qid1}  ${DAY}  ${note}  ${bool[1]}  ${fid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid}  ${wid[0]}

      ${resp}=  Get Waitlist By Id  ${wid} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}  partySize=1   waitlistedBy=${waitlistedby[1]}  personsAhead=0
      Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${s_id1}
      Should Be Equal As Strings  ${resp.json()['consumer']['id']}                  ${id}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${fid}

      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  Consumer Login  ${CUSERNAME22}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilyMember  ${fid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"   "${FAMILY_MEMEBR_NOT_FOUND}"
      # Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION_TO_DELETE_MEMBER}"
     
JD-TC-RemoveFamilyMember-UH2
      [Documentation]  Consumer Remove provider side Waitlisted family member  after cancel a waitlist  
      ${resp}=   Encrypted Provider Login  ${PUSERNAME25}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME25}+76008
      Set Test Variable  ${email}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${dob}=  FakerLibrary.Date
      ${gender}=  Random Element    ${Genderlist}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email}  ${gender}  ${dob}  ${CUSERNAME23}  ${EMPTY}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${id}  ${resp.json()}
      Log  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${note}=  FakerLibrary.word
      ${resp}=  AddFamilyMemberByProvider  ${id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${fid}  ${resp.json()}
      ${resp}=  Get Queue ById  ${qid1}
      Log  ${resp.json()}
      ${s_id1}=  Set Variable  ${resp.json()['services'][0]['id']}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${resp}=  Add To Waitlist  ${id}  ${s_id1}  ${qid1}  ${DAY}  ${note}  ${bool[1]}  ${fid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Suite Variable  ${wid}  ${wid[0]}

      ${msg}=  Fakerlibrary.word
      Append To File  ${EXECDIR}/TDD/TDD_Logs/msgslog.txt  ${SUITE NAME} - ${TEST NAME} - ${msg}${\n}
      ${resp}=  Waitlist Action Cancel  ${wid}  ${waitlist_cancl_reasn[4]}  ${msg}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ProviderLogout
      Should Be Equal As Strings  ${resp.status_code}  200

      sleep   2s
      ${resp}=  Consumer Login  ${CUSERNAME23}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200

      ${resp}=  DeleteFamilyMember  ${fid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"   "${FAMILY_MEMEBR_NOT_FOUND}"
      # Should Be Equal As Strings  "${resp.json()}"    "${NO_PERMISSION_TO_DELETE_MEMBER}"

JD-TC-RemoveFamilyMember-UH3
      [Documentation]  Delete a family member without login
      ${resp}=  DeleteFamilyMember  ${mem_id}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-RemoveFamilyMember-UH4
      [Documentation]    Deleting a family member who is already deleted

      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilyMember  ${mem_id}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"     "${FAMILY_MEMEBR_NOT_FOUND}"
      
JD-TC-RemoveFamilyMember-UH5
      [Documentation]    Delete a family member who is not member of the consumer

      ${resp}=  Consumer Login  ${CUSERNAME24}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember   ${firstname}  ${lastname}   ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  Consumer Logout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilyMember  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_DELETE_MEMBER}"





***comment***
JD-TC-RemoveFamilyMember-UH6
      [Documentation]  Delete a family member after waitlisted in a queue and check that family member in consumer side
      ${resp}=   Encrypted Provider Login  ${PUSERNAME4}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME25}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()[0]['id']}
      clear_location  ${PUSERNAME4}
      clear_queue  ${PUSERNAME4}
      ${resp}=   ProviderKeywords.Get Queues
      Should Be Equal As Strings  ${resp.status_code}  200
      Log   ${resp.json()}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=  Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider    ${cid}   ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  
      Log  ${resp.json()}
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${desc}=   FakerLibrary.word
      ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${desc}  ${bool[1]}  ${mem_id1}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid}  ${wid[0]}
      ${resp}=  Get Waitlist By Id  ${wid} 
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[1]}

      ${resp}=  DeleteFamilymemberByprovidercustomer  ${mem_id1}  ${cid}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}    []
      
      ${resp}=  Consumer Login  ${CUSERNAME25}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}    []


***comment***   
JD-TC-RemoveFamilyMember-3
      [Documentation]    Delete a familymember by provider switched to a consumer

      ${resp}=  Consumer Login  ${PUSERNAME22}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${CUSERPH1}=  Evaluate  ${CUSERNAME}+100100401
      Set Suite Variable   ${CUSERPH1}
      Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${CUSERPH1}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id2}
      ${resp}=  DeleteFamilyMember  ${mem_id2}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Should Not Contain  ${resp.json()}  id=${mem_id2}  
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${CUSERPH1}  ${dob}  ${gender}
      Log  ${resp.json()}  
      Should Be Equal As Strings  ${resp.status_code}  200    
