*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment  Waitlist
Library           Collections
Library           OperatingSystem
Library           String
Library           json
Library           random
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot
Resource          /ebs/TDD/Keywords.robot



*** Variables ***
${test_mail}              test@jaldee.com
${count}                  ${1}
${order}        0
${PASSWORD}               Jaldee01
${var_file}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providers.py
${var_file1}     ${EXECDIR}/data/${ENVIRONMENT}_varfiles/usedproviders.py

*** Test Cases ***
JD-TC-Provider_Signup-1
    [Documentation]   Provider Signup in Random Domain 


    ${data_dir_path2}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}data/
    ${var_file2}=    Set Variable    ${EXECDIR}/data/${ENVIRONMENT}_varfiles/providerconsumer.py
    ${data_file2}=  Set Variable    ${EXECDIR}/data/${ENVIRONMENT}data/${ENVIRONMENT}providerconsumer.txt

    IF  ${{os.path.exists($data_dir_path2)}} is False
        Create Directory   ${data_dir_path2}
    END
    IF  ${{os.path.exists($var_file2)}} is False
        Create File   ${var_file2}
    END
    IF  ${{os.path.exists($data_file2)}} is False
        Create File   ${data_file2}
    END

    ${providers_list}=   Get File    ${var_file}
    ${pro_list}=   Split to lines  ${providers_list}

    FOR  ${provider}  IN  @{pro_list}
        ${provider}=  Remove String    ${provider}    ${SPACE}
        ${provider}  ${ph}=   Split String    ${provider}  =
        Set Test Variable  ${ph}
    
    END

    ${resp}=  Encrypted Provider Login  ${ph}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${num}=  find_last  ${var_file}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${account_id}  ${resp.json()['id']}

# -------------------------------- Add a provider Consumer -----------------------------------

    ${firstName}=  FakerLibrary.name
    Set Suite Variable    ${firstName}
    ${lastName}=  FakerLibrary.last_name
    Set Suite Variable    ${lastName}
    ${primaryMobileNo}    Random Number 	digits=5 
    ${primaryMobileNo}=    Evaluate    f'{${primaryMobileNo}:0>5d}'
    Log  ${primaryMobileNo}
    Set Suite Variable  ${primaryMobileNo}  55555${primaryMobileNo}
    Set Suite Variable  ${email_id}  ${primaryMobileNo}.${test_mail}
 

    # ${primaryMobileNo}    Generate random string    10    123456789
    # ${primaryMobileNo}    Convert To Integer  ${primaryMobileNo}
    # Set Suite Variable    ${primaryMobileNo}
    # ${email}=    FakerLibrary.Email
    # Set Suite Variable    ${email}

    ${resp}=    Send Otp For Login    ${primaryMobileNo}    ${accountId}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    Log  ${resp.request.headers['Cookie']}
        ${cookie_parts}    ${jsessionynw_value}    Split String    ${resp.request.headers['Cookie']}    =
    Log   ${jsessionynw_value}

    ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=    Verify Otp For Login   ${primaryMobileNo}   ${OtpPurpose['Authentication']}
    # Log   ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer SignUp    ${firstName}  ${lastName}  ${email_id}    ${primaryMobileNo}     ${accountId}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200    
   
    ${resp}=    ProviderConsumer Login with token   ${primaryMobileNo}    ${accountId}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}
    Append To File  ${data_file2}  ${primaryMobileNo} - ${accountId} - ${token}${\n}
    Append To File  ${var_file1}  Provider_ConsumerID${num}=${cid}${\n}
    Append To File  ${var_file2}  primaryMobileNo${num}=${primaryMobileNo}${\n}
    Append To File  ${var_file2}  accountId${num}=${accountId}${\n}
    Append To File  ${var_file2}  token${num}=${token}${\n}

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200