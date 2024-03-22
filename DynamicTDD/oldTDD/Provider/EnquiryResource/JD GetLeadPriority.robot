*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***
${self}      0
@{emptylist}
${task_temp_name1}   Follow Up 1
${task_temp_name2}   Follow Up 2
${en_temp_name}   EnquiryName

*** Test Cases ***
JD-TC-GetEnquiriesPriority-1
    [Documentation]   Get Enquiries Priority

    ${resp}=  Consumer Login  ${CUSERNAME19}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME20}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${fname1}   ${resp.json()['firstName']}
    Set Suite Variable  ${lname1}   ${resp.json()['lastName']}

    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME60}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${provider_id}  ${resp.json()['id']}

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${tz}  ${resp.json()['baseLocation']['bSchedule']['timespec'][0]['timezone']}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
        ${resp}=   Get Location ById  ${locId}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}
    END

    ${locId1}=  Create Sample Location
    Set Suite Variable  ${locId1}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${loc_len}=  Get Length   ${resp.json()}
    FOR   ${i}  IN RANGE   ${loc_len}
        IF   '${resp.json()[${i}]['id']}'=='${locId}'
            Set Suite Variable  ${loc_name}  ${resp.json()[${i}]['place']}
        ELSE IF  '${resp.json()[${i}]['id']}'=='${locId1}'
            Set Suite Variable  ${loc_name1}  ${resp.json()[${i}]['place']}
        END
    END

    ${resp}=  Get Provider Enquiry Category  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Type  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Status  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetEnquiriesPriority-2
    [Documentation]   Get Enquiry Priority with another Provider

    ${resp}=   Encrypted Provider Login  ${PUSERNAME61}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-GetEnquiriesPriority-UH1
    [Documentation]   Get Enquiry Priority with Consumer Login

    ${resp}=  Consumer Login  ${CUSERNAME10}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings    ${resp.json()}    ${NoAccess}

JD-TC-GetEnquiriesPriority-UH2
    [Documentation]   Get Enquiry Priority without Login

    ${resp}=  Get Provider Enquiry Priority  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings    ${resp.json()}    ${SESSION_EXPIRED}