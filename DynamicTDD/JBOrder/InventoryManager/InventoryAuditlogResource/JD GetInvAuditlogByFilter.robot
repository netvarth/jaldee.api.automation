*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Auditlog 
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/hl_providers.py
Variables         /ebs/TDD/varfiles/providers.py
Resource          /ebs/TDD/SuperAdminKeywords.robot


*** Test Cases ***

JD-TC-GetInvAuditlogByFilter-1

    [Documentation]  Create inventory item, add item to inventory catalouge, then verify auditlog.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    

    #............create inventory item...............



    ${resp}=   Get Audit Logs
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}             200
    Should Be Equal As Strings  ${resp.json()[0]['date']}       ${DAY1}
    Variable Should exist       ${resp.json()[0]['time']}       ${converted_time1}
    Should Be Equal As Strings  ${resp.json()[0]['subject']}    Logged in
    Should Be Equal As Strings  ${resp.json()[0]['text']}       Login
    Should Be Equal As Strings  ${resp.json()[0]['Action']}     ADD
    Should Be Equal As Strings  ${resp.json()[0]['userType']}   PROVIDER
