*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Vacation
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library         /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py
Resource          /ebs/TDD/ProviderConsumerKeywords.robot


*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${SERVICE5}   SERVICE5
${SERVICE6}   SERVICE6
${digits}       0123456789
${P_PASSWORD}        Netvarth008
${C_PASSWORD}        Netvarth009
${waitlistedby}           PROVIDER
@{countryCode}   91  +91  48 
@{service_names}

***Test Cases***

JD-TC-AssignproviderWaitlist-1
    [Documentation]  Assingn waitlist to user
    
    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200    

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Enable Disable Department  ${toggle[0]}  
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id3}  ${resp.json()['departments'][0]['departmentId']}
    
    ${ph1}  ${u_id1} =  Create and Configure Sample User    deptId=${dep_id3}
    Set Suite Variable  ${ph1}
    Set Suite Variable  ${u_id1}