*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        ORDER ITEM
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Test Cases ***

JD-TC-Get_Default_Catalog_Status-1

    [Documentation]  Provider Get Default Catalog Status

    clear_Item  ${PUSERNAME46}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME46}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Get Default Catalog Status  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 


JD-TC-Get_Default_Catalog_Status-UH1

    [Documentation]   Get Default Catalog Status Without login

    ${resp}=  Get Default Catalog Status
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


    
JD-TC-Get_Default_Catalog_Status-UH2

    [Documentation]   Login as consumer and Get Default Catalog Status

    ${resp}=   Encrypted Provider Login  ${PUSERNAME174}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${account_id}=    get_acc_id       ${PUSERNAME174}

    #............provider consumer creation..........

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
  
    ${resp}=    Send Otp For Login    ${CUSERNAME17}    ${account_id}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Verify Otp For Login   ${CUSERNAME17}   ${OtpPurpose['Authentication']}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Test Variable  ${token}  ${resp.json()['token']}
    
    Set Test Variable  ${email}  ${fname}${CUSERNAME17}.${test_mail}

    ${resp}=    ProviderConsumer SignUp    ${fname}  ${lname}  ${email}    ${CUSERNAME17}     ${account_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    Consumer Logout 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=    ProviderConsumer Login with token   ${CUSERNAME17}    ${account_id}  ${token} 
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Default Catalog Status 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 



