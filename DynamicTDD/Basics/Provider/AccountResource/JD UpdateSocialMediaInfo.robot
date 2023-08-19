*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        SocialMedia
Library           Collections
Library           String
Library           json
Library         FakerLibrary
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Test Cases ***
JD-TC-UpdateSocialMediaInfo-1
    [Documentation]  Update social media info of a service provider
    ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fb}=  Create SocialMedia  facebook  https://facebook.com/netvarth
    ${tw}=  Create SocialMedia  twitter  https://twitter.com/netvarth
    ${yt}=  Create SocialMedia  youtube  https://youtube.com/netvarth     
    Set Suite Variable  ${fb}
    Set Suite Variable  ${tw}
    Set Suite Variable  ${yt} 
    ${resp}=  Update Social Media Info  ${fb}  ${tw}  ${yt}  
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get Business Profile
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['socialMedia']} 
	Should Be Equal As Integers  ${count}  3
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['resource']}  facebook  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['value']}  https://facebook.com/netvarth
    Should Be Equal As Strings  ${resp.json()['socialMedia'][1]['resource']}  twitter  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][1]['value']}   https://twitter.com/netvarth
    Should Be Equal As Strings  ${resp.json()['socialMedia'][2]['resource']}  youtube  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][2]['value']}  https://youtube.com/netvarth

JD-TC-UpdateSocialMediaInfo-2
    [Documentation]  Update social media info of a service provider by one field
    ${resp}=  ProviderLogin  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${fb}=  Create SocialMedia  facebook  https://facebook.com/Jaldee    
    ${resp}=  Update Social Media Info  ${fb}    
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get Business Profile
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['socialMedia']} 
	Should Be Equal As Integers  ${count}  1
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['resource']}  facebook  
    Should Be Equal As Strings  ${resp.json()['socialMedia'][0]['value']}  https://facebook.com/Jaldee    

JD-TC-UpdateSocialMediaInfo-UH1
    [Documentation]  Update social media info of a service provider by Consumer Login
    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Update Social Media Info  ${fb}  ${tw}  ${yt} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings   ${resp.json()}   ${LOGIN_NO_ACCESS_FOR_URL}
    

JD-TC-UpdateSocialMediaInfo-UH2
    [Documentation]   Update social media info of a service provider without login    
    ${resp}=  Update Social Media Info  ${fb}  ${tw}  ${yt} 
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings   ${resp.json()}    ${SESSION_EXPIRED}

