*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Subscription
Library           Collections
Library           String
Library           json
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***

JD-TC-Get Subscription -1
       [Documentation]   Provider check to get Subscription MONTHLY
       ${resp}=   ProviderLogin  ${PUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200       
       ${resp}=   Get Subscription
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  "${resp.json()}"  "MONTHLY"       
    
JD-TC-Get Subscription -2
       [Documentation]   Provider check to get subscription,an account  default subscription is MONTHLY
       ${resp}=   ProviderLogin  ${PUSERNAME3}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200       
       ${resp}=   Get Subscription
       Should Be Equal As Strings   ${resp.status_code}   200
       Should Be Equal As Strings  "${resp.json()}"  "MONTHLY"         
                    
JD-TC-Get Subscription -UH1
       [Documentation]   Provider check to get Subscription without login
       ${resp}=   Get Subscription
       Should Be Equal As Strings   ${resp.status_code}   419
       Should Be Equal As Strings   ${resp.json()}  ${SESSION_EXPIRED}
       
JD-TC-Get Subscription -UH2
       [Documentation]   Consumer check to get Subscription  packages
       ${resp}=   Consumer Login  ${CUSERNAME1}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  Get Subscription
       Should Be Equal As Strings   ${resp.status_code}   401
       Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"
