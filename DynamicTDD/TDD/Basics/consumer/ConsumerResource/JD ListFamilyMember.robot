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
      
JD-TC-ListFamilyMember-1
      [Documentation]    List family member details by consumer login
      ${resp}=  Consumer Login  ${CUSERNAME37}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id}=  get_id  ${CUSERNAME37}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id}  parent=${id}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-ListFamilyMember-2
      [Documentation]    Add a family member by consumer login and add to waitlist then provider list family member 
      ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${pid0}=  get_acc_id  ${PUSERNAME78}
      Should Be Equal As Strings    ${resp.status_code}   200

      clear_location  ${PUSERNAME78}
      clear_queue  ${PUSERNAME78}
      Clear_service  ${PUSERNAME78}
      ${resp} =  Create Sample Queue
      Set Test Variable  ${s_id}  ${resp['service_id']}
      Set Test Variable  ${qid}   ${resp['queue_id']}
      Set Suite Variable   ${lid}   ${resp['location_id']}

      ${resp}=   Get Location ById  ${lid}
      Log  ${resp.content}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${tz}  ${resp.json()['timezone']}
      
      ${resp}=   ProviderLogout
      Should Be Equal As Strings    ${resp.status_code}   200

      ${resp}=  Consumer Login  ${CUSERNAME9}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id4}  ${resp.json()}

      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id5}  ${resp.json()}

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

      ${resp}=   Encrypted Provider Login  ${PUSERNAME78}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME9}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${cid}  ${resp.json()[1]['id']}
      ${resp}=  ListFamilyMemberByProvider  ${cid}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Verify Response List  ${resp}  0  id=${cfid}
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}


JD-TC-ListFamilyMember-UH1
      [Documentation]  List family member without login
      ${resp}=  ListFamilyMember
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"     "${SESSION_EXPIRED}"


*** Comments ***
JD-TC-ListFamilyMember-2
      [Documentation]  List family member details by provider switched to a consumer
      ${resp}=  Consumer Login  ${PUSERNAME18}  ${PASSWORD}
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${id1}=  get_id  ${PUSERNAME18}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${mem_id1}  parent=${id1}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}

JD-TC-ListFamilyMember-2
      [Documentation]  List family member details by provider switched to a consumer
      ${resp}=  Consumer Login  ${PUSERNAME17}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  401
      Should Be Equal As Strings  "${resp.json()}"   "${NOT_REGISTERED_CUSTOMER}"

      ${pid}=  get_id  ${PUSERNAME17}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMember  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Suite Variable  ${fid}  ${resp.json()}
      ${resp}=  ListFamilyMember
      Verify Response List  ${resp}  0  user=${fid}  parent=${pid}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender} 
      ${resp}=  Consumer Logout
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=   Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD} 
      Should Be Equal As Strings    ${resp.status_code}   200
      ${cId}=  get_id  ${PUSERNAME17}
      ${resp}=  ListFamilyMemberByProvider  ${cId}
      Should Be Equal As Strings    ${resp.status_code}   200
      Verify Response List  ${resp}  0  user=${fid}  parent=${pid}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender} 
      clear_Family  ${id}

