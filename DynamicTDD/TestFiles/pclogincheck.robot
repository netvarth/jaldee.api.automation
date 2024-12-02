*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Test Cases ***

JD-TC-GetAppointmentToday-1
    [Documentation]   Checking Get Consumer Appointments Today using  customer login.
    
    ${account_id}=  get_acc_id  ${HLPUSERNAME51}

    ${resp}=    Send Otp For Login    ${CUSERNAME16}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${jsessionynw_value}=   Get Cookie from Header  ${resp}

    ${resp}=    Verify Otp For Login    ${CUSERNAME16}   ${OtpPurpose['Authentication']}  JSESSIONYNW=${jsessionynw_value}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${token}  ${resp.json()['token']}

    ${fname}=  generate_firstname
    ${lname}=  FakerLibrary.last_name
    ${resp}=   ProviderConsumer SignUp    ${fname}  ${lname}  ${EMPTY}  ${CUSERNAME16}  ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME16}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Get Consumer Appointments Today  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 