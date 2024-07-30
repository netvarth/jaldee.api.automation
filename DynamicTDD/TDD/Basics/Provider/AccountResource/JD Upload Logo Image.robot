*** Settings ***
Library           Collections
Library           String
Library           json
Library		    OperatingSystem
Force Tags      LogoImageUplaod
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Library		    /ebs/TDD/Imageupload.py
Test Teardown     Remove File  cookies.txt
*** Test Cases ***

JD-TC-Upload Logo Image-1
    [Documentation]   Provider check to  Upload Logo image
    ${resp}=  Encrypted Provider Login  ${PUSERNAME17}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  pyproviderlogin  ${PUSERNAME17}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME17}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # @{resp}=  uploadLogoImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo
         
JD-TC-Upload Logo Image-UH3
    [Documentation]   Consumer check to Upload Logo image
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # @{resp}=  uploadLogoImages 
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL} 
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Upload Logo Image-UH4 
    [Documentation]   Upload Logo image without login  
    # ${resp}=  uploadLogoImages     
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
    ${empty_cookie}=  Create Dictionary
    ${resp}=  uploadLogoImages   ${empty_cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
