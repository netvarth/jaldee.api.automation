*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        PrivacySettings
Library           Collections
Library           String
Library           json
Library         /ebs/TDD/db.py
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
@{Views}  self  all  customersOnly
*** Test Cases ***

JD-TC-Get Privacy Setting-1
    [Documentation]   Get Privacy Setting of a valid provider
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ph1}=  Evaluate  ${PUSERNAME}+10000101
    ${ph2}=  Evaluate  ${PUSERNAME}+20000102
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${ph_nos}=  Create List  ${ph_nos1}  ${ph_nos2}
    ${emails1}=  Emails  ${name3}  Email  ${name3}${P_Email}.JDtest@netvarth.com  ${views}
    ${emails}=  Create List  ${emails1}
    ${resp}=  Update Privacy Setting  ${ph_nos}  ${emails}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Privacy Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][0]['resource']}  PhoneNo
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][0]['instance']}  ${ph1}
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][0]['permission']}  ${views}
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][0]['label']}  ${name1}
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][1]['resource']}  PhoneNo
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][1]['instance']}  ${ph2}
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][1]['permission']}  ${views}
    Should Be Equal As Strings   ${resp.json()['phoneNumbers'][1]['label']}  ${name2}
    
    Should Be Equal As Strings   ${resp.json()['emails'][0]['resource']}  Email
    Should Be Equal As Strings   ${resp.json()['emails'][0]['instance']}  ${name3}${P_Email}.JDtest@netvarth.com
    Should Be Equal As Strings   ${resp.json()['emails'][0]['permission']}  ${views}
    Should Be Equal As Strings   ${resp.json()['emails'][0]['label']}  ${name3}
    
JD-TC-Get Privacy Setting-2
    [Documentation]   Get business Privacy Setting of a valid provider, provider updated privacy settings with empty values
    ${resp}=  Encrypted Provider Login  ${PUSERNAME7}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${ph1}=  Create List
    ${email}=  Create List
    ${resp}=  Update Privacy Setting  ${ph1}  ${email}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Privacy Setting
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()['phoneNumbers']}  []
    Should Be Equal As Strings   ${resp.json()['emails']}  []
   
JD-TC-Get Privacy Setting-UH2
    [Documentation]   Get Privacy Setting without login
    ${resp}=  Get Privacy Setting
    Should Be Equal As Strings  ${resp.status_code}  419      
    Should Be Equal As Strings   "${resp.json()}"   "${SESSION_EXPIRED}"      

JD-TC-Get Privacy Setting-UH3
    [Documentation]   Consumer Get Privacy Setting  
    ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Get Privacy Setting
    Should Be Equal As Strings  ${resp.status_code}  401   
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 
    
    
    
    
    
    
