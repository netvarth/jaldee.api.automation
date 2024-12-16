*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Familymemeber
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-AddFamilyMemberByProvider-1
    [Documentation]    Add a familymember by provider login
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME0}

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${pid}  ${decrypted_data['id']}

    # Set Test Variable  ${pid}  ${resp.json()['id']}
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    # ${id}=  get_id  ${CUSERNAME9}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+73003
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME9}  ${EMPTY}
    ${resp}=  AddCustomer  ${CUSERNAME9}    firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()}
    # clear_FamilyMember  ${id}
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname1} 
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1} 
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${mem_id0}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${pcid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${mem_id0}  firstName=${firstname1}   lastName=${lastname1}  status=${status[0]}  parent=${pcid}

JD-TC-AddFamilyMemberByProvider-2
    [Documentation]    Adding more family members
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${pcid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${mem_id0}  firstName=${firstname1}   lastName=${lastname1}  status=${status[0]}  parent=${pcid}
    Verify Response List  ${resp}  1  id=${mem_id}  firstName=${firstname}   lastName=${lastname}  status=${status[0]}  parent=${pcid}
    # Verify Response List  ${resp}  0  user=${mem_id}
    # Verify Response List  ${resp}  1  user=${mem_id0}
      

JD-TC-AddFamilyMemberByProvider-3
    [Documentation]    Adding a family member with  same phone number 
    phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}=  Evaluate  ${PUSERNAME0}+200000
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${id}=  get_id  ${PUSERNAME0}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+73004
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME0}  ${EMPTY}
    ${resp}=  AddCustomer  ${PUSERNAME0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid1}  ${resp.json()}
    # clear_FamilyMember  ${id}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}  phoneNo=${Familymember_ph}  countryCode=${countryCode}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name
    ${dob1}=  FakerLibrary.Date
    ${gender1}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${pcid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  id=${mem_id}  firstName=${firstname}   lastName=${lastname}  status=${status[0]}  parent=${pcid1}
    Verify Response List  ${resp}  1  id=${mem_id1}  firstName=${firstname1}   lastName=${lastname1}  status=${status[0]}  parent=${pcid1}

    # Verify Response List  ${resp}  0  user=${mem_id1}
    # Verify Response List  ${resp}  1  user=${mem_id}
    # Should Be Equal As Strings   ${resp.json()}  "${ACCOUNT_EXIST_EMAIL_PHONE}"
      
JD-TC-AddFamilyMemberByProvider-4
    [Documentation]   One familymember added by two providers
    phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}=  Evaluate  ${PUSERNAME0}+200001
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${id}=  get_id  ${PUSERNAME0}
    # clear_FamilyMember  ${id}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Test Variable  ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Test Variable  ${gender}
    ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}  phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${id}=  get_id  ${PUSERNAME0}
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME0}  ${EMPTY}
    ${resp}=  AddCustomer  ${PUSERNAME0}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid2}  ${resp.json()}
    # clear_FamilyMember  ${id}
    ${resp}=  AddFamilyMemberByProvider  ${pcid2}  ${firstname}  ${lastname}  ${dob}  ${gender}  phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  "${resp.json()}"  "${ACCOUNT_EXIST_EMAIL_PHONE}"

JD-TC-AddFamilyMemberByProvider-5
    [Documentation]   One familymember added by one provider and consumer
    phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}=  Evaluate  ${PUSERNAME0}+200002
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${id}=  get_id  ${CUSERNAME0}
    # clear_FamilyMember  ${id}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}  phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${pcid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  2  id=${mem_id}
    # ${resp}=  Consumer Login  ${CUSERNAME0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${CUSERNAME0}  ${token}  Create Sample Customer  ${account_id}  primaryMobileNo=${CUSERNAME0}

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME0}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  AddFamilyMemberWithPhNo   ${firstname}  ${lastname}  phoneNo=${Familymember_ph}  countryCode=${countryCodes[0]}  ${dob}  ${gender}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id1}  ${resp.json()}
    ${resp}=  ListFamilyMember  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response List  ${resp}  0  user=${mem_id1}
    # Should Be Equal As Strings  "${resp.json()}"  "${MEMBER_EXIST_ALREADY_WITH_ANOTHER_PROVIDER}"

