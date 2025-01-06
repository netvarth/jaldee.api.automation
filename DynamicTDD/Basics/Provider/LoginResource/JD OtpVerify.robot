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
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-4

    [Documentation]  add a provider consumer by provider then try to login that provider consumer from csite with a wrong otp for 5 attempts.
    ...   then After 5 try, check the provider consumer is locked to do further tries for a varied time period.
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
    Should Be Equal As Strings    ${resp.status_code}   422
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

JD-TC-OTPVerify-6

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

JD-TC-OTPVerify-7

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
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-8

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
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  5s

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

JD-TC-OTPVerify-9

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

JD-TC-OTPVerify-10

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

JD-TC-OTPVerify-11

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

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

JD-TC-OTPVerify-12

    [Documentation]  signup a provider then do the otp verification in account activate url with a wrong otp for 5 attempts.
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

    #..wrong otp attempt 6,, account locked..
    ${wrong_otp}=    Generate Random String    4    [NUMBERS]
    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}  ${wrong_otp}   JSESSIONYNW=${jsessionynw_value} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  ${resp.content}   "it is locked for a while. try after some time"

    sleep  1s

    ${resp}=  Account Set Credential  ${PUSERNAME_A}  ${PASSWORD}  ${OtpPurpose['ProviderSignUp']}  ${loginId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Encrypted Provider Login  ${loginId}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200