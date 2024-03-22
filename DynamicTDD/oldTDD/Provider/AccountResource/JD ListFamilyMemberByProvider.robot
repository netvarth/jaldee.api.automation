*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        FamilyMember
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***
      
JD-TC-ListFamilyMemberByProvider-1
      [Documentation]    List a family member details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      # clear_FamilyMember  ${pid}
      ${id}=  get_id  ${CUSERNAME9}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      ${dob}=  FakerLibrary.Date
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME9}  ${EMPTY}
      Set Suite Variable  ${pcid}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      # clear_FamilyMember  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id}  ${resp.json()}
      sleep  02s
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Log  ${resp.json()}
      Verify Response List  ${resp}  0  id=${mem_id}  
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}

JD-TC-ListFamilyMemberByProvider-2
      [Documentation]    List more family members details by provider login
      ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      sleep  02s
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Verify Response List  ${resp}  1  id=${mem_id1}  
      Should Be Equal As Strings  ${resp.json()[1]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[1]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[1]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[1]['gender']}  ${gender}


JD-TC-ListFamilyMemberByProvider-3
      [Documentation]    Add a family member by provider own his family memeber then list family memeber details
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${pid}  ${resp.json()['id']}
      # clear_FamilyMember  ${pid}
      ${id1}=  get_id  ${PUSERNAME2}
      Set Suite Variable  ${id}  ${id}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      ${dob}=  FakerLibrary.Date
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME2}  ${EMPTY}
      Set Suite Variable  ${pcid2}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${dob}=  FakerLibrary.Date
      ${gender}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${pcid2}  ${firstname}  ${lastname}  ${dob}  ${gender}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${fid}  ${resp.json()}
      ${resp}=  ListFamilyMemberByProvider  ${pcid2}
      Verify Response List  ${resp}  0  id=${fid} 
      Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname}
      Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname}
      Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob}
      Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender}      


JD-TC-ListFamilyMemberByProvider-4
      [Documentation]    Add customer and add familymembers  after consumer signup of that customer the familymembers are  not list there.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      ${lastname}=  FakerLibrary.last_name
      ${ph2}=  Evaluate  ${PUSERNAME23}+73003
      Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      ${dob}=  FakerLibrary.Date
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}   ${ph2}  ${EMPTY}
      Set Test Variable  ${pcid3}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname1}=  FakerLibrary.first_name
      ${lastname1}=  FakerLibrary.last_name
      ${dob1}=  FakerLibrary.Date
      ${gender1}=   Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider   ${pcid3}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider   ${pcid3}  ${firstname2}  ${lastname2}  ${dob2}  ${gender2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73004
      ${resp}=  Consumer SignUp   ${firstname}  ${lastname}  ${address}  ${ph2}  ${alternativeNo}  ${dob}  ${gender}  ${EMPTY} 
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Activation  ${ph2}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential  ${ph2}  ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login   ${ph2}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  []
      #Verify Response List  ${resp}  0  user=${mem_id2}
     # Verify Response List  ${resp}  1  user=${mem_id1}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname2}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname2}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob2}
     # Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender2}      

     # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['firstName']}  ${firstname1}
     # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['lastName']}  ${lastname1}
     # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['dob']}  ${dob1}
     # Should Be Equal As Strings  ${resp.json()[1]['userProfile']['gender']}  ${gender1}      

JD-TC-ListFamilyMemberByProvider-5
      [Documentation]    Adding a customer and add two family members with two different providers ,in this case one family member is common and if the consumer sign up,then  the list of family members should not be duplicated.
      ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${p_id}  ${resp.json()['id']}
      ${firstname}=  FakerLibrary.first_name
      Set Test Variable  ${firstname}
      ${lastname}=  FakerLibrary.last_name
      Set Test Variable  ${lastname}
      ${ph3}=  Evaluate  ${PUSERNAME23}+7337337
      Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
      ${gender}=  Random Element    ${Genderlist}
      Set Test Variable  ${gender}
      ${dob}=  FakerLibrary.Date
      Set Test Variable  ${dob}
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
      Set Test Variable  ${pcid4}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${firstname1}=  FakerLibrary.first_name
      Set Test Variable  ${firstname1}
      ${lastname1}=  FakerLibrary.last_name
      Set Test Variable  ${lastname1}
      ${dob1}=  FakerLibrary.Date
      Set Test Variable  ${dob1}
      ${gender1}    Random Element    ${Genderlist}
      Set Test Variable  ${gender1}
      ${resp}=  AddFamilyMemberByProvider  ${pcid4}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id1}  ${resp.json()}
      ${firstname2}=  FakerLibrary.first_name
      ${lastname2}=  FakerLibrary.last_name
      ${dob2}=  FakerLibrary.Date
      ${gender2}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider     ${pcid4}    ${firstname2}  ${lastname2}  ${dob2}  ${gender2}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id2}  ${resp.json()}
      ${resp}=  ProviderLogout
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}  ${ph3}  ${EMPTY}
      Set Suite Variable  ${pcid5}  ${resp.json()}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  AddFamilyMemberByProvider  ${pcid5}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id3}  ${resp.json()}
      ${firstname3}=  FakerLibrary.first_name
      ${lastname3}=  FakerLibrary.last_name
      ${dob3}=  FakerLibrary.Date
      ${gender3}    Random Element    ${Genderlist}
      ${resp}=  AddFamilyMemberByProvider  ${pcid5}   ${firstname3}  ${lastname3}  ${dob3}  ${gender3}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Set Test Variable  ${mem_id4}  ${resp.json()}
      ${address}=  FakerLibrary.Address
      ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73004
      ${resp}=  Consumer SignUp   ${firstname}  ${lastname}  ${address}  ${ph3}  ${alternativeNo}  ${dob}  ${gender}  ${EMPTY} 
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  Consumer Activation   ${ph3}   1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Set Credential   ${ph3}   ${PASSWORD}  1
      Log   ${resp.json()}
      Should Be Equal As Strings    ${resp.status_code}    200
      ${resp}=  Consumer Login  ${ph3}  ${PASSWORD}
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMember  
      Log   ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  200
      Should Be Equal As Strings  ${resp.json()}  []
      #Verify Response List  ${resp}  0  user=${mem_id4}
      #Verify Response List  ${resp}  1  user=${mem_id2}
      #Verify Response List  ${resp}  2  user=${mem_id1}
      #Should Not Contain   ${resp}  3  user=${mem_id3}
      #Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname3}
      #Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname3}
      #Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob3}
      #Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender3}      

      #Should Be Equal As Strings  ${resp.json()[1]['userProfile']['firstName']}  ${firstname2}
      #Should Be Equal As Strings  ${resp.json()[1]['userProfile']['lastName']}  ${lastname2}
      #Should Be Equal As Strings  ${resp.json()[1]['userProfile']['dob']}  ${dob2}
      #Should Be Equal As Strings  ${resp.json()[1]['userProfile']['gender']}  ${gender2}      

      #Should Be Equal As Strings  ${resp.json()[2]['userProfile']['firstName']}  ${firstname1}
      #Should Be Equal As Strings  ${resp.json()[2]['userProfile']['lastName']}  ${lastname1}
      #Should Be Equal As Strings  ${resp.json()[2]['userProfile']['dob']}  ${dob1}
      #Should Be Equal As Strings  ${resp.json()[2]['userProfile']['gender']}  ${gender1}      

