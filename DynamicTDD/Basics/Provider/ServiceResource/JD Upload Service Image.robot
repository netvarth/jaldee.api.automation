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
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Library           /ebs/TDD/Imageupload.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


*** Variables ***

${SERVICE3}   SERVICE3
@{service_duration}  10  20  30   40   50

*** Test Cases ***

JD-TC-Upload service Image-1

    [Documentation]  Provider check to  Upload service image
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    ${resp}=  Encrypted Provider Login  ${PUSERNAME199}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_service       ${PUSERNAME199}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${service_duration[2]}  ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[1]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${id}  ${resp.json()}  
    
    # ${resp}=  pyproviderlogin  ${PUSERNAME199}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME199}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=   Get Service By Id    ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['servicegallery'][0]['caption']}   firstImage
    Should Contain  ${resp.json()['servicegallery'][0]['prefix']}  serviceGallery/${id}
    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=   Get Service By Id    ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['servicegallery'][1]['caption']}   firstImage
    Should Contain  ${resp.json()['servicegallery'][1]['prefix']}  serviceGallery/${id}

JD-TC-Upload service Image-UH1

    [Documentation]  Provider check to Upload service image with another provider id
    # ${resp}=  pyproviderlogin  ${PUSERNAME192}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME192}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   uploadServiceImages   ${id}  ${cookie}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Upload service Image-UH2

    [Documentation]  Provider check to  Upload service image with invalid service id
    
    # ${resp}=  pyproviderlogin  ${PUSERNAME199}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME199}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadServiceImages   0   ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${SERVICE_NOT_FOUND}  