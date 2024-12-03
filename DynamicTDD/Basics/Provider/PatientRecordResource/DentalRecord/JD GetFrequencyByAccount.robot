*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PURCHASE 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot

*** Test Cases ***

JD-TC-GetFrequencyByAccount-1

    [Documentation]  Get Frequency By Account

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}

    ${frequency0}=       Random Int  min=26  max=30
    ${dosage0}=          Random Int  min=1  max=3000
    ${description0}=     FakerLibrary.sentence
    ${remark0}=          FakerLibrary.sentence
    ${dos0}=             Evaluate    float(${dosage0})

    ${resp}=    Create Frequency  ${frequency0}  ${dosage0}  description=${description0}  remark=${remark0}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id0}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id0}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200

    ${frequency}=       Random Int  min=120  max=125
    ${dosage}=          Random Int  min=1  max=3000
    ${description}=     FakerLibrary.sentence
    ${remark}=          FakerLibrary.sentence
    ${dos}=             Evaluate    float(${dosage})

    ${resp}=    Create Frequency  ${frequency}  ${dosage}  description=${description}  remark=${remark}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     200
    Set Suite Variable              ${frequency_id}         ${resp.json()}

    ${resp}=    Get Frequency  ${frequency_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}             200

    ${resp}=    Get Frequency By Account  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 200

    ${len}=  Get Length  ${resp.json()}
 

    FOR  ${i}  IN RANGE   ${len}

        IF  '${resp.json()[${i}]['id']}' == '${frequency_id}'  
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos}

        ELSE IF     '${resp.json()[${i}]['id']}' == '${frequency_id0}'     
            Should Be Equal As Strings      ${resp.json()[${i}]['id']}             ${frequency_id0}
            Should Be Equal As Strings      ${resp.json()[${i}]['frequency']}      ${frequency0}
            Should Be Equal As Strings      ${resp.json()[${i}]['description']}    ${description0}
            Should Be Equal As Strings      ${resp.json()[${i}]['remark']}         ${remark0}
            Should Be Equal As Strings      ${resp.json()[${i}]['dosage']}         ${dos0}
        END
    END


JD-TC-GetFrequencyByAccount-UH1

    [Documentation]  Get Frequency By Account - where account id is invalid

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${inv}=     Random Int  min=5000  max=6000

    ${resp}=    Get Frequency By Account  ${inv}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 422

JD-TC-GetFrequencyByAccount-UH2

    [Documentation]  Get Frequency By Account with Provider consumer login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME300}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Suite Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    Set Suite Variable  ${fname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${pc_emailid1}  ${fname}${C_Email}.${test_mail}

    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  countryCode=${countryCodes[1]}  email=${pc_emailid1}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}
    
    # ${resp}=  ProviderLogout
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}            ${resp.json()['providerConsumer']}

    ${resp}=    Get Frequency By Account  ${cid}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}                 401
    Should Be Equal As Strings              ${resp.json()}   ${NoAccess}
JD-TC-GetFrequencyByAccount-3

    [Documentation]  Get Frequency By Account - without login 

    ${resp}=    Get Frequency By Account  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}     419
    Should Be Equal As Strings      ${resp.json()}          ${SESSION_EXPIRED}
