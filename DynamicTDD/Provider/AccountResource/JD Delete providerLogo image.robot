*** Settings ***
Library         Collections
Library         String
Library         json
Force Tags      LogoImageUplaod
Library		    OperatingSystem
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Library		    /ebs/TDD/Imageupload.py
Test Teardown   Remove File  cookies.txt
*** Test Cases ***

JD-TC-Delete Provider Logo Image-1
    Comment   Provider check to  Delete Logo Image
    # ${resp}=  pyproviderlogin  ${PUSERNAME20}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages 
    # Should Be Equal As Strings  ${resp[1]}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME20}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadLogoImages   ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME20}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    set Suite Variable   ${name}  ${resp.json()[0]['keyName']}
    # ${resp}=  DeleteProviderLogoImage  ${name}
    # Should Be Equal As Strings  ${resp[1]}  200
    ${resp}=  Imageupload.deleteProviderLogo  ${name}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get GalleryOrlogo image  logo
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Not Contain  ${resp.json()}  logo
         
JD-TC-Delete Provider Logo Image-UH1
    Comment   Consumer check to Delete Logo Image
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  DeleteProviderLogoImage  ${name}  
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL}
    ${resp}=  Imageupload.deleteProviderLogo  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Delete Provider Logo Image-UH2
    Comment   Delete Logo Image without login  
    # ${resp}=  DeleteProviderLogoImage  ${name}   
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
    ${empty_cookie}=  Create Dictionary
    ${resp}=  Imageupload.deleteProviderLogo  ${name}  ${empty_cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}  "${SESSION_EXPIRED}"
    

    
