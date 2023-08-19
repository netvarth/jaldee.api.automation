*** Settings ***
Library           Collections
Library           String
Library           json
Force Tags       GalleryImageUplaod
Library		  OperatingSystem
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Library		    /ebs/TDD/Imageupload.py
Test Teardown     Remove File  cookies.txt
*** Test Cases ***

JD-TC-Upload Gallery Image-1
    [Documentation]   Provider check to  Upload Gallery image
    # ${resp}=  pyproviderlogin  ${PUSERNAME16}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # @{resp}=  uploadGalleryImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=  uploadGalleryImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  ProviderLogin  ${PUSERNAME16}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200
       
JD-TC-Upload Gallery Image-UH1
    [Documentation]   Consumer check to Upload Gallery image
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  uploadGalleryImages   
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL} 
    ${resp}=  uploadGalleryImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Upload Gallery Image-UH2
    [Documentation]   Upload Gallery image without login  
    # ${resp}=  uploadGalleryImages    
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
    ${empty_cookie}=  Create Dictionary
    ${resp}=  uploadGalleryImages   ${empty_cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
 
 
    
    
