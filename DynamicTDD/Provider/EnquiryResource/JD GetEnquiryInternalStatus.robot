*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords  Delete All Sessions
Force Tags        ENQUIRY
Library           Collections
Library           FakerLibrary
Library 	      JSONLibrary
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
JD-TC-GetEnquiryInternalStatus-1
    [Documentation]   Get Enquiry internal status for a provider

    ${resp}=   Encrypted Provider Login  ${PUSERNAME26}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry Internal Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}   0
    Should Be Equal As Strings    ${resp.json()[0]['name']}  New

    Should Be Equal As Strings  ${resp.json()[1]['id']}   1
    Should Be Equal As Strings    ${resp.json()[1]['name']}  Assigned

    Should Be Equal As Strings  ${resp.json()[2]['id']}   2
    Should Be Equal As Strings    ${resp.json()[2]['name']}  In Progress

    Should Be Equal As Strings  ${resp.json()[3]['id']}   3
    Should Be Equal As Strings    ${resp.json()[3]['name']}  Canceled

    Should Be Equal As Strings  ${resp.json()[4]['id']}   4
    Should Be Equal As Strings    ${resp.json()[4]['name']}  Pending

    Should Be Equal As Strings  ${resp.json()[5]['id']}   5
    Should Be Equal As Strings    ${resp.json()[5]['name']}  Rejected

    Should Be Equal As Strings  ${resp.json()[6]['id']}   6
    Should Be Equal As Strings    ${resp.json()[6]['name']}  Completed

    Should Be Equal As Strings  ${resp.json()[7]['id']}   7
    Should Be Equal As Strings    ${resp.json()[7]['name']}  Verified

    Should Be Equal As Strings  ${resp.json()[8]['id']}   8
    Should Be Equal As Strings    ${resp.json()[8]['name']}  Closed


JD-TC-GetEnquiryInternalStatus-UH1
    [Documentation]   Get Enquiry internal status by consumer

    ${resp}=   Consumer Login  ${CUSERNAME19}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Get Enquiry Internal Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}


JD-TC-GetEnquiryInternalStatus-UH2
    [Documentation]   Get Enquiry internal status without login

    ${resp}=  Get Enquiry Internal Status
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.json()}   ${SESSION_EXPIRED}