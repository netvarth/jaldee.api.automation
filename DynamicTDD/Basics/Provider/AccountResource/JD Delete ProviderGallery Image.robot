*** Settings ***
Library         Collections
Library         String
Library         json
Force Tags      GalleryImageUplaod
Library		    OperatingSystem
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 
Library		    /ebs/TDD/Imageupload.py
Test Teardown   Remove File  cookies.txt
*** Test Cases ***

YNW-TC-Delete Provider Gallery Image-1
    Comment   Provider check to Delete Gallery Image
    # ${resp}=  pyproviderlogin  ${PUSERNAME10}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200  
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME10}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  uploadGalleryImages  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${itemId}   ${resp[0]}
    ${resp}=  ProviderLogin  ${PUSERNAME10}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    set Suite Variable   ${name}  ${resp.json()[0]['keyName']}   
    # ${resp}=  DeleteProviderGalleryImage  ${name}
    # Should Be Equal As Strings  ${resp[1]}  200

    # ${resp}=  Delete Gallery Image   ${name} 
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Imageupload.deleteGalleryImg  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Not Contain  ${resp.json()}  ${name}

YNW-TC-Delete Provider Gallery Image-UH1
    Comment   Consumer check to Delete Gallery Image
    # ${resp}=  Pyconsumerlogin  ${CUSERNAME1}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200
    ${cookie}  ${resp}=   Imageupload.conLogin  ${CUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  DeleteProviderGalleryImage  ${name} 
    # Should Be Equal As Strings  ${resp[1]}  401
    # Should Be Equal As Strings  ${resp[0]}   ${LOGIN_NO_ACCESS_FOR_URL}
    ${resp}=  Imageupload.deleteGalleryImg  ${name}  ${cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  ${resp.content}    "${LOGIN_NO_ACCESS_FOR_URL}"

YNW-TC-Delete Provider Gallery Image-UH2
    Comment   Delete Gallery Image without login  
    ${empty_cookie}=  Create Dictionary
    # ${resp}=  DeleteProviderGalleryImage  ${name}   
    # Should Be Equal As Strings  ${resp[1]}  419
    # Should Be Equal As Strings  ${resp[0]}   ${SESSION_EXPIRED}
    ${resp}=  Imageupload.deleteGalleryImg  ${name}  ${empty_cookie}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  ${resp.content}    "${SESSION_EXPIRED}"
    
