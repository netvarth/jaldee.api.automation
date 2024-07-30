*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${cc}                               +91

*** Test Cases ***

JD-TC-DeleteFamilyMembersFormProviderConsumer-1
    
    [Documentation]  Add Family Member for Provider Consumer, then Delete that member.
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${accountId}=    get_acc_id       ${PUSERNAME22}
    Set Suite Variable     ${accountId}

    ${gender}                     Random Element    ${Genderlist}                   
    ${dob}                        FakerLibrary.Date
    ${fname}                      FakerLibrary. name
    ${lname}                      FakerLibrary.last_name
    ${email}                      FakerLibrary.email
    ${city}                       FakerLibrary.city
    ${state}                      FakerLibrary.state
    ${address}                    FakerLibrary.address
    ${primnum}                    FakerLibrary.Numerify   text=%%%%%%%%%%
    ${altno}                      FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numt}                       FakerLibrary.Numerify   text=%%%%%%%%%%
    ${numw}                       FakerLibrary.Numerify   text=%%%%%%%%%%

    Set Suite Variable      ${gender}
    Set Suite Variable      ${dob}
    Set Suite Variable      ${fname}
    Set Suite Variable      ${lname}
    Set Suite Variable      ${email}
    Set Suite Variable      ${city}
    Set Suite Variable      ${state}
    Set Suite Variable      ${address}
    Set Suite Variable      ${primnum}
    Set Suite Variable      ${altno}
    Set Suite Variable      ${numt}
    Set Suite Variable      ${numw}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    ${resp1}=  AddCustomer  ${CUSERNAME36}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME36}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME36}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME36}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id}  ${resp.json()}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

    ${resp}=    Delete Family Members   ${memb_id}      ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ListFamilyMemberByProvider     ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}    []

JD-TC-DeleteFamilyMembersFormProviderConsumer-2
    
    [Documentation]  Add Family Member for Provider Consumer,update member then Delete that member.
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME36}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id1}  ${resp.json()}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${numt}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

    ${resp}=   Update Family Members   ${memb_id1}  ${cid}   ${fname}  ${lname}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${numt}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

    ${resp}=    Delete Family Members   ${memb_id1}      ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Get Family Members   ${cid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  ListFamilyMemberByProvider     ${cid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings    ${resp.json()}    []


JD-TC-DeleteFamilyMembersFormProviderConsumer-3
    
    [Documentation]  Delete a family member then try to create same member again.
    
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME36}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id2}  ${resp.json()}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${numt}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

    ${resp}=    Delete Family Members   ${memb_id2}      ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

    ${resp}=    Create Family Member       ${fname}  ${lname}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id3}  ${resp.json()}

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${numt}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}
    Should Be Equal As Strings    ${resp.json()[0]['address']}    ${address}
    Should Be Equal As Strings    ${resp.json()[0]['dob']}    ${dob}


JD-TC-DeleteFamilyMembersFormProviderConsumer-4
    
    [Documentation]  Provider create a family member then provider consumer delete that member.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME22}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+76003
    Set Suite Variable  ${ph2}
    Set Suite Variable  ${email2}  ${firstname}${ph2}${C_Email}.${test_mail}
    ${dob}=  FakerLibrary.Date
    ${gender}=  Random Element    ${Genderlist}
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${CUSERNAME18}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${pcid}  ${resp.json()}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${ph2}${\n}
    ${firstname1}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${gender1}=  Random Element    ${Genderlist}
    Set Suite Variable  ${gender1}
    ${Familymember_ph}=  Evaluate  ${PUSERNAME0}+300000

    ${resp}=  AddFamilyMemberByProviderWithPhoneNo  ${pcid}  ${firstname1}  ${lastname1}  ${dob1}  ${gender1}  ${Familymember_ph}
    Log  ${resp.json()}
    Set Suite Variable  ${mem_id0}  ${resp.json()}
    ${resp}=  ListFamilyMemberByProvider  ${pcid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Verify Response List  ${resp}  0  id=${mem_id0}   
    Should Be Equal As Strings  ${resp.json()[0]['firstName']}  ${firstname1}
    Should Be Equal As Strings  ${resp.json()[0]['lastName']}  ${lastname1}
    Should Be Equal As Strings  ${resp.json()[0]['dob']}  ${dob1}
    Should Be Equal As Strings  ${resp.json()[0]['gender']}  ${gender1}

    ${resp}=    Send Otp For Login    ${CUSERNAME18}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME18}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME18}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lastname1}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${Familymember_ph}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${pcid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${firstname1}

    ${resp}=    Delete Family Members   ${mem_id0}      ${pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${pcid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()}    []

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-DeleteFamilyMembersFormProviderConsumer-UH1
    
    [Documentation]  Delete member with invalid member id.

    ${resp}=    Send Otp For Login    ${CUSERNAME36}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME36}   ${OtpPurpose['Authentication']}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME36}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Family Member       ${EMPTY}  ${EMPTY}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id3}  ${resp.json()}

    ${resp}=    Get FamilyMember
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Members   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()[0]['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()[0]['phoneNo']}    ${numt}
    Should Be Equal As Strings    ${resp.json()[0]['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()[0]['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()[0]['firstName']}    ${fname}

    ${resp}=    Delete Family Members   ${mem_id0}      ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${NOT_A_Familiy_Member}


JD-TC-DeleteFamilyMembersFormProviderConsumer-UH2
    
    [Documentation]  Delete member with invalid Customer id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME36}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Create Family Member       ${EMPTY}  ${EMPTY}  ${dob}  ${gender}   ${numt}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${memb_id4}  ${resp.json()}

    ${resp}=    Delete Family Members   ${memb_id4}      40000
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422