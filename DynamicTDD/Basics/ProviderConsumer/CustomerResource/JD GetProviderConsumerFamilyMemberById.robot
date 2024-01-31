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
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***

${cc}                               +91

*** Test Cases ***

JD-TC-GetFamilyMemberById-1
    
    [Documentation]  Add Family Member for Provider Consumer, then Get by id.
    
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

    ${resp1}=  AddCustomer  ${CUSERNAME37}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}
   
    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=    Send Otp For Login    ${CUSERNAME37}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
  
    ${resp}=    Verify Otp For Login   ${CUSERNAME37}   12  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable   ${token}  ${resp.json()['token']}

    ${resp}=  Customer Logout   
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME37}    ${accountId}    ${token}
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

    ${resp}=    Get Family Member By Id   ${memb_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname}

JD-TC-GetFamilyMemberById-2
    
    [Documentation]  Add Family Member for Provider Consumer, update the number then Get by id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME37}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${fname1}                      FakerLibrary. name

    ${resp}=   Update Family Members   ${memb_id}  ${cid}   ${fname1}  ${lname}  ${dob}  ${gender}   ${primnum}  ${countryCodes[0]}  ${address}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Member By Id   ${memb_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname1}

JD-TC-GetFamilyMemberById-3
    
    [Documentation]  Delete that Family Member then Get by id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME37}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Delete Family Members   ${memb_id}      ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Family Member By Id   ${memb_id}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings    ${resp.json()['lastName']}    ${lname}
    Should Be Equal As Strings    ${resp.json()['phoneNo']}    ${primnum}
    Should Be Equal As Strings    ${resp.json()['parent']}    ${cid}
    Should Be Equal As Strings    ${resp.json()['countryCode']}    ${countryCodes[0]}
    Should Be Equal As Strings    ${resp.json()['firstName']}    ${fname1}

JD-TC-GetFamilyMemberById-UH
    
    [Documentation]  Try to Get by id with invalid id.

    ${resp}=    ProviderConsumer Login with token    ${CUSERNAME37}    ${accountId}    ${token}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Family Member By Id   ${cc}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${INVALID_FAMILY_MEMBER_ID}
