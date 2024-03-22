*** Settings ***
Library           Collections
Library           String
Library           json
Force Tags       GalleryImageUplaod
Library		     OperatingSystem
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Library		    /ebs/TDD/Imageupload.py
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
*** Test Cases ***

JD-TC-Get Gallery or Logo Image-1
    [Documentation]  Get Gallery or Logo Image for valid provider  Gallery Image
    # ${resp}=  pyproviderlogin  ${PUSERNAME15}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # @{resp}=  uploadGalleryImages
    # Log   ${resp[0]}  
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadGalleryImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['caption']}   firstImage
    Should Be Equal As Strings  ${resp.json()[0]['prefix']}  gallery
    
    
JD-TC-Get Gallery or Logo Image-2
    [Documentation]  Get Gallery or Logo Image  valid provider for logo image
    # ${resp}=  pyproviderlogin  ${PUSERNAME15}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    # @{resp}=  uploadLogoImages
    # Log   ${resp[0]} 
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['keyName']}  mylogojpg
    Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo
        
JD-TC-Get Gallery or Logo Image-UH1 
    [Documentation]  Get Gallery or Logo Image  invalid input
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get GalleryOrlogo image  biju
    Should Be Equal As Strings    ${resp.status_code}   422
    
JD-TC-Get Gallery or Logo Image-UH2
    [Documentation]  Get Gallery or Logo Image without login 
    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  419            
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  
    
JD-TC-Get Gallery or Logo Image-UH3
    [Documentation]  Get Gallery or Logo Image without login   
    ${resp}=  ConsumerLogin  ${CUSERNAME1}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"  
            