JD-TC-AddFamilyMemberByProvider-6
    [Documentation]    Add customer and add familymembers  after consumer signup of that customer the familymembers are not list there.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}

    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${lastname}
    ${ph3}=  Evaluate  ${PUSERNAME23}+73005
    Set Test Variable  ${ph3}
    Set Test Variable  ${email3}  ${firstname}${ph3}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${gender}
    ${dob}=  FakerLibrary.Date
    Set Test Variable  ${dob}
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email3}  ${gender}  ${dob}   ${ph3}  ${EMPTY}
    ${resp}=  AddCustomer  ${ph3}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid3}  ${resp.json()}
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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
    ${address}=  FakerLibrary.Address
    ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73006
    ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph3}    ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${ph3}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${ph3}  ${PASSWORD}  1
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login   ${ph3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ListFamilyMember  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    #Verify Response List  ${resp}  0  user=${mem_id2}
    #Verify Response List  ${resp}  1  user=${mem_id1}

JD-TC-AddFamilyMemberByProvider-7
    [Documentation]    Adding a customer and add two family members with two different providers ,in this case one family member is common and if the consumer sign up,then  the list of family members should not be duplicated.
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Test Variable  ${p_id}  ${decrypted_data['id']}
    
    # Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    Set Test Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Test Variable  ${lastname}
    ${ph4}=  Evaluate  ${PUSERNAME23}+73007
    Set Test Variable  ${ph4}
    Set Test Variable  ${email4}  ${firstname}${ph4}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    Set Test Variable  ${gender}
    ${dob}=  FakerLibrary.Date
    Set Test Variable  ${dob}
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email4}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
    ${resp}=  AddCustomer  ${ph4}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid4}  ${resp.json()}
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
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email4}  ${gender}  ${dob}  ${ph4}  ${EMPTY}
    ${resp}=  AddCustomer  ${ph4}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid5}  ${resp.json()}
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
    # Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph3}${\n}
    # ${address}=  FakerLibrary.Address
    # ${alternativeNo}=  Evaluate  ${PUSERNAME23}+73008
    # ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${ph4}   ${alternativeNo}  ${dob}  ${gender}   ${EMPTY}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Activation  ${ph4}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Set Credential  ${ph4}  ${PASSWORD}  1
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Consumer Login  ${ph4}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=    Send Otp For Login    ${ph4}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${ph4}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}

    ${resp}=    ProviderConsumer Login with token   ${ph4}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  ListFamilyMember  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()}  []
    #Verify Response List  ${resp}  0  user=${mem_id4}
    #Verify Response List  ${resp}  1  user=${mem_id2}
    #Verify Response List  ${resp}  2  user=${mem_id1}
    #Should Not Contain   ${resp}  3  user=${mem_id3}

JD-TC-AddFamilyMemberByProvider-UH1
    [Documentation]  Add a family member without login1710000011
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
    Should Be Equal As Strings   ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}


JD-TC-AddFamilyMemberByProvider-UH2
    [Documentation]    Adding a family member with  same name 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph5}=  Evaluate  ${PUSERNAME23}+73008
    Set Test Variable  ${email5}  ${firstname}${ph5}${C_Email}.${test_mail}
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    # ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email5}  ${gender}  ${dob}   ${ph5}  ${EMPTY}
    ${resp}=  AddCustomer  ${ph5}  firstName=${firstname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${email5}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pcid6}  ${resp.json()}
    ${firstname4}=  FakerLibrary.first_name
    Set Test Variable  ${firstname4}
    ${lastname4}=  FakerLibrary.last_name
    Set Test Variable  ${lastname4}
    ${dob4}=  FakerLibrary.Date
    Set Test Variable  ${dob4}
    ${gender4}    Random Element    ${Genderlist}
    Set Test Variable  ${gender4}
    ${resp}=  AddFamilyMemberByProvider  ${pcid6}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${mem_id}  ${resp.json()}
    ${resp}=  AddFamilyMemberByProvider  ${pcid6}  ${firstname4}  ${lastname4}  ${dob4}  ${gender4}  
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings   ${resp.json()}   ${FAMILY_MEMBEBR_NAME_SAME}

# JD-TC-AddFamilyMemberByProvider-3
#       [Documentation]    Add a Familymember by provider switched to a consumer
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${id1}=  get_id  ${PUSERNAME0}
#       ${firstname}=  FakerLibrary.first_name
#       ${lastname}=  FakerLibrary.last_name
#       ${ph2}=  Evaluate  ${PUSERNAME23}+73003
#       Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
#       ${gender}=  Random Element    ${Genderlist}
#       ${dob}=  FakerLibrary.Date
#       ${resp}=  AddCustomer   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${PUSERNAME0}  ${EMPTY}
#       Log  ${resp.json()}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Suite Variable  ${pcid1}  ${resp.json()}
#       clear_FamilyMember  ${id1}
#       ${firstname}=  FakerLibrary.first_name
#       Set Suite Variable  ${firstname}
#       ${lastname}=  FakerLibrary.last_name
#       Set Suite Variable  ${lastname}
#       ${dob}=  FakerLibrary.Date
#       Set Suite Variable  ${dob}
#       ${gender}    Random Element    ${Genderlist}
#       Set Suite Variable  ${gender}
#       ${resp}=  AddFamilyMemberByProvider  ${pcid1}  ${firstname}  ${lastname}  ${dob}  ${gender}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Set Test Variable  ${mem_id1}  ${resp.json()}
#       ${resp}=  ListFamilyMemberByProvider  ${pcid1}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       Verify Response List  ${resp}  0  user=${mem_id1}


# JD-TC-AddFamilyMemberByProvider-UH1
#       [Documentation]    Adding a family member with existing family member details
#       ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${firstname}=  FakerLibrary.first_name
#       Set Test Variable  ${firstname}
#       ${lastname}=  FakerLibrary.last_name
#       Set Test Variable  ${lastname}
#       ${dob}=  FakerLibrary.Date
#       Set Test Variable  ${dob}
#       ${gender}    Random Element    ${Genderlist}
#       Set Test Variable  ${gender}
#       ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
#       Should Be Equal As Strings  ${resp.status_code}  200
#       ${resp}=  AddFamilyMemberByProvider  ${pcid}  ${firstname}  ${lastname}  ${dob}  ${gender}
#       Should Be Equal As Strings  ${resp.status_code}  422
#       Should Be Equal As Strings   ${resp.json()}  "${FAMILY_MEMBEBR_NAME_SAME}"
      