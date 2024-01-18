*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        Communications
Library           Collections
Library           String
Library           json
Library           /ebs/TDD/db.py
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***

${jpgfile}      /ebs/TDD/uploadimage.jpg
${pngfile}      /ebs/TDD/upload.png
${pdffile}      /ebs/TDD/sample.pdf

*** Test Cases ***

JD-TC-BroadcastMessageToCustomers-1

    [Documentation]   Send message to all provider consumers in account.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${numbers}=  Create List
    FOR   ${i}  IN RANGE   5
        ${PO_Number1}    Generate random string    3    0123456789
        ${PO_Number1}    Convert To Integer  ${PO_Number1}
        ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    
    # ${PO_Number1}    Generate random string    3    0123456789
    # ${PO_Number1}    Convert To Integer  ${PO_Number1}
    # ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200