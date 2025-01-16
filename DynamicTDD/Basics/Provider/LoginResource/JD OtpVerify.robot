*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        OTP
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***


JD-TC-OTPVerify-1

    [Documentation]  add a provider consumer by provider then login that provider consumer from csite with a valid otp in first attempt.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-2

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
   

JD-TC-OTPVerify-3

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-4

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-5

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-6

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-7

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..
    ...   then again try to do 5 wrong attempts and check the lock state.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-8

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..
    ...   then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 3s time period

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   3s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-9

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..
    ...   then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 3s time period
    ...  then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 4s time period

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   3s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-10

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..
    ...   then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 3s time period
    ...  then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 4s time period
    ...  

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   3s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  4s 
    
    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}   "OTP expired"

JD-TC-OTPVerify-11

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts then locked for 2s, try login before the locked time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s
    
    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-12

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to do 5 wrong attempts and check the lock state then do further tries for 2s time period..
    ...   then again try to do 5 wrong attempts and check the lock state. check the provider consumer is locked to do further tries for 3s time period
    ...  then try login before the locked time.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   2s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-13

    [Documentation]  add a provider consumer by provider then try to login after the otp expiry time period(10s).

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    sleep   10s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.content}   "OTP expired"

JD-TC-OTPVerify-14

    [Documentation]  signup a provider then do the otp verification in account verify url with a valid otp in first attempt.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OTPVerify-15

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

JD-TC-OTPVerify-16

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-17

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OTPVerify-18

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-19

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  2s
    
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OTPVerify-20

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  2s
    
    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-21

    [Documentation]  signup a provider then do the otp verification in account verify url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  2s
    
    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  3s
    
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OTPVerify-22

    [Documentation]  signup a provider then do the otp verification in account activate url with a valid otp in first attempt.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

JD-TC-OTPVerify-23

    [Documentation]  signup a provider then do the otp verification in account activate url with a wrong otp for 5 attempts.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

JD-TC-OTPVerify-24

    [Documentation]  signup a provider then do the otp verification in account activate url with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}
  
JD-TC-OTPVerify-25

    [Documentation]  signup a provider then try to login after the otp expiry time period(10s).

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    sleep   10s
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.content}   "OTP expired"

JD-TC-OTPVerify-26

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 3 attempts.
    ...   then check the login.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
   
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${resp}=    ProviderConsumer Login with token   ${PCPHONENO}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-27

    [Documentation]  do the provider signup and check forget password and forget login id otp check..

    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.content}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    ${d1}=  Random Int   min=0  max=${dlen-1}
    Set Test Variable  ${dom}  ${domresp.json()[${d1}]['domain']}
    ${sdlen}=  Get Length  ${domresp.json()[${d1}]['subDomains']}
    ${sdom}=  Random Int   min=0  max=${sdlen-1}
    Set Test Variable  ${sub_dom}  ${domresp.json()[${d1}]['subDomains'][${sdom}]['subDomain']}

    ${licresp}=   Get Licensable Packages
    Should Be Equal As Strings   ${licresp.status_code}   200
    ${liclen}=  Get Length  ${licresp.json()}
    FOR  ${pos}  IN RANGE  ${liclen}
        Set Test Variable  ${pkgId}  ${licresp.json()[${pos}]['pkgId']}
    END

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${PO_Number}    Generate random string    7    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERNAME_A}=  Evaluate  ${PUSERNAME}+${PO_Number}
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_A}${\n}
    Set Test Variable   ${PUSERNAME_A}
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${dom}  ${sub_dom}  ${PUSERNAME_A}    ${pkgId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}

    ${resp}=  Account Activation  ${PUSERNAME_A}   ${OtpPurpose['ProviderSignUp']}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${loginId}=   Generate random string    7    0123456789
    
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Provider Logout
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Forgot Password   loginId=${loginId}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Forgot Password   otp=${wrong_otp}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

    ${resp}=    Forgot LoginId   countryCode=${countryCodes[1]}  phoneNo=${PUSERNAME_A}  
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    202

    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Forgot LoginId     otp=${wrong_otp}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  ${resp.json()}   ${ENTER_VALID_OTP}

JD-TC-OTPVerify-28

    [Documentation]  do a provider consumer signup and verify otp.

    #............provider consumer signup..........
    
    ${NewCustomer}  ${token}  Create Sample Customer  ${acc_id1}
    
    ${resp}=    ProviderConsumer Login with token   ${NewCustomer}    ${acc_id1}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

JD-TC-OTPVerify-29

    [Documentation]  do a provider consumer signup  with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for 1s time period.
    ...   when it is unlocked , try to verify login with a valid otp.

    #............provider consumer signup..........
    
    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  555${PH_Number}

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    #..wrong otp attempt 1..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 2..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 3..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 4..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 5..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.json()}   ${OTP_VALIDATION_FAILED}
    
    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=    Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   403
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep   1s

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    ${firstName}=  generate_firstname
    ${lastName}=  FakerLibrary.last_name
    ${email}  Set Variable  ${firstName}${C_Email}.${test_mail}

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email}  ${PCPHONENO}  ${acc_id1}  Authorization=${token}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
    
JD-TC-OTPVerify-30

    [Documentation]  add a provider consumer by provider then try to login after the otp expiry time period(10s) check access key table for otp removed.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    #............provider consumer creation..........
    
    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${acc_id1}  ${resp.json()['id']}

    clear_customer   ${PUSERNAME306}

    ${PH_Number}=  FakerLibrary.Numerify  %#####
    ${PH_Number}=    Evaluate    f'{${PH_Number}:0>7d}'
    Log  ${PH_Number}
    Set Test Variable  ${PCPHONENO}  222${PH_Number}

    ${fname}=  generate_firstname
    ${lastname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${PCPHONENO}    firstName=${fname}   lastName=${lastname}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Send Otp For Login    ${PCPHONENO}    ${acc_id1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    sleep   12s

    ${key}=   verify accnt  ${PCPHONENO}  ${OtpPurpose['Authentication']}   ${jsessionynw_value}

    ${resp}=   Verify Otp For Login   ${PCPHONENO}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   401
    Should Be Equal As Strings  ${resp.content}   "OTP expired"

    ${otp_check}=   otp_check  ${PCPHONENO}

    ${resp} =  SuperAdminLogin  ${SUSERNAME}  ${SPASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    OTP Trancation Check
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Encrypted Provider Login  ${PUSERNAME306}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${otp_check}=   otp_check  ${PCPHONENO}
    Should Be Equal As Strings  ${otp_check}   0

