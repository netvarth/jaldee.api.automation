*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        jaldeeInegration
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***

JD-TC-JaldeeIDformat-1
    [Documentation]   Jaldeeidformat By AUTO

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${resp}=  JaldeeId Format   ${customerseries[0]}   ${EMPTY}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+72000
    Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Set Test Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    ${resp}=  GetCustomer ById  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['dob']}   ${dob}
    Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['createdBy']['id']}  ${p_id}
    Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}

JD-TC-JaldeeIDformat-2
    [Documentation]   Jaldeeidformat By MANUAL

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${resp}=  JaldeeId Format   ${customerseries[1]}   ${EMPTY}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+72003
    Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${m_jid}=  Random Int  min=10  max=50
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${m_jid}
    Set Test Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    ${resp}=  GetCustomer ById  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['dob']}   ${dob}
    Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['createdBy']['id']}  ${p_id}
    Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}

JD-TC-JaldeeIDformat-3
    [Documentation]   Jaldeeidformat By PATTERN

    ${resp}=  Encrypted Provider Login  ${PUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${prefix}=  FakerLibrary.name
    Set Suite Variable  ${prefix}
    ${suffix}=  FakerLibrary.name
    Set Suite Variable  ${suffix}
    ${resp}=  JaldeeId Format   ${customerseries[2]}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+72002
    Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Set Test Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    ${resp}=  GetCustomer ById  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['dob']}   ${dob}
    Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['createdBy']['id']}  ${p_id}
    Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}

JD-TC-JaldeeIDformat-4
    [Documentation]   Jaldeeidformat By Same PATTERN with different provider

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${p_id}  ${resp.json()['id']}
    ${resp}=  JaldeeId Format   ${customerseries[2]}   ${prefix}   ${suffix}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${ph2}=  Evaluate  ${PUSERNAME23}+72002
    Set Test Variable  ${email2}  ${firstname}${ph2}${C_Email}.ynwtest@netvarth.com
    ${gender}=  Random Element    ${Genderlist}
    ${dob}=  FakerLibrary.Date
    ${resp}=  AddCustomer with email   ${firstname}  ${lastname}  ${EMPTY}  ${email2}  ${gender}  ${dob}  ${ph2}  ${EMPTY}
    Set Test Variable  ${cid}  ${resp.json()}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${ph2}${\n}
    ${resp}=  GetCustomer ById  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    Log  ${resp.json()}
    Set Test Variable  ${j_id}  ${resp.json()['jaldeeId']}
    Should Be Equal As Strings  ${resp.json()['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['phoneNo']}  ${ph2}
    Should Be Equal As Strings  ${resp.json()['dob']}   ${dob}
    Should Be Equal As Strings  ${resp.json()['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['email_verified']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['phone_verified']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['favourite']}  ${bool[0]}
    Should Be Equal As Strings  ${resp.json()['jaldeeId']}  ${j_id}



