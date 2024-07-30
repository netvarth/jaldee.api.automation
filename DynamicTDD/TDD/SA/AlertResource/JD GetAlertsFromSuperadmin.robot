*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Alert
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${alert_reason}   Server maintenance 
${tz}   Asia/Kolkata

*** Test Cases ***
JD-TC-GetAlertsFromSuperadmin-1
    [Documentation]    Create an alert and get alerts from superadmin

    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME6}
    clear_Alert  ${pid}
    ${DAY}=  db.add_timezone_date  ${tz}  1  
    ${time}=  db.add_timezone_time  ${tz}  1  10
    ${resp}=  Schedule Maintenance   ${DAY}  ${time}    
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout 
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep  4s
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Alerts From Superadmin
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Contain  ${resp.json()[0]['text']}  Jaldee won't be available from ${DAY} ${time} for a while.
    Should Be Equal As Strings  ${resp.json()[0]['subject']}   ${alert_reason}

JD-TC-GetAlertsFromSuperadmin-UH1
    [Documentation]  Add customer with out login

    ${resp}=  Get Alerts From Superadmin
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}
     
JD-TC-GetAlertsFromSuperadmin-UH2
    [Documentation]  Add a customer using consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Alerts From Superadmin
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
     