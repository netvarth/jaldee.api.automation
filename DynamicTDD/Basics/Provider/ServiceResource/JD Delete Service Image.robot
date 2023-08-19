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
Suite Setup       Run Keyword    wlsettings

*** Variables ***

${SERVICE1}   SERVICE1
@{service_duration}  10  20  30   40   50
@{status}   ACTIVE   INACTIVE

*** Test Cases ***
JD-TC-Delete Service Image-1

    [Documentation]  Provider check to  Delete Service Image
    ${resp}=  Provider Login  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${description}=  FakerLibrary.sentence
    ${min_pre}=   Random Int   min=10   max=50
    ${Total}=   Random Int   min=100   max=500
    ${min_pre}=  Convert To Number  ${min_pre}  1
    ${Total}=  Convert To Number  ${Total}  1
    clear_service       ${PUSERNAME120}
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${service_duration[1]}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${min_pre}  ${Total}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200   
    Set Suite Variable  ${id}  ${resp.json()}   
    # ${resp}=  pyproviderlogin  ${PUSERNAME120}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    # Should Be Equal As Strings  ${resp[1]}  200
    Log  ${resp}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadServiceImages   ${id}  ${cookie}
    # Should Be Equal As Strings  ${resp[1]}  200
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=   Get Service By Id    ${id} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['servicegallery']} 
	Should Be Equal As Integers  ${count}  2
    Should Be Equal As Strings  ${resp.json()['servicegallery'][0]['caption']}   firstImage
    Should Contain  ${resp.json()['servicegallery'][0]['prefix']}  serviceGallery/${id}
    Set Suite Variable  ${imgName}  ${resp.json()['servicegallery'][0]['keyName']}  
    Set Suite Variable  ${img2}  ${resp.json()['servicegallery'][1]['keyName']}
    # ${resp}=  DeleteServiceImage  ${id}  ${imgName}
    ${resp}=  DeleteServiceImg  ${id}  ${imgName}  ${cookie}
    sleep  02s
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=   Get Service By Id    ${id} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['servicegallery']} 
	Should Be Equal As Integers  ${count}  1
    # ${resp}=  DeleteServiceImage  ${id}  ${img2}
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  DeleteServiceImg  ${id}  ${img2}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get Service By Id    ${id} 
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings  ${resp.json()['servicegallery']}   []


JD-TC-Delete Service Image-UH1

    [Documentation]  Provider check to Delete Service Image with another provider id
    # ${resp}=  pyproviderlogin  ${PUSERNAME153}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=   DeleteServiceImage  ${id}  ${imgName}  
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}  ${NO_PERMISSION}
    ${resp}=  DeleteServiceImg  ${id}  ${imgName}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${NO_PERMISSION}"

JD-TC-Delete Service Image-UH2

    [Documentation]  Provider check to  Delete Service Image image with invalid service id and image name
    # ${resp}=  pyproviderlogin  ${PUSERNAME120}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME120}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  DeleteServiceImage  0  abcd.png 
    # Should Be Equal As Strings  ${resp[1]}  422
    #Should Be Equal As Strings  ${resp[0]}  "${SERVICE_NOT_EXISTS}"
    ${resp}=  DeleteServiceImg  0  abcd.png  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    # Should Be Equal As Strings  "${resp.content}"  "${NO_PERMISSION}"

JD-TC-Delete Service Image-UH3

    [Documentation]  Consumer check to Delete Service Image
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME4}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  DeleteServiceImage  ${id}  ${imgName}
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL}
   # logged in user has no access permission to this url 
    ${resp}=  DeleteServiceImg  ${id}  ${imgName}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Delete Service Image-UH4

    [Documentation]  Delete Service Image without login
    # ${resp}=  DeleteServiceImage  ${id}  ${imgName}
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
    ${empty_cookie}=  Create Dictionary
    ${resp}=  DeleteServiceImg  ${id}  ${imgName}  ${empty_cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"


*** Keywords ***
wlsettings
    ${resp}=  ProviderLogin  ${PUSERNAME120}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
	${resp}=  View Waitlist Settings
	Run Keyword If  ${resp.json()['filterByDept']}==${bool[1]}   Toggle Department Disable  
	ProviderLogout 