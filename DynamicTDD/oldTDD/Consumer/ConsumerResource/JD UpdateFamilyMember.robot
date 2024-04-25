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

JD-TC-UpdateFamilyMember-1
      [Documentation]    Update a familymemeber by consumer login
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME31}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-UpdateFamilyMember-2
      [Documentation]    Update a family member when that family member is also a consumer
      ${CUSERPH1}=  Evaluate  ${CUSERNAME}+100100501
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH1}${\n}
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME31}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${address}=  FakerLibrary.address
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${CUSERPH1}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${resp}=  Consumer Logout       
      Should Be Equal As Strings    ${resp.status_code}    200
      ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH1}+1000
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH1}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${CUSERPH1}  1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${CUSERPH1}  ${PASSWORD}  1
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

      

JD-TC-UpdateFamilyMember-3
      [Documentation]    Update a family member when that family member also a consumer
      ${CUSERPH2}=  Evaluate  ${CUSERNAME}+100100502
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${CUSERPH2}${\n}
      ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH2}+1000
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${address}=  FakerLibrary.address
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH2}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Activation  ${CUSERPH2}  1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Logout
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME31}
      Set Suite Variable  ${id}  ${id}
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${CUSERPH2}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-UpdateFamilyMember-4
      [Documentation]    Update a familymemeber when that familymember also a provider
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME31}
      Set Suite Variable  ${id}  ${id}
      ${PUSERPH1}=  Evaluate  ${PUSERNAME}+100100501
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${address}=  FakerLibrary.address
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${PUSERPH1}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${resp}=  Consumer Logout       
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
      Log  ${d1}
      Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH1}    1
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERPH1}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERPH1}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERPH1}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}     

JD-TC-UpdateFamilyMember-5
      [Documentation]    Update a familymemeber when that familymember also a provider
      ${resp}=  Get BusinessDomainsConf
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
      Log  ${d1}
      Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
      ${PUSERPH2}=  Evaluate  ${PUSERNAME}+100100502
      Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${address}=  FakerLibrary.address
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH2}    1
      Log  ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Activation  ${PUSERPH2}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Account Set Credential  ${PUSERPH2}  ${PASSWORD}  0
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Encrypted Provider Login  ${PUSERPH2}  ${PASSWORD}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME31}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  ${PUSERPH2}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      Log   ${resp.json()}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-UpdateFamilyMember-6
      [Documentation]  Update a family member after take waitlist
      ${resp}=   Encrypted Provider Login  ${PUSERNAME79}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${pid0}=  get_acc_id  ${PUSERNAME79}
      Should Be Equal As Strings    ${resp.status_code}   200

      clear_location  ${PUSERNAME79}
      clear_queue  ${PUSERNAME79}
      Clear_service  ${PUSERNAME79}
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

      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  Consumer Login  ${CUSERNAME14}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddFamilyMember   ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id5}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Log   ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id5}

      ${DAY}=  db.get_date_by_timezone  ${tz}
      ${cnote}=   FakerLibrary.word
      ${resp}=  Add To Waitlist Consumers  ${pid0}  ${qid}  ${DAY}  ${s_id}  ${cnote}  ${bool[0]}  ${mem_id5} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200 
      
      ${wid}=  Get Dictionary Values  ${resp.json()}
      Set Test Variable  ${wid1}  ${wid[0]}

      ${resp}=  Get consumer Waitlist By Id   ${wid1}  ${pid0}   
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response  ${resp}  date=${DAY}  waitlistStatus=${wl_status[0]}  partySize=1   waitlistedBy=CONSUMER
      Should Be Equal As Strings  ${resp.json()['service']['id']}  ${s_id}
      # Should Be Equal As Strings  ${resp.json()['consumer']['jaldeeConsumer']}  ${cid}
      Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['jaldeeFamilyMemberId']}  ${mem_id5}
      Should Be Equal As Strings  ${resp.json()['queue']['id']}  ${qid}
      Set Test Variable  ${cfid}   ${resp.json()['waitlistingFor'][0]['id']}

      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name

      ${dob1}=  FakerLibrary.Date
      ${gender1}    Random Element    ${Genderlist}
      Log   ${resp.json()}
      ${resp}=  UpdateFamilyMember  ${mem_id5}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  user=${mem_id5}  
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender1}


JD-TC-UpdateFamilyMember-UH1
      [Documentation]  Update a family member without login
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"    "${SESSION_EXPIRED}"

JD-TC-UpdateFamilyMember-UH2
      [Documentation]  Update a family member using provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422 
      Should Be Equal As Strings  "${resp.json()}"    "${NO_ACCESS_TO_URL}"   
      # Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION_TO_UPDATE_MEMBER}"
     

*** Comments ***
JD-TC-UpdateFamilyMember-CLEAR
      ${resp}=  Consumer Login  ${CUSERNAME31}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  DeleteFamilyMember  ${mem_id}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Should Not Contain  ${resp.json()}  id=${mem_id}
      ${resp}=  Consumer Logout

JD-TC-UpdateFamilyMember-2
      [Documentation]    Update a familymemeber by provider switched to a consumer
      ${resp}=  Consumer Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${PUSERNAME28}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id1}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id1}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-UpdateFamilyMember-3
      [Documentation]  Update a details of their own family member using provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME28}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${address}=  FakerLibrary.address
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  UpdateFamilyMember  ${mem_id1}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id1}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}
