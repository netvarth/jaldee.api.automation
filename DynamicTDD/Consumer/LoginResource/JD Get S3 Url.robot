*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        S3URL
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/consumerlist.py



*** Test Cases ***

JD-TC-Get S3 Url-1
    [Documentation]  Get S3 Url with consumerlogin
    ${resp}=  ConsumerLogin  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get S3 Url
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
  
JD-TC-Get S3 Url-2
    [Documentation]  Get S3 Url without consumerlogin
    ${resp}=  Get S3 Url
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200