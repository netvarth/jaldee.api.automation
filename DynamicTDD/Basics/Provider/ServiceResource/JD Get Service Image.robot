*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Run Keywords     Delete All Sessions
...               AND           Remove File  cookies.txt
Force Tags        Service
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/CustomKeywords.py
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${SERVICE1}  SERVICE1
@{service_duration}  10  20  30   40   50


*** Test Cases ***

JD-TC-Get Service Image-1

    [Documentation]  Provider check to Get Gallery Image
    ${resp}=  Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    # clear_service       ${PUSERNAME215}
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    ${resp}=  Create Service  ${SERVICE1}  ${description}  ${service_duration[2]}  ${bool[1]}  ${Total}  ${bool[0]}  minPrePaymentAmount=${min_pre}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Set Suite Variable  ${id}  ${resp.json()}   
    # ${resp}=  pyproviderlogin  ${PUSERNAME215}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME215}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=   Get ServiceImage    ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['caption']}   firstImage
    Should Contain  ${resp.json()[0]['prefix']}  serviceGallery/${id}
    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=   Get ServiceImage    ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['caption']}   firstImage
    Should Contain  ${resp.json()[1]['prefix']}  serviceGallery/${id}
    

JD-TC-Get Service Image-UH1

    [Documentation]  Provider check to Get Gallery Image with another provider service id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME91}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get ServiceImage    ${id}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Get Service Image-UH2

    [Documentation]  Provider check to Get Gallery Image with invalid service id
    ${resp}=  Encrypted Provider Login  ${PUSERNAME215}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get ServiceImage   0  
    Should Be Equal As Strings  "${resp.json()}"  "${NO_SERVICE_FOUND}" 
    Should Be Equal As Strings  ${resp.status_code}  422 

JD-TC-Get Service Image-UH3

    [Documentation]  Consumer check to Get Gallery Image

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get ServiceImage    ${id}    
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