JD-TC-ListFamilyMemberByProvider-UH1
      [Documentation]  List a family member  details without login
      ${resp}=  ListFamilyMemberByProvider  ${pcid}
      Should Be Equal As Strings  ${resp.status_code}  419
      Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
      

NW-TC-ListFamilyMemberByProvider-UH2
      [Documentation]    invalid id using in ListFamilyMemberByProvider
      ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
      Should Be Equal As Strings  ${resp.status_code}  200
      ${resp}=  ListFamilyMemberByProvider   0
      Log  ${resp.json()}
      Should Be Equal As Strings  ${resp.status_code}  422
      Should Be Equal As Strings  "${resp.json()}"  "${INVALID_ID}"


# JD-TC-ListFamilyMemberByProvider-3
#       [Documentation]    List Familymember details by provider as a consumer
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Test Variable  ${pid}  ${resp.json()['id']}
#       clear_FamilyMember  ${pid}
#       ${id1}=  get_id  ${PUSERNAME6}
#       ${firstname}=  FakerLibrary.first_name
#       ${lastname}=  FakerLibrary.last_name
#       ${ph2}=  Evaluate  ${PUSERNAME23}+73003
#       Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
#       ${gender}=  Random Element    ${Genderlist}
#       ${dob}=  FakerLibrary.Date
#       ${resp}=  AddCustomer   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME6}  ${EMPTY}
#       Set Suite Variable  ${pcid1}  ${resp.json()}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${firstname}=  FakerLibrary.first_name
#       ${lastname}=  FakerLibrary.last_name
#       ${dob}=  FakerLibrary.Date
#       ${gender}    Random Element    ${Genderlist}
#       ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Test Variable  ${mem_id1}  ${resp.json()}
#       ${resp}=  ListFamilyMemberByProvider  ${pcid1}
#       Verify Response List  ${resp}  0  user=${mem_id1}  parent=${pcid1}
#       Should Be Equal As Strings  ${resp.json()[0]['userProfile']['firstName']}  ${firstname}
#       Should Be Equal As Strings  ${resp.json()[0]['userProfile']['lastName']}  ${lastname}
#       Should Be Equal As Strings  ${resp.json()[0]['userProfile']['dob']}  ${dob}
#       Should Be Equal As Strings  ${resp.json()[0]['userProfile']['gender']}  ${gender}