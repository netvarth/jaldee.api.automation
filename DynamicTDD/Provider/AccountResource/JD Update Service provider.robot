*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ProviderDetails
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
*** Test Cases ***

JD-TC-Get provider Details-1
    [Documentation]   Service Provider of a valid provider
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    ${firstname}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
    ${gender}    Random Element    ${Genderlist}
    Set Suite Variable  ${gender}
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}   ${dob}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${PUSERNAME6}

JD-TC-Update Service Provider-2
    [Documentation]   Update provider details with email id
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}  ${firstname}${PUSERNAME6}.ynwtest@netvarth.com
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${PUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}  ${firstname}${PUSERNAME6}.ynwtest@netvarth.com

JD-TC-Update Service Provider-3
    [Documentation]   Update provider details with empty email id
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}  ${EMPTY}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${PUSERNAME6}

JD-TC-Update Service Provider-4
    [Documentation]   Update provider details with another email id
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}  ${lastname}${P_Email}.ynwtest@netvarth.com
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${PUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}  ${lastname}${P_Email}.ynwtest@netvarth.com

JD-TC-Update Service Provider-5
    [Documentation]   Update provider details when an email exists
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}  ${lastname}${P_Email}.ynwtest@netvarth.com
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Provider Details  ${id}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['basicInfo']['id']}  ${id}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['firstName']}  ${firstname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['lastName']}  ${lastname}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['dob']}  ${dob}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['gender']}  ${gender}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['mobile']}  ${PUSERNAME6}
    Should Be Equal As Strings  ${resp.json()['basicInfo']['email']}  ${lastname}${P_Email}.ynwtest@netvarth.com

JD-TC-Update Service Provider-UH1
    [Documentation]   Update provider details with already used provider email id
    ${resp}=  ProviderLogin  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${id}  ${resp.json()['id']}
    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}  ${lastname}${P_Email}.ynwtest@netvarth.com
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"

JD-TC-Update Service Provider-UH2
    [Documentation]   Update provider details with already used consumer email id
    ${resp}=   Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer By Id  ${CUSERNAME2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${c_email}  ${resp.json()['userProfile']['email']}
    ${resp}=  ProviderLogin  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider With Emailid  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}   ${c_email}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${EMAIL_EXISTS}"


JD-TC-Update Service Provider-UH3
    [Documentation]   Update Service Provider details of  another provider id
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"

JD-TC-Update Service Provider-UH4
    [Documentation]  consumer login to update service provider 
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}
    Should Be Equal As Strings  ${resp.status_code}  401  
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"
    
JD-TC-Update Service Provider-UH5
    [Documentation]   update business profile without login
    ${resp}=  Update Service Provider  ${id}  ${firstname}  ${lastname}  ${gender}  ${dob}
    Should Be Equal As Strings  ${resp.status_code}  419          
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"
    
JD-TC-Update Service Provider-UH6
    [Documentation]   Update invalid service provider details
    ${resp}=  ProviderLogin  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Update Service Provider  0  ${firstname}  ${lastname}  ${gender}  ${dob}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"
    
    
    
    
