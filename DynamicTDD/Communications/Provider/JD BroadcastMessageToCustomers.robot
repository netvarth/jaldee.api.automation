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

    [Documentation]   Send message to all provider consumers in account  with all medium enabled.

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200


    ${numbers}=  Create List
    FOR   ${i}  IN RANGE   5
        ${CUSERPH0}=  Generate Random Test Phone Number
        Set Test Variable  ${CUSERPH${i}}  ${CUSERPH0}
        ${fname}=  FakerLibrary.first_name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${i}}  ${resp.json()}
        
    END
    
    FOR   ${i}  IN RANGE   5
        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${i}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${i}}
    END

    ${resp}=  Provider Logout
    Should Be Equal As Strings    ${resp.status_code}    200

    FOR   ${i}  IN RANGE   5
        ${resp}=    Send Otp For Login    ${CUSERNAME1}    ${accountId}
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
    
        ${resp}=    Verify Otp For Login   ${CUSERNAME1}   12  
        Log   ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable   ${token}  ${resp.json()['token']}

        ${resp}=  Customer Logout   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    
        ${resp}=    ProviderConsumer Login with token    ${CUSERNAME1}    ${accountId}    ${token}    ${countryCode}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}   200
        Set Suite Variable    ${cid}    ${resp.json()['providerConsumer']}

        ${resp}=  Customer Logout   
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
    END

    ${resp}=   Encrypted Provider Login  ${PUSERNAME302}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${msg}=   FakerLibrary.sentence
    ${resp}=  Broadcast Message to customers  ${msg}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}